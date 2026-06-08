// ============================================================================
// 4. ORDER SERVICE (order_service.dart)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../model/order_history_model.dart';




// ============================================================================
// UPDATED ORDER SERVICE (order_service.dart)
// Matches the new API response structure without status filter
// ============================================================================


class OrderService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch all orders with pagination
  /// Status parameter is optional - if not provided, gets all orders
  static Future<OrdersResponse> fetchOrders({
    required int page,
    required int limit,
    String? status,
  }) async {
    try {
      debugPrint('📦 Fetching orders:');
      debugPrint('  Page: $page');
      debugPrint('  Limit: $limit');
      if (status != null) debugPrint('  Status: $status');

      // Build URL - status is optional
      String ordersEndpoint =
          'orders?page=$page&limit=$limit';

      if (status != null && status.isNotEmpty) {
        ordersEndpoint += '&status=$status';
      }

      final Response response = await _networkService.get(ordersEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final ordersResponse = OrdersResponse.fromJson(response.data);

        debugPrint('✅ Orders fetched successfully:');
        debugPrint('  Total orders: ${ordersResponse.data.pagination.total}');
        debugPrint('  Current page: ${ordersResponse.data.pagination.page}');
        debugPrint('  Total pages: ${ordersResponse.data.pagination.totalPages}');
        debugPrint('  Orders in this page: ${ordersResponse.data.orders.length}');

        return ordersResponse;
      } else {
        throw Exception(
            response.data['response'] ?? 'Failed to fetch orders');
      }
    } on DioException catch (e) {
      debugPrint('❌ Orders fetch error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (e.response?.statusCode == 404) {
        // Return empty response instead of throwing error
        return OrdersResponse(
          status: true,
          response: 'No orders found',
          data: OrdersData(
            orders: [],
            pagination: PaginationData(
              page: page,
              limit: limit,
              total: 0,
              totalPages: 0,
              hasNext: false,
              hasPrev: false,
            ),
          ),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching orders: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Fetch specific order details
  static Future<Order> fetchOrderDetails({
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
        // Parse the order from response
        final Map<String, dynamic> responseData = response.data;
        
        Order order;
        if (responseData['data'] != null) {
          // If response has data wrapper
          order = Order.fromJson(responseData['data']);
        } else {
          // If response is direct order object
          order = Order.fromJson(responseData);
        }

        debugPrint('✅ Order details fetched successfully:');
        debugPrint('  Order Number: ${order.orderNumber}');
        debugPrint('  Status: ${order.status}');
        debugPrint('  Total Items: ${order.items.length}');
        debugPrint('  Total Amount: ${order.totalAmount}');

        return order;
      } else {
        throw Exception(
            response.data['response'] ?? 'Failed to fetch order details');
      }
    } on DioException catch (e) {
      debugPrint('❌ Order details fetch error: ${e.message}');

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