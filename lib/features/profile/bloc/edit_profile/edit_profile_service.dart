// // ============================================================================
// USER PROFILE SERVICE (user_profile_service.dart)
// ============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';

import '../../model/profile_model.dart';

class UserProfileService {
  static final NetworkService _networkService = ServiceLocator.networkService;

  /// Fetch user profile data
  static Future<UserProfileResponse> fetchUserProfile() async {
    try {
      debugPrint('👤 Fetching user profile...');

      final Response response = await _networkService.get(Endpoints.profile);

      if (response.statusCode == null) {
        throw Exception('Failed to fetch user profile.');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final profileResponse = UserProfileResponse.fromJson(response.data);

        debugPrint('✅ User profile fetched successfully:');
        debugPrint('  Name: ${profileResponse.data.name}');
        debugPrint('  Email: ${profileResponse.data.email}');
        debugPrint('  Phone: ${profileResponse.data.phone}');

        return profileResponse;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to fetch user profile',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Profile fetch error: ${e.message}');

      if (e.response?.statusCode == 401) {
        throw Exception('Please login to view profile');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error fetching profile: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Something went wrong. Please try again.');
    }
  }

  /// Update user profile (name and email only)
  static Future<UpdateProfileResponse> updateUserProfile({
    required String name,
    required String email,
  }) async {
    try {
      debugPrint('📝 Updating user profile...');
      debugPrint('  Name: $name');
      debugPrint('  Email: $email');

      const String updateEndpoint = 'user/update-profile';

      final payload = UpdateProfileRequest(name: name, email: email);

      debugPrint('📤 Payload: ${payload.toJson()}');

      final Response response = await _networkService.patch(
        updateEndpoint,
        data: payload.toJson(),
      );

      if (response.statusCode == null) {
        throw Exception('Somethng went wrong. Please try again later');
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final updateResponse = UpdateProfileResponse.fromJson(response.data);

        debugPrint('✅ Profile updated successfully:');
        debugPrint('  Name: ${updateResponse.data.name}');
        debugPrint('  Email: ${updateResponse.data.email}');

        return updateResponse;
      } else {
        throw Exception(
          response.data['response'] ?? 'Failed to update profile',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ Profile update error: ${e.message}');

      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        final msg =
            e.response?.data['message'] ??
            e.response?.data['response'] ??
            'Email already exists';
        throw Exception(msg);
      } else if (e.response?.statusCode == 401) {
        throw Exception('Please login to update profile');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timeout. Please try again.');
      } else {
        throw Exception('Somethng went wrong. Please try again later');
      }
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      if (e is Exception) rethrow;
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
