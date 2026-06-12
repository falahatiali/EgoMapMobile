class ApiConfig {
  const ApiConfig._();

  /// Override at run time:
  /// flutter run --dart-define=API_BASE_URL=https://egomap.test/api/v1
  ///
  /// Android emulator + Herd (after `adb reverse tcp:443 tcp:443`):
  /// flutter run --dart-define=API_BASE_URL=https://egomap.test/api/v1 --dart-define=API_HOST=egomap.test
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://egomap.test/api/v1',
  );

  static const String virtualHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );

  static const String defaultLocale = 'en';

  static Map<String, String> get defaultHeaders {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': defaultLocale,
    };

    if (virtualHost.isNotEmpty) {
      headers['Host'] = virtualHost;
    }

    return headers;
  }
}
