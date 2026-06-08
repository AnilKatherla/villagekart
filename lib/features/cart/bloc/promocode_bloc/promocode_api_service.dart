import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/cart/model/promocode_model.dart';

class PromoCodeService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch coupons by pincode
  /// GET /api/v1/coupons?pincode={pincode}
  static Future<Map<String, List<CouponModel>>> fetchCoupons(
    String pincode,
  ) async {
    try {
      final Response response = await _networkService.get(
        'coupons',
        queryParameters: {'pincode': pincode},
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to fetch coupons');
      }

      final data = response.data['data'];

      final personalized = (data['personalized'] as List? ?? [])
          .map((e) => CouponModel.fromJson(e))
          .toList();

      final global = (data['global'] as List? ?? [])
          .map((e) => CouponModel.fromJson(e))
          .toList();

      return {'personalized': personalized, 'global': global};
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Failed to fetch coupons',
      );
    } catch (e) {
      throw Exception('Failed to fetch coupons');
    }
  }
}
