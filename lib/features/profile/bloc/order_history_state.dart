// ============================================================================
// FIXED ORDER STATES (order_state.dart)
// Status field is now nullable
// ============================================================================


import '../model/order_history_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus; // ✅ Now nullable

  OrderLoaded({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus, // ✅ Optional parameter
  });
}

class OrderRefreshing extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus; // ✅ Now nullable

  OrderRefreshing({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus, // ✅ Optional parameter
  });
}

class OrderLoadingMore extends OrderState {
  final List<Order> orders;
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final String? currentStatus; // ✅ Now nullable

  OrderLoadingMore({
    required this.orders,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    this.currentStatus, // ✅ Optional parameter
  });
}

class OrderEmpty extends OrderState {
  final String message;

  OrderEmpty({required this.message});
}

class OrderError extends OrderState {
  final String errorMessage;

  OrderError({required this.errorMessage});
}