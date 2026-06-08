// ============================================================================
// ORDER TRACKING BLOC (order_tracking_bloc.dart)
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';

import 'map_route_evet.dart';
import 'map_route_service.dart';
import 'map_route_state.dart';


class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  OrderTrackingBloc() : super(OrderTrackingInitial()) {
    on<FetchOrderTracking>(_onFetchOrderTracking);
    on<RefreshOrderTracking>(_onRefreshOrderTracking);
  }

  /// Handle initial fetch of order tracking
  Future<void> _onFetchOrderTracking(
    FetchOrderTracking event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(OrderTrackingLoading());

    try {
      final trackingResponse =
          await OrderTrackingService.fetchOrderTracking(
        orderId: event.orderId,
      );

      emit(OrderTrackingLoaded(trackingData: trackingResponse.data));
    } catch (e) {
      emit(OrderTrackingError(errorMessage: e.toString()));
    }
  }

  /// Handle refresh of order tracking
  Future<void> _onRefreshOrderTracking(
    RefreshOrderTracking event,
    Emitter<OrderTrackingState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderTrackingLoaded) {
      emit(OrderTrackingRefreshing(trackingData: currentState.trackingData));
    }

    try {
      final trackingResponse =
          await OrderTrackingService.fetchOrderTracking(
        orderId: event.orderId,
      );

      emit(OrderTrackingLoaded(trackingData: trackingResponse.data));
    } catch (e) {
      if (currentState is OrderTrackingLoaded) {
        emit(currentState); // Revert to previous state
      }
      emit(OrderTrackingError(errorMessage: e.toString()));
    }
  }
}