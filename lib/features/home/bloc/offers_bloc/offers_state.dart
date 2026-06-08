// offers_state.dart
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;

  OffersLoaded({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
}

class OffersRefreshing extends OffersState {
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;

  OffersRefreshing({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
}

// Add this new state
class OffersLoadingMore extends OffersState {
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;

  OffersLoadingMore({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
}

class OffersEmpty extends OffersState {
  final String message;

  OffersEmpty({required this.message});
}

class OffersError extends OffersState {
  final String errorMessage;

  OffersError({required this.errorMessage});
}