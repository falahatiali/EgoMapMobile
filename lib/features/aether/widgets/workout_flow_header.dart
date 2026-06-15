import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';

class WorkoutFlowHeader extends StatelessWidget {
  const WorkoutFlowHeader({super.key, required this.activeStep});

  final int activeStep;

  static const _steps = ['Plan', 'Train', 'Log'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_steps.length, (index) {
        final step = index + 1;
        final active = step <= activeStep;
        final current = step == activeStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: current ? 28 : 22,
                      height: current ? 28 : 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active ? EgColors.success : Colors.white.withValues(alpha: 0.08),
                        border: Border.all(
                          color: active ? EgColors.success : EgColors.borderSubtle,
                        ),
                        boxShadow: current
                            ? [
                                BoxShadow(
                                  color: EgColors.success.withValues(alpha: 0.35),
                                  blurRadius: 16,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$step',
                        style: EgFonts.style(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: active ? const Color(0xFF041016) : EgColors.slate500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _steps[index],
                      style: EgFonts.style(
                        fontSize: 12,
                        fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                        color: active ? EgColors.textPrimary : EgColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: step < activeStep
                            ? [EgColors.success, const Color(0xFF818CF8)]
                            : [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.08)],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
