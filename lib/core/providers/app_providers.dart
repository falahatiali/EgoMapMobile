import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../storage/app_local_storage.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/home/data/bootstrap_repository.dart';
import '../../features/quiz/data/quiz_repository.dart';

final appLocalStorageProvider = Provider<AppLocalStorage>((ref) {
  throw StateError('AppLocalStorage has not been initialized.');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(storage: ref.watch(appLocalStorageProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final bootstrapRepositoryProvider = Provider<BootstrapRepository>((ref) {
  return BootstrapRepository(ref.watch(apiClientProvider));
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(apiClientProvider));
});
