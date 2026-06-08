import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/category_model.dart';

class CategoryService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  // static Future<CategoryResponse> fetchCategories({
  //   required String pincode,
  // }) async {
  //   try {
  //     debugPrint('📦 Fetching categories for pincode: $pincode');

  //     // ✅ GET with query parameter instead of POST with body
  //     final Response response = await _networkService.get(
  //       _categoriesEndpoint,
  //       queryParameters: {'pincode': pincode},
  //     );

  //     if (response.statusCode == null) {
  //       throw Exception('Somethng went wrong. Please try again later');
  //     }

  //     if (response.statusCode! >= 200 && response.statusCode! < 300) {
  //       if (response.data == null) {
  //         throw Exception('Empty response from server.');
  //       }

  //       if (response.data is! Map<String, dynamic>) {
  //         throw Exception('Unexpected response format.');
  //       }

  //       final categoryResponse = CategoryResponse.fromJson(
  //         response.data as Map<String, dynamic>,
  //       );

  //       debugPrint('✅ Categories fetched successfully:');
  //       debugPrint(
  //         '  Total categories: ${categoryResponse.data?.categories.length ?? 0}',
  //       );
  //       debugPrint('  Serviceable: ${categoryResponse.data?.serviceable}');

  //       return categoryResponse;
  //     } else {
  //       throw Exception(
  //         response.data['message'] ?? 'Failed to fetch categories',
  //       );
  //     }
  //   } on DioException catch (e) {
  //     debugPrint('❌ Category fetch DioException:');
  //     debugPrint('  Status: ${e.response?.statusCode}');
  //     debugPrint('  Message: ${e.message}');
  //     debugPrint('  Response: ${e.response?.data}');

  //     if (e.response?.statusCode == 400) {
  //       throw Exception(
  //         e.response?.data?['message'] ?? 'Invalid location data',
  //       );
  //     } else if (e.response?.statusCode == 404) {
  //       throw Exception('No categories found for this location');
  //     } else if (e.type == DioExceptionType.connectionTimeout) {
  //       throw Exception('Connection timeout. Please try again.');
  //     } else {
  //       throw Exception('Somethng went wrong. Please try again later');
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Error fetching categories: $e');
  //     if (e is Exception) rethrow;
  //     throw Exception('Something went wrong. Please try again.');
  //   }
  // }
  static Future<CategoryResponse> fetchCategories({
    required String pincode,
    int retryCount = 0,
  }) async {
    const maxRetries = 2;

    try {
      debugPrint(
        '📦 Fetching categories for pincode: $pincode (attempt ${retryCount + 1})',
      );

      final Response response = await _networkService.get(
        Endpoints.categories(pinCode: pincode),
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        if (response.data == null)
          throw Exception('Empty response from server.');
        if (response.data is! Map<String, dynamic>)
          throw Exception('Unexpected response format.');

        final categoryResponse = CategoryResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return categoryResponse;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch categories',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ Category fetch DioException (attempt ${retryCount + 1}): ${e.type}',
      );

      // ✅ Retry on timeout or connection errors
      final isRetryable =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError;

      if (isRetryable && retryCount < maxRetries) {
        debugPrint('🔄 Retrying... (${retryCount + 1}/$maxRetries)');
        await Future.delayed(
          Duration(seconds: retryCount + 1),
        ); // wait 1s, then 2s
        return fetchCategories(pincode: pincode, retryCount: retryCount + 1);
      }

      if (e.response?.statusCode == 400) {
        throw Exception(
          e.response?.data?['message'] ?? 'Invalid location data',
        );
      } else if (e.response?.statusCode == 404) {
        throw Exception('No categories found for this location');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching categories: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
