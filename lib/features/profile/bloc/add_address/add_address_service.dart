// ============================================================================
// ADD ADDRESS SERVICE (add_address_service.dart)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../../model/order_history_model.dart';


class AddAddressService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Create a new address
  static Future<Address> createAddress({
    required String label,
    required String line1,
    required String line2,
    required String city,
    required String state,
    required String pincode,
    required double lat,
    required double lng,
    required bool isDefault,
  }) async {
    try {
      debugPrint('📍 Creating address...');
      debugPrint('  Label: $label');
      debugPrint('  City: $city');
      debugPrint('  Pincode: $pincode');

      const String createEndpoint =
          'addresses';

      final Map<String, dynamic> payload = {
        'label': label,
        'line1': line1,
        'line2': line2,
        'city': city,
        'state': state,
        'pincode': pincode,
        'location': {
          'lat': lat,
          'lng': lng,
        },
        'isDefault': isDefault,
      };

      debugPrint('📤 Payload: $payload');

      final Response response = await _networkService.post(
        createEndpoint,
        data: payload,
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('✅ Address created successfully');
        debugPrint('Response: ${response.data}');

        // Parse the response - adjust based on actual API response structure
        final addressData = response.data['data'] ?? response.data;
        final address = Address.fromJson(addressData);

        return address;
      } else {
        throw Exception(
            response.data['response'] ?? 'Failed to create address');
      }
    } on DioException catch (e) {
      debugPrint('❌ Address creation error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid address data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Please login to add address');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error creating address: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Update an existing address (if API supports)
 static Future<Address> updateAddress({
  required String addressId,
  required String label,
  required String line1,
  required String line2,
  required String city,
  required String state,
  required String pincode,
  required double lat,
  required double lng,
  required bool isDefault,
}) async {
  try {
    debugPrint('📍 Updating address...');
    debugPrint('  Address ID: $addressId');

    final String updateEndpoint =
        'addresses/$addressId';

    final Map<String, dynamic> payload = {
      'label': label,
      'line1': line1,
      'line2': line2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'location': {
        'lat': lat,
        'lng': lng,
      },
      'isDefault': isDefault,
    };

    debugPrint('📤 Update Payload: $payload');

    final Response response = await _networkService.patch(
      updateEndpoint,
      data: payload,
    );

    if (response.statusCode == null) {
      throw Exception('Somethng went wrong. Please try again later');
    }

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      debugPrint('✅ Address updated successfully');
      debugPrint('Response: ${response.data}');

      final addressData = response.data['data'] ?? response.data;
      return Address.fromJson(addressData);
    } else {
      throw Exception(
          response.data['response'] ?? 'Failed to update address');
    }
  } on DioException catch (e) {
    debugPrint('❌ Address update error: ${e.message}');
    debugPrint('❌ Status Code: ${e.response?.statusCode}');
    debugPrint('❌ Response: ${e.response?.data}');

    if (e.response?.statusCode == 404) {
      throw Exception('Address not found');
    } else if (e.response?.statusCode == 401) {
      throw Exception('Please login again');
    } else {
      throw Exception('Somethng went wrong. Please try again later');
    }
  }
}
}
