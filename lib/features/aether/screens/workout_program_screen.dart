import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../models/aether_checkin_models.dart';
import '../models/aether_program_models.dart';
import '../providers/aether_provider.dart';
import '../widgets/volume_chart_card.dart';
import '../widgets/weekly_checkin_sheet.dart';
import '../widgets/workout_day_card.dart';
import '../widgets/workout_flow_header.dart';

class WorkoutProgramScreen extends ConsumerWidget {
  const WorkoutProgramScreen({super.key, required this.programUuid});

  final String programUuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(aetherProgramProvider(programUuid));

    return programAsync.when(
      loading: () => const EgFlowScaffold(
        title: 'Workout plan',
        body: Center(child: CircularProgressIndicator(color: EgColors.success)),
      ),
      error: (_, __) => EgFlowScaffold(
        title: 'Workout plan',
        body: Center(
          child: Text(
            'Could not load your plan.',
            style: EgFonts.style(color: EgColors.slate400),
          ),
        ),
      ),
      data: (detail) => _ProgramBody(
        program: detail.program,
        programUuid: programUuid,
      ),
    );
  }
}

class _ProgramBody extends ConsumerStatefulWidget {
  const _ProgramBody({required this.program, required this.programUuid});

  final AetherProgram program;
  final String programUuid;

  @override
  ConsumerState<_ProgramBody> createState() => _ProgramBodyState();
}

class _ProgramBodyState extends ConsumerState<_ProgramBody> {
  AetherCheckInResult? _checkInResult;

  @override
  Widget build(BuildContext context) {
    final program = widget.program;
    final checkInAsync = ref.watch(checkInStatusProvider(widget.programUuid));

    final adherence = program.adherencePercent ??
        (program.totalSets == 0
            ? 0
            : ((program.completedSets / program.totalSets) * 100).round());

    AetherWorkoutDay? nextDay;
    for (final day in program.workoutDays) {
      if (day.completionRatio < 1) {
        nextDay = day;
        break;
      }
    }
    nextDay ??=
        program.workoutDays.isNotEmpty ? program.workoutDays.first : null;

    return EgFlowScaffold(
      title: 'Workout plan',
      subtitle: program.missionTitle ?? program.summary,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          EgSpacing.page, EgSpacing.page, EgSpacing.page, 100,
        ),
        children: [
          const WorkoutFlowHeader(activeStep: 1),
          const SizedBox(height: 20),

          // ── Check-in prompt (shown when due) ─────────────────────────
          if (_checkInResult != null) ...[
            _CoachingResultCard(result: _checkInResult!),
            const SizedBox(height: 14),
          ] else
            checkInAsync.when(
              data: (status) => status.isDue
                  ? _CheckInPromptCard(
                      weekNumber: status.currentWeek - 1,
                      onTap: () => _openCheckIn(context, status.currentWeek),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // ── Adherence card ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(EgSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
              gradient: LinearGradient(
                colors: [
                  EgColors.success.withValues(alpha: 0.18),
                  const Color(0x10818CF8),
                ],
              ),
              border: Border.all(color: EgColors.success.withValues(alpha: 0.28)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: adherence / 100,
                        strokeWidth: 6,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.08),
                        color: EgColors.success,
                      ),
                      Text(
                        '$adherence%',
                        style: EgFonts.style(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week adherence',
                        style: EgFonts.style(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${program.completedSets} of ${program.totalSets} sets logged',
                        style: EgFonts.style(
                          fontSize: 14,
                          height: 1.45,
                          color: EgColors.slate400,
                        ),
                      ),
                      if (nextDay != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Up next: ${nextDay.label}',
                          style: EgFonts.style(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EgColors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Coach focus ───────────────────────────────────────────────
          if (program.coach.weekFocus != null &&
              program.coach.weekFocus!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
                color: Colors.white.withValues(alpha: 0.04),
                border: Border.all(color: EgColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coach focus',
                    style: EgFonts.style(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EgColors.success,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    program.coach.weekFocus!,
                    style: EgFonts.style(fontSize: 15, height: 1.5),
                  ),
                ],
              ),
            ),
          ],

          // ── Volume chart ──────────────────────────────────────────────
          const SizedBox(height: 16),
          VolumeChartCard(programUuid: widget.programUuid),

          // ── Training days ─────────────────────────────────────────────
          const SizedBox(height: 24),
          Text(
            'Your training days',
            style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Pick a day. Follow the exercises. Tap each set when done.',
            style: EgFonts.style(
              fontSize: 14,
              height: 1.5,
              color: EgColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          ...program.workoutDays.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: WorkoutDayCard(
                day: day,
                highlight: nextDay?.id == day.id,
                onTap: () => context.push(
                  '/aether/programs/${program.uuid}/days/${day.id}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openCheckIn(BuildContext context, int currentWeek) async {
    final result = await WeeklyCheckInSheet.show(
      context,
      programUuid: widget.programUuid,
      currentWeek: currentWeek,
    );

    if (result != null && mounted) {
      setState(() => _checkInResult = result);
    }
  }
}

// ─── Check-in prompt banner ───────────────────────────────────────────────────

class _CheckInPromptCard extends StatelessWidget {
  const _CheckInPromptCard({
    required this.weekNumber,
    required this.onTap,
  });

  final int weekNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
          gradient: LinearGradient(
            colors: [
              EgColors.accentBright.withValues(alpha: 0.15),
              EgColors.accent.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(color: EgColors.accentBright.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: EgColors.accentBright.withValues(alpha: 0.15),
              ),
              child: const Text('📋', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Week $weekNumber check-in ready',
                    style: EgFonts.style(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: EgColors.accentBright,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Answer 3 quick questions so we can optimize next week.',
                    style: EgFonts.style(
                      fontSize: 13,
                      height: 1.4,
                      color: EgColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: EgColors.accentBright),
          ],
        ),
      ),
    );
  }
}

// ─── Coaching result card (shown after submission) ────────────────────────────

class _CoachingResultCard extends StatelessWidget {
  const _CoachingResultCard({required this.result});

  final AetherCheckInResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        gradient: LinearGradient(
          colors: [
            EgColors.success.withValues(alpha: 0.14),
            EgColors.accentBright.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏋️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'Coach response',
                style: EgFonts.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: EgColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.coachingMessage,
            style: EgFonts.style(fontSize: 15, height: 1.55),
          ),
          if (result.adjustmentHint != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.05),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: EgColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.adjustmentHint!,
                      style: EgFonts.style(
                        fontSize: 13,
                        height: 1.5,
                        color: EgColors.slate400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
