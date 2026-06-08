// ============================================================================
// 2. ORDER TRACKING SERVICE (order_tracking_service.dart)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import '../model/map_route_model.dart';

import 'map_route_bloc.dart' show OrderTrackingResponse;

class OrderTrackingService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch order tracking information
  static Future<OrderTrackingResponse> fetchOrderTracking({
    required String orderId,
  }) async {
    try {
      debugPrint('📍 Fetching order tracking:');
      debugPrint('  Order ID: $orderId');

      final String trackingEndpoint =
          'orders/$orderId/tracking';

      final Response response = await _networkService.get(trackingEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final trackingResponse = OrderTrackingResponse.fromJson(response.data);

        debugPrint('✅ Order tracking fetched successfully:');
        debugPrint('  Order Number: ${trackingResponse.data.orderNumber}');
        debugPrint('  Current Status: ${trackingResponse.data.currentStatus}');
        debugPrint('  Timeline Events: ${trackingResponse.data.timeline.length}');

        return trackingResponse;
      } else {
        throw Exception(response.data['response'] ??
            'Failed to fetch order tracking');
      }
    } on DioException catch (e) {
      debugPrint('❌ Order tracking fetch error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid order ID');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching order tracking: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}