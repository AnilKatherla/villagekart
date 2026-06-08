// ============================================================================
// UPDATED ADDRESS STATES (address_state.dart)
// ============================================================================

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../model/order_history_model.dart';

abstract class AddressState {}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressLoaded extends AddressState {
  final List<Address> addresses;

  AddressLoaded({required this.addresses});
}

class AddressRefreshing extends AddressState {
  final List<Address> addresses;

  AddressRefreshing({required this.addresses});
}

class AddressEmpty extends AddressState {
  final String message;

  AddressEmpty({required this.message});
}

class AddressDeleting extends AddressState {
  final List<Address> addresses;
  final String deletingAddressId;

  AddressDeleting({
    required this.addresses,
    required this.deletingAddressId,
  });
}

class AddressDeleted extends AddressState {
  final List<Address> addresses;
  final String message;

  AddressDeleted({
    required this.addresses,
    required this.message,
  });
}

class AddressSelected extends AddressState {
  final Address address;
  final LatLng? latLng;

  AddressSelected({
    required this.address,
    this.latLng,
  });
}

class AddressError extends AddressState {
  final String errorMessage;

  AddressError({required this.errorMessage});
}