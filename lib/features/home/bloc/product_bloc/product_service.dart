// product_service.dart
import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/product_response.dart';

class ProductService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static Future<ProductResponse> fetchProductsByCategory({
    required String categoryId,
    required String pincode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final endpoint = '/products/category/$categoryId';
      final Response response = await _networkService.get(
        endpoint,
        queryParameters: {'pincode': pincode, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return ProductResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Somethng went wrong. Please try again later');
    } catch (e) {
      throw Exception('Failed to fetch products');
    }
  }

  static Future<ProductResponse> fetchProductsBySubCategory({
    required String subCategoryId,
    required String pincode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final endpoint = 'products/subcategory/$subCategoryId';

      final Response response = await _networkService.get(
        endpoint,
        queryParameters: {'pincode': pincode, 'page': page, 'limit': limit},
      );

      if (response.statusCode == 200) {
        return ProductResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch products');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Somethng went wrong. Please try again later');
    } catch (e) {
      throw Exception('Failed to fetch products');
    }
  }
}
