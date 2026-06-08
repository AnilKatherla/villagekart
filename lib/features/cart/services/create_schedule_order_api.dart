import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/cart/model/create_order_schedule_model.dart';

class CreateScheduledOrderApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  Future<CreateScheduledOrderResponse> createScheduledOrder({
    required CreateScheduledOrderRequest request,
  }) async {
    try {
      final response = await _networkService.post(
        Endpoints.createOrder,
        data: request.toJson(),
      );

      // HTTP validation
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create scheduled order');
      }

      final data = response.data;

      // API validation
      if (data['status'] != true) {
        throw Exception(data['response'] ?? 'Order failed');
      }

      return CreateScheduledOrderResponse.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['response'] ?? e.message;
      throw Exception(message);
    }
  }
}
