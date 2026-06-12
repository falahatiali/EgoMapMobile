import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/app_header_bar.dart';
import '../../../core/widgets/eg_primary_button.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../auth/models/auth_models.dart';
import '../../auth/providers/auth_controller.dart';
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
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: EgColors.navy950,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const LandingAtmosphere(),
          SafeArea(
            child: bootstrap.when(
              loading: () => const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.success),
                ),
              ),
              error: (error, _) => _ErrorState(message: error.toString()),
              data: (data) => _LandingBody(
                landing: data.landing,
                user: auth.user,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LandingBody extends StatelessWidget {
  const _LandingBody({
    required this.landing,
    required this.user,
  });

  final LandingContent landing;
  final UserModel? user;

  void _startScan(BuildContext context) {
    HapticFeedback.lightImpact();
    context.push('/quiz-intro');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeaderBar(
          brandLabel: landing.terminalBar,
          user: user,
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    Text(
                      landing.coreMessage.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: EgFonts.style(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.4,
                        color: EgColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      landing.heroTitle1,
                      textAlign: TextAlign.center,
                      style: EgFonts.style(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.6,
                        color: EgColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    GradientText(
                      landing.heroTitle2,
                      textAlign: TextAlign.center,
                      style: EgFonts.style(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        letterSpacing: -0.6,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF8FAFC), Color(0xFF6EE7B7)],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: HeroTypedLine(
                        prefix: landing.heroTypedPrefix,
                        words: landing.heroTypedWords,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      landing.heroSubtitle,
                      textAlign: TextAlign.center,
                      style: EgFonts.style(fontSize: 15, height: 1.65, color: EgColors.slate400),
                    ),
                    const SizedBox(height: 40),
                    EgPrimaryButton(
                      label: 'Start your scan',
                      icon: Icons.play_arrow_rounded,
                      backgroundColor: EgColors.success,
                      onPressed: () => _startScan(context),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '2-minute check-in · Free · No account',
                      textAlign: TextAlign.center,
                      style: EgFonts.style(fontSize: 13, height: 1.45, color: EgColors.slate500),
                    ),
                    const SizedBox(height: 48),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: EgColors.borderSubtle,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'After the scan, you\'ll get:',
                      textAlign: TextAlign.center,
                      style: EgFonts.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: EgColors.slate400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const ScanPreviewCards(),
                    const SizedBox(height: 20),
                    Text(
                      '→ Your personal snapshot',
                      textAlign: TextAlign.center,
                      style: EgFonts.style(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: EgColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
