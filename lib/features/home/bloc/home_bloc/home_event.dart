// No part-of directive here - this is a standalone file


import 'package:villag_kart/features/location/model/location_response_model.dart';

abstract class HomeEvent {
  const HomeEvent();
}

class HomeInitialized extends HomeEvent {
  const HomeInitialized();
}

class CategorySelected extends HomeEvent {
  final String categoryName;
  const CategorySelected(this.categoryName);
}

class LocationTapped extends HomeEvent {
  const LocationTapped();
}
class UpdateHomeLocation extends HomeEvent {

  const UpdateHomeLocation({
    required this.address,
    required this.pincode,
    required this.latitude,
    required this.longitude,
    required this.label,
    this.warehouse,
  });
  final String address;
  final String label;
  final String pincode;
  final double latitude;
  final double longitude;
  final Warehouse? warehouse; 
}

class SeeAllTapped extends HomeEvent {
  final String section;
  const SeeAllTapped(this.section);
}

class BrandTapped extends HomeEvent {
  final String brandName;
  const BrandTapped(this.brandName);
}

class OfferTapped extends HomeEvent {
  final String productName;
  const OfferTapped(this.productName);
}

class PopularProductTapped extends HomeEvent {
  final String productName;
  const PopularProductTapped(this.productName);
}

class SuggestionTapped extends HomeEvent {
  const SuggestionTapped();
}