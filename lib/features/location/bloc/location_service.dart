import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/location/bloc/location_state.dart';
import 'package:villag_kart/features/location/model/location_response_model.dart';

class LocationService {
  static NetworkService networkService = ServiceLocator.networkService;

  //  Add your Google Places API key here
  static const String _googlePlacesApiKey =
      'AIzaSyAo4st5l0hHkYEPWqT9G2ht8JxEQJ34rvk';

  /// Get current device location
  static Future<Position?> getCurrentPosition() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get address from coordinates
  static Future<Map<String, String>> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return {'address': 'Unable to fetch address', 'pincode': ''};
      }

      final place = placemarks.first;

      final addressParts = [
        if (place.name != null && place.name!.isNotEmpty) place.name,
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          place.subLocality,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality,
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          place.postalCode,
      ];

      return {
        'address': addressParts.join(', '),
        'pincode': place.postalCode ?? '',
      };
    } catch (e) {
      debugPrint('Error getting address: $e');
      return {'address': 'Unable to fetch address', 'pincode': ''};
    }
  }

  ///  Search places using Google Places Autocomplete API
  static Future<List<PlacePrediction>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      const url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';

      final response = await Dio().get(
        url,
        queryParameters: {
          'input': query,
          'key': _googlePlacesApiKey,
          'components': 'country:in', //  Restrict to India
        },
      );

      if (response.statusCode == 200) {
        // Check for API errors in response body
        final status = response.data['status'] as String?;

        if (status != null && status != 'OK' && status != 'ZERO_RESULTS') {
          debugPrint('❌ Google Places API Error: $status');
          debugPrint(
            '   Error Message: ${response.data['error_message'] ?? 'No error message'}',
          );

          // Common error statuses
          if (status == 'REQUEST_DENIED') {
            debugPrint(
              '   ⚠️  API key might be invalid or missing required permissions',
            );
          } else if (status == 'INVALID_REQUEST') {
            debugPrint('   ⚠️  Invalid request parameters');
          } else if (status == 'OVER_QUERY_LIMIT') {
            debugPrint('   ⚠️  API quota exceeded');
          }

          return [];
        }

        // Check if predictions exist
        if (response.data['predictions'] != null) {
          final predictions = response.data['predictions'] as List;
          debugPrint(
            '✅ Found ${predictions.length} predictions for query: "$query"',
          );
          return predictions
              .map((json) => PlacePrediction.fromJson(json))
              .toList();
        }

        debugPrint('ℹ️  No predictions found for query: "$query"');
        return [];
      }

      debugPrint('❌ HTTP Error: ${response.statusCode}');
      return [];
    } on DioException catch (e) {
      debugPrint('❌ Dio Error searching places: ${e.message}');
      if (e.response != null) {
        debugPrint('   Response data: ${e.response?.data}');
        debugPrint('   Status code: ${e.response?.statusCode}');
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      return [];
    }
  }

  ///  Get place details (lat, lng) from place ID
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      const url = 'https://maps.googleapis.com/maps/api/place/details/json';

      final response = await Dio().get(
        url,
        queryParameters: {
          'place_id': placeId,
          'key': _googlePlacesApiKey,
          'fields': 'geometry,formatted_address,address_components',
        },
      );

      if (response.statusCode == 200) {
        // Check for API errors in response body
        final status = response.data['status'] as String?;

        if (status != null && status != 'OK') {
          debugPrint('❌ Google Places Details API Error: $status');
          debugPrint(
            '   Error Message: ${response.data['error_message'] ?? 'No error message'}',
          );
          return null;
        }

        final result = response.data['result'];
        if (result == null) {
          debugPrint('❌ No result found for place_id: $placeId');
          return null;
        }

        final location = result['geometry']?['location'];
        if (location == null) {
          debugPrint('❌ No location found for place_id: $placeId');
          return null;
        }

        // Extract pincode from address components
        String pincode = '';
        if (result['address_components'] != null) {
          final addressComponents = result['address_components'] as List;
          for (final component in addressComponents) {
            final types = component['types'] as List;
            if (types.contains('postal_code')) {
              pincode = component['long_name'];
              break;
            }
          }
        }

        return {
          'latitude': location['lat'],
          'longitude': location['lng'],
          'address': result['formatted_address'] ?? '',
          'pincode': pincode,
        };
      }

      debugPrint('❌ HTTP Error: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Dio Error getting place details: ${e.message}');
      if (e.response != null) {
        debugPrint('   Response data: ${e.response?.data}');
        debugPrint('   Status code: ${e.response?.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting place details: $e');
      return null;
    }
  }

  // =====================================================
  // SERVICEABILITY + NEAREST STORES
  // =====================================================
  static Future<LocationResponseModel> checkServiceability({
    required double latitude,
    required double longitude,
    required String pincode,
    required String userId,
    String? warehouseId,
  }) async {
    try {
      const endpoint = Endpoints.checkServiceAvailability;

      // final pincodeInt = int.tryParse(pincode);
      // if (pincodeInt == null) {
      //   throw Exception('Invalid pincode');
      // }

      final response = await networkService.post(
        endpoint,
        data: {
          'pincode': pincode,
          'latitude': latitude,
          'longitude': longitude,
          'userId': userId,
          if (warehouseId != null) 'warehouseId': warehouseId,
        },
      );

      final locationResponse = LocationResponseModel.fromJson(response.data);

      // ADD DISTANCE + SORT NEAREST STORES
      if (!locationResponse.data.serviceable) {
        _attachDistanceAndSort(
          latitude,
          longitude,
          locationResponse.data.availableWarehouses ?? [],
        );
      }

      debugPrint('✅ Serviceable: ${locationResponse.data.serviceable}');
      debugPrint('🏬 Warehouse: ${locationResponse.data.warehouse?.name ?? 'N/A'}');

      return locationResponse;
    } catch (e) {
      debugPrint('❌ Serviceability error: $e');
      rethrow;
    }
  }

  static Future<ServiceabilityAddressResponse> checkServiceabilityAddress({
    required String pincode,
    required String userId,
    required String? warehouseId,
  }) async {
    try {
      final response = await networkService.post(
        'check-serviceability',
        data: {
          'pincode': pincode,
          'userId': userId,
          'warehouseId': warehouseId,
        },
      );

      return ServiceabilityAddressResponse.fromJson(response.data);
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  // DISTANCE CALCULATION

  static void _attachDistanceAndSort(
    double userLat,
    double userLng,
    List<Warehouse> warehouses,
  ) {
    for (final w in warehouses) {
      w.distance = _calculateDistance(
        userLat,
        userLng,
        w.location.latitude,
        w.location.longitude,
      );
    }

    warehouses.sort((a, b) => a.distance.compareTo(b.distance));
  }

  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371; // KM
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _degToRad(double deg) => deg * pi / 180;

  // =====================================================
  // PERSIST LOCATION
  // =====================================================
  static Future<Map<String, dynamic>> persistLocation({
    required double latitude,
    required double longitude,
    required String pincode,
    required String address,
  }) async {
    await SharedPrefs.saveUserLocation(
      latitude: latitude,
      longitude: longitude,
      pincode: pincode,
      address: address,
    );

    final saved = await SharedPrefs.getUserLocation();
    if (saved == null) throw Exception('Location not persisted');
    return saved;
  }

  static Future<String> getUserId() async {
    return await SharedPrefs.getUserId() ?? '';
  }

  static Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  static Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  static Future<bool> openLocationSettings() =>
      Geolocator.openLocationSettings();

  static Future<Map<String, dynamic>?> getSavedLocation() =>
      SharedPrefs.getUserLocation();
}
