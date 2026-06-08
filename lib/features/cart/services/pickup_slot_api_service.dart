import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import '../model/pickup_slot_model.dart';

class PickupSlotApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

  Future<PickupSlotResponse> getPickupSlots({
    required String warehouseId,
    
  }) async {
    try {
      final response = await _networkService.get(
        Endpoints.getPickupSlots(
          warehouseId: warehouseId,
         
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load pickup slots');
      }

      if (response.data['status'] != true) {
        throw Exception(response.data['response']);
      }

      if (response.data['data'] == null) {
        throw Exception('No pickup slot data');
      }

      return PickupSlotResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['response'] ?? e.message);
    }
  }
}
