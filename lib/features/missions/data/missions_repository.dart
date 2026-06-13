import '../../../core/api/api_client.dart';
import '../models/mission_models.dart';
import '../models/mission_workspace_models.dart';

class MissionsRepository {
  MissionsRepository(this._api);

  final ApiClient _api;

  Future<MissionHubState> fetchHub() async {
    final data = await _api.get('/missions');
    return MissionHubState.fromJson(data);
  }

  Future<MissionTemplateDetailResponse> fetchTemplate(String slug) async {
    final data = await _api.get('/missions/$slug');
    return MissionTemplateDetailResponse.fromJson(data);
  }

  Future<MissionEnrollResult> enroll(String slug) async {
    final data = await _api.post('/missions/$slug/enroll');
    return MissionEnrollResult.fromJson(data);
  }

  Future<MissionWorkspaceResponse> fetchWorkspace(String enrollmentUuid) async {
    final data = await _api.get('/missions/enrollments/$enrollmentUuid');
    return MissionWorkspaceResponse.fromJson(data);
  }

  Future<CalibrationDefaults> fetchCalibrationDefaults(String enrollmentUuid) async {
    final data = await _api.get('/mission-enrollments/$enrollmentUuid/calibration/defaults');
    return CalibrationDefaults.fromJson(data);
  }

  Future<MissionWorkspaceResponse> completeCalibration({
    required String enrollmentUuid,
    required List<String> targets,
    required Map<String, dynamic> wizard,
    String? entryToolKey,
  }) async {
    final data = await _api.post(
      '/mission-enrollments/$enrollmentUuid/calibration/complete',
      data: {
        'intent': {
          if (entryToolKey != null) 'entry_tool_key': entryToolKey,
        },
        'targets': targets,
        'wizard': wizard,
        'commitment': {'confirmed': true},
      },
      receiveTimeout: const Duration(seconds: 120),
      connectTimeout: const Duration(seconds: 30),
    );

    return MissionWorkspaceResponse.fromJson(data);
  }
}
