import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../models/bootstrap_models.dart';

final bootstrapProvider = FutureProvider<BootstrapPayload>((ref) async {
  final repository = ref.watch(bootstrapRepositoryProvider);
  return repository.fetch();
});
