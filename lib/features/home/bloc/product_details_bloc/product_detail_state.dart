// features/product_detail/bloc/product_detail_state.dart
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_details_response.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  ProductDetailLoaded({
    required this.product,
    required this.warehouse,
    required this.isServiceable,
  });
  final Product product;
  final Warehouse warehouse;
  final bool isServiceable;
}

class ProductDetailRefreshing extends ProductDetailState {
  ProductDetailRefreshing({
    required this.product,
    required this.warehouse,
    required this.isServiceable,
  });
  final Product product;
  final Warehouse warehouse;
  final bool isServiceable;
}

class ProductDetailError extends ProductDetailState {
  ProductDetailError({required this.errorMessage});
  final String errorMessage;
}
