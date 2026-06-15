/// Runtime environment configuration — the Flutter equivalent of Laravel's .env.
///
/// ── Development ────────────────────────────────────────────────────────────
/// flutter run --dart-define-from-file=.env.dev.json
///
/// ── Production build ───────────────────────────────────────────────────────
/// 1. Copy .env.prod.json.example → .env.prod.json
/// 2. Fill in your live API URL
/// 3. flutter build apk --dart-define-from-file=.env.prod.json
///    flutter build ipa --dart-define-from-file=.env.prod.json
///
/// .env.prod.json is gitignored. .env.dev.json is tracked (no secrets).
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://egomap.test/api/v1',
  );

  /// Set to match the Herd virtual-host name when running on an Android
  /// emulator (after `adb reverse tcp:443 tcp:443`).
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
