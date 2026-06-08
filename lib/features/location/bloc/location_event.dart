import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class LocationEvent {}

/// Event to get current location
class GetCurrentLocationEvent extends LocationEvent {}

/// Event to update location when camera moves
class UpdateLocationEvent extends LocationEvent {
  UpdateLocationEvent({
    required this.latLng,
  });

  final LatLng latLng;
}

///  NEW: Event to search places
class SearchPlacesEvent extends LocationEvent {
  SearchPlacesEvent(this.query);
  final String query;
}

///  NEW: Event to select a place from search results
class SelectPlaceEvent extends LocationEvent {
  SelectPlaceEvent({
    required this.placeId,
    required this.description,
  });

  final String placeId;
  final String description;
}

///  Event to check serviceability (auto-called)
class CheckServiceabilityEvent extends LocationEvent {
  CheckServiceabilityEvent({
    required this.latitude,
    required this.longitude,
    required this.pincode,
    required this.userId,
    this.warehouseId,
  });

  final double latitude;
  final double longitude;
  final String pincode;
  final String userId;
  final String? warehouseId;
}




class FetchNearestStoresEvent extends LocationEvent {
  FetchNearestStoresEvent({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

/// Event to confirm location
class ConfirmLocationEvent extends LocationEvent {
  ConfirmLocationEvent({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.pincode,
  });

  final double latitude;
  final double longitude;
  final String address;
  final String pincode;
}

/// Event to request location permission
class RequestLocationPermissionEvent extends LocationEvent {}

///  NEW: Clear search results
class ClearSearchEvent extends LocationEvent {}
class CheckServiceabilityAddressEvent extends LocationEvent {
  CheckServiceabilityAddressEvent({
    required this.pincode,
    required this.userId,
    this.warehouseId,
  });

  final String pincode;
  final String userId;
  final String? warehouseId;
}