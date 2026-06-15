import '../../../core/api/api_client.dart';
import '../models/aether_checkin_models.dart';
import '../models/aether_program_models.dart';
import '../models/aether_volume_models.dart';

class AetherRepository {
  AetherRepository(this._api);

  final ApiClient _api;

  Future<AetherProgramDetail> fetchProgram(String uuid) async {
    final data = await _api.get('/aether/programs/$uuid');
    return AetherProgramDetail.fromJson(data);
  }

  Future<AetherSetToggleResult> toggleSet({
    required String programUuid,
    required int dayId,
    required int setId,
  }) async {
    final data = await _api.post('/aether/programs/$programUuid/workout-days/$dayId/sets/$setId/toggle');
    return AetherSetToggleResult.fromJson(data);
  }

  /// Log the weight used for a specific set. [weightKg] may be 0 to clear.
  Future<void> logWeight({
    required String programUuid,
    required int dayId,
    required int setId,
    required double weightKg,
  }) async {
    await _api.post(
      '/aether/programs/$programUuid/workout-days/$dayId/sets/$setId/weight',
      data: {'weight_kg': weightKg},
    );
  }

  /// Check whether a weekly re-calibration is due for this program.
  Future<AetherCheckInStatus> fetchCheckInStatus(String programUuid) async {
    final data = await _api.get('/aether/programs/$programUuid/check-in/status');
    return AetherCheckInStatus.fromJson(data);
  }

  /// Submit the weekly check-in answers.
  Future<AetherCheckInResult> submitCheckIn({
    required String programUuid,
    required AetherCheckInPayload payload,
  }) async {
    final data = await _api.post(
      '/aether/programs/$programUuid/check-in',
      data: payload.toJson(),
    );
    return AetherCheckInResult.fromJson(data);
  }

  /// Fetch volume chart data for the given program.
  Future<AetherVolumeChart> fetchVolumeChart(String programUuid, {int days = 30}) async {
    final data = await _api.get('/aether/programs/$programUuid/volume-chart?days=$days');
    return AetherVolumeChart.fromJson(data);
  }
}
