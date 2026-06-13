import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../data/missions_repository.dart';
import '../models/mission_models.dart';
import '../models/mission_workspace_models.dart';

final missionsRepositoryProvider = Provider<MissionsRepository>((ref) {
  return MissionsRepository(ref.watch(apiClientProvider));
});

final missionsHubProvider = AsyncNotifierProvider<MissionsHubNotifier, MissionHubState?>(MissionsHubNotifier.new);

class MissionsHubNotifier extends AsyncNotifier<MissionHubState?> {
  @override
  Future<MissionHubState?> build() async => null;

  Future<void> ensureLoaded() async {
    if (state.hasValue && state.value != null) {
      return;
    }

    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return ref.read(missionsRepositoryProvider).fetchHub();
    });
  }
}

final missionTemplateProvider =
    FutureProvider.autoDispose.family<MissionTemplateDetailResponse, String>((ref, slug) async {
  return ref.read(missionsRepositoryProvider).fetchTemplate(slug);
});

final missionWorkspaceProvider =
    FutureProvider.autoDispose.family<MissionWorkspaceResponse, String>((ref, uuid) async {
  return ref.read(missionsRepositoryProvider).fetchWorkspace(uuid);
});

final calibrationDefaultsProvider =
    FutureProvider.autoDispose.family<CalibrationDefaults, String>((ref, uuid) async {
  return ref.read(missionsRepositoryProvider).fetchCalibrationDefaults(uuid);
});

Future<MissionEnrollResult?> enrollInMission(WidgetRef ref, String slug) async {
  try {
    final result = await ref.read(missionsRepositoryProvider).enroll(slug);
    ref.invalidate(missionsHubProvider);
    return result;
  } on ApiException {
    rethrow;
  }
}

String? missionErrorMessage(Object? error) {
  if (error is ApiException) {
    return error.displayMessage;
  }

  return error?.toString();
}
