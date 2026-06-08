import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

abstract class PopularProductsState {}

class PopularProductsInitial extends PopularProductsState {}

class PopularProductsLoading extends PopularProductsState {}

class PopularProductsLoaded extends PopularProductsState {
  PopularProductsLoaded({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;
}

class PopularProductsRefreshing extends PopularProductsState {
  PopularProductsRefreshing({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;
}

class PopularProductsLoadingMore extends PopularProductsState {
  PopularProductsLoadingMore({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    required this.hasReachedMax,
    required this.currentPage,
  });
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final bool hasReachedMax;
  final int currentPage;
}

// Add this missing state
class PopularProductsEmpty extends PopularProductsState {
  PopularProductsEmpty({required this.message});
  final String message;
}

class PopularProductsError extends PopularProductsState {
  PopularProductsError({required this.errorMessage});
  final String errorMessage;
}
