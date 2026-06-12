import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../storage/app_local_storage.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({
    required AppLocalStorage storage,
    Dio? dio,
  })  : _storage = storage,
        _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                headers: ApiConfig.defaultHeaders,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
                validateStatus: (status) => status != null && status < 600,
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readApiToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          final guestToken = await _storage.readGuestToken();
          if (guestToken != null && guestToken.isNotEmpty) {
            options.headers[guestTokenHeader] = guestToken;
          }

          handler.next(options);
        },
      ),
    );
  }

  final AppLocalStorage _storage;
  final Dio _dio;

  static const guestTokenHeader = 'X-Guest-Token';

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _dio.get<Map<String, dynamic>>(path);
    return _persistGuestToken(_parse(response));
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    return _persistGuestToken(_parse(response));
  }

  Future<Map<String, dynamic>> _persistGuestToken(Map<String, dynamic> data) async {
    final guestToken = data['guest_token'] as String?;

    if (guestToken != null && guestToken.isNotEmpty) {
      await _storage.writeGuestToken(guestToken);
    }

    return data;
  }

  Future<void> saveToken(String token) => _storage.writeApiToken(token);

  Future<void> clearToken() => _storage.clearApiToken();

  Map<String, dynamic> _parse(Response<Map<String, dynamic>> response) {
    final data = response.data ?? <String, dynamic>{};
    final status = response.statusCode ?? 500;

    if (status >= 200 && status < 300) {
      return data;
    }

    throw _toException(status, data);
  }

  ApiException _toException(int status, Map<String, dynamic> data) {
    final message = data['message'] as String? ?? 'Something went wrong.';

    final errors = <String, List<String>>{};
    final rawErrors = data['errors'];
    if (rawErrors is Map) {
      rawErrors.forEach((key, value) {
        if (value is List) {
          errors['$key'] = value.map((e) => '$e').toList();
        }
      });
    }

    return ApiException(
      message: message,
      statusCode: status,
      fieldErrors: errors,
      verificationRequired: data['verification_required'] == true,
      verificationToken: data['verification_token'] as String?,
      email: data['email'] as String?,
      remainingSeconds: data['remaining_seconds'] as int?,
    );
  }
}
