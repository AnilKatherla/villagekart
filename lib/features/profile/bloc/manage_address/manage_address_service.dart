import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import '../../model/manage_address_model.dart';


class AddressService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch all user addresses
  static Future<AddressesResponse> fetchAddresses() async {
    try {
      debugPrint('📍 Fetching addresses...');

      const String addressesEndpoint =
          'addresses';

      final Response response = await _networkService.get(addressesEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final addressesResponse = AddressesResponse.fromJson(response.data);

        debugPrint('✅ Addresses fetched successfully:');
        debugPrint('  Total addresses: ${addressesResponse.data.addresses.length}');

        return addressesResponse;
      } else {
        throw Exception(
            response.data['response'] ?? 'Failed to fetch addresses');
      }
    } on DioException catch (e) {
      debugPrint('❌ Addresses fetch error: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Please login to view addresses');
      } else if (e.response?.statusCode == 404) {
        // Return empty addresses instead of error
        return AddressesResponse(
          status: true,
          response: 'No addresses found',
          data: AddressesData(addresses: []),
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching addresses: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Delete an address
  static Future<DeleteAddressResponse> deleteAddress({
    required String addressId,
  }) async {
    try {
      debugPrint('🗑️ Deleting address:');
      debugPrint('  Address ID: $addressId');

      final String deleteEndpoint =
          'addresses/$addressId';

      final Response response = await _networkService.delete(deleteEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final deleteResponse = DeleteAddressResponse.fromJson(response.data);

        debugPrint('✅ Address deleted successfully');

        return deleteResponse;
      } else {
        throw Exception(
            response.data['response'] ?? 'Failed to delete address');
      }
    } on DioException catch (e) {
      debugPrint('❌ Delete address error: ${e.message}');

      if (e.response?.statusCode == 404) {
        throw Exception('Address not found');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error deleting address: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}