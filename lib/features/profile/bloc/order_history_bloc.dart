
import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_history_event.dart';
import 'order_history_service.dart';
import 'order_history_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<LoadMoreOrders>(_onLoadMoreOrders);
    on<ChangeOrderTab>(_onChangeOrderTab);
  }

  // Handle initial fetch
  Future<void> _onFetchOrders(
    FetchOrders event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final ordersResponse = await OrderService.fetchOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      if (ordersResponse.data.orders.isEmpty) {
        emit(OrderEmpty(message: 'No orders found'));
      } else {
        emit(OrderLoaded(
          orders: ordersResponse.data.orders,
          currentPage: ordersResponse.data.pagination.page,
          totalPages: ordersResponse.data.pagination.totalPages,
          totalCount: ordersResponse.data.pagination.total,
          currentStatus: event.status,
        ));
      }
    } catch (e) {
      emit(OrderError(errorMessage: e.toString()));
    }
  }

  // Handle refresh (pull to refresh)
  Future<void> _onRefreshOrders(
    RefreshOrders event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderLoaded) {
      emit(OrderRefreshing(
        orders: currentState.orders,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalCount: currentState.totalCount,
        currentStatus: currentState.currentStatus,
      ));
    }

    try {
      final ordersResponse = await OrderService.fetchOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );

      if (ordersResponse.data.orders.isEmpty) {
        emit(OrderEmpty(message: 'No orders found'));
      } else {
        emit(OrderLoaded(
          orders: ordersResponse.data.orders,
          currentPage: ordersResponse.data.pagination.page,
          totalPages: ordersResponse.data.pagination.totalPages,
          totalCount: ordersResponse.data.pagination.total,
          currentStatus: event.status,
        ));
      }
    } catch (e) {
      if (currentState is OrderLoaded) {
        emit(currentState); // Revert to previous state
      }
      emit(OrderError(errorMessage: e.toString()));
    }
  }

  // Handle load more (pagination)
  Future<void> _onLoadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderLoaded) {
      // Only load more if there are more pages
      if (event.page <= currentState.totalPages) {
        emit(OrderLoadingMore(
          orders: currentState.orders,
          currentPage: currentState.currentPage,
          totalPages: currentState.totalPages,
          totalCount: currentState.totalCount,
          currentStatus: currentState.currentStatus,
        ));

        try {
          final ordersResponse = await OrderService.fetchOrders(
            page: event.page,
            limit: event.limit,
            status: event.status,
          );

          final updatedOrders = [
            ...currentState.orders,
            ...ordersResponse.data.orders
          ];

          emit(OrderLoaded(
            orders: updatedOrders,
            currentPage: ordersResponse.data.pagination.page,
            totalPages: ordersResponse.data.pagination.totalPages,
            totalCount: ordersResponse.data.pagination.total,
            currentStatus: event.status,
          ));
        } catch (e) {
          emit(currentState); // Revert to previous state
          emit(OrderError(errorMessage: e.toString()));
        }
      }
    }
  }

  // Handle tab change
  Future<void> _onChangeOrderTab(
    ChangeOrderTab event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());

    try {
      final ordersResponse = await OrderService.fetchOrders(
        page: 1,
        limit: 20,
        status: event.status,
      );

      if (ordersResponse.data.orders.isEmpty) {
        emit(OrderEmpty(message: 'No orders found'));
      } else {
        emit(OrderLoaded(
          orders: ordersResponse.data.orders,
          currentPage: ordersResponse.data.pagination.page,
          totalPages: ordersResponse.data.pagination.totalPages,
          totalCount: ordersResponse.data.pagination.total,
          currentStatus: event.status,
        ));
      }
    } catch (e) {
      emit(OrderError(errorMessage: e.toString()));
    }
  }
}
