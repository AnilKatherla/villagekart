import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/cart/model/api_cart_model.dart';
import 'package:villag_kart/features/profile/model/repeat_order_model.dart';

class CartApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  // ---------------------------------------------------------------------------
  // GET CART
  // ---------------------------------------------------------------------------
  Future<ApiCart> getCart(String? warehouseId) async {
    final response = await _networkService.get(
      Endpoints.getCart(warehouseId: warehouseId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load cart');
    }

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }

    if (response.data['data'] == null) {
      //Shown a error snackbar
      throw Exception('Something went wrong');
    }

    return ApiCart.fromJson(response.data['data']);
  }

  // ---------------------------------------------------------------------------
  // ADD TO CART (PRODUCT OR VARIANT)
  // ---------------------------------------------------------------------------
  Future<ApiCart> addToCart(
    String id,
    int quantity, {
    bool isVariant = false,
    String? productId,
  }) async {
    final Map<String, dynamic> body = {'quantity': quantity};

    if (isVariant) {
      body['productVariantId'] = id;
      body['productId'] = productId; // ✅ FIX
    } else {
      body['productId'] = id;
    }

    final response = await _networkService.post(
      Endpoints.addToCartItem,
      data: body,
    );

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }

    return ApiCart.fromJson(response.data['data']['cart']);
  }

  // ---------------------------------------------------------------------------
  // UPDATE CART ITEM
  // ---------------------------------------------------------------------------
  Future<ApiCart> updateCartItem(String cartItemId, int quantity) async {
    final response = await _networkService.patch(
      Endpoints.updateCartItem(cartItemId),
      data: {'quantity': quantity},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart');
    }

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }

    if (response.data['data']['cart'] == null) {
      throw Exception('Something went wrong');
    }

    return ApiCart.fromJson(response.data['data']['cart']);
  }

  // ---------------------------------------------------------------------------
  // REMOVE FROM CART
  // ---------------------------------------------------------------------------
  Future<ApiCart> removeFromCart(String cartItemId) async {
    final response = await _networkService.delete(
      Endpoints.removeCartItem(cartItemId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove cart item');
    }

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }

    if (response.data['data']['cart'] == null) {
      throw Exception('Something went wrong');
    }

    return ApiCart.fromJson(response.data['data']['cart']);
  }

  // ---------------------------------------------------------------------------
  // CLEAR CART
  // ---------------------------------------------------------------------------
  Future<void> clearCart() async {
    final warehouseId = await SharedPrefs.getWarehouseId();
    final response = await _networkService.delete(
      Endpoints.clearCart(warehouseId: warehouseId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }
  }

  Future<RepeatOrderModel> reorderOrder(String orderId) async {
    final response = await _networkService.post(Endpoints.reorder(orderId));
    if (response.statusCode != 200) {
      throw Exception('Failed to reorder items');
    }
    if (response.data == null) {
      throw Exception('Empty response from server');
    }
    if (response.data['status'] != true) {
      throw Exception(response.data['response'] ?? 'Reorder failed');
    }
    //final skipped = response.data['data']['skippeditems'] ?? [];

    return RepeatOrderModel.fromJson(response.data);
  }
}
