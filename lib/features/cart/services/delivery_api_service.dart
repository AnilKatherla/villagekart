import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/cart/model/delivery_type_model.dart';
import 'package:villag_kart/features/cart/model/order_create_response.dart';

class DeliveryApiService {
  final NetworkService _networkService = ServiceLocator.networkService;

 Future<DeliveryTypesResponse> getDeliveryTypes({
  required String warehouseId,
}) async {
  try {
    final response = await _networkService.get(
      Endpoints.getDeliveryTypes(warehouseId),
    
    );
    debugPrint('${warehouseId}');

    if (response.statusCode != 200) {
      throw Exception('Failed to load delivery types');
    }

    if (response.data['status'] != true) {
      throw Exception(response.data['response']);
    }

    if (response.data['data'] == null) {
      throw Exception('No delivery data');
    }

    return DeliveryTypesResponse.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception(e.response?.data['response'] ?? e.message);
  }
}
Future<OrderCreateResponse> createOrder({
  required String warehouseId,
  required String orderStatus,
  required String addressId,
  required String deliveryType,
  String? specialInstructions,
  String? deliveryDate,
  String? deliverySlot,
  String? routeMapId,
  String? couponCode,
  String? pickupSlotId,
}) async {
  try {
    final body = <String, dynamic>{
      "addressId": addressId,
      "deliveryType": deliveryType,
      "specialInstructions": specialInstructions ?? "",
      "warehouseId": warehouseId,
      "orderStatus": orderStatus,
    };
    if (deliveryDate != null && deliveryDate.isNotEmpty) {
      body["deliveryDate"] = deliveryDate;
    }
    if (deliverySlot != null && deliverySlot.isNotEmpty) {
      body["deliverySlot"] = deliverySlot;
    }
    if (routeMapId != null && routeMapId.isNotEmpty) {
      body["routeMapId"] = routeMapId;
    }
    if (couponCode != null && couponCode.isNotEmpty) {
      body["couponCode"] = couponCode;
    }
    if (pickupSlotId != null && pickupSlotId.isNotEmpty) {
      body["pickupSlotId"] = pickupSlotId;
    }

    final response = await _networkService.post(
      Endpoints.createOrder,
      data: body,
    );

    return OrderCreateResponse.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception(e.response?.data['response'] ?? e.message);
  }
}

}