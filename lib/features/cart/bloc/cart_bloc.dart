import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/core/utils/global_snackbar.dart';
import 'package:villag_kart/features/cart/model/api_cart_model.dart';
import 'package:villag_kart/features/cart/model/cart_item_model.dart';
import 'package:villag_kart/features/cart/services/cart_api_service.dart';
import 'package:villag_kart/features/profile/model/repeat_order_model.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<FetchCartItemsEvent>(_handleFetchCartItems);
    on<CartIncrement>(_onIncrement);
    on<CartDecrement>(_onDecrement);
    on<CartItemRemove>(_onCartItemRemove);
    on<ClearCartEvent>(_onClearCart);
    on<ReorderItemsEvent>(_onReorderItems);
    on<SwitchWarehouseEvent>(_onSwitchWarehouse);
  }

  final CartApiService _apiService = CartApiService();

  // ---------------------------------------------------------------------------
  // LOAD CART
  // ---------------------------------------------------------------------------
  Future<void> _handleFetchCartItems(
    FetchCartItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    if (state is CartLoading) {
      return;
    }

    emit(CartLoading());

    try {
      final apiCart = await _apiService.getCart(event.warehouseId);
      await _applyApiCart(apiCart, emit);
    } catch (e) {
      // emit(CartError(e.toString()));
      // showSnakckbar('Error', e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // INCREMENT
  // ---------------------------------------------------------------------------
  Future<void> _onIncrement(
    CartIncrement event,
    Emitter<CartState> emit,
  ) async {
    try {
      final id = event.id;
      final isVariant = event.isVariant;
      final productId = event.productId;

      final currentQty = state.quantities[id] ?? 0;
      final newQty = currentQty == 0 ? (event.quantity ?? 1) : currentQty + 1;

      if (newQty > (event.maxQty ?? 99)) {
        GlobalSnackbar.show(
          'Maximum Quantity',
          'You can only order up to ${event.maxQty} units of this item.',
          isError: true,
        );
        return;
      }

      ApiCart apiCart;

      if (currentQty == 0) {
        apiCart = await _apiService.addToCart(
          id,
          newQty,
          isVariant: isVariant,
          productId: productId,
        );
      } else {
        // 🔍 Find the item in cartItems with prioritized search
        CartItemModel? cartItem;
        if (isVariant) {
          cartItem = state.cartItems.cast<CartItemModel?>().firstWhere(
            (item) => item?.productVariantId == id,
            orElse: () => null,
          );
        } else {
          cartItem = state.cartItems.cast<CartItemModel?>().firstWhere(
            (item) => item?.product?.id == id,
            orElse: () => null,
          );
        }

        // Final fallback: try matching either field if still not found
        cartItem ??= state.cartItems.cast<CartItemModel?>().firstWhere(
          (item) =>
              item?.productVariantId == id || item?.productVariantId == null,
          orElse: () => null,
        );

        if (cartItem == null) {
          // If for some reason the item is not in cartItems but quantity > 0,
          // we treat it as adding for the first time or skip.
          apiCart = await _apiService.addToCart(
            id,
            newQty,
            isVariant: isVariant,
            productId: productId,
          );
        } else {
          apiCart = await _apiService.updateCartItem(cartItem.id, newQty);
        }
      }

      await _applyApiCart(apiCart, emit);
    } catch (e) {
      // emit(CartError(e.toString()));
      showSnakckbar('Error', e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // DECREMENT
  // ---------------------------------------------------------------------------
  Future<void> _onDecrement(
    CartDecrement event,
    Emitter<CartState> emit,
  ) async {
    try {
      final id = event.id;
      final isVariant = event.isVariant;
      final minQty = event.minQty ?? 1;

      final currentQty = state.quantities[id] ?? 0;
      if (currentQty == 0) {
        return;
      }

      // 🔍 Find the item in cartItems.
      // We prioritize matching the productVariantId if it's a variant,
      // but fall back to productId search for robustness.
      CartItemModel? cartItem;
      if (isVariant) {
        cartItem = state.cartItems.cast<CartItemModel?>().firstWhere(
          (item) => item?.productVariantId == id,
          orElse: () => null,
        );
      } else {
        cartItem = state.cartItems.cast<CartItemModel?>().firstWhere(
          (item) => item?.product?.id == id,
          orElse: () => null,
        );
      }

      // Final fallback: try matching either field if still not found
      cartItem ??= state.cartItems.cast<CartItemModel?>().firstWhere(
        (item) =>
            item?.productVariantId == id || item?.productVariantId == null,
        orElse: () => null,
      );

      if (cartItem == null) {
        showSnakckbar('Error', 'Cart item not found');
        return;
      }

      ApiCart apiCart;

      // 🗑️ REMOVE if at or below minimum quantity
      if (currentQty <= minQty) {
        apiCart = await _apiService.removeFromCart(cartItem.id);
        if (minQty > 1) {
          GlobalSnackbar.show(
            'Minimum Quantity',
            'Minimum quantity is $minQty',
            isError: true,
            position: SnackPosition.top,
          );
        }
      } else {
        // ➖ NORMAL DECREMENT
        apiCart = await _apiService.updateCartItem(cartItem.id, currentQty - 1);
      }

      await _applyApiCart(apiCart, emit);
    } catch (e) {
      showSnakckbar('Error', e.toString());
    }
  }

  Future<void> _onCartItemRemove(
    CartItemRemove event,
    Emitter<CartState> emit,
  ) async {
    try {
      final apiCart = await _apiService.removeFromCart(event.cartItemId);
      await _applyApiCart(apiCart, emit);
    } catch (e) {
      showSnakckbar('Error', e.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // APPLY SERVER CART → STATE
  // ---------------------------------------------------------------------------
  Future<void> _applyApiCart(ApiCart apiCart, Emitter<CartState> emit) async {
    final cartItems = apiCart.items;
    final quantities = <String, int>{};

    for (final item in cartItems) {
      /// VARIANT ITEM
      if (item.productVariantId != null && item.productVariantId!.isNotEmpty) {
        quantities[item.productVariantId!] = item.quantity ?? 0;
      }
      /// PRODUCT ITEM
      else if (item.product != null) {
        quantities[item.product!.id] = item.quantity ?? 0;
      }
    }

    if (cartItems.isEmpty) {
      emit(CartEmpty());
    } else {
      emit(
        CartLoadedState(
          cartItems: cartItems,
          quantities: quantities,
          summary: apiCart.summary,
        ),
      );
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      await _apiService.clearCart();
      final warehouseId = await SharedPrefs.getWarehouseId();
      final apiCart = await _apiService.getCart(warehouseId); // refresh
      await _applyApiCart(apiCart, emit);
    } catch (e) {
      GlobalSnackbar.show('Error', e.toString());
    }
  }

  void showSnakckbar(String title, String message) {
    GlobalSnackbar.show(title, message, isError: true);
  }

  Future<void> _onReorderItems(
    ReorderItemsEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());

    try {
      final RepeatOrderModel result = await _apiService.reorderOrder(
        event.orderId,
      );
      final warehouseId = await SharedPrefs.getWarehouseId();
      final apiCart = await _apiService.getCart(warehouseId);

      await _applyApiCart(apiCart, emit);

      final skippedItems = result.data.skippedItems.length;

      if (skippedItems > 0) {
        GlobalSnackbar.show(
          'Out of Stock',
          '$skippedItems item(s) were out of stock',
        );
      }
    } catch (e) {
      emit(CartError(e.toString()));
      GlobalSnackbar.show('Error', e.toString());
    }
  }

  Future<void> _onSwitchWarehouse(
    SwitchWarehouseEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final oldWarehouse = await SharedPrefs.getWarehouse();

      if (oldWarehouse?.id == event.warehouse?.id) {
        return;
      }

      await SharedPrefs.saveWarehouse(event.warehouse!);

      emit(CartEmpty());
      final warehouseId = await SharedPrefs.getWarehouseId();

      final apiCart = await _apiService.getCart(warehouseId);

      await _applyApiCart(apiCart, emit);
    } catch (e) {
      emit(CartError(e.toString()));
      GlobalSnackbar.show('Error', e.toString());
    }
  }
}
