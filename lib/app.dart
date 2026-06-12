import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/eg_theme.dart';

class EgoMapApp extends ConsumerWidget {
  const EgoMapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.read(appRouterProvider);

    return MaterialApp.router(
      title: 'EgoMap',
      debugShowCheckedModeBanner: false,
      theme: EgTheme.dark(),
      routerConfig: router,
    );
  }
}
