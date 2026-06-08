import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/profile/bloc/order/order_event.dart';
import 'package:villag_kart/features/profile/bloc/order/order_state.dart';
import 'package:villag_kart/features/profile/services/order_service.dart';


class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<FetchOrders>(_onFetchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<LoadMoreOrders>(_onLoadMoreOrders);
    on<ChangeOrderTab>(_onChangeOrderTab);
    on<GetOrderDetails>(_onGetOrderDetails);
    on<GetOrderTracking>(_onGetOrderTracking);
    on<GetLiveTracking>(_onGetLiveTracking);
    on<CancelOrder>(_onCancelOrder);
    on<CancelOrderItem>(_onCancelOrderItem);
    on<GetInvoice>(_onGetInvoice);
    // on<DownloadInvoice>(_onDownloadInvoice);
  }

  // Handle initial fetch of orders
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

  // Handle refresh of orders
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
        emit(currentState);
      }
      emit(OrderError(errorMessage: e.toString()));
    }
  }

  // Handle load more orders
  Future<void> _onLoadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    if (currentState is OrderLoaded) {
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
          emit(currentState);
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

  // Handle get order details
  Future<void> _onGetOrderDetails(
    GetOrderDetails event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderDetailsLoading());

    try {
      final orderDetails = await OrderService.fetchOrderDetails(
        orderId: event.orderId,
      );

      emit(OrderDetailsLoaded(orderDetails: orderDetails));
    } catch (e) {
      emit(OrderDetailsError(errorMessage: e.toString()));
    }
  }

  // Handle get order tracking
  Future<void> _onGetOrderTracking(
    GetOrderTracking event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderTrackingLoading());

    try {
      final trackingResponse = await OrderService.fetchOrderTracking(
        orderId: event.orderId,
      );

      emit(OrderTrackingLoaded(trackingData: trackingResponse.data));
    } catch (e) {
      emit(OrderTrackingError(errorMessage: e.toString()));
    }
  }

  // Handle get live tracking
  Future<void> _onGetLiveTracking(
    GetLiveTracking event,
    Emitter<OrderState> emit,
  ) async {
    emit(LiveTrackingLoading());

    try {
      final liveTracking = await OrderService.fetchLiveTracking(
        orderId: event.orderId,
      );

      emit(LiveTrackingLoaded(trackingData: liveTracking.data));
    } catch (e) {
      emit(LiveTrackingError(errorMessage: e.toString()));
    }
  }

  // Handle cancel order
  Future<void> _onCancelOrder(
    CancelOrder event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is OrderLoaded) {
      emit(OrderCancelling(
        orderId: event.orderId,
        addresses: currentState.orders,
        currentPage: currentState.currentPage,
        totalPages: currentState.totalPages,
        totalCount: currentState.totalCount,
        currentStatus: currentState.currentStatus,
      ));

      try {
        await OrderService.cancelOrder(
          orderId: event.orderId,
          reason: event.reason,
        );

        // Refresh orders after cancellation
        add(FetchOrders(page: 1, limit: 20, status: currentState.currentStatus));
        
        emit(OrderCancelled(
          orderId: event.orderId,
          message: 'Order cancelled successfully',
        ));
      } catch (e) {
        emit(currentState);
        emit(OrderError(errorMessage: e.toString()));
      }
    }
  }

  // Handle cancel order item
  Future<void> _onCancelOrderItem(
    CancelOrderItem event,
    Emitter<OrderState> emit,
  ) async {
    final currentState = state;
    
    if (currentState is OrderDetailsLoaded) {
      emit(OrderItemCancelling(
        orderId: event.orderId,
        itemId: event.itemId,
      ));

      try {
        await OrderService.cancelOrderItem(
          orderId: event.orderId,
          itemId: event.itemId,
          reason: event.reason,
        );

        // Refresh order details
        add(GetOrderDetails(orderId: event.orderId));
        
        emit(OrderItemCancelled(
          orderId: event.orderId,
          itemId: event.itemId,
          message: 'Item cancelled successfully',
        ));
      } catch (e) {
        emit(currentState);
        emit(OrderError(errorMessage: e.toString()));
      }
    }
  }

  // Handle get invoice
  Future<void> _onGetInvoice(
    GetInvoice event,
    Emitter<OrderState> emit,
  ) async {
    emit(InvoiceLoading(orderId: event.orderId));

    try {
      final invoiceResponse = await OrderService.fetchInvoice(
        orderId: event.orderId,
      );

      emit(InvoiceLoaded(invoiceData: invoiceResponse.data));
    } catch (e) {
      emit(InvoiceError(errorMessage: e.toString()));
    }
  }

  // // Handle download invoice
  // Future<void> _onDownloadInvoice(
  //   DownloadInvoice event,
  //   Emitter<OrderState> emit,
  // ) async {
  //   emit(InvoiceDownloading());

  //   try {
  //     final filePath = await OrderService.downloadInvoice(
  //       orderId: event.orderId,
  //     );

  //     emit(InvoiceDownloaded(filePath: filePath));
  //   } catch (e) {
  //     emit(InvoiceError(errorMessage: e.toString()));
  //   }
  // }
}