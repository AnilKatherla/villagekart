import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'environmental_variables.dart';

class FirebaseOptionsParser {
  static FirebaseOptions get options {
    final bucket =
        '${EnvironmentalVariables.firebaseProjectId}.firebasestorage.app';
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: EnvironmentalVariables.firebaseWebApiKey,
        appId: EnvironmentalVariables.firebaseWebAppId,
        messagingSenderId: EnvironmentalVariables.firebaseMessagingSenderId,
        projectId: EnvironmentalVariables.firebaseProjectId,
        storageBucket: bucket,
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: EnvironmentalVariables.firebaseAndroidApiKey,
          appId: EnvironmentalVariables.firebaseAndroidAppId,
          messagingSenderId: EnvironmentalVariables.firebaseMessagingSenderId,
          projectId: EnvironmentalVariables.firebaseProjectId,
          storageBucket: bucket,
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: EnvironmentalVariables.firebaseIosApiKey,
          appId: EnvironmentalVariables.firebaseIosAppId,
          messagingSenderId: EnvironmentalVariables.firebaseMessagingSenderId,
          projectId: EnvironmentalVariables.firebaseProjectId,
          storageBucket: bucket,
        );
      default:
        throw UnsupportedError('Platform not supported');
    }
  }
}
