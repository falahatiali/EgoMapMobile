import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/ghost_mode_models.dart';

class GhostModeShieldRing extends StatelessWidget {
  const GhostModeShieldRing({
    super.key,
    required this.percent,
    required this.copy,
    required this.day,
    required this.totalDays,
  });

  final int percent;
  final GhostModeCopy copy;
  final int day;
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final value = (percent / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EgColors.navy900.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 10,
                    backgroundColor: EgColors.success.withValues(alpha: 0.12),
                    color: EgColors.success,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      copy.shieldTitle,
                      textAlign: TextAlign.center,
                      style: EgFonts.style(fontSize: 11, fontWeight: FontWeight.w600, color: EgColors.slate500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      copy.shieldPercentLabel(percent),
                      style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800, color: EgColors.success),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      copy.dayOfLabel(day, totalDays),
                      style: EgFonts.style(fontSize: 12, color: EgColors.slate400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
