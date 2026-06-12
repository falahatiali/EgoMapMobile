import '../../../core/api/api_client.dart';
import '../../../core/api/api_exception.dart';
import '../models/auth_models.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = await _client.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final session = AuthSession.fromJson(data);
      await _client.saveToken(session.token);

      return session;
    } on ApiException catch (error) {
      if (error.verificationRequired && error.verificationToken != null) {
        throw VerificationRequiredException(
          challenge: VerificationChallenge(
            email: error.email ?? email,
            verificationToken: error.verificationToken!,
            remainingSeconds: error.remainingSeconds ?? 0,
            message: error.message,
          ),
        );
      }

      rethrow;
    }
  }

  Future<VerificationChallenge> register({
    required String email,
    required String password,
  }) async {
    final data = await _client.post('/auth/register', data: {
      'email': email,
      'password': password,
    });

    return VerificationChallenge.fromJson(data);
  }

  Future<AuthSession> verifyEmail({
    required String verificationToken,
    required String code,
  }) async {
    final data = await _client.post('/auth/verify-email', data: {
      'verification_token': verificationToken,
      'code': code,
    });

    final session = AuthSession.fromJson(data);
    await _client.saveToken(session.token);

    return session;
  }

  Future<int> resendVerification(String verificationToken) async {
    final data = await _client.post('/auth/resend-verification', data: {
      'verification_token': verificationToken,
    });

    return data['remaining_seconds'] as int? ?? 0;
  }

  Future<UserModel?> currentUser() async {
    final token = await _client.get('/auth/me');
    final user = token['user'];

    if (user is Map<String, dynamic>) {
      return UserModel.fromJson(user);
    }

    return null;
  }

  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      await _client.clearToken();
    }
  }
}

class VerificationRequiredException implements Exception {
  VerificationRequiredException({required this.challenge});

  final VerificationChallenge challenge;
}
