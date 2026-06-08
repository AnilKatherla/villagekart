// order_status_event.dart
abstract class OrderStatusEvent {}

class LoadOrderStatusesEvent extends OrderStatusEvent {}

class UpdateOrderStatusEvent extends OrderStatusEvent {
  UpdateOrderStatusEvent({
    required this.orderId,
    required this.statusId,
  });
  final String orderId;
  final int statusId;
}

class CancelOrderEvent extends OrderStatusEvent {
  CancelOrderEvent({
    required this.orderId,
    required this.reason,
  });
  final String orderId;
  final String reason;
}