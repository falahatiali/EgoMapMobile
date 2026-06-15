import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../missions/models/mission_models.dart';

/// Shows the first active mission or a "browse" CTA on the Today screen.
class TodayActiveMissionCard extends StatelessWidget {
  const TodayActiveMissionCard({
    super.key,
    required this.hub,
    required this.loading,
    required this.onOpen,
    required this.onBrowse,
  });

  final MissionHubState? hub;
  final bool loading;

  /// Called with the enrollment UUID when the user taps an active mission.
  final ValueChanged<String> onOpen;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 80,
        decoration: BoxDecoration(
          color: EgColors.navy900.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
          border: Border.all(color: EgColors.borderSubtle),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: EgColors.accent),
          ),
        ),
      );
    }

    final active = hub?.activeEnrollments ?? [];

    if (active.isEmpty) {
      return _NoMissionCard(onBrowse: onBrowse);
    }

    return _ActiveMissionCard(
      mission: active.first,
      onOpen: () => onOpen(active.first.uuid),
    );
  }
}

class _ActiveMissionCard extends StatelessWidget {
  const _ActiveMissionCard({required this.mission, required this.onOpen});

  final MissionEnrollmentSummary mission;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final percent = mission.progressPercent.round();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(EgSpacing.lg),
          decoration: BoxDecoration(
            color: EgColors.accent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            border: Border.all(color: EgColors.accent.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: EgColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.flag_rounded, size: 20, color: EgColors.accentBright),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTIVE MISSION',
                          style: EgFonts.style(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: EgColors.accentBright,
                          ),
                        ),
                        Text(
                          mission.title,
                          style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EgColors.slate500),
                ],
              ),
              if (mission.currentPhaseTitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  mission.currentPhaseTitle!,
                  style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: mission.progressPercent / 100.0,
                        backgroundColor: EgColors.accentBright.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation(EgColors.accentBright),
                        minHeight: 5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$percent%',
                    style: EgFonts.style(fontSize: 12, fontWeight: FontWeight.w700, color: EgColors.accentBright),
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

class _NoMissionCard extends StatelessWidget {
  const _NoMissionCard({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onBrowse,
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(EgSpacing.lg),
          decoration: BoxDecoration(
            color: EgColors.navy900.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: EgColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.route_rounded, size: 20, color: EgColors.accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No active mission',
                      style: EgFonts.style(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Browse missions to start your journey',
                      style: EgFonts.style(fontSize: 13, color: EgColors.slate400),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: EgColors.slate500),
            ],
          ),
        ),
      ),
    );
  }
}
