import 'dart:developer';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:villag_kart/environmental_variables.dart';

class EnvLoader {
  static Future<void> loadEnv() async {
    const envFile = String.fromEnvironment('ENV_FILE');

    log(envFile);

    try {
      await dotenv.load(fileName: envFile);

      EnvironmentalVariables.assignValues(
        baseUrl: dotenv.env['BASE_URL'] ?? '',
        appName: dotenv.env['APP_NAME'] ?? 'Villagkart',
        firebaseProjectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? '',
        firebaseMessagingSenderId:
            dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
        firebaseAndroidApiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
        firebaseAndroidAppId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '',
        firebaseIosApiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
        firebaseIosAppId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '',
        firebaseWebApiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
        firebaseWebAppId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '',
        razorpayKey: dotenv.env['RAZORPAY_KEY'] ?? '',
        socketOrigin: dotenv.env['SOCKET_ORIGIN'] ?? '',
      );
    } catch (e) {
      throw const EnvFileNotFoundException('Failed to load env file: $envFile');
    }
  }
}

class EnvFileNotFoundException implements Exception {
  const EnvFileNotFoundException(this.message);
  final String message;

  @override
  String toString() => 'EnvFileNotFoundException: $message';
}
