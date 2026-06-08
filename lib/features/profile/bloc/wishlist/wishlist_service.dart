// ============================================================================
// 3. WISHLIST SERVICE (wishlist_service.dart)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../../model/wishlist_model.dart';

class WishlistService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch all wishlist items
  static Future<WishlistResponse> fetchWishlist() async {
    try {
      const String wishlistEndpoint =
          'wishlist';

      final Response response = await _networkService.get(wishlistEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        try {
          return WishlistResponse.fromJson(response.data);
        } catch (e) {
          throw Exception('Data parsing error: ${e.toString()}');
        }
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch wishlist',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Please login to view wishlist');
      } else if (e.response?.statusCode == 404) {
        // Return empty wishlist instead of error
        return WishlistResponse(
          status: true,
          response: 'Wishlist is empty',
          data: [],
        );
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

  /// Remove item from wishlist
  static Future<RemoveWishlistResponse> removeFromWishlist({
    required String productId,
  }) async {
    try {
      final String removeEndpoint =
          'wishlist/remove/$productId';

      final Response response = await _networkService.delete(removeEndpoint);

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return RemoveWishlistResponse.fromJson(response.data);
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to remove item from wishlist',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Item not found in wishlist');
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
