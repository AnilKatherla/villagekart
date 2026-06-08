// ============================================================================
// UPDATED ORDER DETAILS SERVICE (order_details_service.dart)
// Matches the actual API response structure
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../../model/order_history_model.dart';


class OrderDetailsService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static Future<OrderDetailsResponse> fetchOrderDetails({
    required String orderId,
  }) async {
    try {
      debugPrint('📋 Fetching order details:');
      debugPrint('  Order ID: $orderId');

      final String orderDetailsEndpoint =
          'orders/$orderId';

      final Response response = await _networkService.get(orderDetailsEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Parse the response
        final Map<String, dynamic> responseData = response.data;

        // Parse complete response model
        final OrderDetailsResponse orderResponse =
            OrderDetailsResponse.fromJson(
              responseData,
            );

        debugPrint('✅ Order details fetched successfully');
        debugPrint(
          'Order Number: ${orderResponse.data.order.orderNumber}',
        );
        debugPrint(
          'Status: ${orderResponse.data.order.status}',
        );
        debugPrint(
          'Delivery Boy: ${orderResponse.data.order.delivery.name}',
        );
        debugPrint(
          'Phone: ${orderResponse.data.order.delivery.phone}',
        );

        return orderResponse;
      }

        throw Exception(  'Failed to fetch order details');
    }

    on DioException catch (e) {
      debugPrint(
        '❌ Order details fetch error: ${e.message}',
      );

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
      debugPrint('❌ Error fetching order details: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}