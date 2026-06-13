import '../../../core/api/api_exception.dart';
import '../../../core/api/api_client.dart';
import '../models/quiz_models.dart';

class QuizRepository {
  QuizRepository(this._api);

  final ApiClient _api;

  static const _generationTimeout = Duration(seconds: 120);
  static const _pollTimeout = Duration(seconds: 45);
  static const _maxResultAttempts = 12;

  Future<QuizMeta> fetchQuiz(String slug) async {
    final data = await _api.get('/quizzes/$slug');
    return QuizMeta.fromJson(data['quiz'] as Map<String, dynamic>);
  }

  Future<QuizEntry> fetchEntry(
    String slug, {
    String? resumeUuid,
  }) async {
    final query = resumeUuid == null ? '' : '?resume_uuid=$resumeUuid';
    final data = await _api.get('/quizzes/$slug/entry$query');
    return QuizEntry.fromJson(data);
  }

  Future<QuizSessionStartResult> startSession(
    String slug, {
    String? resumeUuid,
    bool forceFresh = false,
  }) async {
    final data = await _api.post(
      '/quizzes/$slug/sessions',
      data: forceFresh || resumeUuid == null ? null : {'resume_uuid': resumeUuid},
    );

    return QuizSessionStartResult(
      state: QuizSessionState.fromJson(data),
      guestToken: data['guest_token'] as String?,
    );
  }

  Future<QuizSessionState> fetchSession(String uuid) async {
    final data = await _api.get('/quiz-sessions/$uuid');
    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> submitAnswer(
    String uuid, {
    required Object value,
  }) async {
    final data = await _api.post(
      '/quiz-sessions/$uuid/answers',
      data: {'value': value},
      receiveTimeout: _generationTimeout,
    );

    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> submitSafetyAnswer(String uuid, int value) async {
    final data = await _api.post(
      '/quiz-sessions/$uuid/safety-answer',
      data: {'value': value},
      receiveTimeout: _generationTimeout,
    );

    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> goBack(String uuid) async {
    final data = await _api.post('/quiz-sessions/$uuid/back');
    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> fetchResult(
    String uuid, {
    void Function(int attempt)? onAttempt,
  }) async {
    ApiException? lastError;

    for (var attempt = 1; attempt <= _maxResultAttempts; attempt++) {
      onAttempt?.call(attempt);

      try {
        final timeout = attempt == 1 ? _generationTimeout : _pollTimeout;
        final data = await _api.get(
          '/quiz-sessions/$uuid/result',
          receiveTimeout: timeout,
        );
        final state = QuizSessionState.fromJson(data);

        if (state.result != null) {
          return state;
        }
      } on ApiException catch (error) {
        lastError = error;

        if (error.statusCode != 408 || attempt == _maxResultAttempts) {
          rethrow;
        }
      }

      await Future<void>.delayed(Duration(seconds: 2 + (attempt ~/ 4)));
    }

    throw lastError ??
        ApiException(
          message: 'Your result is still being prepared. Please try again.',
          statusCode: 408,
        );
  }

  Future<QuizSessionStartResult> resetAfterCrisis(String uuid) async {
    final data = await _api.post('/quiz-sessions/$uuid/reset-after-crisis');

    return QuizSessionStartResult(
      state: QuizSessionState.fromJson(data),
      guestToken: data['guest_token'] as String?,
    );
  }

  Future<QuizResultPayload> sendReport(String uuid, String email) async {
    final data = await _api.post(
      '/quiz-sessions/$uuid/send-report',
      data: {'email': email},
    );

    return QuizResultPayload.fromJson(data['result'] as Map<String, dynamic>);
  }
}
