import '../../../core/api/api_client.dart';
import '../models/ghost_mode_models.dart';

class GhostModeRepository {
  GhostModeRepository(this._api);

  final ApiClient _api;

  Future<GhostModeState> fetchState() async {
    final data = await _api.get('/ghost-mode');
    return GhostModeState.fromJson(data);
  }

  Future<GhostModeState> startProtocol(int durationDays) async {
    final data = await _api.post('/ghost-mode/protocol', data: {
      'duration_days': durationDays,
    });

    return GhostModeState.fromJson(data);
  }
}
