import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_events.dart';
import 'package:villag_kart/features/home/bloc/brands_bloc/brands_service.dart';
import 'brands_state.dart';

class BrandsBloc extends Bloc<BrandsEvent, BrandsState> {
  BrandsBloc() : super(BrandsInitial()) {
    on<FetchBrands>(_onFetchBrands,transformer: droppable(),);
    on<RefreshBrands>(_onRefreshBrands);
  }

  Future<void> _onFetchBrands(
    FetchBrands event,
    Emitter<BrandsState> emit,
  ) async {
    debugPrint('🚀 BrandsBloc: Fetching brands...');
    emit(BrandsLoading());

    try {
      final brandsResponse = await BrandsService.fetchBrands(
        pincode: event.pincode,
        latitude: event.latitude,
        longitude: event.longitude,
        userId: event.userId,
      );

      debugPrint(
        '✅ BrandsBloc: Received ${brandsResponse.data.brands.length} brands',
      );

      if (brandsResponse.data.brands.isNotEmpty) {
        emit(
          BrandsLoaded(
            brands: brandsResponse.data.brands,
            warehouse: brandsResponse.data.warehouse,
            isServiceable: brandsResponse.data.serviceable,
          ),
        );
      } else {
        debugPrint('⚠️ BrandsBloc: No brands available');
        emit(BrandsEmpty(message: 'No brands available'));
      }
    } catch (e) {
      debugPrint('❌ BrandsBloc Error: $e');
      emit(
        BrandsError(errorMessage: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<void> _onRefreshBrands(
    RefreshBrands event,
    Emitter<BrandsState> emit,
  ) async {
    if (state is BrandsLoaded) {
      final currentState = state as BrandsLoaded;
      emit(
        BrandsRefreshing(
          brands: currentState.brands,
          warehouse: currentState.warehouse,
          isServiceable: currentState.isServiceable,
        ),
      );

      try {
        final brandsResponse = await BrandsService.fetchBrands(
          pincode: event.pincode,
          latitude: event.latitude,
          longitude: event.longitude,
          userId: event.userId,
        );

        if (brandsResponse.data.brands.isNotEmpty) {
          emit(
            BrandsLoaded(
              brands: brandsResponse.data.brands,
              warehouse: brandsResponse.data.warehouse,
              isServiceable: brandsResponse.data.serviceable,
            ),
          );
        } else {
          emit(BrandsEmpty(message: 'No brands available'));
        }
      } catch (e) {
        emit(
          BrandsError(errorMessage: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }
}
