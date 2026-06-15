import 'package:flutter/material.dart';

import '../../../../core/theme/eg_colors.dart';
import '../../../../core/theme/eg_fonts.dart';

class AetherWizardProgress extends StatelessWidget {
  const AetherWizardProgress({
    super.key,
    required this.current,
    required this.total,
  });

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                color: Colors.transparent,
              );
            },
          ),
        ),
        const SizedBox(height: 2),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFF34D399), Color(0xFF818CF8)],
          ).createShader(bounds),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: Colors.transparent,
                color: Colors.white,
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Step $current of $total',
          style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w600, color: EgColors.slate500),
        ),
      ],
    );
  }
}
