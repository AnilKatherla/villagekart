import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/cart/model/create_order_pickup_model.dart';


class CreateOrderPickupApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  Future<CreateOrderResponse> createOrder({
    required CreateOrderRequest request,
  }) async {
    try {
      final response = await _networkService.post(
        Endpoints.createOrder,
        data: request.toJson(),
      );

      // HTTP layer validation
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create order');
      }

      final data = response.data;

      // API-level validation
      if (data['status'] != true) {
        throw Exception(data['response'] ?? 'Order failed');
      }

      if (data['data'] == null || data['data']['order'] == null) {
        throw Exception('No order data received');
      }

      return CreateOrderResponse.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['response'] ?? e.message;
      throw Exception(message);
    }
  }
}
