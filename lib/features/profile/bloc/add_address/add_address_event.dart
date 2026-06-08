// ============================================================================
// ADD ADDRESS EVENTS (add_address_events.dart)
// ============================================================================


import '../../model/order_history_model.dart';

abstract class AddAddressEvent {}

class InitializeAddAddress extends AddAddressEvent {
  final Address? existingAddress; // For edit mode

  InitializeAddAddress({this.existingAddress});
}

class UpdateAddressField extends AddAddressEvent {
  final String field;
  final String value;

  UpdateAddressField({required this.field, required this.value});
}

class UpdateLocation extends AddAddressEvent {
  final double lat;
  final double lng;

  UpdateLocation({required this.lat, required this.lng});
}

class UpdateLabel extends AddAddressEvent {
  final String label;

  UpdateLabel({required this.label});
}

class SetDefaultAddress extends AddAddressEvent {
  final bool isDefault;

  SetDefaultAddress({required this.isDefault});
}

class SaveAddress extends AddAddressEvent {
  final Address addressData;

  SaveAddress({required this.addressData});
}

class FetchLocationFromAddress extends AddAddressEvent {
  final String fullAddress;

  FetchLocationFromAddress({required this.fullAddress});
}

