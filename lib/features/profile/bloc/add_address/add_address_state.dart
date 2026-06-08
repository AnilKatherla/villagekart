
// ============================================================================
// ADD ADDRESS STATES (add_address_state.dart)
// ============================================================================

import '../../model/order_history_model.dart';

abstract class AddAddressState {}

class AddAddressInitial extends AddAddressState {}

class AddAddressLoading extends AddAddressState {}

class AddAddressFormUpdated extends AddAddressState {
  final String? label;
  final String? line1;
  final String? line2;
  final String? city;
  final String? state;
  final String? pincode;
  final double? lat;
  final double? lng;
  final bool isDefault;

  AddAddressFormUpdated({
    this.label,
    this.line1,
    this.line2,
    this.city,
    this.state,
    this.pincode,
    this.lat,
    this.lng,
    required this.isDefault,
  });
}

class AddAddressSaving extends AddAddressState {}

class AddAddressSuccess extends AddAddressState {
  final String message;
  final Address address;

  AddAddressSuccess({
    required this.message,
    required this.address,
  });
}

class AddAddressError extends AddAddressState {
  final String errorMessage;

  AddAddressError({required this.errorMessage});
}

class AddressLocationFetched extends AddAddressState {
  final double lat;
  final double lng;

  AddressLocationFetched({
    required this.lat,
    required this.lng,
  });
}
