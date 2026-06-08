// ============================================================================
// UPDATED ADDRESS EVENTS (address_events.dart)
// ============================================================================

import 'package:villag_kart/features/profile/model/order_history_model.dart';

abstract class AddressEvent {}

class FetchAddresses extends AddressEvent {}

class RefreshAddresses extends AddressEvent {}

class DeleteAddress extends AddressEvent {
  final String addressId;

  DeleteAddress({required this.addressId});
}

class SelectAddress extends AddressEvent {
  final Address address;

  SelectAddress({required this.address});
}