import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class CrashlyticsService {
  static FirebaseCrashlytics get _instance => FirebaseCrashlytics.instance;

  /// Call once after Firebase.initializeApp()
  static Future<void> init() async {
    await _instance.setCrashlyticsCollectionEnabled(true);
  }

  static void log(String message) {
    _instance.log(message);
  }

  static void recordError(
    dynamic error,
    StackTrace stack, {
    bool fatal = false,
  }) {
    _instance.recordError(error, stack, fatal: fatal);
  }

  static void setUser(String userId) {
    _instance.setUserIdentifier(userId);
  }

  static void setKey(String key, dynamic value) {
    _instance.setCustomKey(key, value);
  }

  /// Flutter framework errors
  static void handleFlutterError(FlutterErrorDetails details) {
    _instance.recordFlutterError(details);
  }

  /// Async + isolate errors
  static bool handlePlatformError(Object error, StackTrace stack) {
    _instance.recordError(error, stack, fatal: true);
    return true;
  }
}
