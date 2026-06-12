import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_surface.dart';
import '../models/profile_models.dart';

class ProfileTestCard extends StatelessWidget {
  const ProfileTestCard({
    super.key,
    required this.record,
    required this.onTap,
  });

  final ProfileTestRecord record;
  final VoidCallback onTap;

  Color get _accent {
    final hex = record.palette.accent.replaceFirst('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }

    return EgColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return EgSurface(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(EgSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _BadgeIcon(record: record, accent: _accent),
                    const SizedBox(width: 12),
                    _StatusBadge(
                      label: record.statusLabel,
                      isInProgress: record.isInProgress,
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_rounded, size: 18, color: EgColors.slate500),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  record.quizName,
                  style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w700, height: 1.25),
                ),
                if (record.isInProgress) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${record.progressPercent}% · question ${record.currentQuestion} of ${record.totalQuestions}',
                    style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: record.progressPercent / 100,
                      minHeight: 6,
                      backgroundColor: const Color(0x18FFFFFF),
                      color: _accent,
                    ),
                  ),
                ] else ...[
                  if (record.resultTitle != null && record.resultTitle!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      record.resultTitle!,
                      style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w600, color: EgColors.textPrimary),
                    ),
                  ],
                  if (record.tagline != null && record.tagline!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      record.tagline!,
                      style: EgFonts.style(fontSize: 13, height: 1.45, color: EgColors.slate400),
                    ),
                  ],
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      record.isInProgress ? Icons.schedule_outlined : Icons.event_available_outlined,
                      size: 14,
                      color: EgColors.slate500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        record.isInProgress
                            ? 'Started ${record.startedAtLabel ?? '—'}'
                            : 'Completed ${record.completedAtLabel ?? '—'}',
                        style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({required this.record, required this.accent});

  final ProfileTestRecord record;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: record.isRebootProtocol
          ? Icon(Icons.shield_moon_outlined, color: accent, size: 20)
          : Text(
              (record.typeCode ?? '?').toUpperCase(),
              style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w800, color: accent),
            ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.isInProgress});

  final String label;
  final bool isInProgress;

  @override
  Widget build(BuildContext context) {
    final color = isInProgress ? EgColors.warning : EgColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: EgFonts.style(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.6, color: color),
      ),
    );
  }
}
