import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/brands_model.dart';

class BrandsService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static const String _brandsEndpoint = 'brands';

  /// Fetch brands
  static Future<BrandsResponse> fetchBrands({
    required String pincode,
    required double latitude,
    required double longitude,
    required String userId,
  }) async {
    try {
      debugPrint('🏷️ Fetching brands for:');
      debugPrint('  Pincode: $pincode');
      debugPrint('  Lat: $latitude, Lng: $longitude');
      debugPrint('  UserID: $userId');

      final queryParams = {
        'pincode': pincode,
      };

      final Response response = await _networkService.get(
        _brandsEndpoint,
        queryParameters: queryParams,
      );

      debugPrint('📡 Brands API Response Status: ${response.statusCode}');
      debugPrint('📡 Brands API Response Data: ${response.data}');

      if (response.statusCode == null) {
        throw Exception('Failed to fetch brands.');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        try {
          final brandsResponse = BrandsResponse.fromJson(response.data);
          
          debugPrint('✅ Brands fetched successfully:');
          debugPrint('  Success: ${brandsResponse.success}');
          debugPrint('  Total brands: ${brandsResponse.data.brands.length}');
          debugPrint('  Serviceable: ${brandsResponse.data.serviceable}');
          debugPrint('  Message: ${brandsResponse.message}');
          
          return brandsResponse;
        } catch (e) {
          debugPrint('❌ Error parsing brands response: $e');
          debugPrint('❌ Response data type: ${response.data.runtimeType}');
          debugPrint('❌ Response data: ${response.data}');
          throw Exception('Failed to parse brands data: $e');
        }
      } else {
        final errorMessage = response.data is Map 
            ? (response.data['message'] ?? 'Failed to fetch brands')
            : 'Failed to fetch brands';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ Brands fetch DioException:');
      debugPrint('  Type: ${e.type}');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Status Code: ${e.response?.statusCode}');
      debugPrint('  Response Data: ${e.response?.data}');
      
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        if (statusCode == 400) {
          final errorMsg = responseData is Map 
              ? (responseData['message'] ?? 'Invalid location data')
              : 'Invalid location data';
          throw Exception(errorMsg);
        } else if (statusCode == 404) {
          final errorMsg = responseData is Map 
              ? (responseData['message'] ?? 'No brands found for this location')
              : 'No brands found for this location';
          throw Exception(errorMsg);
        } else {
          final errorMsg = responseData is Map 
              ? (responseData['message'] ?? 'Failed to fetch brands')
              : 'Failed to fetch brands';
          throw Exception(errorMsg);
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Error fetching brands: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}