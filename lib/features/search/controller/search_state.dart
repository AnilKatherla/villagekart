import 'package:equatable/equatable.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';


class SearchState extends Equatable {
  const SearchState({
    required this.categories,
    required this.products,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.lastAddedProductId,
  });
  factory SearchState.initial({
    List<CategoryModel>? categories,
    List<Product>? products,
  }) {
    return SearchState(
      categories: categories ?? const [],
      products: products ?? const [],
    );
  }
  final List<CategoryModel> categories;
  final List<Product> products;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final String? lastAddedProductId;

  SearchState copyWith({
    List<CategoryModel>? categories,
    List<Product>? products,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    String? lastAddedProductId,
  }) {
    return SearchState(
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      lastAddedProductId: lastAddedProductId ?? this.lastAddedProductId,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    products,
    selectedCategoryId,
    searchQuery,
    isLoading,
    lastAddedProductId,
  ];
}
