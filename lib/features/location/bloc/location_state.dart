import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart';

abstract class LocationState {}

class LocationInitialState extends LocationState {}

class LocationLoadingState extends LocationState {}

/// ===============================
/// LOCATION FETCHED
/// ===============================
class LocationFetchedState extends LocationState {
  LocationFetchedState({
    required this.latLng,
    required this.address,
    required this.pincode,
  });

  final LatLng latLng;
  final String address;
  final String pincode;
}

/// ===============================
/// LOCATION UPDATED (MAP MOVE)
/// ===============================
class LocationUpdatedState extends LocationState {
  LocationUpdatedState({
    required this.latLng,
    required this.address,
    required this.pincode,
  });

  final LatLng latLng;
  final String address;
  final String pincode;
}

/// ===============================
/// SEARCH RESULTS
/// ===============================
class SearchResultsState extends LocationState {
  SearchResultsState({
    required this.predictions,
    required this.currentLatLng,
    required this.currentAddress,
    required this.currentPincode,
  });

  final List<PlacePrediction> predictions;
  final LatLng currentLatLng;
  final String currentAddress;
  final String currentPincode;
}

/// ===============================
/// PLACE PREDICTION MODEL
/// ===============================
class PlacePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: json['structured_formatting']?['main_text'] ?? '',
      secondaryText: json['structured_formatting']?['secondary_text'] ?? '',
    );
  }
}

/// ===============================
/// PLACE SELECTED
/// ===============================
class PlaceSelectedState extends LocationState {
  PlaceSelectedState({
    required this.latLng,
    required this.address,
    required this.pincode,
  });

  final LatLng latLng;
  final String address;
  final String pincode;
}

/// ===============================
/// CHECKING SERVICEABILITY
/// ===============================
class CheckingServiceabilityState extends LocationState {
  CheckingServiceabilityState({
    required this.latLng,
    required this.address,
    required this.pincode,
  });

  final LatLng latLng;
  final String address;
  final String pincode;
}

/// ===============================
/// SERVICEABLE LOCATION
/// ===============================
class ServiceableLocationState extends LocationState {
  ServiceableLocationState({
    required this.locationResponse,
    required this.latLng,
    required this.address,
    required this.pincode,
    this.warehouseId
  });

  final LocationResponseModel locationResponse;
  final LatLng latLng;
  final String address;
  final String pincode;
  final String? warehouseId;
}

/// ===============================
/// ❌ NON-SERVICEABLE LOCATION (UPDATED)
/// ===============================
class NonServiceableLocationState extends LocationState {
  NonServiceableLocationState({
    required this.message,
    required this.latLng,
    required this.address,
    required this.pincode,
    required this.availableWarehouses,
  });

  final String message;
  final LatLng latLng;
  final String address;
  final String pincode;

  ///  Nearest / Available stores
  final List<Warehouse> availableWarehouses;
}

/// ===============================
/// LOCATION CONFIRMED
/// ===============================
class LocationConfirmedState extends LocationState {
  LocationConfirmedState({
    required this.userLocation,
    required this.locationResponse,
  });

  final UserLocation userLocation;
  final LocationResponseModel locationResponse;
}

/// ===============================
/// ERROR & PERMISSION STATES
/// ===============================
class LocationErrorState extends LocationState {
  LocationErrorState(this.error);
  final String error;
}
class NearbySellersLoadingState extends LocationState {}

class NearbySellersLoadedState extends LocationState {
   NearbySellersLoadedState({required this.stores, this.total = 0});
  final List<StoreModel> stores;
  final int total;

  @override
  List<Object?> get props => [stores, total];
}
class NearbySellersErrorState extends LocationState {
   NearbySellersErrorState(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
class LocationPermissionDeniedState extends LocationState {}

class LocationPermissionGrantedState extends LocationState {}

class AddressServiceabilityState extends LocationState {
  final bool serviceable;
  final String message;
  final String pincode;

  AddressServiceabilityState({
    required this.serviceable,
    required this.message,
    required this.pincode,
  });
}
