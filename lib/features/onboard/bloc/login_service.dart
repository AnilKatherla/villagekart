import 'package:dio/dio.dart';
import 'package:villag_kart/core/services/notification_service.dart';
import 'package:villag_kart/core/dependency_injection/service_locator.dart';
import 'package:villag_kart/core/network/endpoints.dart';
import 'package:villag_kart/core/network/network_service.dart';
import 'package:villag_kart/features/onboard/model/login_response_model.dart';

class LoginService {
  static NetworkService networkService = ServiceLocator.networkService;

  // SEND OTP
  static Future<void> sendOtp({
    required String phoneNumber,
    required Function(String error) onError,
    required Function(String otp) onSuccess,
    String countryCode = '+91',
  }) async {
    try {
      final Response response = await networkService.post(
        Endpoints.sendOtp,
        data: {'phone': phoneNumber, 'countryCode': countryCode},
      );

      if (response.statusCode == null) {
        onError.call('Something went wrong');
        return;
      }

      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Extract OTP from response
        final String otp = response.data['data']['otp']?.toString() ?? '123456';
        onSuccess.call(otp);
      } else if (response.statusCode == 429) {
        // Handle rate limiting - extract wait time from message
        final String errorMessage =
            response.data['response'] ??
            'Please wait before requesting new OTP';
        onError.call(errorMessage);
      } else {
        onError.call(response.data['response'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 429) {
        final String errorMessage =
            e.response?.data['response'] ??
            'Please wait before requesting new OTP';
        onError.call(errorMessage);
      } else {
        onError.call('Something went wrong. Please try again later');
      }
    }
  }

  // RESEND OTP (reuses sendOtp)
  static Future<void> resendOtp({
    required String phoneNumber,
    required Function(String otp) onSuccess,
    required Function(String error) onError,
    String countryCode = '+91',
  }) async {
    await sendOtp(
      phoneNumber: phoneNumber,
      onSuccess: onSuccess,
      onError: onError,
      countryCode: countryCode,
    );
  }

  // VERIFY OTP
  static Future<AuthResponseModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    String countryCode = '+91',
  }) async {
    try {
      final String? fcmToken = await NotificationService().getToken();

      final Response response = await networkService.post(
        Endpoints.verifyOtp,
        data: {
          'phone': phoneNumber,
          'countryCode': countryCode,
          'otp': otp,
          'deviceToken': fcmToken,
        },
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return AuthResponseModel.fromJson(response.data);
      } else {
        final errorMessage =
            response.data?['message']?.toString() ??
            response.data?['response']?.toString() ??
            'Invalid OTP';

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      // ✅ BACKEND RESPONDED → show exact error
      if (e.response != null) {
        final backendMessage =
            e.response?.data?['message']?.toString() ??
            e.response?.data?['response']?.toString() ??
            'Something went wrong';

        throw Exception(backendMessage);
      }

      // ❌ NO RESPONSE AT ALL → real network issue
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection. Please check your network.');
      }

      throw Exception('Something went wrong. Please try again.');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Something went wrong. Please try again.');
    }
  }
}
