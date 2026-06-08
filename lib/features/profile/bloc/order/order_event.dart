// // order_event.dart
// abstract class OrderEvent {}

// class LoadOrdersEvent extends OrderEvent {
//   LoadOrdersEvent({
//     required this.latitude,
//     required this.longitude,
//   });
//   final double latitude;
//   final double longitude;
// }

// class GetOrderByIdEvent extends OrderEvent {
//   GetOrderByIdEvent({
//     required this.orderId,
//     required this.latitude,
//     required this.longitude,
//   });
//   final String orderId;
//   final double latitude;
//   final double longitude;
// }

// class FilterOrdersEvent extends OrderEvent {
//   FilterOrdersEvent({
//     this.filterType = 'all', // 'all', 'delivered', 'canceled', 'active'
//   });
//   final String filterType;
// }

// class CancelOrderItemEvent extends OrderEvent {
//   CancelOrderItemEvent({
//     required this.orderId,
//     required this.orderItemId,
//     required this.status,
//     required this.reason,
//     required this.latitude,
//     required this.longitude,
//   });
//   final int orderId;
//   final int orderItemId;
//   final String status;
//   final String reason;
//   final double latitude;
//   final double longitude;
// }

// class CancelOrderEvent extends OrderEvent {
//   CancelOrderEvent({
//     required this.orderId,
//     required this.reason,
//     required this.latitude,
//     required this.longitude,
//   });
//   final int orderId;
//   final String reason;
//   final double latitude;
//   final double longitude;
// }

// class GetInvoiceEvent extends OrderEvent {
//   GetInvoiceEvent({
//     required this.orderId,
//   });
//   final int orderId;
// }

// class DownloadInvoiceEvent extends OrderEvent {
//   DownloadInvoiceEvent({
//     required this.orderId,
//   });
//   final int orderId;
// }

// ============================================================================
// UPDATED ORDER EVENTS (order_events.dart)
// Complete event definitions for all APIs
// ============================================================================

abstract class OrderEvent {}

class FetchOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status;

  FetchOrders({
    required this.page,
    required this.limit,
    this.status,
  });
}

class RefreshOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status;

  RefreshOrders({
    required this.page,
    required this.limit,
    this.status,
  });
}

class ChangeOrderTab extends OrderEvent {
  final String? status;

  ChangeOrderTab({this.status});
}

class LoadMoreOrders extends OrderEvent {
  final int page;
  final int limit;
  final String? status;

  LoadMoreOrders({
    required this.page,
    required this.limit,
    this.status,
  });
}

class GetOrderDetails extends OrderEvent {
  final String orderId;

  GetOrderDetails({required this.orderId});
}

class GetOrderTracking extends OrderEvent {
  final String orderId;

  GetOrderTracking({required this.orderId});
}

class GetLiveTracking extends OrderEvent {
  final String orderId;

  GetLiveTracking({required this.orderId});
}

class CancelOrder extends OrderEvent {
  final String orderId;
  final String reason;

  CancelOrder({required this.orderId, required this.reason});
}

class CancelOrderItem extends OrderEvent {
  final String orderId;
  final String itemId;
  final String reason;

  CancelOrderItem({
    required this.orderId,
    required this.itemId,
    required this.reason,
  });
}

class GetInvoice extends OrderEvent {
  final String orderId;

  GetInvoice({required this.orderId});
}

class DownloadInvoice extends OrderEvent {
  final String orderId;

  DownloadInvoice({required this.orderId});
}