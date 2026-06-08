

// ============================================================================
// ADD ADDRESS BLOC (add_address_bloc.dart)
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../model/order_history_model.dart';
import 'add_address_event.dart';
import 'add_address_service.dart';
import 'add_address_state.dart';
import 'package:geocoding/geocoding.dart';




// ============================================================================
// ADD ADDRESS BLOC (add_address_bloc.dart)
// ============================================================================



class AddAddressBloc extends Bloc<AddAddressEvent, AddAddressState> {
  String? label;
  String? line1;
  String? line2;
  String? city;
  String? states;
  String? pincode;
  double? lat;
  double? lng;
  bool isDefault = false;
  Address? existingAddress;

  AddAddressBloc() : super(AddAddressInitial()) {
    on<InitializeAddAddress>(_onInitialize);
    on<UpdateAddressField>(_onUpdateField);
    on<UpdateLocation>(_onUpdateLocation);
    on<UpdateLabel>(_onUpdateLabel);
    on<SetDefaultAddress>(_onSetDefault);
    on<SaveAddress>(_onSaveAddress);
    on<FetchLocationFromAddress>(_onFetchLocationFromAddress);
  }

  /// Initialize form (for edit mode)
  Future<void> _onInitialize(
    InitializeAddAddress event,
    Emitter<AddAddressState> emit,
  ) async {
    if (event.existingAddress != null) {
      existingAddress = event.existingAddress;
      label = event.existingAddress!.label;
      line1 = event.existingAddress!.line1;
      line2 = event.existingAddress!.line2;
      city = event.existingAddress!.city;
      states = event.existingAddress!.state;
      pincode = event.existingAddress!.pincode;
      lat = event.existingAddress!.location?.lat;
      lng = event.existingAddress!.location?.lng;
      isDefault = event.existingAddress!.isDefault;
    }

    emit(_formState());
  }

  Future<void> _onUpdateField(
    UpdateAddressField event,
    Emitter<AddAddressState> emit,
  ) async {
    switch (event.field) {
      case 'line1':
        line1 = event.value;
        break;
      case 'line2':
        line2 = event.value;
        break;
      case 'city':
        city = event.value;
        break;
      case 'state':
        states = event.value;
        break;
      case 'pincode':
        pincode = event.value;
        break;
    }

    emit(_formState());
  }

  /// Update location from map
  Future<void> _onUpdateLocation(
    UpdateLocation event,
    Emitter<AddAddressState> emit,
  ) async {
    lat = event.lat;
    lng = event.lng;
    emit(_formState());
  }

  /// Update label (Home, Office, etc.)
  Future<void> _onUpdateLabel(
    UpdateLabel event,
    Emitter<AddAddressState> emit,
  ) async {
    label = event.label;
    emit(_formState());
  }

  /// Set default address
  Future<void> _onSetDefault(
    SetDefaultAddress event,
    Emitter<AddAddressState> emit,
  ) async {
    isDefault = event.isDefault;
    emit(_formState());
  }

  /// Save address
  Future<void> _onSaveAddress(
    SaveAddress event,
    Emitter<AddAddressState> emit,
  ) async {
    emit(AddAddressSaving());

    try {
      // Validate required fields
      if (label == null || label!.isEmpty) {
        throw Exception('Please select an address label (Home, Office, etc.)');
      }
      if (line1 == null || line1!.isEmpty) {
        throw Exception('Please enter flat/house number');
      }
      if (line2 == null || line2!.isEmpty) {
        throw Exception('Please enter street/society name');
      }
      if (city == null || city!.isEmpty) {
        throw Exception('Please enter city');
      }
      if (states == null || states!.isEmpty) {
        throw Exception('Please enter state');
      }
      if (pincode == null || pincode!.isEmpty) {
        throw Exception('Please enter pincode');
      }
      if (lat == null || lng == null) {
        throw Exception('Please select location from map');
      }

      final Address savedAddress;

      if (existingAddress != null && existingAddress!.id.isNotEmpty) {
   //     Update existing address
        savedAddress = await AddAddressService.updateAddress(
          addressId: existingAddress!.id,
          label: label!,
          line1: line1!,
          line2: line2 ?? '',
          city: city!,
          state: states!,
          pincode: pincode ?? '',
          lat: lat!,
          lng: lng!,
          isDefault: isDefault,
        );
      } else {
        // Create new address
        savedAddress = await AddAddressService.createAddress(
          label: label!,
          line1: line1!,
          line2: line2 ?? '',
          city: city!,
          state: states!,
          pincode: pincode ?? '',
          lat: lat!,
          lng: lng!,
          isDefault: isDefault,
        );
      }

      emit(AddAddressSuccess(
        message: 'Address saved successfully',
        address: savedAddress,
      ));
    } catch (e) {
      emit(AddAddressError(errorMessage: e.toString()));
    }
  }


  Future<void> _onFetchLocationFromAddress(
    FetchLocationFromAddress event,
    Emitter<AddAddressState> emit,
  ) async {
    try {
      final locations = await locationFromAddress(event.fullAddress);

      if (locations.isNotEmpty) {
        final loc = locations.first;

        lat = loc.latitude;
        lng = loc.longitude;

        // send to UI
        emit(AddressLocationFetched(lat: lat!, lng: lng!));

        // keep form in sync
        emit(_formState());
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  AddAddressFormUpdated _formState() {
    return AddAddressFormUpdated(
      label: label,
      line1: line1,
      line2: line2,
      city: city,
      state: states,
      pincode: pincode,
      lat: lat,
      lng: lng,
      isDefault: isDefault,
    );
  }
}
