import '../../../core/api/api_client.dart';
import '../models/bootstrap_models.dart';

class BootstrapRepository {
  BootstrapRepository(this._client);

  final ApiClient _client;

  Future<BootstrapPayload> fetch() async {
    final data = await _client.get('/bootstrap');
    return BootstrapPayload.fromJson(data);
  }
}
