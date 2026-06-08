// features/profile/bloc/order_state.dart



import 'package:villag_kart/features/profile/model/invoice_model.dart';
import 'package:villag_kart/features/profile/model/order_history_model.dart';
import 'package:villag_kart/features/profile/model/order_response_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus;

  OrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus,
  });
}

class OrderRefreshing extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus;

  OrderRefreshing({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus,
  });
}

class OrderLoadingMore extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus;

  OrderLoadingMore({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus,
  });
}

class OrderEmpty extends OrderState {
  final String message;

  OrderEmpty({required this.message});
}

class OrderError extends OrderState {
  final String errorMessage;

  OrderError({required this.errorMessage});
}

// Order Details States
class OrderDetailsLoading extends OrderState {}

class OrderDetailsLoaded extends OrderState {
  final OrderDetailsResponse orderDetails;

  OrderDetailsLoaded({required this.orderDetails});
}

class OrderDetailsError extends OrderState {
  final String errorMessage;

  OrderDetailsError({required this.errorMessage});
}

// Invoice States
class InvoiceLoading extends OrderState {
  final String orderId;

  InvoiceLoading({required this.orderId});
}

class InvoiceLoaded extends OrderState {
  final InvoiceData invoiceData;

  InvoiceLoaded({required this.invoiceData});
}

class InvoiceError extends OrderState {
  final String errorMessage;

  InvoiceError({required this.errorMessage});
}

class InvoiceDownloading extends OrderState {
  final String orderId;

  InvoiceDownloading({required this.orderId});
}

class InvoiceDownloaded extends OrderState {
  final String filePath;
  final String orderId;

  InvoiceDownloaded({required this.filePath, required this.orderId});
}

// Order Tracking States
class OrderTrackingLoading extends OrderState {}

class OrderTrackingLoaded extends OrderState {
  final TrackingData trackingData;

  OrderTrackingLoaded({required this.trackingData});
}

class OrderTrackingError extends OrderState {
  final String errorMessage;

  OrderTrackingError({required this.errorMessage});
}

// Live Tracking States
class LiveTrackingLoading extends OrderState {}

class LiveTrackingLoaded extends OrderState {
  final LiveTrackingData trackingData;

  LiveTrackingLoaded({required this.trackingData});
}

class LiveTrackingError extends OrderState {
  final String errorMessage;

  LiveTrackingError({required this.errorMessage});
}

// Cancel Order States
class OrderCancelling extends OrderState {
  final String orderId;
  final List<Order> addresses;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus;

  OrderCancelling({
    required this.orderId,
    required this.addresses,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus,
  });
}

class OrderCancelled extends OrderState {
  final String orderId;
  final String message;

  OrderCancelled({required this.orderId, required this.message});
}

// Cancel Order Item States
class OrderItemCancelling extends OrderState {
  final String orderId;
  final String itemId;

  OrderItemCancelling({required this.orderId, required this.itemId});
}

class OrderItemCancelled extends OrderState {
  final String orderId;
  final String itemId;
  final String message;

  OrderItemCancelled({
    required this.orderId,
    required this.itemId,
    required this.message,
  });
}