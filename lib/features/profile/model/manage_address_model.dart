// ============================================================================
// USE YOUR EXISTING ADDRESS MODEL FROM order_history_model.dart
// DO NOT CREATE A NEW address_model.dart FILE
// ============================================================================

// Your existing Address model from order_history_model.dart is PERFECT!
// It already has:
// - id
// - label
// - line1
// - line2
// - city
// - state
// - pincode
// - location
// - isDefault

// Just add these helper methods to your EXISTING Address class:

// ADD THIS TO YOUR EXISTING Address CLASS in order_history_model.dart:

/*
extension AddressHelpers on Address {
  // Get full address for display
  String get fullAddress =>
      '$line1, $line2,\n$city, $state $pincode';

  // Get short address for display
  String get shortAddress =>
      '$line1, $line2, $city, $state $pincode';
}
*/

// ============================================================================
// RESPONSES FOR ADDRESS API (add_to_your_existing_order_model.dart)
// ============================================================================

import 'order_history_model.dart';

class AddressesResponse {
  final bool status;
  final String response;
  final AddressesData data;

  AddressesResponse({
    required this.status,
    required this.response,
    required this.data,
  });

  factory AddressesResponse.fromJson(Map<String, dynamic> json) {
    return AddressesResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
      data: AddressesData.fromJson(json['data'] ?? {}),
    );
  }
}

class AddressesData {
  final List<Address> addresses;

  AddressesData({required this.addresses});

  factory AddressesData.fromJson(Map<String, dynamic> json) {
    return AddressesData(
      addresses: (json['addresses'] as List?)
              ?.map((e) => Address.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class DeleteAddressResponse {
  final bool status;
  final String response;

  DeleteAddressResponse({
    required this.status,
    required this.response,
  });

  factory DeleteAddressResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAddressResponse(
      status: json['status'] ?? false,
      response: json['response'] ?? '',
    );
  }
}

