// ============================================================================
// UPDATED ORDER DETAILS STATE (order_details_state.dart)
// Simplified to use only Order model
// ============================================================================

import '../../model/order_history_model.dart' show Order;

abstract class OrderDetailsState {}

class OrderDetailsInitial extends OrderDetailsState {}

class OrderDetailsLoading extends OrderDetailsState {}

class OrderDetailsLoaded extends OrderDetailsState {
  OrderDetailsLoaded({required this.order});
  final Order order;
}

class OrderDetailsRefreshing extends OrderDetailsState {
  OrderDetailsRefreshing({required this.order});
  final Order order;
}

class OrderDetailsError extends OrderDetailsState {
  OrderDetailsError({required this.errorMessage});
  final String errorMessage;
}
