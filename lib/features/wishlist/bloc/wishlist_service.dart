// features/wishlist/services/wishlist_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/core/storage/shared_preferences.dart';
import 'package:villag_kart/features/wishlist/model/wishlist_model.dart';

class WishlistService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  static const String _baseWishlistEndpoint = 'wishlist';

  /// Add item to wishlist - returns success status
  /// Warehouse ID is automatically retrieved from SharedPreferences
  static Future<bool> addToWishlist({required String productId}) async {
    try {
      final warehouseId = await SharedPrefs.getWarehouseId();

      if (warehouseId == null || warehouseId.isEmpty) {
        throw Exception(
          'Warehouse not available. Please select a location first.',
        );
      }

      debugPrint(
        '📡 Adding to wishlist: URL: ${NetworkService.baseUrl}$_baseWishlistEndpoint/add',
      );
      final body = {
        'warehouseId': warehouseId,
        'productId': productId,
        'status': 'ACTIVE',
      };
      debugPrint('📡 Add Body: $body');

      final Response response = await _networkService.post(
        '$_baseWishlistEndpoint/add',
        data: body,
      );

      debugPrint('📡 Add Response Status: ${response.statusCode}');
      debugPrint('📡 Add Response Data: ${response.data}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to add to wishlist',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Add to wishlist error: ${e.message}, Data: ${e.response?.data}');
      if (e.response?.statusCode == 401)
        throw Exception('Please login to add to wishlist');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error adding to wishlist: $e');
      rethrow;
    }
  }

  static Future<bool> removeFromWishlist({required String productId}) async {
    try {
      final String path = '$_baseWishlistEndpoint/remove/$productId';
      debugPrint('📡 Removing from wishlist: URL: ${NetworkService.baseUrl}$path');

      final Response response = await _networkService.delete(path);

      debugPrint('📡 Remove Response Status: ${response.statusCode}');
      debugPrint('📡 Remove Response Data: ${response.data}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to remove from wishlist',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        '❌ Remove from wishlist error: ${e.message}, Data: ${e.response?.data}',
      );
      rethrow;
    } catch (e) {
      debugPrint('❌ Error removing from wishlist: $e');
      rethrow;
    }
  }

  static Future<WishlistModel> getWishlist() async {
    try {
      debugPrint(
        '📡 Fetching wishlist: URL: ${NetworkService.baseUrl}$_baseWishlistEndpoint',
      );

      final Response response = await _networkService.get(
        _baseWishlistEndpoint,
      );

      debugPrint('📡 Get Wishlist Response Status: ${response.statusCode}');

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        return WishlistModel.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch wishlist');
      }
    } on DioException catch (e) {
      debugPrint('❌ Wishlist fetch error: ${e.message}, Data: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ Error fetching wishlist: $e');
      rethrow;
    }
  }
}
