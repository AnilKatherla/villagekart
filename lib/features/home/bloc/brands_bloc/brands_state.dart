import 'package:villag_kart/features/home/model/brands_model.dart';
import 'package:villag_kart/features/home/model/category_model.dart';

abstract class BrandsState {}

class BrandsInitial extends BrandsState {}

class BrandsLoading extends BrandsState {}

class BrandsLoaded extends BrandsState {
  final List<Brand> brands;
  final Warehouse warehouse;
  final bool isServiceable;

  BrandsLoaded({
    required this.brands,
    required this.warehouse,
    required this.isServiceable,
  });
}

class BrandsRefreshing extends BrandsState {
  final List<Brand> brands;
  final Warehouse warehouse;
  final bool isServiceable;

  BrandsRefreshing({
    required this.brands,
    required this.warehouse,
    required this.isServiceable,
  });
}

class BrandsEmpty extends BrandsState {
  final String message;

  BrandsEmpty({required this.message});
}

class BrandsError extends BrandsState {
  final String errorMessage;

  BrandsError({required this.errorMessage});
}