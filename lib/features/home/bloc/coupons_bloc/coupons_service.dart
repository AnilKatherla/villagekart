import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/coupons_model.dart';

class CouponsService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch coupons for user
  static Future<CouponsResponse> fetchCoupons({
   
    required String pincode,
    required double cartValue,
  }) async {
    try {
      debugPrint('🎫 Fetching coupons for:');
     // debugPrint('  UserID: $userId');
      debugPrint('  Pincode: $pincode');
      debugPrint('  Cart Value: $cartValue');

      const String endpoint = 'coupons';

      final queryParams = {
       
        'pincode': pincode,
        'cartValue': cartValue.toString(),
      };

      final Response response = await _networkService.get(
        endpoint,
        queryParameters: queryParams,
      );

      if (response.statusCode == null) {
        throw Exception('Something  error. Please try again.');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final couponsResponse = CouponsResponse.fromMap(response.data);

        debugPrint('✅ Coupons fetched successfully:');
        debugPrint('  Total coupons: ${couponsResponse.data.count}');
        debugPrint('  Personalized: ${couponsResponse.data.personalized.length}');
        debugPrint('  Global: ${couponsResponse.data.global.length}');

        // Filter out expired coupons and sort by value
        final filteredCoupons = _filterAndSortCoupons(
          couponsResponse.data.allCoupons,
          pincode,
          cartValue,
        );

        return CouponsResponse(
          success: couponsResponse.success,
          data: CouponsData(
            personalized: couponsResponse.data.personalized,
            global: couponsResponse.data.global,
            count: filteredCoupons.length,
          ),
          message: couponsResponse.message,
        );
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch coupons');
      }
    } on DioException catch (e) {
      debugPrint('❌ Coupons fetch error: ${e.message}');

      if (e.response?.statusCode == 400) {
        throw Exception('Invalid request data');
      } else if (e.response?.statusCode == 404) {
        // Return empty response for 404
        return CouponsResponse(
          success: true,
          data: CouponsData(personalized: [], global: [], count: 0),
          message: 'No coupons available',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching coupons: $e');
      rethrow;
    }
  }

  static List<Coupon> _filterAndSortCoupons(
    List<Coupon> coupons,
    String pincode,
    double cartValue,
  ) {
    return coupons
        .where(
          (coupon) =>
              coupon.isActive &&
              coupon.isApplicableForPincode(pincode) &&
              cartValue >= coupon.minOrderValue,
        )
        .toList()
      ..sort((a, b) {
        // Sort by discount value (higher first)
        final aDiscount = a.calculateDiscount(cartValue);
        final bDiscount = b.calculateDiscount(cartValue);
        return bDiscount.compareTo(aDiscount);
      });
  }
}
