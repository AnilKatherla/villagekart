import 'package:villag_kart/features/cart/model/cart_item_model.dart';
import 'package:villag_kart/features/cart/model/api_cart_model.dart';

/// ---------------------------------------------------------------------------
/// BASE CART STATE
/// ---------------------------------------------------------------------------
abstract class CartState {
  /// cart items from API
  final List<CartItemModel> cartItems;

  /// key → quantity
  /// key can be productId OR productVariantId
  final Map<String, int> quantities;
  final ApiCartSummary? summary;

  CartState({
    required this.cartItems,
    required this.quantities,
     this.summary, 
  });

  // -----------------------------
  // Quantity by key
  // -----------------------------
  int getCount(String key) {
    return quantities[key] ?? 0;
  }

  // -----------------------------
  // Total Price (variant aware)
  // -----------------------------
  double get totalPrice {
  double total = 0.0;

  for (final item in cartItems) {
    total += item.totalPrice;
  }

  return total;
}


  // -----------------------------
  // Total Item Count
  // -----------------------------
  int get totalItems {
    return quantities.values.fold(0, (a, b) => a + b);
  }

  // -----------------------------
  // Out of Stock Check
  // -----------------------------
  bool get hasOutOfStock {
    for (final item in cartItems) {
      if (item.quantity > 0 && item.isOutOfStock) {
        return true;
      }
    }
    return false;
  }

  // -----------------------------
  // Total Savings
  // -----------------------------
  double get totalSaved {
  return cartItems.fold(0.0, (sum, item) => sum + item.savings);
}


  // -----------------------------
  // Copy with
  // -----------------------------
  CartState copyWith({
    List<CartItemModel>? cartItems,
    Map<String, int>? quantities,
    ApiCartSummary? summary,
  }) {
    return CartLoadedState(
      cartItems: cartItems ?? this.cartItems,
      quantities: quantities ?? this.quantities,
      summary: summary ?? this.summary,
    );
  }
}

/// ---------------------------------------------------------------------------
/// ALL CART STATES
/// ---------------------------------------------------------------------------

class CartInitial extends CartState {
  CartInitial() : super(cartItems: [], quantities: {});
}

class CartLoading extends CartState {
  CartLoading() : super(cartItems: [], quantities: {});
}

class CartEmpty extends CartState {
  CartEmpty() : super(cartItems: [], quantities: {});
}

class CartLoadedState extends CartState {
  CartLoadedState({required super.cartItems, required super.quantities,super.summary, });
}

class CartUpdating extends CartState {
  CartUpdating({required super.cartItems, required super.quantities,super.summary, });
}

class CartError extends CartState {
  CartError(this.message) : super(cartItems: [], quantities: {});
  final String message;
}

class CartSyncing extends CartState {
  CartSyncing({required super.cartItems, required super.quantities});
}

class CartCouponApplied extends CartState {
  CartCouponApplied({
    required super.cartItems,
    required super.quantities,
    required this.discount,
  });
  final double discount;
}

class CartCheckoutInProgress extends CartState {
  CartCheckoutInProgress({required super.cartItems, required super.quantities});
}
