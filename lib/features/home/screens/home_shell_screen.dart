import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/theme/eg_text.dart';
import '../../../core/widgets/eg_background.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../auth/providers/auth_controller.dart';

class HomeShellScreen extends ConsumerWidget {
  const HomeShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Recovery OS', style: EgText.label(color: EgColors.textPrimary)),
          actions: [
            IconButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
              icon: const Icon(Icons.logout_rounded, size: 20),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(EgSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back', style: EgText.display(context).copyWith(fontSize: 26)),
                const SizedBox(height: EgSpacing.sm),
                Text(user?.email ?? '', style: EgText.body(context)),
                const Spacer(),
                EgPrimaryButton(
                  label: 'Start Step 1',
                  icon: Icons.bolt_rounded,
                  onPressed: () => context.push('/quiz-intro'),
                ),
                const SizedBox(height: EgSpacing.sm),
                EgPrimaryButton(
                  label: 'Back to landing',
                  onPressed: () => context.go('/'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
