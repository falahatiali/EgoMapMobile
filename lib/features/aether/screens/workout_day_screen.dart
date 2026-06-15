import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../../../core/widgets/eg_flow_scaffold.dart';
import '../models/aether_program_models.dart';
import '../providers/aether_provider.dart';
import '../widgets/rest_timer_sheet.dart';
import '../widgets/weight_input_sheet.dart';
import '../widgets/workout_exercise_card.dart';
import '../widgets/workout_flow_header.dart';

/// Default rest durations by goal / set characteristics, used when the
/// server does not return a [AetherWorkoutSet.restSeconds].
const int _kDefaultRestSeconds = 90;
const int _kHeavyRestSeconds = 120; // strength / compound lifts
const int _kLightRestSeconds = 45; // isolation / cardio sets

class WorkoutDayScreen extends ConsumerStatefulWidget {
  const WorkoutDayScreen({
    super.key,
    required this.programUuid,
    required this.dayId,
  });

  final String programUuid;
  final int dayId;

  @override
  ConsumerState<WorkoutDayScreen> createState() => _WorkoutDayScreenState();
}

class _WorkoutDayScreenState extends ConsumerState<WorkoutDayScreen> {
  int? _togglingSetId;

  @override
  Widget build(BuildContext context) {
    final programAsync = ref.watch(aetherProgramProvider(widget.programUuid));

    return programAsync.when(
      loading: () => const EgFlowScaffold(
        title: 'Training day',
        body: Center(child: CircularProgressIndicator(color: EgColors.success)),
      ),
      error: (_, __) => const EgFlowScaffold(
        title: 'Training day',
        body: Center(child: Text('Could not load this day.')),
      ),
      data: (detail) {
        // Find the requested day.
        AetherWorkoutDay? day;
        for (final item in detail.program.workoutDays) {
          if (item.id == widget.dayId) {
            day = item;
            break;
          }
        }

        if (day == null) {
          return const EgFlowScaffold(
            title: 'Training day',
            body: Center(child: Text('Day not found.')),
          );
        }

        final selectedDay = day;
        final progress = selectedDay.completionRatio;
        final allDone = progress >= 1 && selectedDay.totalSets > 0;

        return EgFlowScaffold(
          title: selectedDay.label,
          subtitle: selectedDay.focus,
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              EgSpacing.page, EgSpacing.page, EgSpacing.page, 120,
            ),
            children: [
              // ── Step indicator ──────────────────────────────────────────
              const WorkoutFlowHeader(activeStep: 2),
              const SizedBox(height: 20),

              // ── Session progress bar ────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  color: allDone ? EgColors.success : EgColors.accentBright,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                allDone
                    ? '🎉 Day complete!'
                    : '${selectedDay.completedSets}/${selectedDay.totalSets} sets done',
                style: EgFonts.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: allDone ? EgColors.success : EgColors.accentBright,
                ),
              ),

              const SizedBox(height: 20),

              // ── Heading ─────────────────────────────────────────────────
              Text(
                'Exercises',
                style: EgFonts.style(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap a set when you finish it — a rest timer starts automatically.',
                style: EgFonts.style(
                  fontSize: 14,
                  height: 1.5,
                  color: EgColors.slate400,
                ),
              ),
              const SizedBox(height: 16),

              // ── Exercise cards ──────────────────────────────────────────
              ...selectedDay.exercises.map(
                (exercise) => WorkoutExerciseCard(
                  exercise: exercise,
                  togglingSetId: _togglingSetId,
                  // Completing a set → API call → rest timer
                  onSetCompleted: (set) => _completeSet(
                    dayId: selectedDay.id,
                    set: set,
                    exerciseName: exercise.name,
                    nextSetLabel: _nextSetLabel(exercise, set),
                  ),
                  // Un-completing a set → API call, no timer
                  onSetUncompleted: (set) => _uncompleteSet(
                    dayId: selectedDay.id,
                    set: set,
                  ),
                ),
              ),

              // ── Completion nudge ────────────────────────────────────────
              const SizedBox(height: 12),
              if (allDone) ...[
                _DayCompleteCard(),
                const SizedBox(height: 16),
              ],

              WorkoutFlowHeader(activeStep: allDone ? 3 : 2),
              const SizedBox(height: 8),
              Text(
                allDone
                    ? 'You crushed it. See you next session 💪'
                    : 'Logged sets sync your adherence in real time.',
                textAlign: TextAlign.center,
                style: EgFonts.style(fontSize: 13, color: EgColors.slate500),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Label shown inside the rest timer: "Next: Set 3 — 8–10 reps"
  String? _nextSetLabel(AetherWorkoutExercise exercise, AetherWorkoutSet set) {
    final nextIndex = exercise.sets.indexWhere((s) => s.id == set.id) + 1;
    if (nextIndex >= exercise.sets.length) {
      return null;
    }
    final nextSet = exercise.sets[nextIndex];
    return 'Next: Set ${nextSet.setNumber} — ${nextSet.repsLabel}';
  }

  /// Rest duration: prefer server value, fall back to a sensible default.
  int _restDuration(AetherWorkoutSet set) {
    if (set.restSeconds != null && set.restSeconds! > 0) {
      return set.restSeconds!;
    }
    // Heuristic: heavy compound = longer rest.
    if (set.targetRepsMax != null && set.targetRepsMax! <= 6) {
      return _kHeavyRestSeconds;
    }
    if (set.targetRepsMin != null && set.targetRepsMin! >= 15) {
      return _kLightRestSeconds;
    }
    return _kDefaultRestSeconds;
  }

  // ─── Actions ─────────────────────────────────────────────────────────────

  Future<void> _completeSet({
    required int dayId,
    required AetherWorkoutSet set,
    required String exerciseName,
    String? nextSetLabel,
  }) async {
    setState(() => _togglingSetId = set.id);

    try {
      await ref.read(aetherRepositoryProvider).toggleSet(
            programUuid: widget.programUuid,
            dayId: dayId,
            setId: set.id,
          );
      ref.invalidate(aetherProgramProvider(widget.programUuid));
    } finally {
      if (mounted) {
        setState(() => _togglingSetId = null);
      }
    }

    if (!mounted) {
      return;
    }

    // 1. Ask for weight first (while it's fresh in the user's mind).
    final weightKg = await WeightInputSheet.show(
      context,
      exerciseName: exerciseName,
      setNumber: set.setNumber,
      previousWeightKg: set.weightKg,
      suggestedWeightKg: set.suggestedWeightKg,
    );

    if (weightKg != null && mounted) {
      // Fire-and-forget; invalidate so the badge updates.
      ref
          .read(aetherRepositoryProvider)
          .logWeight(
            programUuid: widget.programUuid,
            dayId: dayId,
            setId: set.id,
            weightKg: weightKg,
          )
          .then((_) {
        if (mounted) {
          ref.invalidate(aetherProgramProvider(widget.programUuid));
        }
      });
    }

    if (!mounted) {
      return;
    }

    // 2. Then show the rest timer.
    final duration = _restDuration(set);
    await RestTimerSheet.show(
      context,
      seconds: duration,
      exerciseName: exerciseName,
      nextSetLabel: nextSetLabel,
    );
  }

  Future<void> _uncompleteSet({
    required int dayId,
    required AetherWorkoutSet set,
  }) async {
    setState(() => _togglingSetId = set.id);

    try {
      await ref.read(aetherRepositoryProvider).toggleSet(
            programUuid: widget.programUuid,
            dayId: dayId,
            setId: set.id,
          );
      ref.invalidate(aetherProgramProvider(widget.programUuid));
    } finally {
      if (mounted) {
        setState(() => _togglingSetId = null);
      }
    }
  }
}

// ─── Day-complete celebration card ────────────────────────────────────────

class _DayCompleteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(EgSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        gradient: LinearGradient(
          colors: [
            EgColors.success.withValues(alpha: 0.18),
            EgColors.accentBright.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day complete!',
                  style: EgFonts.style(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your adherence has been updated. Rest and recover well.',
                  style: EgFonts.style(
                    fontSize: 13,
                    height: 1.5,
                    color: EgColors.slate400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
