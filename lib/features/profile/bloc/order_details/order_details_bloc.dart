// ============================================================================
// UPDATED ORDER DETAILS BLOC (order_details_bloc.dart)
// Now works with just the Order model
// ============================================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/realtime/consumer_realtime_hub.dart';
import 'package:villag_kart/features/profile/bloc/order_details/order_details_service.dart';

import 'order_details_event.dart';
import 'order_details_state.dart';

class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  OrderDetailsBloc() : super(OrderDetailsInitial()) {
    on<FetchOrderDetails>(_onFetchOrderDetails);
    on<RefreshOrderDetails>(_onRefreshOrderDetails);
    on<SocketEventReceived>(_onSocketEvent);
  }

  String? _realtimeOrderId;

  void _attachRealtime(String orderId) {
    if (_realtimeOrderId != null) {
      ConsumerRealtimeHub.instance.removeOrderListener(
        _realtimeOrderId!,
        _onSocketEventRaw,
      );
    }
    _realtimeOrderId = orderId;
    ConsumerRealtimeHub.instance.addOrderListener(orderId, _onSocketEventRaw);
  }

  void _onSocketEventRaw(ConsumerSocketEvent ev) {
    if (!isClosed) {
      add(SocketEventReceived(ev));
    }
  }

  void _onSocketEvent(
    SocketEventReceived event,
    Emitter<OrderDetailsState> emit,
  ) {
    final ev = event.event;
    if (isClosed) {
      return;
    }
    if (state is! OrderDetailsLoaded && state is! OrderDetailsRefreshing) {
      return;
    }
    final order = state is OrderDetailsLoaded
        ? (state as OrderDetailsLoaded).order
        : (state as OrderDetailsRefreshing).order;
    if (order.id != _realtimeOrderId) {
      return;
    }

    if (ev.kind == 'status') {
      final st = ev.payload['status']?.toString();
      if (st == null || st.isEmpty) {
        return;
      }
      emit(
        OrderDetailsLoaded(
          order: order.copyWith(status: st, updatedAt: DateTime.now()),
        ),
      );
      return;
    }
    if (ev.kind == 'location') {
      final loc = ev.payload['location'];
      double? lat;
      double? lng;
      if (loc is Map) {
        lat =
            (loc['lat'] as num?)?.toDouble() ??
            (loc['latitude'] as num?)?.toDouble();
        lng =
            (loc['lng'] as num?)?.toDouble() ??
            (loc['longitude'] as num?)?.toDouble();
      }
      Map<String, dynamic>? etaMap;
      final eta = ev.payload['eta'];
      if (eta is Map<String, dynamic>) {
        etaMap = eta;
      } else if (eta is Map) {
        etaMap = Map<String, dynamic>.from(eta);
      }
      emit(
        OrderDetailsLoaded(
          order: order.copyWith(
            liveRiderLat: lat,
            liveRiderLng: lng,
            liveRiderEta: etaMap,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    if (_realtimeOrderId != null) {
      ConsumerRealtimeHub.instance.removeOrderListener(
        _realtimeOrderId!,
        _onSocketEventRaw,
      );
      _realtimeOrderId = null;
    }
    return super.close();
  }

  /// Handle initial fetch of order details
  Future<void> _onFetchOrderDetails(
    FetchOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {
    emit(OrderDetailsLoading());

    try {
      final response = await OrderDetailsService.fetchOrderDetails(
        orderId: event.orderId,
      );

      emit(OrderDetailsLoaded(order: response.data.order));
      _attachRealtime(response.data.order.id);
    } catch (e) {
      emit(OrderDetailsError(errorMessage: e.toString()));
    }
  }

  // =========================================================
  // REFRESH ORDER DETAILS
  // =========================================================

  Future<void> _onRefreshOrderDetails(
    RefreshOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {
    final currentState = state;

    if (currentState is OrderDetailsLoaded) {
      emit(OrderDetailsRefreshing(order: currentState.order));
    }

    try {
      final response = await OrderDetailsService.fetchOrderDetails(
        orderId: event.orderId,
      );

      emit(OrderDetailsLoaded(order: response.data.order));
      _attachRealtime(response.data.order.id);
    } catch (e) {
      if (currentState is OrderDetailsLoaded) {
        emit(currentState);
      } else {
        emit(OrderDetailsError(errorMessage: e.toString()));
      }
    }
  }
}
