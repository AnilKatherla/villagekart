import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/location/bloc/location_event.dart';
import 'package:villag_kart/features/location/bloc/location_service.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  LocationBloc() : super(LocationInitialState()) {
    on<GetCurrentLocationEvent>(_handleGetCurrentLocation);
    on<UpdateLocationEvent>(_handleUpdateLocation);
    on<SearchPlacesEvent>(_handleSearchPlaces);
    on<SelectPlaceEvent>(_handleSelectPlace);
    on<CheckServiceabilityEvent>(_handleCheckServiceability);
    on<ConfirmLocationEvent>(_handleConfirmLocation);
    on<CheckServiceabilityAddressEvent>(_handleCheckServiceabilityAddress);
    on<RequestLocationPermissionEvent>(_handleRequestPermission);
    on<ClearSearchEvent>(_handleClearSearch);
  }

  Timer? _debounceTimer;

  /// Get current location
  Future<void> _handleGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());

    try {
      final position = await LocationService.getCurrentPosition();

      if (position == null) {
        emit(LocationErrorState('Unable to get current location'));
        return;
      }

      final addressData = await LocationService.getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      final latLng = LatLng(position.latitude, position.longitude);

      if (!emit.isDone) {
        emit(
          LocationFetchedState(
            latLng: latLng,
            address: addressData['address'] ?? 'Unknown location',
            pincode: addressData['pincode'] ?? '',
          ),
        );

        // Scenario 1: Auto-check serviceability
        if (addressData['pincode']!.isNotEmpty) {
          add(
            CheckServiceabilityEvent(
              latitude: position.latitude,
              longitude: position.longitude,
              pincode: addressData['pincode']!,
              userId: await LocationService.getUserId(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Get current location error: $e');
      if (!emit.isDone) {
        emit(LocationErrorState(e.toString().replaceAll('Exception: ', '')));
      }
    }
  }

  /// Update location when camera moves
  Future<void> _handleUpdateLocation(
    UpdateLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      _debounceTimer?.cancel();

      final completer = Completer<void>();

      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        completer.complete();
      });

      await completer.future;

      final addressData = await LocationService.getAddressFromCoordinates(
        latitude: event.latLng.latitude,
        longitude: event.latLng.longitude,
      );

      if (!emit.isDone) {
        emit(
          LocationUpdatedState(
            latLng: event.latLng,
            address: addressData['address'] ?? 'Unknown location',
            pincode: addressData['pincode'] ?? '',
          ),
        );

        // Auto-check serviceability when pincode is available
        if ((addressData['pincode'] ?? '').isNotEmpty) {
          add(
            CheckServiceabilityEvent(
              latitude: event.latLng.latitude,
              longitude: event.latLng.longitude,
              pincode: addressData['pincode']!,
              userId: await LocationService.getUserId(),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Update location error: $e');
    }
  }

  ///  Search places
  Future<void> _handleSearchPlaces(
    SearchPlacesEvent event,
    Emitter<LocationState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // Return to previous location state
      return;
    }

    try {
      final predictions = await LocationService.searchPlaces(event.query);

      // Get current location from previous state
      LatLng currentLatLng = const LatLng(0, 0);
      String currentAddress = '';
      String currentPincode = '';

      if (state is LocationFetchedState) {
        final s = state as LocationFetchedState;
        currentLatLng = s.latLng;
        currentAddress = s.address;
        currentPincode = s.pincode;
      } else if (state is LocationUpdatedState) {
        final s = state as LocationUpdatedState;
        currentLatLng = s.latLng;
        currentAddress = s.address;
        currentPincode = s.pincode;
      } else if (state is ServiceableLocationState) {
        final s = state as ServiceableLocationState;
        currentLatLng = s.latLng;
        currentAddress = s.address;
        currentPincode = s.pincode;
      } else if (state is NonServiceableLocationState) {
        final s = state as NonServiceableLocationState;
        currentLatLng = s.latLng;
        currentAddress = s.address;
        currentPincode = s.pincode;
      }

      if (!emit.isDone) {
        emit(
          SearchResultsState(
            predictions: predictions,
            currentLatLng: currentLatLng,
            currentAddress: currentAddress,
            currentPincode: currentPincode,
          ),
        );
      }
    } catch (e) {
      debugPrint('Search places error: $e');
    }
  }

  ///  Select place from search results
  Future<void> _handleSelectPlace(
    SelectPlaceEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());

    try {
      final placeDetails = await LocationService.getPlaceDetails(event.placeId);

      if (placeDetails == null) {
        emit(LocationErrorState('Unable to get place details'));
        return;
      }

      final lat = placeDetails['latitude'];
      final lng = placeDetails['longitude'];

      final latLng = LatLng(lat, lng);

      String? pincode = placeDetails['pincode'];

      if (pincode == null || pincode.isEmpty) {
        final placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isNotEmpty) {
          pincode = placemarks.first.postalCode ?? '';
        }
      }

      if (!emit.isDone) {
        emit(
          PlaceSelectedState(
            latLng: latLng,
            address: placeDetails['address'],
            pincode: pincode ?? '',
          ),
        );
      }

      if (pincode != null && pincode.isNotEmpty) {
        add(
          CheckServiceabilityEvent(
            latitude: lat,
            longitude: lng,
            pincode: pincode,
            userId: await LocationService.getUserId(),
          ),
        );
      } else {
        emit(LocationErrorState('Service not available: Pincode not found'));
      }
    } catch (e) {
      debugPrint('Select place error: $e');
      if (!emit.isDone) {
        emit(LocationErrorState('Failed to select location'));
      }
    }
  }

  ///  Check serviceability
  Future<void> _handleCheckServiceability(
    CheckServiceabilityEvent event,
    Emitter<LocationState> emit,
  ) async {
    // Show checking state with current location data
    emit(
      CheckingServiceabilityState(
        latLng: LatLng(event.latitude, event.longitude),
        address: '', // Will be filled from previous state
        pincode: event.pincode,
      ),
    );

    try {
      final locationResponse = await LocationService.checkServiceability(
        latitude: event.latitude,
        longitude: event.longitude,
        pincode: event.pincode,
        userId: event.userId,
        warehouseId: event.warehouseId,
      );

      final addressData = await LocationService.getAddressFromCoordinates(
        latitude: event.latitude,
        longitude: event.longitude,
      );

      final latLng = LatLng(event.latitude, event.longitude);

      if (locationResponse.data.serviceable &&
          locationResponse.data.warehouse != null) {
        await SharedPrefs.saveWarehouse(locationResponse.data.warehouse!);

        emit(
          ServiceableLocationState(
            locationResponse: locationResponse,
            latLng: latLng,
            address: addressData['address'] ?? '',
            pincode: event.pincode,
          ),
        );
      } else {
        emit(
          NonServiceableLocationState(
            message: locationResponse.data.reason,
            latLng: latLng,
            address: addressData['address'] ?? '',
            pincode: event.pincode,
            availableWarehouses:
                locationResponse.data.availableWarehouses ?? [],
          ),
        );
      }
    } catch (e) {
      emit(
        NonServiceableLocationState(
          message: e.toString(),
          latLng: LatLng(event.latitude, event.longitude),
          address: '',
          pincode: event.pincode,
          availableWarehouses: const [],
        ),
      );
    }
  }

  /// Confirm location
  Future<void> _handleConfirmLocation(
    ConfirmLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    LocationResponseModel? locationResponse;

    if (state is ServiceableLocationState) {
      locationResponse = (state as ServiceableLocationState).locationResponse;
    }

    final userLocation = UserLocation(
      latitude: event.latitude,
      longitude: event.longitude,
      address: event.address,
      pincode: event.pincode,
    );

    await LocationService.persistLocation(
      latitude: event.latitude,
      longitude: event.longitude,
      pincode: event.pincode,
      address: event.address,
    );

    if (!emit.isDone && locationResponse != null) {
      emit(
        LocationConfirmedState(
          userLocation: userLocation,
          locationResponse: locationResponse,
        ),
      );
    }
  }

  /// Request location permission
  Future<void> _handleRequestPermission(
    RequestLocationPermissionEvent event,
    Emitter<LocationState> emit,
  ) async {
    try {
      var permission = await LocationService.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await LocationService.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        if (!emit.isDone) {
          emit(LocationPermissionGrantedState());
        }
        add(GetCurrentLocationEvent());
      } else {
        if (!emit.isDone) {
          emit(LocationPermissionDeniedState());
        }
      }
    } catch (e) {
      debugPrint('Request permission error: $e');
      if (!emit.isDone) {
        emit(LocationErrorState('Failed to get location permission'));
      }
    }
  }

  ///  Clear search results
  Future<void> _handleClearSearch(
    ClearSearchEvent event,
    Emitter<LocationState> emit,
  ) async {
    // Don't emit GetCurrentLocationEvent as it causes full screen rebuild
    // Just return to the previous location state without rebuilding
    if (state is ServiceableLocationState) {
      emit(state as ServiceableLocationState);
    } else if (state is NonServiceableLocationState) {
      emit(state as NonServiceableLocationState);
    } else if (state is LocationUpdatedState) {
      emit(state as LocationUpdatedState);
    } else if (state is LocationFetchedState) {
      emit(state as LocationFetchedState);
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  Future<void> _handleCheckServiceabilityAddress(
    CheckServiceabilityAddressEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoadingState());

    try {
      final response = await LocationService.checkServiceabilityAddress(
        pincode: event.pincode,
        userId: event.userId,
        warehouseId: event.warehouseId,
      );

      emit(
        AddressServiceabilityState(
          serviceable: response.serviceable,
          message: response.reason,
          pincode: event.pincode,
        ),
      );
    } catch (e) {
      emit(
        AddressServiceabilityState(
          serviceable: false,
          message: e.toString(),
          pincode: event.pincode,
        ),
      );
    }
  }
}
