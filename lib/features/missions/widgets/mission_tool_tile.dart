import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/mission_workspace_models.dart';
import 'mission_template_tile.dart';

class MissionToolTile extends StatelessWidget {
  const MissionToolTile({
    super.key,
    required this.tool,
    required this.accent,
    required this.onTap,
  });

  final MissionTool tool;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = tool.isLocked;
    final snippet = tool.snippet;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            color: locked
                ? Colors.white.withValues(alpha: 0.04)
                : accent.withValues(alpha: 0.08),
            border: Border.all(
              color: locked
                  ? EgColors.borderSubtle
                  : accent.withValues(alpha: 0.28),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MissionIconBadge(iconKey: tool.icon, size: 44, accent: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tool.label,
                            style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Icon(
                          locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                          size: 20,
                          color: EgColors.slate500,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locked
                          ? (tool.lock?.message ?? 'Tap to unlock')
                          : (snippet?.detail ?? 'Ready'),
                      style: EgFonts.style(fontSize: 13, height: 1.4, color: EgColors.slate400),
                    ),
                    if (!locked && snippet != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        snippet.headline,
                        style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w600, color: accent),
                      ),
                      if (snippet.metric != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${snippet.metric!.label}: ${snippet.metric!.value}',
                          style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                        ),
                      ],
                    ],
                    if (tool.insight != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(EgSpacing.radius),
                          color: accent.withValues(alpha: 0.08),
                        ),
                        child: Text(
                          tool.insight!.text,
                          style: EgFonts.style(fontSize: 12, height: 1.45, color: EgColors.slate400),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
