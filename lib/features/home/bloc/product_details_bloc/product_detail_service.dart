// features/product_detail/bloc/product_detail_service.dart
import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/product_details_response.dart';

class ProductDetailService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch product details by ID
  static Future<ProductDetailResponse> fetchProductDetail({
    required String productId,
    required String pincode,
  }) async {
    try {
      final endpoint = 'products/$productId';

      final queryParams = {'pincode': pincode};

      final Response response = await _networkService.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final productDetailResponse = ProductDetailResponse.fromJson(
          response.data,
        );

        return productDetailResponse;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch product details',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid product ID or pincode');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
