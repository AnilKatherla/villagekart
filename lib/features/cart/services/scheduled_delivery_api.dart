import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/cart/model/scheduled_delivery_model.dart';



class DeliverySlotApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  Future<DeliverySlotResponseModel> getDeliverySlots({
    required String warehouseId,
    required String deliveryDate,
  }) async {
    try {
      final response = await _networkService.get(
        Endpoints.getDeliverySlots(
          warehouseId: warehouseId,
          deliveryDate: deliveryDate,
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load delivery slots');
      }

      if (response.data['status'] != true) {
        throw Exception(response.data['response']);
      }

      if (response.data['data'] == null) {
        throw Exception('No delivery slot data');
      }

      return DeliverySlotResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['response'] ?? e.message);
    }
  }
}
