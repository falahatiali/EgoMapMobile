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

  Future<Map<String, dynamic>> get(
    String path, {
    Duration? receiveTimeout,
    Duration? connectTimeout,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        options: _options(
          receiveTimeout: receiveTimeout,
          connectTimeout: connectTimeout,
        ),
      );

      return _persistGuestToken(_parse(response));
    } on DioException catch (error) {
      throw _fromDio(error);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Duration? receiveTimeout,
    Duration? connectTimeout,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: _options(
          receiveTimeout: receiveTimeout,
          connectTimeout: connectTimeout,
        ),
      );

      return _persistGuestToken(_parse(response));
    } on DioException catch (error) {
      throw _fromDio(error);
    }
  }

  Options? _options({
    Duration? receiveTimeout,
    Duration? connectTimeout,
  }) {
    if (receiveTimeout == null && connectTimeout == null) {
      return null;
    }

    return Options(
      receiveTimeout: receiveTimeout,
      sendTimeout: receiveTimeout,
      connectTimeout: connectTimeout,
    );
  }

  ApiException _fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'The server is taking longer than expected. Please wait a moment and try again.',
          statusCode: 408,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Could not reach the server. Check your connection and try again.',
          statusCode: 503,
        );
      default:
        final status = error.response?.statusCode;
        if (error.response?.data is Map<String, dynamic>) {
          return _toException(
            status ?? 500,
            error.response!.data! as Map<String, dynamic>,
          );
        }

        return ApiException(
          message: error.message ?? 'Something went wrong.',
          statusCode: status,
        );
    }
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
