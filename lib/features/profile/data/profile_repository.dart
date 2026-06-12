import '../../../core/api/api_client.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._api);

  final ApiClient _api;

  Future<ProfilePayload> fetchProfile() async {
    final data = await _api.get('/profile');
    return ProfilePayload.fromJson(data);
  }
}
