// ============================================================================
// UPDATED ORDER EVENTS (order_events.dart)
// Status parameter is now optional
// ============================================================================

abstract class OrderEvent {}

class FetchOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status; // Now optional

  FetchOrders({
    required this.page,
    required this.limit,
    this.status, // No longer required
  });
}

class RefreshOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status; // Now optional

  RefreshOrders({
    required this.page,
    required this.limit,
    this.status, // No longer required
  });
}

class ChangeOrderTab extends OrderEvent {
  final String? status; // Now optional - null means all orders

  ChangeOrderTab({this.status});
}

class LoadMoreOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status; // Now optional

  LoadMoreOrders({
    required this.page,
    required this.limit,
    this.status, // No longer required
  });
}