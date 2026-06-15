import '../../../core/api/api_client.dart';
import '../models/virtue_models.dart';

class VirtueRepository {
  VirtueRepository(this._api);

  final ApiClient _api;

  Future<List<VirtueHabit>> fetchHabits() async {
    final data = await _api.get('/virtue/habits');
    final list = data['data'] as List<dynamic>;
    return list.map((j) => VirtueHabit.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<VirtueHabit> analyzeCustomHabit(String description) async {
    final data = await _api.post('/virtue/habits/analyze', data: {'description': description});
    return VirtueHabit.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<VirtueRoutine>> fetchRoutines({String? status}) async {
    final query = status != null ? '?status=$status' : '';
    final data = await _api.get('/virtue/routines$query');
    final list = data['data'] as List<dynamic>;
    return list.map((j) => VirtueRoutine.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<VirtueRoutine> startRoutine({
    required int habitId,
    String? personalNote,
    String goalType = 'days_count',
    int goalTarget = 21,
  }) async {
    final data = await _api.post('/virtue/routines', data: {
      'virtue_habit_id': habitId,
      if (personalNote != null && personalNote.isNotEmpty) 'personal_note': personalNote,
      'goal_type': goalType,
      'goal_target': goalTarget,
    });
    return VirtueRoutine.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<VirtueRoutine> fetchRoutineProgress(int routineId) async {
    final data = await _api.get('/virtue/routines/$routineId');
    return VirtueRoutine.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> logSuccess(
    int routineId, {
    String? situation,
    String? emotionalState,
  }) async {
    final body = <String, dynamic>{};
    if (situation != null) body['situation'] = situation;
    if (emotionalState != null) body['emotional_state'] = emotionalState;
    final data = await _api.post('/virtue/routines/$routineId/success', data: body);
    return data['data'] as Map<String, dynamic>;
  }

  Future<VirtueSlipResult> logSlip(int routineId, {String? whatHappened}) async {
    final body = <String, dynamic>{};
    if (whatHappened != null && whatHappened.isNotEmpty) body['what_happened'] = whatHappened;
    final data = await _api.post('/virtue/routines/$routineId/slip', data: body);
    return VirtueSlipResult.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<VirtueRoutine> completeRoutine(int routineId) async {
    final data = await _api.post('/virtue/routines/$routineId/complete', data: {});
    return VirtueRoutine.fromJson(
      (data['data'] as Map<String, dynamic>)['routine'] as Map<String, dynamic>,
    );
  }
}
