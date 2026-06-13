import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/mission_models.dart';

class MissionIconBadge extends StatelessWidget {
  const MissionIconBadge({
    super.key,
    required this.iconKey,
    this.size = 56,
    this.accent = EgColors.success,
  });

  final String iconKey;
  final double size;
  final Color accent;

  IconData get _icon {
    if (iconKey.contains('dumbbell')) {
      return Icons.fitness_center_rounded;
    }
    if (iconKey.contains('ghost')) {
      return Icons.shield_moon_outlined;
    }
    if (iconKey.contains('utensils')) {
      return Icons.restaurant_rounded;
    }
    if (iconKey.contains('capsules')) {
      return Icons.medication_liquid_rounded;
    }
    if (iconKey.contains('calendar')) {
      return Icons.calendar_month_rounded;
    }
    if (iconKey.contains('brain')) {
      return Icons.psychology_alt_rounded;
    }
    if (iconKey.contains('bag-shopping') || iconKey.contains('toolbox')) {
      return Icons.shopping_bag_outlined;
    }
    if (iconKey.contains('clipboard')) {
      return Icons.checklist_rounded;
    }
    if (iconKey.contains('book')) {
      return Icons.menu_book_rounded;
    }
    if (iconKey.contains('wallet')) {
      return Icons.account_balance_wallet_outlined;
    }
    if (iconKey.contains('chart')) {
      return Icons.show_chart_rounded;
    }
    if (iconKey.contains('list-check') || iconKey.contains('square-check')) {
      return Icons.check_box_outlined;
    }

    return Icons.flag_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.22),
            accent.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(_icon, color: accent, size: size * 0.46),
    );
  }
}

Color missionAccentColor(String accent) {
  return switch (accent) {
    'violet' || 'purple' => EgColors.accent,
    'amber' || 'warning' => EgColors.warning,
    _ => EgColors.success,
  };
}

class MissionTemplateTile extends StatelessWidget {
  const MissionTemplateTile({
    super.key,
    required this.template,
    required this.labels,
    required this.onTap,
    this.compact = false,
  });

  final MissionTemplateCard template;
  final MissionLabels labels;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = missionAccentColor(template.accent);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Ink(
          padding: EdgeInsets.all(compact ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            color: const Color(0x10FFFFFF),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MissionIconBadge(iconKey: template.icon, size: compact ? 48 : 56, accent: accent),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (template.isFeatured)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              labels.featured.toUpperCase(),
                              style: EgFonts.style(fontSize: 10, fontWeight: FontWeight.w700, color: accent),
                            ),
                          ),
                        Text(
                          template.title,
                          style: EgFonts.style(
                            fontSize: compact ? 18 : 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        if (template.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            template.category!,
                            style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (template.summary.isNotEmpty && !compact) ...[
                const SizedBox(height: 14),
                Text(
                  template.summary,
                  style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
                ),
              ],
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (template.estimatedDays != null)
                    _MetaChip(
                      icon: Icons.schedule_rounded,
                      label: labels.daysLabel(template.estimatedDays!),
                    ),
                  if (template.ghostModeRecommended)
                    _MetaChip(
                      icon: Icons.shield_moon_outlined,
                      label: labels.ghostHint,
                    ),
                  if (template.hasActiveEnrollment)
                    _MetaChip(
                      icon: Icons.play_circle_fill_rounded,
                      label: labels.continueMission,
                      accent: accent,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    this.accent = EgColors.slate400,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(label, style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w600, color: accent)),
        ],
      ),
    );
  }
}

class ActiveMissionHeroCard extends StatelessWidget {
  const ActiveMissionHeroCard({
    super.key,
    required this.enrollment,
    required this.labels,
    required this.onOpen,
  });

  final MissionEnrollmentSummary enrollment;
  final MissionLabels labels;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final accent = EgColors.success;
    final progress = enrollment.progressPercent.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(EgSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.18),
            const Color(0x12FFFFFF),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MissionIconBadge(iconKey: enrollment.icon, accent: accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enrollment.title,
                      style: EgFonts.style(fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                    ),
                    if (enrollment.currentPhaseTitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        enrollment.currentPhaseTitle!,
                        style: EgFonts.style(fontSize: 14, color: EgColors.slate400),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              color: accent,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: EgFonts.style(fontSize: 13, fontWeight: FontWeight.w700, color: accent),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EgSpacing.radius)),
            ),
            child: Text(
              labels.continueMission,
              style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
