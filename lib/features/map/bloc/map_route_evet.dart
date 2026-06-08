// ============================================================================
// ORDER TRACKING EVENTS (order_tracking_events.dart)
// ============================================================================

abstract class OrderTrackingEvent {}

class FetchOrderTracking extends OrderTrackingEvent {
  final String orderId;

  FetchOrderTracking({required this.orderId});
}

class RefreshOrderTracking extends OrderTrackingEvent {
  final String orderId;

  RefreshOrderTracking({required this.orderId});
}

