import '../../../core/api/api_client.dart';
import '../models/quiz_models.dart';

class QuizRepository {
  QuizRepository(this._api);

  final ApiClient _api;

  Future<QuizMeta> fetchQuiz(String slug) async {
    final data = await _api.get('/quizzes/$slug');
    return QuizMeta.fromJson(data['quiz'] as Map<String, dynamic>);
  }

  Future<QuizSessionStartResult> startSession(
    String slug, {
    String? resumeUuid,
  }) async {
    final data = await _api.post(
      '/quizzes/$slug/sessions',
      data: resumeUuid == null ? null : {'resume_uuid': resumeUuid},
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
    );

    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> submitSafetyAnswer(String uuid, int value) async {
    final data = await _api.post(
      '/quiz-sessions/$uuid/safety-answer',
      data: {'value': value},
    );

    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> goBack(String uuid) async {
    final data = await _api.post('/quiz-sessions/$uuid/back');
    return QuizSessionState.fromJson(data);
  }

  Future<QuizSessionState> fetchResult(String uuid) async {
    final data = await _api.get('/quiz-sessions/$uuid/result');
    return QuizSessionState.fromJson(data);
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
