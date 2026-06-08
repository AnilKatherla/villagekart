// offers_bloc.dart
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/offers_bloc/offers_service.dart';
import 'offers_event.dart';
import 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  OffersBloc() : super(OffersInitial()) {
    on<FetchOffers>(_onFetchOffers,transformer: droppable(),);
    on<RefreshOffers>(_onRefreshOffers);
    on<LoadMoreOffers>(_onLoadMoreOffers); // Add this
  }

  Future<void> _onFetchOffers(
    FetchOffers event,
    Emitter<OffersState> emit,
  ) async {
    emit(OffersLoading());

    try {
      final offersResponse = await OffersService.fetchOffers(
        pincode: event.pincode,
        page: event.page,
        limit: event.limit,
      );

      debugPrint('🔍 Checking offers response:');
      debugPrint('  Success: ${offersResponse.success}');
      debugPrint('  Data is null: ${offersResponse.data == null}');
      if (offersResponse.data != null) {
        debugPrint('  Products count: ${offersResponse.data!.products.length}');
        debugPrint('  Count field: ${offersResponse.data!.count}');
      }
      
      if (offersResponse.data != null && offersResponse.data!.products.isNotEmpty) {
        debugPrint('✅ Emitting OffersLoaded with ${offersResponse.data!.products.length} products');
        emit(OffersLoaded(
          products: offersResponse.data!.products,
          warehouse: offersResponse.data!.warehouse,
          isServiceable: offersResponse.data!.serviceable,
          hasReachedMax: offersResponse.data!.products.length < event.limit,
          currentPage: event.page,
        ));
      } else {
        debugPrint('⚠️ Emitting OffersEmpty - no products found');
        debugPrint('  Message: ${offersResponse.message}');
        emit(OffersEmpty(
          message: offersResponse.message.isNotEmpty 
              ? offersResponse.message 
              : 'No offers available',
        ));
      }
    } catch (e) {
      debugPrint('❌ Error in _onFetchOffers: $e');
      
  if (e is DioException) {
    final statusCode = e.response?.statusCode;

    // ✅ Treat 400 as EMPTY
    if (statusCode == 400) {
      emit( OffersEmpty(
        message: 'No offers available for your area',
      ));
      return;
    }
  }

  // 🔴 Real error
  emit(OffersError(
    errorMessage: 'Something went wrong. Please try again.',
  ));


    }
  }

  Future<void> _onRefreshOffers(
    RefreshOffers event,
    Emitter<OffersState> emit,
  ) async {
    if (state is OffersLoaded) {
      final currentState = state as OffersLoaded;
      emit(OffersRefreshing(
        products: currentState.products,
        warehouse: currentState.warehouse,
        isServiceable: currentState.isServiceable,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));

      try {
        final offersResponse = await OffersService.fetchOffers(
          pincode: event.pincode,
          page: 1,
          limit: event.limit,
        );

        if (offersResponse.data != null && offersResponse.data!.products.isNotEmpty) {
          emit(OffersLoaded(
            products: offersResponse.data!.products,
            warehouse: offersResponse.data!.warehouse,
            isServiceable: offersResponse.data!.serviceable,
            hasReachedMax: offersResponse.data!.products.length < event.limit,
            currentPage: 1,
          ));
        } else {
          emit(OffersEmpty(
            message: offersResponse.message,
          ));
        }
      } catch (e) {
  if (e is DioException && e.response?.statusCode == 400) {
    emit( OffersEmpty(
      message: 'No offers available for your area',
    ));
    return;
  }

  emit( OffersError(
    errorMessage: 'Failed to refresh offers',
  ));
}

    }
  }

  Future<void> _onLoadMoreOffers(
    LoadMoreOffers event,
    Emitter<OffersState> emit,
  ) async {
    if (state is OffersLoaded) {
      final currentState = state as OffersLoaded;
      
      if (currentState.hasReachedMax) return;

      emit(OffersLoadingMore(
        products: currentState.products,
        warehouse: currentState.warehouse,
        isServiceable: currentState.isServiceable,
        hasReachedMax: currentState.hasReachedMax,
        currentPage: currentState.currentPage,
      ));

      try {
        final nextPage = currentState.currentPage + 1;
        final offersResponse = await OffersService.fetchOffers(
          pincode: event.pincode,
          page: nextPage,
          limit: event.limit,
        );

        final allProducts = [
          ...currentState.products,
          ...offersResponse.data!.products,
        ];

        emit(OffersLoaded(
          products: allProducts,
          warehouse: offersResponse.data!.warehouse,
          isServiceable: offersResponse.data!.serviceable,
          hasReachedMax: offersResponse.data!.products.length < event.limit,
          currentPage: nextPage,
        ));
      } catch (e) {
        emit(OffersError(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ));
      }
    }
  }
}