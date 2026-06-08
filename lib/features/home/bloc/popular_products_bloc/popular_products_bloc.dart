// popular_products_bloc.dart - Update with load more capability
import 'package:bloc_concurrency/bloc_concurrency.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/popular_produts_state.dart';
import 'package:villag_kart/features/home/bloc/popular_products_bloc/products_service.dart';
import 'popular_products_event.dart';

class PopularProductsBloc extends Bloc<PopularProductsEvent, PopularProductsState> {
  PopularProductsBloc() : super(PopularProductsInitial()) {
  on<FetchPopularProducts>(
    _onFetchPopularProducts,
    transformer: droppable(),
  );

  on<RefreshPopularProducts>(_onRefreshPopularProducts);
  on<LoadMorePopularProducts>(_onLoadMorePopularProducts);
}


  
Future<void> _onFetchPopularProducts(
  FetchPopularProducts event,
  Emitter<PopularProductsState> emit,
) async {
  
  if (state is PopularProductsLoading) return;

  if (state is PopularProductsLoaded) {
    final current = state as PopularProductsLoaded;

    if (current.currentPage == event.page) {
      return;
    }
  }

  emit(PopularProductsLoading());

  try {
    final response = await PopularProductsService.fetchPopularProducts(
      pincode: event.pincode,
      page: event.page,
      limit: event.limit,
    );

    emit(PopularProductsLoaded(
      products: response.data.products,
      warehouse: response.data.warehouse,
      isServiceable: response.data.serviceable,
      hasReachedMax: response.data.products.length < event.limit,
      currentPage: event.page,
    ));

  } catch (e) {
    emit(PopularProductsError(
      errorMessage: e.toString().replaceAll('Exception: ', ''),
    ));
  }
}

  Future<void> _onRefreshPopularProducts(
    RefreshPopularProducts event,
    Emitter<PopularProductsState> emit,
  ) async {
    if (state is PopularProductsLoaded) {
      final currentState = state as PopularProductsLoaded;
      emit(PopularProductsRefreshing(
        products: currentState.products,
        warehouse: currentState.warehouse,
        isServiceable: currentState.isServiceable,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));

      try {
        final popularProductsResponse = await PopularProductsService.fetchPopularProducts(
          pincode: event.pincode,
          page: 1, // Reset to first page on refresh
          limit: event.limit,
        );

        emit(PopularProductsLoaded(
          products: popularProductsResponse.data.products,
          warehouse: popularProductsResponse.data.warehouse,
          isServiceable: popularProductsResponse.data.serviceable,
          hasReachedMax: popularProductsResponse.data.products.length < event.limit,
          currentPage: 1,
        ));
      } catch (e) {
        emit(PopularProductsError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }

  Future<void> _onLoadMorePopularProducts(
    LoadMorePopularProducts event,
    Emitter<PopularProductsState> emit,
  ) async {
    if (state is PopularProductsLoaded) {
      final currentState = state as PopularProductsLoaded;
      
      if (currentState.hasReachedMax) return;

      emit(PopularProductsLoadingMore(
        products: currentState.products,
        warehouse: currentState.warehouse,
        isServiceable: currentState.isServiceable,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));

      try {
        final nextPage = currentState.currentPage + 1;
        final popularProductsResponse = await PopularProductsService.fetchPopularProducts(
          pincode: event.pincode,
          page: nextPage,
          limit: event.limit,
        );

        final allProducts = [
          ...currentState.products,
          ...popularProductsResponse.data.products,
        ];

        emit(PopularProductsLoaded(
          products: allProducts,
          warehouse: popularProductsResponse.data.warehouse,
          isServiceable: popularProductsResponse.data.serviceable,
          hasReachedMax: popularProductsResponse.data.products.length < event.limit,
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(PopularProductsError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }
}