

// ============================================================================
// ORDER TRACKING STATES (order_tracking_state.dart)
// ============================================================================



import '../model/map_route_model.dart';

abstract class OrderTrackingState {}

class OrderTrackingInitial extends OrderTrackingState {}

class OrderTrackingLoading extends OrderTrackingState {}

class OrderTrackingLoaded extends OrderTrackingState {
  final OrderTrackingData trackingData;

  OrderTrackingLoaded({required this.trackingData});
}

class OrderTrackingRefreshing extends OrderTrackingState {
  final OrderTrackingData trackingData;

  OrderTrackingRefreshing({required this.trackingData});
}

class OrderTrackingError extends OrderTrackingState {
  final String errorMessage;

  OrderTrackingError({required this.errorMessage});
}