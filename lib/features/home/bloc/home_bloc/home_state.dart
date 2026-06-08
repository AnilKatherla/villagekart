// No part-of directive here - this is a standalone file
import 'package:villag_kart/features/location/model/location_response_model.dart';
enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final String? selectedCategory;
  final String? selectedBrand;
  final String? selectedOffer;
  final String? selectedPopularProduct;
  final String? errorMessage;
  final String? label;
  final String? address;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final String? userId;
  final Warehouse? warehouse;

  const HomeState({
    this.status = HomeStatus.initial,
    this.selectedCategory,
    this.selectedBrand,
    this.selectedOffer,
    this.selectedPopularProduct,
    
    this.label,
    this.address,
    this.pincode,
    this.latitude,
    this.longitude,
    this.userId,
    this.errorMessage,
    this.warehouse,
  });

  String? get warehouseId => warehouse?.id;

  HomeState copyWith({
    HomeStatus? status,
    
    String? selectedCategory,
    String? selectedBrand,
    String? selectedOffer,
    String? selectedPopularProduct,
    String? label,
    String? address,
    String? pincode,
    double? latitude,
    double? longitude,
    String? userId,
    String? errorMessage,
    Warehouse? warehouse,
  }) {
    return HomeState(
      status: status ?? this.status,
     
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedOffer: selectedOffer ?? this.selectedOffer,
      selectedPopularProduct:
          selectedPopularProduct ?? this.selectedPopularProduct,     
      label: label ?? this.label,
      address: address ?? this.address,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      userId: userId ?? this.userId, 
      errorMessage: errorMessage ?? this.errorMessage,
      warehouse: warehouse ?? this.warehouse,
    );
  }
}
abstract class HomeFlowState {}

class HomeFlowInitial extends HomeFlowState {}

class HomeFlowLoading extends HomeFlowState {}

class HomeFlowSuccess extends HomeFlowState {}

class HomeFlowServiceUnavailable extends HomeFlowState {}

class HomeFlowError extends HomeFlowState {
  final String message;
  HomeFlowError(this.message);
}