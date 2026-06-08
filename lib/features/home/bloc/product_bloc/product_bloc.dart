// product_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/product_bloc/product_service.dart';
import 'package:villag_kart/features/home/model/category_model.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

// Events
abstract class ProductEvent {}
class ClearProducts extends ProductEvent {}


class FetchProductsByCategory extends ProductEvent {
  final String categoryId;
  final String pincode;
  final int page;
  final int limit;

  FetchProductsByCategory({
    required this.categoryId,
    required this.pincode,
    this.page = 1,
    this.limit = 20,
  });
}

class FetchProductsBySubCategory extends ProductEvent {
  final String subCategoryId;
  final String pincode;
  final int page;
  final int limit;

  FetchProductsBySubCategory({
    required this.subCategoryId,
    required this.pincode,
    this.page = 1,
    this.limit = 20,
  });
}

class RefreshProducts extends ProductEvent {
  final String? categoryId;
  final String? subCategoryId;
  final String pincode;

  RefreshProducts({this.categoryId, this.subCategoryId, required this.pincode});
}

class UpdateProductCartCount extends ProductEvent {
  final String productId;
  final int count;

  UpdateProductCartCount({required this.productId, required this.count});
}

class FetchAllCategoryProducts extends ProductEvent {
  final List<String> categoryIds;
  final String pincode;

  FetchAllCategoryProducts({
    required this.categoryIds,
    required this.pincode,
  });
}

// States
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final Warehouse warehouse;
  final bool isServiceable;
  final CategoryModel? category;
  final SubCategory? subCategory;
  final int total;
  final int page;
  final int totalPages;

  ProductLoaded({
    required this.products,
    required this.warehouse,
    required this.isServiceable,
    this.category,
    this.subCategory,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class ProductError extends ProductState {
  final String errorMessage;

  ProductError({required this.errorMessage});
}

// BLoC
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(ProductInitial()) {
    on<FetchProductsByCategory>(_onFetchProductsByCategory);
    on<FetchProductsBySubCategory>(_onFetchProductsBySubCategory);
    on<RefreshProducts>(_onRefreshProducts);
    on<UpdateProductCartCount>(_onUpdateProductCartCount);
     on<FetchAllCategoryProducts>(_onFetchAllCategoryProducts);

      on<ClearProducts>((event, emit) {
    emit(ProductInitial());
  });
  }

  Future<void> _onFetchProductsByCategory(
    FetchProductsByCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final productResponse = await ProductService.fetchProductsByCategory(
        categoryId: event.categoryId,
        pincode: event.pincode,
        page: event.page,
        limit: event.limit,
      );

      emit(
        ProductLoaded(
          products: productResponse.data.products,
          warehouse: productResponse.data.warehouse,
          isServiceable: productResponse.data.serviceable,
          category: productResponse.data.category,
          total: productResponse.data.total,
          page: productResponse.data.page,
          totalPages: productResponse.data.totalPages,
        ),
      );
    } catch (e) {
      emit(
        ProductError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onFetchProductsBySubCategory(
    FetchProductsBySubCategory event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    try {
      final productResponse = await ProductService.fetchProductsBySubCategory(
        subCategoryId: event.subCategoryId,
        pincode: event.pincode,
        page: event.page,
        limit: event.limit,
      );

      emit(
        ProductLoaded(
          products: productResponse.data.products,
          warehouse: productResponse.data.warehouse,
          isServiceable: productResponse.data.serviceable,
          subCategory: productResponse.data.subCategory,
          total: productResponse.data.total,
          page: productResponse.data.page,
          totalPages: productResponse.data.totalPages,
        ),
      );
    } catch (e) {
      emit(
        ProductError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      try {
        ProductResponse productResponse;

        if (event.categoryId != null) {
          productResponse = await ProductService.fetchProductsByCategory(
            categoryId: event.categoryId!,
            pincode: event.pincode,
          );
        } else if (event.subCategoryId != null) {
          productResponse = await ProductService.fetchProductsBySubCategory(
            subCategoryId: event.subCategoryId!,
            pincode: event.pincode,
          );
        } else {
          return;
        }

        emit(
          ProductLoaded(
            products: productResponse.data.products,
            warehouse: productResponse.data.warehouse,
            isServiceable: productResponse.data.serviceable,
            category: productResponse.data.category,
            subCategory: productResponse.data.subCategory,
            total: productResponse.data.total,
            page: productResponse.data.page,
            totalPages: productResponse.data.totalPages,
          ),
        );
      } catch (e) {
        emit(
          ProductError(
            errorMessage: e.toString().replaceAll('Exception: ', ''),
          ),
        );
      }
    }
  }

  void _onUpdateProductCartCount(
    UpdateProductCartCount event,
    Emitter<ProductState> emit,
  ) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      final updatedProducts = currentState.products.map((product) {
        if (product.id == event.productId) {
          return Product(
            id: product.id,
            name: product.name,
            description: product.description,
            price: product.price,
            mrp: product.mrp,
            discount: product.discount,
            savedAmount: product.savedAmount,
            images: product.images,
            unit: product.unit,
            stock: product.stock,
            inStock: product.inStock,
            minOrderQty: product.minOrderQty,
            maxOrderQty: product.maxOrderQty,
            isFeatured: product.isFeatured,
            brand: product.brand,
            category: product.category,
            subCategory: product.subCategory,
            rating: product.rating,
            ratingCount: product.ratingCount,
            weight: product.weight,
            createdAt: product.createdAt,
            cartCount: event.count,
            warehouse: product.warehouse,
             variants: product.variants,
          );
        }
        return product;
      }).toList();

      emit(
        ProductLoaded(
          products: updatedProducts,
          warehouse: currentState.warehouse,
          isServiceable: currentState.isServiceable,
          category: currentState.category,
          subCategory: currentState.subCategory,
          total: currentState.total,
          page: currentState.page,
          totalPages: currentState.totalPages,
        ),
      );
    }
  }


 Future<void> _onFetchAllCategoryProducts(
  FetchAllCategoryProducts event,
  Emitter<ProductState> emit,
) async {

  debugPrint("FetchAllCategoryProducts called");

  emit(ProductLoading());

  try {

    /// Run API calls in parallel
    final responses = await Future.wait(
      event.categoryIds.map(
        (categoryId) => ProductService.fetchProductsByCategory(
          categoryId: categoryId,
          pincode: event.pincode,
        ),
      ),
    );

    List<Product> allProducts = [];
    Warehouse? warehouse;
    bool isServiceable = false;

    for (final response in responses) {
      warehouse ??= response.data.warehouse;
      isServiceable = response.data.serviceable;
      allProducts.addAll(response.data.products);
    }

    emit(
      ProductLoaded(
        products: allProducts,
        warehouse: warehouse!,
        isServiceable: isServiceable,
        total: allProducts.length,
        page: 1,
        totalPages: 1,
      ),
    );

  } catch (e) {

    emit(
      ProductError(
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ),
    );

  }
}
}
