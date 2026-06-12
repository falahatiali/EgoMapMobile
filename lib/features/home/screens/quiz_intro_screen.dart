import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/storage/app_local_storage.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/eg_surface.dart';
import '../../quiz/providers/quiz_entry_provider.dart';
import '../providers/bootstrap_provider.dart';

class QuizIntroScreen extends ConsumerStatefulWidget {
  const QuizIntroScreen({super.key});

  @override
  ConsumerState<QuizIntroScreen> createState() => _QuizIntroScreenState();
}

class _QuizIntroScreenState extends ConsumerState<QuizIntroScreen> {
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveEntry());
  }

  Future<void> _resolveEntry() async {
    final slug = ref.read(bootstrapProvider).maybeWhen(
          data: (data) => data.quiz.featuredSlug,
          orElse: () => null,
        );

    if (slug == null || !mounted) {
      return;
    }

    try {
      final entry = await ref.read(quizEntryProvider(slug).future);

      if (!mounted) {
        return;
      }

      if (entry.isShowPrevious && entry.returning != null) {
        context.pushReplacement('/quiz/returning?slug=$slug', extra: entry.returning);
        return;
      }

      if (entry.isResume && entry.sessionUuid != null) {
        context.pushReplacement('/quiz/session/${entry.sessionUuid}');
      }
    } catch (_) {}
  }

  Future<void> _begin(String slug, {bool forceFresh = false}) async {
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
      final savedUuid = forceFresh ? null : await storage.readQuizSessionUuid(slug);

      if (forceFresh) {
        await storage.delete(AppLocalStorage.quizSessionKey(slug));
      }

      final entry = await repository.fetchEntry(slug, resumeUuid: savedUuid);

      if (entry.guestToken != null && entry.guestToken!.isNotEmpty) {
        await storage.writeGuestToken(entry.guestToken!);
      }

      if (entry.isShowPrevious && entry.returning != null) {
        if (!mounted) {
          return;
        }

        context.pushReplacement('/quiz/returning?slug=$slug', extra: entry.returning);
        return;
      }

      if (entry.isResume && entry.sessionUuid != null) {
        await storage.writeQuizSessionUuid(slug, entry.sessionUuid!);

        if (!mounted) {
          return;
        }

        context.pushReplacement('/quiz/session/${entry.sessionUuid}');
        return;
      }

      final result = await repository.startSession(slug, forceFresh: true);

      await storage.writeQuizSessionUuid(slug, result.state.session.uuid);

      if (!mounted) {
        return;
      }

      context.pushReplacement('/quiz/session/${result.state.session.uuid}');
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

    return EgFlowScaffold(
      title: 'Step 1 · Scan',
      subtitle: 'Reboot Protocol check-in',
      body: bootstrap.when(
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
          ),
        ),
        error: (_, _) => const SizedBox.shrink(),
        data: (data) {
          final quiz = data.quiz;

          return Padding(
            padding: const EdgeInsets.all(EgSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 1',
                  style: EgFonts.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: EgColors.success,
                  ),
                ),
                const SizedBox(height: EgSpacing.sm),
                Text(
                  quiz.checkinTitle,
                  style: EgFonts.style(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: EgSpacing.sm),
                Text(
                  quiz.checkinSubtitle,
                  style: EgFonts.style(fontSize: 17, height: 1.55, color: EgColors.slate400),
                ),
                const SizedBox(height: EgSpacing.lg),
                const Expanded(
                  child: EgSurface(
                        padding: EdgeInsets.all(EgSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                      onPressed: () => _begin(quiz.featuredSlug, forceFresh: true),
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
