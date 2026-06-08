// order_status_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/profile/bloc/order_status/order_status_event.dart';
import 'package:villag_kart/features/profile/bloc/order_status/order_status_state.dart';
import 'package:villag_kart/features/profile/services/order_service.dart';

class OrderStatusBloc extends Bloc<OrderStatusEvent, OrderStatusState> {
  OrderStatusBloc() : super(OrderStatusInitialState()) {
    on<LoadOrderStatusesEvent>(_onLoadOrderStatuses);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<CancelOrderEvent>(_onCancelOrder);
  }

  Future<void> _onLoadOrderStatuses(
    LoadOrderStatusesEvent event,
    Emitter<OrderStatusState> emit,
  ) async {
    emit(OrderStatusLoadingState());
    // Consumer API has no `order-statuses` route; avoid invalid network calls.
    emit(OrderStatusesLoadedState(statuses: []));
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatusEvent event,
    Emitter<OrderStatusState> emit,
  ) async {
    emit(OrderStatusErrorState(
      error: 'Order status cannot be updated from this screen.',
    ));
  }

  Future<void> _onCancelOrder(
    CancelOrderEvent event,
    Emitter<OrderStatusState> emit,
  ) async {
    emit(OrderStatusLoadingState());
    try {
      await OrderService.cancelOrder(
        orderId: event.orderId,
        reason: event.reason,
      );
      if (!emit.isDone) {
        emit(OrderCancelledState(
          orderId: event.orderId,
          message: 'Order cancelled successfully',
        ));
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(OrderStatusErrorState(error: e.toString()));
      }
    }
  }
}
