import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/aether_program_models.dart';

class WorkoutDayCard extends StatelessWidget {
  const WorkoutDayCard({
    super.key,
    required this.day,
    required this.onTap,
    this.highlight = false,
  });

  final AetherWorkoutDay day;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final progress = day.completionRatio;
    final accent = highlight ? EgColors.success : const Color(0xFF818CF8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            border: Border.all(color: highlight ? accent.withValues(alpha: 0.55) : EgColors.borderSubtle),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: highlight
                  ? [accent.withValues(alpha: 0.16), const Color(0x08FFFFFF)]
                  : [const Color(0x0CFFFFFF), const Color(0x04FFFFFF)],
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      color: accent,
                    ),
                    Text(
                      '${day.dayIndex}',
                      style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(day.label, style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      day.focus,
                      style: EgFonts.style(fontSize: 13, height: 1.4, color: EgColors.slate400),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${day.exercises.length} exercises · ${day.completedSets}/${day.totalSets} sets',
                      style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w600, color: accent),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: highlight ? accent : EgColors.slate500),
            ],
          ),
        ),
      ),
    );
  }
}
