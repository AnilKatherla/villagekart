// subcategory_service.dart
import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/subcategory_model.dart';

class SubCategoryService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static Future<SubCategoryResponse> fetchSubCategories({
    required String categoryId,
    required String pincode,
  }) async {
    try {
      const endpoint = 'subcategories';
      final Response response = await _networkService.get(
        endpoint,
        queryParameters: {'pincode': pincode, 'categoryId': categoryId},
      );

      if (response.statusCode == 200) {
        return SubCategoryResponse.fromJson(response.data);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to fetch subcategories',
        );
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Somethng went wrong. Please try again later');
    } catch (e) {
      throw Exception('Failed to fetch subcategories');
    }
  }
}
