import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/model/order_response_model.dart';

class OrderService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch orders with optional status filter
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

      ServiceLocator.networkService;

      // Build URL with optional status parameter
      String ordersEndpoint = 'orders?page=$page&limit=$limit';

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
        throw Exception(response.data['response'] ?? 'Failed to fetch orders');
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
        final orderDetails = OrderDetailsResponse.fromJson(response.data);

        debugPrint('✅ Order details fetched successfully:');
        debugPrint('  Order Number: ${orderDetails.data.order.orderNumber}');
        debugPrint('  Status: ${orderDetails.data.order.status}');

        return orderDetails;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch order details',
        );
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

        debugPrint('✅ Tracking info fetched successfully:');
        debugPrint('  Current Status: ${trackingResponse.data.currentStatus}');
        debugPrint('  Timeline events: ${trackingResponse.data.timeline.length}');

        return trackingResponse;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch tracking info',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Tracking fetch error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid order ID');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching tracking: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Fetch live tracking information
  static Future<LiveTrackingResponse> fetchLiveTracking({
    required String orderId,
  }) async {
    try {
      debugPrint('📍 Fetching live tracking:');
      debugPrint('  Order ID: $orderId');

      final String liveTrackingEndpoint =
          'orders/$orderId/tracking/live';

      final Response response = await _networkService.get(liveTrackingEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final liveTracking = LiveTrackingResponse.fromJson(response.data);

        debugPrint('✅ Live tracking info fetched successfully:');
        debugPrint('  Delivery Status: ${liveTracking.data.deliveryStatus}');
        debugPrint('  ETA: ${liveTracking.data.eta}');

        return liveTracking;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch live tracking',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Live tracking fetch error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid order ID');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching live tracking: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Cancel entire order
  static Future<CancelOrderResponse> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    try {
      debugPrint('❌ Cancelling order:');
      debugPrint('  Order ID: $orderId');
      debugPrint('  Reason: $reason');

      final String cancelEndpoint =
          'orders/$orderId/cancel';

      final Response response = await _networkService.post(
        cancelEndpoint,
        data: {'reason': reason},
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final cancelResponse = CancelOrderResponse.fromJson(response.data);

        debugPrint('✅ Order cancelled successfully');
        return cancelResponse;
      } else {
        throw Exception(response.data['response'] ?? 'Failed to cancel order');
      }
    } on DioException catch (e) {
      debugPrint('❌ Order cancel error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Cannot cancel order in current status');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Order already cancelled');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error cancelling order: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Cancel specific order item
  static Future<CancelItemResponse> cancelOrderItem({
    required String orderId,
    required String itemId,
    required String reason,
  }) async {
    try {
      debugPrint('❌ Cancelling order item:');
      debugPrint('  Order ID: $orderId');
      debugPrint('  Item ID: $itemId');
      debugPrint('  Reason: $reason');

      final String cancelItemEndpoint =
          'orders/$orderId/items/$itemId/cancel';

      final Response response = await _networkService.post(
        cancelItemEndpoint,
        data: {'reason': reason},
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final cancelResponse = CancelItemResponse.fromJson(response.data);

        debugPrint('✅ Order item cancelled successfully');
        return cancelResponse;
      } else {
        throw Exception(response.data['response'] ?? 'Failed to cancel item');
      }
    } on DioException catch (e) {
      debugPrint('❌ Item cancel error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Item not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Cannot cancel item in current status');
      } else if (e.response?.statusCode == 409) {
        throw Exception('Item already cancelled');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error cancelling item: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Fetch invoice
  static Future<InvoiceResponse> fetchInvoice({required String orderId}) async {
    try {
      debugPrint('📄 Fetching invoice:');
      debugPrint('  Order ID: $orderId');

      final String invoiceEndpoint =
          'orders/$orderId/invoice';

      final Response response = await _networkService.get(invoiceEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final invoiceResponse = InvoiceResponse.fromJson(response.data);

        debugPrint('✅ Invoice fetched successfully');
        debugPrint(
          '  Invoice Number: ${invoiceResponse.data.invoice.invoiceNumber}',
        );

        return invoiceResponse;
      } else {
        throw Exception(response.data['response'] ?? 'Failed to fetch invoice');
      }
    } on DioException catch (e) {
      debugPrint('❌ Invoice fetch error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Order not found');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid order ID');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching invoice: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }

  // /// Download invoice (returns file path)
  // static Future<String> downloadInvoice({
  //   required String orderId,
  // }) async {
  //   try {
  //     debugPrint('💾 Downloading invoice:');
  //     debugPrint('  Order ID: $orderId');

  //     final String invoiceEndpoint =
  //         'orders/$orderId/invoice/download';

  //     final Response response = await _networkService.downloadFile(
  //       invoiceEndpoint,
  //       'invoice_$orderId.pdf',
  //     );

  //     if (response.statusCode == null) {
  //       throw Exception('Somethng went wrong. Please try again later');
  //     }

  //     if (response.statusCode! >= 200 && response.statusCode! < 300) {
  //       debugPrint('✅ Invoice downloaded successfully');
  //       return response.data['filePath'] ?? 'invoice_$orderId.pdf';
  //     } else {
  //       throw Exception(
  //           response.data['response'] ?? 'Failed to download invoice');
  //     }
  //   } on DioException catch (e) {
  //     debugPrint('❌ Invoice download error: ${e.message}');
  //     throw Exception('Failed to download invoice: ${e.message}');
  //   } catch (e) {
  //     debugPrint('❌ Error downloading invoice: $e');
  //     throw Exception('Something went wrong. Please try again.');
  //   }
  // }

  // Add to OrderService class
  static Future<String> fetchInvoiceHtml({required String orderId}) async {
    try {
      debugPrint('📄 Fetching invoice HTML:');
      debugPrint('  Order ID: $orderId');

      final String invoiceEndpoint =
          'orders/$orderId/invoice/html';

      final Response response = await _networkService.get(invoiceEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final htmlContent = response.data['html'] ?? '';
        debugPrint('✅ Invoice HTML fetched successfully');
        return htmlContent;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch invoice HTML',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Invoice HTML fetch error: ${e.message}');
      throw Exception('Failed to fetch invoice HTML');
    } catch (e) {
      debugPrint('❌ Error fetching invoice HTML: $e');
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
