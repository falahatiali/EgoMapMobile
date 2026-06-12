import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_background.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../providers/bootstrap_provider.dart';

class QuizIntroScreen extends ConsumerStatefulWidget {
  const QuizIntroScreen({super.key});

  @override
  ConsumerState<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends ConsumerState<QuizIntroScreen> {
  bool _starting = false;
  String? _error;

  Future<void> _begin(String slug) async {
    if (_starting) {
      return;
    }

    setState(() {
      _starting = true;
      _error = null;
    });

    HapticFeedback.lightImpact();

    try {
      final storage = ref.read(appLocalStorageProvider);
      final repository = ref.read(quizRepositoryProvider);
      final savedUuid = await storage.readQuizSessionUuid(slug);

      final result = await repository.startSession(
        slug,
        resumeUuid: savedUuid,
      );

      await storage.writeQuizSessionUuid(slug, result.state.session.uuid);

      if (!mounted) {
        return;
      }

      context.push('/quiz/session/${result.state.session.uuid}');
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _starting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bootstrap = ref.watch(bootstrapProvider);

    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
        ),
        body: SafeArea(
          child: bootstrap.when(
            loading: () => const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
            data: (data) {
              final quiz = data.quiz;
              final welcome = quiz.checkinTitle;

              return Padding(
                padding: const EdgeInsets.all(EgSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 1',
                      style: EgFonts.style(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: EgColors.success,
                      ),
                    ),
                    const SizedBox(height: EgSpacing.sm),
                    Text(
                      welcome,
                      style: EgFonts.style(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: EgSpacing.sm),
                    Text(
                      quiz.checkinSubtitle,
                      style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
                    ),
                    const SizedBox(height: EgSpacing.lg),
                    Expanded(
                      child: EgSurface(
                        padding: const EdgeInsets.all(EgSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            _PreviewRow(
                              icon: '📍',
                              title: 'Where you are right now',
                              subtitle: 'Current emotional state',
                            ),
                            SizedBox(height: 16),
                            _PreviewRow(
                              icon: '⚠️',
                              title: 'Risk you face tonight',
                              subtitle: 'What could make it worse',
                            ),
                            SizedBox(height: 16),
                            _PreviewRow(
                              icon: '🎯',
                              title: 'First need',
                              subtitle: 'Your personalized first move',
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: EgFonts.style(fontSize: 13, color: EgColors.danger),
                      ),
                    ],
                    const SizedBox(height: EgSpacing.lg),
                    EgPrimaryButton(
                      label: quiz.checkinCta,
                      icon: Icons.play_arrow_rounded,
                      loading: _starting,
                      backgroundColor: EgColors.success,
                      onPressed: () => _begin(quiz.featuredSlug),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '2-minute check-in · Free · No account',
                      textAlign: TextAlign.center,
                      style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: EgFonts.style(fontSize: 13, height: 1.4, color: EgColors.slate500)),
            ],
          ),
        ),
      ],
    );
  }
}
