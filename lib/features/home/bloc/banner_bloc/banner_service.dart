import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/home/model/banner_model.dart';

class BannerService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static const String _bannerEndpoint = 'banner';

  /// Fetch banners (ONLY imageUrl)
  static Future<List<BannerModel>> fetchBanners() async {
    try {
      debugPrint('🖼️ Fetching banners...');

      final Response response = await _networkService.get(
        _bannerEndpoint,
        queryParameters: {
          'section': 'Home Page Banner',
          'isActive': true,
          'warehouseId': await SharedPrefs.getWarehouseId(),
        },
      );

      debugPrint('📡 Banner API Status: ${response.statusCode}');
      debugPrint('📡 Banner API Data: ${response.data}');

      if (response.statusCode == null) {
        throw Exception('Failed to fetch banners');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        try {
          final List data = response.data['data'] ?? [];

          final banners = data
              .map((e) => BannerModel.fromJson(e))
              .where((b) => b.imageUrl.isNotEmpty)
              .toList();

          debugPrint('✅ Banners fetched: ${banners.length}');
          return banners;
        } catch (e) {
          debugPrint('❌ Banner parsing error: $e');
          throw Exception('Failed to parse banner data');
        }
      } else {
        final errorMessage = response.data is Map
            ? (response.data['message'] ?? 'Failed to fetch banners')
            : 'Failed to fetch banners';
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ Banner DioException: ${e.message}');
      debugPrint('❌ Status Code: ${e.response?.statusCode}');
      debugPrint('❌ Response: ${e.response?.data}');

      if (e.response != null) {
        final responseData = e.response!.data;
        final errorMsg = responseData is Map
            ? (responseData['message'] ?? 'Failed to fetch banners')
            : 'Failed to fetch banners';
        throw Exception(errorMsg);
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Something went wrong. Please try again.');
      }
    } catch (e) {
      debugPrint('❌ Banner fetch error: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong');
    }
  }
}
