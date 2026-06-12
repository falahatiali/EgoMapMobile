import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/profile_repository.dart';
import '../models/profile_models.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final profileProvider = FutureProvider<ProfilePayload>((ref) async {
  return ref.watch(profileRepositoryProvider).fetchProfile();
});

List<ProfileTestRecord> filterProfileTests(
  List<ProfileTestRecord> tests,
  ProfileTestsFilter filter,
) {
  return switch (filter) {
    ProfileTestsFilter.inProgress => tests.where((test) => test.isInProgress).toList(),
    ProfileTestsFilter.completed => tests.where((test) => !test.isInProgress).toList(),
    ProfileTestsFilter.all => tests,
  };
}
