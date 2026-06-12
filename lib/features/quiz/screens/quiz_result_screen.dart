import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_background.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../models/quiz_models.dart';
import '../widgets/quiz_stability_ring.dart';

class QuizResultScreen extends ConsumerStatefulWidget {
  const QuizResultScreen({super.key, required this.sessionUuid});

  final String sessionUuid;

  @override
  ConsumerState<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends ConsumerState<QuizResultScreen> {
  QuizResultPayload? _result;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final state = await ref.read(quizRepositoryProvider).fetchResult(widget.sessionUuid);
      final result = state.result;

      if (result == null) {
        throw ApiException(message: 'Result not ready yet.', statusCode: 404);
      }

      setState(() {
        _result = result;
        _loading = false;
        if (_emailController.text.isEmpty && result.email.address.isNotEmpty) {
          _emailController.text = result.email.address;
        }
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _loading = false;
      });
    }
  }

  Future<void> _sendReport() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || _sending) {
      return;
    }

    setState(() => _sending = true);

    try {
      final result = await ref.read(quizRepositoryProvider).sendReport(
            widget.sessionUuid,
            email,
          );

      setState(() {
        _result = result;
        _sending = false;
      });
    } on ApiException catch (error) {
      setState(() {
        _error = error.message;
        _sending = false;
      });
    }
  }

  Color _accent(QuizResultPayload result) {
    final hex = result.accentColor.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }

    return EgColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return EgBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: _loading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
                  ),
                )
              : _error != null && _result == null
                  ? _ErrorState(message: _error!, onRetry: _load)
                  : _buildContent(context, _result!),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, QuizResultPayload result) {
    final accent = _accent(result);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HeroSection(result: result, accent: accent)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(EgSpacing.page, 0, EgSpacing.page, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (result.disclaimer.isNotEmpty) ...[
                Text(
                  result.disclaimer,
                  style: EgFonts.style(fontSize: 13, height: 1.5, color: EgColors.slate500),
                ),
                const SizedBox(height: 20),
              ],
              if (result.stabilityScore != null)
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.stabilityTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          QuizStabilityRing(score: result.stabilityScore!, accent: accent),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              result.typeLabel,
                              style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
                            ),
                          ),
                        ],
                      ),
                      if (result.stabilityNote.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          result.stabilityNote,
                          style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                        ),
                      ],
                    ],
                  ),
                ),
              if (result.emergency) ...[
                const SizedBox(height: 16),
                _Panel(
                  borderColor: EgColors.danger.withValues(alpha: 0.35),
                  backgroundColor: EgColors.danger.withValues(alpha: 0.08),
                  child: Text(
                    result.emergencyAlert,
                    style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600, color: EgColors.danger),
                  ),
                ),
              ],
              if (result.prescription.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.firstPrescriptionTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(
                        result.prescription,
                        style: EgFonts.style(fontSize: 15, height: 1.6, color: EgColors.slate400),
                      ),
                    ],
                  ),
                ),
              ],
              ...result.sections.map(
                (section) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: _Panel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (section.heading.isNotEmpty)
                          Text(section.heading, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                        if (section.body.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(section.body, style: EgFonts.style(fontSize: 15, height: 1.6, color: EgColors.slate400)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (result.nextSteps.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.nextStepsTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...List.generate(result.nextSteps.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(alpha: 0.15),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: accent),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result.nextSteps[index],
                                  style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              if (result.dimensionRows.isNotEmpty) ...[
                const SizedBox(height: 16),
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result.dimensionBreakdownTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      ...result.dimensionRows.map((row) => _DimensionBar(row: row, accent: accent)),
                    ],
                  ),
                ),
              ],
              if (result.aiInsights != null) ...[
                const SizedBox(height: 16),
                _AiInsightsPanel(insights: result.aiInsights!, accent: accent),
              ],
              const SizedBox(height: 20),
              _EmailPanel(
                email: result.email,
                controller: _emailController,
                sending: _sending,
                onSend: _sendReport,
              ),
              if (result.accountCta != null) ...[
                const SizedBox(height: 16),
                _AccountCtaPanel(
                  cta: result.accountCta!,
                  onRegister: () => context.push('/register'),
                ),
              ],
              const SizedBox(height: 20),
              if (result.isAuthenticated)
                EgPrimaryButton(
                  label: result.profileLabel,
                  onPressed: () => context.go('/home'),
                )
              else
                EgPrimaryButton(
                  label: result.backHomeLabel,
                  onPressed: () => context.go('/'),
                ),
              const SizedBox(height: 12),
              if (!result.isAuthenticated)
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: Text('Sign in', style: EgFonts.style(fontSize: 14, color: EgColors.slate400)),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.result, required this.accent});

  final QuizResultPayload result;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.fromLTRB(EgSpacing.page, 28, EgSpacing.page, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0.18),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          Text(
            result.heroLabel.toUpperCase(),
            style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: accent),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accent.withValues(alpha: 0.3)),
            ),
            child: Text(
              result.typeLabel,
              style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.archetype,
            textAlign: TextAlign.center,
            style: EgFonts.style(fontSize: 30, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Text(
            result.tagline,
            textAlign: TextAlign.center,
            style: EgFonts.style(fontSize: 16, height: 1.6, color: EgColors.slate400),
          ),
          if (result.scoreTagline.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              result.scoreTagline,
              textAlign: TextAlign.center,
              style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: accent),
            ),
          ],
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.child,
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0x0AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor ?? EgColors.borderSubtle),
      ),
      child: child,
    );
  }
}

