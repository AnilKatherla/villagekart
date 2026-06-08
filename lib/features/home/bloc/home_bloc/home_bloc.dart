import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_event.dart';
import 'package:villag_kart/features/home/bloc/home_bloc/home_state.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState()) {
    on<HomeInitialized>(_onHomeInitialized);
    on<CategorySelected>(_onCategorySelected);
    on<LocationTapped>(_onLocationTapped);
    on<SeeAllTapped>(_onSeeAllTapped);
    on<BrandTapped>(_onBrandTapped);
    on<UpdateHomeLocation>(_onUpdateHomeLocation);

    on<OfferTapped>(_onOfferTapped);
    on<PopularProductTapped>(_onPopularProductTapped);
    on<SuggestionTapped>(_onSuggestionTapped);
  }

  void _onHomeInitialized(
    HomeInitialized event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading));

    final location = await LocationService.getSavedLocation();
    final userId = await LocationService.getUserId();
     final warehouse = await SharedPrefs.getWarehouse();

    if (location == null) {
    emit(state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Location not ready',
    ));
      return;
    }
    if (warehouse != null) {
    await SharedPrefs.saveWarehouse(warehouse!); 
  }


  emit(state.copyWith(
        status: HomeStatus.loaded,
        address: location['address'],
        pincode: location['pincode'],
        latitude: location['latitude'],
        longitude: location['longitude'],
        userId: userId,
        warehouse: warehouse,
      ));
  }

Future<void> _onUpdateHomeLocation(
  UpdateHomeLocation event,
  Emitter<HomeState> emit,
) async {
  debugPrint(' HomeBloc received address: ${event.address}');

  emit(
    state.copyWith(
      address: event.address,
      label: event.label,
      pincode: event.pincode,
      latitude: event.latitude,
      longitude: event.longitude,
      warehouse: event.warehouse,
      status: HomeStatus.loaded,
    ),
  );
  
  // Save to local storage for persistence
  await SharedPrefs.saveUserLocation(
    address: event.address,
    pincode: event.pincode,
    latitude: event.latitude,
    longitude: event.longitude,
  );
   if (event.warehouse != null) {
    await SharedPrefs.saveWarehouse(event.warehouse!);
  }
  
  debugPrint('🔥 HomeBloc state.address = ${state.address}');
}

  void _onCategorySelected(CategorySelected event, Emitter<HomeState> emit) {
    // Handle category selection
    emit(state.copyWith(selectedCategory: event.categoryName));
  }

  void _onLocationTapped(LocationTapped event, Emitter<HomeState> emit) {
    // Handle location tap
  }

  void _onSeeAllTapped(SeeAllTapped event, Emitter<HomeState> emit) {
    // Handle see all tap for different sections
  }

  void _onBrandTapped(BrandTapped event, Emitter<HomeState> emit) {
    // Handle brand tap
    emit(state.copyWith(selectedBrand: event.brandName));
  }

  void _onOfferTapped(OfferTapped event, Emitter<HomeState> emit) {
    // Handle offer product tap
    emit(state.copyWith(selectedOffer: event.productName));
  }

  void _onPopularProductTapped(
    PopularProductTapped event,
    Emitter<HomeState> emit,
  ) {
    // Handle popular product tap
    emit(state.copyWith(selectedPopularProduct: event.productName));
  }

  void _onSuggestionTapped(SuggestionTapped event, Emitter<HomeState> emit) {
    // Handle suggestion card tap
  }
}
