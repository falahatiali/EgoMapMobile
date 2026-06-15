import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/virtue_models.dart';

const _kVirtueColor = Color(0xFF8B5CF6);

class VirtueRoutineCard extends StatelessWidget {
  const VirtueRoutineCard({
    super.key,
    required this.routine,
    required this.onTap,
  });

  final VirtueRoutine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final habit = routine.habit;
    final isActive = routine.isActive;
    final isCompleted = routine.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? EgColors.success.withValues(alpha: 0.06)
              : _kVirtueColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCompleted
                ? EgColors.success.withValues(alpha: 0.25)
                : _kVirtueColor.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? EgColors.success.withValues(alpha: 0.12)
                        : _kVirtueColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    habit?.categoryIcon ?? '✨',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit?.name ?? 'Habit',
                        style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        habit?.categoryLabel ?? '',
                        style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: EgColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, size: 13, color: EgColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Complete',
                          style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w600, color: EgColors.success),
                        ),
                      ],
                    ),
                  ),
                if (isActive)
                  const Icon(Icons.chevron_right_rounded, color: EgColors.slate500, size: 22),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 14),
              _ProgressBar(percent: routine.progressPercent),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatBadge(
                    icon: Icons.local_fire_department_rounded,
                    label: '${routine.currentStreak} day streak',
                    color: EgColors.warning,
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    icon: Icons.check_circle_outline_rounded,
                    label: '${routine.totalSuccesses} wins',
                    color: EgColors.success,
                  ),
                  const Spacer(),
                  Text(
                    '${routine.progressPercent.toStringAsFixed(0)}%',
                    style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: _kVirtueColor),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.percent});

  final double percent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: EgColors.borderSubtle,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                width: (constraints.maxWidth * percent / 100).clamp(0, constraints.maxWidth),
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_kVirtueColor, _kVirtueColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label, style: EgFonts.style(fontSize: 12, color: EgColors.slate400, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
