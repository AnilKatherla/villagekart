import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/home/model/offers_model.dart';

class OffersService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static Future<OffersResponse> fetchOffers({
    required String pincode,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('🎁 Fetching offers for:');
      debugPrint('  Pincode: $pincode');
      debugPrint('  Page: $page, Limit: $limit');

      final endpoint = Endpoints.productsOffers(
        pinCode: pincode,
        page: page,
        limit: limit,
      );

      final Response response = await _networkService.get(endpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        debugPrint('📦 Raw API Response: ${response.data}');

        try {
          // Ensure response.data is a Map
          if (response.data == null) {
            throw Exception('API returned null response');
          }

          if (response.data is! Map<String, dynamic>) {
            debugPrint(
              '❌ Response data is not a Map. Type: ${response.data.runtimeType}',
            );
            debugPrint('  Data: ${response.data}');
            throw Exception('API response is not in expected format');
          }

          final offersResponse = OffersResponse.fromJson(
            response.data as Map<String, dynamic>,
          );

          debugPrint('✅ Offers fetched successfully:');
          debugPrint('  Success: ${offersResponse.success}');
          debugPrint('  Has data: ${offersResponse.data != null}');
          if (offersResponse.data != null) {
            debugPrint(
              '  Products count: ${offersResponse.data!.products.length}',
            );
            debugPrint('  Count: ${offersResponse.data!.count}');
          }
          debugPrint('  Message: ${offersResponse.message}');

          return offersResponse;
        } catch (parseError) {
          debugPrint('❌ Error parsing offers response: $parseError');
          debugPrint('  Response data type: ${response.data?.runtimeType}');
          debugPrint('  Response data: ${response.data}');
          debugPrint('  Stack trace: ${StackTrace.current}');
          // Re-throw to be caught by outer catch
          throw Exception('Failed to parse offers response: $parseError');
        }
      } else {
        debugPrint('❌ API returned error status: ${response.statusCode}');
        debugPrint('  Response: ${response.data}');
        throw Exception('API returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ Offers fetch DioException:');
      debugPrint('  Message: ${e.message}');
      debugPrint('  Response: ${e.response?.data}');
      debugPrint('  Status Code: ${e.response?.statusCode}');

      // If we have a response, try to parse it
      if (e.response != null && e.response!.statusCode == 200) {
        try {
          final offersResponse = OffersResponse.fromJson(e.response!.data);
          debugPrint('✅ Parsed response from error: ${offersResponse.success}');
          return offersResponse;
        } catch (_) {
          // If parsing fails, continue to throw
        }
      }

      throw Exception('Somethng went wrong. Please try again later');
    } catch (e) {
      debugPrint('❌ Error fetching offers: $e');
      debugPrint('  Error type: ${e.runtimeType}');
      rethrow;
    }
  }
}
