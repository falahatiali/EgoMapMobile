import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';
import 'core/storage/app_local_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ProviderScope(
      overrides: [
        appLocalStorageProvider.overrideWithValue(AppLocalStorage()),
      ],
      child: const EgoMapApp(),
    ),
  );
}
