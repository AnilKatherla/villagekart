import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateService {
  static const _minAppVersionKey = 'min_app_version';

  static Future<String?> fetchMinAppVersion() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      
      // Configure settings
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Set default values
      await remoteConfig.setDefaults({
        _minAppVersionKey: '1.0.0',
      });

      // Fetch and activate
      await remoteConfig.fetchAndActivate();

      final version = remoteConfig.getString(_minAppVersionKey).trim();
      return version.split('+').first;
    } catch (e) {
      // In case of error, return null or a default version
      return null;
    }
  }

  static Future<String> getCurrentAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
