import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';

class RegisterService {
  static NetworkService networkService = ServiceLocator.networkService;

  /// Register / Update user profile
  static Future<void> registerUser({
    required String name,
    String? email,
    String? referralCode,
    required Function(Map<String, dynamic> data) onSuccess,
    required Function(String error) onError,
  }) async {
    try {
      final Response response = await networkService.patch(
        Endpoints.updateProfile,
        data: {
          'name': name,
          if (email != null && email.isNotEmpty) 'email': email,
          if (referralCode != null && referralCode.isNotEmpty)
            'referralCode': referralCode,
          'gender': 'male',
          'dob': '1990-01-15T00:00:00.000Z',
          'profileImage': 'https://example.com/profile.jpg',
        },
      );

      // Safety check
      if (response.statusCode == null) {
        onError.call('Something went wrong');
        return;
      }

      // ✅ Success
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data as Map<String, dynamic>;
        onSuccess.call(data);
        return;
      }

      // ❌ API error but no DioException
      onError.call(response.data?['response'] ?? 'Registration failed');
    } on DioException catch (e) {
      debugPrint('❌ Register API Error');
      debugPrint('StatusCode: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');

      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      /// 🔴 Validation errors (email exists, referral invalid, etc.)
      if (statusCode == 400 || statusCode == 409) {
        String errorMessage = 'Validation failed';

        if (data is Map<String, dynamic>) {
          if (data['error'] != null &&
              data['error']['errors'] is List &&
              data['error']['errors'].isNotEmpty) {
            errorMessage =
                data['error']['errors'][0]['message'] ?? errorMessage;
          } else if (data['response'] != null) {
            errorMessage = data['response'];
          }
        }

        onError.call(errorMessage);
        return;
      }

      /// 🔴 Endpoint not found
      if (statusCode == 404) {
        onError.call('Profile update endpoint not found.');
        return;
      }

      /// 🔴 Timeout
      if (e.type == DioExceptionType.connectionTimeout) {
        onError.call('Connection timeout. Please try again.');
        return;
      }

      onError.call('Something went wrong. Please try again.');
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      onError.call('Something went wrong. Please try again.');
    }
  }
}
