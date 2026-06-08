// order_status_state.dart
import 'package:villag_kart/features/profile/model/order_status_model.dart';

abstract class OrderStatusState {}

class OrderStatusInitialState extends OrderStatusState {}

class OrderStatusLoadingState extends OrderStatusState {}

class OrderStatusesLoadedState extends OrderStatusState {
  OrderStatusesLoadedState({
    required this.statuses,
  });
  final List<OrderStatus> statuses;
}

class OrderStatusUpdatedState extends OrderStatusState {
  OrderStatusUpdatedState({
    required this.orderId,
    required this.newStatusId,
    required this.message,
  });
  final String orderId;
  final int newStatusId;
  final String message;
}

class OrderCancelledState extends OrderStatusState {
  OrderCancelledState({
    required this.orderId,
    required this.message,
  });
  final String orderId;
  final String message;
}

class OrderStatusErrorState extends OrderStatusState {
  OrderStatusErrorState({required this.error});
  final String error;
}