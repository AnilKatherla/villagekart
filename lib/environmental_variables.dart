/// Class that holds variant secrets for different app flavors and environments
class EnvironmentalVariables {
  const EnvironmentalVariables._();

  static late String baseUrl;
  static late String appName;
  static late String firebaseProjectId;
  static late String firebaseMessagingSenderId;
  static late String firebaseAndroidApiKey;
  static late String firebaseAndroidAppId;
  static late String firebaseIosApiKey;
  static late String firebaseIosAppId;
  static late String firebaseWebApiKey;
  static late String firebaseWebAppId;
  static late String razorpayKey;
  /// Optional override, e.g. `https://consumer-api.example.com` (no path). If empty, derived from [baseUrl].
  static late String socketOrigin;

  static void assignValues({
    required String baseUrl,
    required String appName,
    required String firebaseProjectId,
    required String firebaseMessagingSenderId,
    required String firebaseAndroidApiKey,
    required String firebaseAndroidAppId,
    required String firebaseIosApiKey,
    required String firebaseIosAppId,
    required String firebaseWebApiKey,
    required String firebaseWebAppId,
    required String razorpayKey,
    String socketOrigin = '',
  }) {
    EnvironmentalVariables.baseUrl = baseUrl;
    EnvironmentalVariables.socketOrigin = socketOrigin;
    EnvironmentalVariables.appName = appName;
    EnvironmentalVariables.firebaseProjectId = firebaseProjectId;
    EnvironmentalVariables.firebaseMessagingSenderId =
        firebaseMessagingSenderId;
    EnvironmentalVariables.firebaseAndroidApiKey = firebaseAndroidApiKey;
    EnvironmentalVariables.firebaseAndroidAppId = firebaseAndroidAppId;
    EnvironmentalVariables.firebaseIosApiKey = firebaseIosApiKey;
    EnvironmentalVariables.firebaseIosAppId = firebaseIosAppId;
    EnvironmentalVariables.firebaseWebApiKey = firebaseWebApiKey;
    EnvironmentalVariables.firebaseWebAppId = firebaseWebAppId;
    EnvironmentalVariables.razorpayKey = razorpayKey;
  }

  /// Consumer API HTTP base is `.../api/v1/`; Socket.IO is on the same host without that suffix.
  static String resolvedSocketOrigin() {
    final o = socketOrigin.trim();
    if (o.isNotEmpty) return o.replaceAll(RegExp(r'/+$'), '');
    final b = baseUrl.trim();
    if (b.isEmpty) return '';
    try {
      final u = Uri.parse(b);
      if (!u.hasScheme || u.host.isEmpty) return '';
      return '${u.scheme}://${u.host}${u.hasPort ? ':${u.port}' : ''}';
    } catch (_) {
      return '';
    }
  }
}
