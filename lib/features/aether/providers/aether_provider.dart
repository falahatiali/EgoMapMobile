import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/aether_repository.dart';
import '../models/aether_checkin_models.dart';
import '../models/aether_program_models.dart';
import '../models/aether_volume_models.dart';

final aetherRepositoryProvider = Provider<AetherRepository>((ref) {
  return AetherRepository(ref.watch(apiClientProvider));
});

final aetherProgramProvider = FutureProvider.autoDispose.family<AetherProgramDetail, String>((ref, uuid) async {
  return ref.read(aetherRepositoryProvider).fetchProgram(uuid);
});

final checkInStatusProvider = FutureProvider.autoDispose.family<AetherCheckInStatus, String>((ref, uuid) async {
  return ref.read(aetherRepositoryProvider).fetchCheckInStatus(uuid);
});

final volumeChartProvider = FutureProvider.autoDispose.family<AetherVolumeChart, String>((ref, uuid) async {
  return ref.read(aetherRepositoryProvider).fetchVolumeChart(uuid);
});
