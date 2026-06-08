import 'package:villag_kart/features/home/model/category_model.dart';

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class CategoryEmpty extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<CategoryModel> categories;
  final Warehouse warehouse;
  final bool isServiceable;

  CategoryLoaded({
    required this.categories,
    required this.warehouse,
    required this.isServiceable,
  });
}

class CategoryRefreshing extends CategoryState {
  final List<CategoryModel> categories;
  final Warehouse warehouse;
  final bool isServiceable;

  CategoryRefreshing({
    required this.categories,
    required this.warehouse,
    required this.isServiceable,
  });
}

class CategoryError extends CategoryState {
  final String errorMessage;

  CategoryError({required this.errorMessage});
}