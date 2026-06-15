import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/aether_program_models.dart';
import 'exercise_detail_sheet.dart';

/// Shows a single exercise with its sets.
///
/// [onSetCompleted] fires when an incomplete set is tapped — the parent
/// should call the API and then show the rest timer.
///
/// [onSetUncompleted] fires when a completed set is tapped — the parent
/// should call the API to undo (no timer needed).
class WorkoutExerciseCard extends StatelessWidget {
  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
    required this.onSetCompleted,
    required this.onSetUncompleted,
    this.togglingSetId,
  });

  final AetherWorkoutExercise exercise;
  final ValueChanged<AetherWorkoutSet> onSetCompleted;
  final ValueChanged<AetherWorkoutSet> onSetUncompleted;
  final int? togglingSetId;

  @override
  Widget build(BuildContext context) {
    final allDone = exercise.completedSetCount == exercise.sets.length &&
        exercise.sets.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
        border: Border.all(
          color: allDone
              ? EgColors.success.withValues(alpha: 0.35)
              : EgColors.borderSubtle,
        ),
        color: allDone
            ? EgColors.success.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header (tappable → opens detail sheet) ──────────────────────
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(EgSpacing.radiusLg)),
              onTap: () {
                HapticFeedback.selectionClick();
                ExerciseDetailSheet.show(context, exercise);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MediaPreview(url: exercise.mediaUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: EgFonts.style(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (allDone)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: EgColors.success,
                                  size: 20,
                                )
                              else
                                const Icon(
                                  Icons.info_outline_rounded,
                                  color: EgColors.slate500,
                                  size: 18,
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.muscleGroupLabel,
                            style: EgFonts.style(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: EgColors.success,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _SetProgressPill(
                            completed: exercise.completedSetCount,
                            total: exercise.sets.length,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────────────────
          const Divider(height: 1, color: Color(0x14FFFFFF)),

          // ── Sets ─────────────────────────────────────────────────────────
          ...exercise.sets.map(
            (set) => _SetRow(
              set: set,
              loading: togglingSetId == set.id,
              onTap: () {
                if (set.completed) {
                  onSetUncompleted(set);
                } else {
                  onSetCompleted(set);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ───────────────────────────────────────────────────────────────────────────

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        height: 72,
        color: const Color(0x12FFFFFF),
        child: url != null && url!.isNotEmpty
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (context, e, s) => const _FallbackIcon(),
              )
            : const _FallbackIcon(),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.fitness_center_rounded, color: EgColors.slate500);
  }
}

class _SetProgressPill extends StatelessWidget {
  const _SetProgressPill({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(total, (index) {
          final done = index < completed;
          return Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done
                  ? EgColors.success
                  : Colors.white.withValues(alpha: 0.12),
            ),
          );
        }),
        const SizedBox(width: 6),
        Text(
          '$completed/$total sets',
          style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.set,
    required this.onTap,
    required this.loading,
  });

  final AetherWorkoutSet set;
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final nextSet = !set.completed && !loading;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            color: nextSet
                ? EgColors.success.withValues(alpha: 0.05)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              // Checkbox
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: set.completed
                      ? EgColors.success
                      : Colors.transparent,
                  border: Border.all(
                    color: set.completed
                        ? EgColors.success
                        : nextSet
                            ? EgColors.success.withValues(alpha: 0.5)
                            : EgColors.slate500,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: _CheckboxContent(
                  completed: set.completed,
                  loading: loading,
                ),
              ),

              const SizedBox(width: 12),

              // Set number
              Text(
                'Set ${set.setNumber}',
                style: EgFonts.style(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: set.completed
                      ? EgColors.slate400
                      : EgColors.textPrimary,
                ),
              ),

              const Spacer(),

              // Reps
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                child: Text(
                  set.repsLabel,
                  style: EgFonts.style(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: EgColors.slate400,
                  ),
                ),
              ),

              // Weight badge (logged) or suggested nudge
              if (set.weightKg != null) ...[
                const SizedBox(width: 8),
                _WeightBadge(label: set.weightLabel!, logged: true),
              ] else if (set.suggestedWeightKg != null && !set.completed) ...[
                const SizedBox(width: 8),
                _WeightBadge(label: set.suggestedWeightLabel!, logged: false),
              ],

              // Rest seconds badge
              if (set.restSeconds != null) ...[
                const SizedBox(width: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: EgColors.slate500),
                    const SizedBox(width: 3),
                    Text(
                      '${set.restSeconds}s',
                      style: EgFonts.style(fontSize: 12, color: EgColors.slate500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightBadge extends StatelessWidget {
  const _WeightBadge({required this.label, required this.logged});

  final String label;

  /// True = user already logged this weight; false = suggested nudge.
  final bool logged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: logged
            ? EgColors.accentBright.withValues(alpha: 0.15)
            : EgColors.warning.withValues(alpha: 0.10),
        border: Border.all(
          color: logged
              ? EgColors.accentBright.withValues(alpha: 0.4)
              : EgColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            logged ? Icons.fitness_center_rounded : Icons.lightbulb_outline_rounded,
            size: 10,
            color: logged ? EgColors.accentBright : EgColors.warning,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: EgFonts.style(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: logged ? EgColors.accentBright : EgColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxContent extends StatelessWidget {
  const _CheckboxContent({required this.completed, required this.loading});

  final bool completed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.all(4),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF041016),
        ),
      );
    }
    if (completed) {
      return const Icon(Icons.check_rounded, size: 15, color: Color(0xFF041016));
    }
    return const SizedBox.shrink();
  }
}
