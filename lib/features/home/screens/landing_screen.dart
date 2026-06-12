import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/storage/app_local_storage.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../quiz/models/quiz_models.dart';
import '../../quiz/providers/quiz_entry_provider.dart';
import '../models/bootstrap_models.dart';
import '../providers/bootstrap_provider.dart';
import '../widgets/hero_typed_line.dart';
import '../widgets/landing_atmosphere.dart';
import '../widgets/scan_preview_cards.dart';

class LandingScreen extends ConsumerWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(bootstrapProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        const LandingAtmosphere(),
        bootstrap.when(
          loading: () => const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
            ),
          ),
          error: (error, _) => _ErrorState(message: error.toString()),
          data: (data) => _LandingBody(
            landing: data.landing,
            quizSlug: data.quiz.featuredSlug,
          ),
        ),
      ],
    );
  }
}

class _LandingBody extends ConsumerWidget {
  const _LandingBody({
    required this.landing,
    required this.quizSlug,
  });

  final LandingContent landing;
  final String quizSlug;

  void _openQuiz(BuildContext context, QuizEntry entry) {
    HapticFeedback.lightImpact();

    if (entry.isShowPrevious && entry.returning != null) {
      context.push('/quiz/returning?slug=$quizSlug', extra: entry.returning);
      return;
    }

    if (entry.isResume && entry.sessionUuid != null) {
      context.push('/quiz/session/${entry.sessionUuid}');
      return;
    }

    context.push('/quiz-intro');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(quizEntryProvider(quizSlug));

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 12, EgSpacing.page, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            children: [
              Text(
                landing.coreMessage.toUpperCase(),
                textAlign: TextAlign.center,
                style: EgFonts.style(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                  color: EgColors.slate500,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                landing.heroTitle1,
                textAlign: TextAlign.center,
                style: EgFonts.style(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.7,
                  color: EgColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GradientText(
                landing.heroTitle2,
                textAlign: TextAlign.center,
                style: EgFonts.style(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.7,
                ),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF8FAFC), Color(0xFF6EE7B7)],
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: HeroTypedLine(
                  prefix: landing.heroTypedPrefix,
                  words: landing.heroTypedWords,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                landing.heroSubtitle,
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 17, height: 1.6, color: EgColors.slate400),
              ),
              const SizedBox(height: 32),
              _JourneySteps(
                landing: landing,
                quizEntry: entryAsync,
              ),
              const SizedBox(height: 28),
              entryAsync.when(
                loading: () => const EgPrimaryButton(
                  label: 'Loading…',
                  loading: true,
                  backgroundColor: EgColors.success,
                  onPressed: null,
                ),
                error: (_, __) => EgPrimaryButton(
                  label: landing.ctaStep1,
                  icon: Icons.play_arrow_rounded,
                  backgroundColor: EgColors.success,
                  onPressed: () => context.push('/quiz-intro'),
                ),
                data: (entry) => Column(
                  children: [
                    EgPrimaryButton(
                      label: _scanButtonLabel(entry, landing),
                      icon: _scanButtonIcon(entry),
                      backgroundColor: EgColors.success,
                      onPressed: () => _openQuiz(context, entry),
                    ),
                    if (entry.isShowPrevious) ...[
                      const SizedBox(height: 14),
                      EgPrimaryButton(
                        label: entry.returning?.retakeLabel ?? 'Retake scan',
                        expanded: true,
                        onPressed: () async {
                          await ref.read(appLocalStorageProvider).delete(
                                AppLocalStorage.quizSessionKey(quizSlug),
                              );
                          ref.invalidate(quizEntryProvider(quizSlug));
                          if (context.mounted) {
                            context.push('/quiz-intro');
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                landing.ctaStep1Note,
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 15, height: 1.45, color: EgColors.slate500),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                height: 1,
                color: EgColors.borderSubtle,
              ),
              const SizedBox(height: 28),
              Text(
                'After the scan, you\'ll get:',
                textAlign: TextAlign.center,
                style: EgFonts.style(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: EgColors.slate400,
                ),
              ),
              const SizedBox(height: 20),
              const ScanPreviewCards(),
            ],
          ),
        ),
      ),
    );
  }

  String _scanButtonLabel(QuizEntry entry, LandingContent landing) {
    if (entry.isShowPrevious) {
      return entry.returning?.viewResultLabel ?? 'View your snapshot';
    }

    if (entry.isResume) {
      return 'Continue your scan';
    }

    return landing.ctaStep1;
  }

  IconData _scanButtonIcon(QuizEntry entry) {
    if (entry.isShowPrevious) {
      return Icons.insights_rounded;
    }

    if (entry.isResume) {
      return Icons.play_circle_outline_rounded;
    }

    return Icons.play_arrow_rounded;
  }
}

class _JourneySteps extends StatelessWidget {
  const _JourneySteps({
    required this.landing,
    required this.quizEntry,
  });

  final LandingContent landing;
  final AsyncValue<QuizEntry> quizEntry;

  @override
  Widget build(BuildContext context) {
    final scanDone = quizEntry.maybeWhen(
      data: (entry) => entry.isShowPrevious,
      orElse: () => false,
    );

    return Column(
      children: [
        for (var i = 0; i < landing.steps.length; i++) ...[
          _StepRow(
            index: i + 1,
            title: landing.steps[i].title,
            description: landing.steps[i].description,
            done: i == 0 && scanDone,
          ),
          if (i < landing.steps.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.description,
    required this.done,
  });

  final int index;
  final String title;
  final String description;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done ? EgColors.success.withValues(alpha: 0.15) : const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: done ? EgColors.success : EgColors.borderSubtle),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 16, color: EgColors.success)
              : Text(
                  '$index',
                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.slate400),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(description, style: EgFonts.style(fontSize: 15, height: 1.45, color: EgColors.slate500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Connection failed', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}
