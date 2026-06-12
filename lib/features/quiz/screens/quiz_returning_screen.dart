import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/storage/app_local_storage.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/quiz_models.dart';

class QuizReturningScreen extends ConsumerWidget {
  const QuizReturningScreen({
    super.key,
    required this.slug,
    required this.preview,
  });

  final String slug;
  final QuizReturningPreview preview;

  Future<void> _retake(WidgetRef ref, BuildContext context) async {
    final storage = ref.read(appLocalStorageProvider);
    await storage.delete(AppLocalStorage.quizSessionKey(slug));

    if (context.mounted) {
      context.pushReplacement('/quiz-intro');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EgFlowScaffold(
      title: preview.quizName,
      subtitle: preview.eyebrow,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(EgSpacing.page),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: EgSurface(
              padding: const EdgeInsets.all(EgSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: EgColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      preview.typeCode.toUpperCase(),
                      style: EgFonts.style(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: EgColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    preview.title,
                    textAlign: TextAlign.center,
                    style: EgFonts.style(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    preview.summary,
                    textAlign: TextAlign.center,
                    style: EgFonts.style(fontSize: 17, height: 1.55, color: EgColors.slate400),
                  ),
                  const SizedBox(height: 32),
                  EgPrimaryButton(
                    label: preview.viewResultLabel,
                    icon: Icons.insights_rounded,
                    backgroundColor: EgColors.success,
                    onPressed: () => context.go('/quiz/session/${preview.sessionUuid}/result'),
                  ),
                  const SizedBox(height: 12),
                  EgPrimaryButton(
                    label: preview.retakeLabel,
                    expanded: true,
                    onPressed: () => _retake(ref, context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
