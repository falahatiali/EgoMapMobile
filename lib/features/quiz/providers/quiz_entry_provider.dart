import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../data/quiz_repository.dart';
import '../models/quiz_models.dart';

final quizEntryProvider = FutureProvider.family<QuizEntry, String>((ref, slug) async {
  final storage = ref.read(appLocalStorageProvider);
  final repository = ref.read(quizRepositoryProvider);
  final savedUuid = await storage.readQuizSessionUuid(slug);

  final entry = await repository.fetchEntry(slug, resumeUuid: savedUuid);

  if (entry.guestToken != null && entry.guestToken!.isNotEmpty) {
    await storage.writeGuestToken(entry.guestToken!);
  }

  if (entry.sessionUuid != null) {
    await storage.writeQuizSessionUuid(slug, entry.sessionUuid!);
  }

  return entry;
});
