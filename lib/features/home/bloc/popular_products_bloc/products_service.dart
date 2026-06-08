import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/popular_product_model.dart';

class PopularProductsService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static const String _popularProductsEndpoint = 'products/popular';
  static const String _searchProductsEndpoint = 'products';

  /// Fetch popular products
  static Future<PopularProductsResponse> fetchPopularProducts({
    required String pincode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📦 Fetching popular products for:');
      debugPrint('  Pincode: $pincode');
      debugPrint('  Page: $page, Limit: $limit');

      final queryParams = {
        'pincode': pincode,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final Response response = await _networkService.get(
        _popularProductsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final popularProductsResponse = PopularProductsResponse.fromJson(
          response.data,
        );

        debugPrint('✅ Popular products fetched successfully:');
        debugPrint(
          'Total products: ${popularProductsResponse.data.products.length}',
        );
        debugPrint(
          '  Serviceable: ${popularProductsResponse.data.serviceable}',
        );

        return popularProductsResponse;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch popular products',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Popular products fetch error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid pincode');
      } else if (e.response?.statusCode == 404) {
        throw Exception('No popular products found for this location');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching popular products: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Search products by query
  static Future<PopularProductsResponse> searchProducts({
    required String pincode,
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('🔍 Searching products:');
      debugPrint('  Pincode: $pincode');
      debugPrint('  Query: $query');
      debugPrint('  Page: $page, Limit: $limit');

      final queryParams = {
        'pincode': pincode,
        'query': query,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final Response response = await _networkService.get(
        _searchProductsEndpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final searchResponse = PopularProductsResponse.fromJson(response.data);

        debugPrint('✅ Search completed successfully:');
        debugPrint('  Total products found: ${searchResponse.data.products.length}');
        debugPrint('  Serviceable: ${searchResponse.data.serviceable}');

        return searchResponse;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to search products',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Search error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid request parameters');
      } else if (e.response?.statusCode == 404) {
        throw Exception('No products found matching your search');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error searching products: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