class _DimensionBar extends StatelessWidget {
  const _DimensionBar({required this.row, required this.accent});

  final QuizDimensionRow row;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final barColor = row.key == 'readiness' ? accent : const Color(0xFF60A5FA);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(row.label, style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600))),
              Text('${row.percent}%', style: EgFonts.style(fontSize: 13, color: EgColors.slate500)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: row.percent / 100),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: const Color(0x12FFFFFF),
                  color: barColor,
                );
              },
            ),
          ),
          if (row.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(row.description, style: EgFonts.style(fontSize: 12, height: 1.4, color: EgColors.slate500)),
          ],
        ],
      ),
    );
  }
}

class _AiInsightsPanel extends StatelessWidget {
  const _AiInsightsPanel({required this.insights, required this.accent});

  final QuizAiInsights insights;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(insights.title, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(insights.badge, style: EgFonts.style(fontSize: 10, fontWeight: FontWeight.w700, color: accent)),
              ),
            ],
          ),
          if (insights.summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(insights.summary, style: EgFonts.style(fontSize: 14, height: 1.6, color: EgColors.slate400)),
          ],
        ],
      ),
    );
  }
}

class _EmailPanel extends StatelessWidget {
  const _EmailPanel({
    required this.email,
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final QuizResultEmail email;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    if (email.sent) {
      return _Panel(
        borderColor: EgColors.success.withValues(alpha: 0.3),
        backgroundColor: EgColors.success.withValues(alpha: 0.08),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, color: EgColors.success, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(email.sentTitle, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
                  if (email.sentMessage != null) ...[
                    const SizedBox(height: 6),
                    Text(email.sentMessage!, style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400)),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(email.title, style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(email.description, style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400)),
          const SizedBox(height: 16),
          Text(email.label, style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: EgColors.slate500)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            style: EgFonts.style(fontSize: 15),
            decoration: InputDecoration(
              hintText: email.placeholder,
              filled: true,
              fillColor: const Color(0x08FFFFFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: EgColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: EgColors.borderSubtle),
              ),
            ),
          ),
          const SizedBox(height: 14),
          EgPrimaryButton(
            label: sending ? email.sending : email.submit,
            loading: sending,
            onPressed: sending ? null : onSend,
          ),
        ],
      ),
    );
  }
}

class _AccountCtaPanel extends StatelessWidget {
  const _AccountCtaPanel({required this.cta, required this.onRegister});

  final QuizAccountCta cta;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(cta.title, style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(cta.body, style: EgFonts.style(fontSize: 14, height: 1.55, color: EgColors.slate400)),
          const SizedBox(height: 16),
          EgPrimaryButton(label: cta.button, onPressed: onRegister),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(EgSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load result', style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: EgFonts.style(fontSize: 14, color: EgColors.slate500)),
            const SizedBox(height: 20),
            EgPrimaryButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
