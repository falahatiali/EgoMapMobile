import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../models/aether_program_models.dart';

/// Full exercise detail sheet — opens when the user taps the exercise header.
///
/// Shows: large GIF/image, name, muscle group, RPE, tempo, sets/reps,
/// and full coaching instructions. Tapping the GIF toggles it full-height.
class ExerciseDetailSheet extends StatefulWidget {
  const ExerciseDetailSheet({super.key, required this.exercise});

  final AetherWorkoutExercise exercise;

  static Future<void> show(BuildContext context, AetherWorkoutExercise exercise) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExerciseDetailSheet(exercise: exercise),
    );
  }

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  bool _gifExpanded = false;

  AetherWorkoutExercise get exercise => widget.exercise;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (_, controller) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: Container(
          decoration: const BoxDecoration(
            color: EgColors.navy900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: CustomScrollView(
            controller: controller,
            slivers: [
              // Drag handle
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),

              // ── GIF Hero ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeInOut,
                  height: _gifExpanded ? screenHeight * 0.45 : 240,
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _GifHero(
                    url: exercise.mediaUrl,
                    exerciseName: exercise.name,
                    expanded: _gifExpanded,
                    onToggle: () => setState(() => _gifExpanded = !_gifExpanded),
                  ),
                ),
              ),

              // ── Title + Muscle ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: EgFonts.style(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: EgColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MuscleChip(label: exercise.muscleGroupLabel),
                    ],
                  ),
                ),
              ),

              // ── Stats row ──────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _StatsRow(exercise: exercise),
                ),
              ),

              // ── Default weight nudge ───────────────────────────────────────
              if (exercise.defaultWeightKg != null && exercise.defaultWeightKg! > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                    child: _WeightNudge(kg: exercise.defaultWeightKg!),
                  ),
                ),

              // ── Instructions divider ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 14, color: EgColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'How to perform',
                        style: EgFonts.style(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: EgColors.accent,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Instructions ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: _InstructionsCard(notes: exercise.notes),
                ),
              ),

              // ── Sets overview ──────────────────────────────────────────────
              if (exercise.sets.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: _SetsOverview(exercise: exercise),
                  ),
                ),

              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GIF Hero
// ─────────────────────────────────────────────────────────────────────────────

class _GifHero extends StatefulWidget {
  const _GifHero({
    this.url,
    required this.exerciseName,
    required this.expanded,
    required this.onToggle,
  });

  final String? url;
  final String exerciseName;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  State<_GifHero> createState() => _GifHeroState();
}

class _GifHeroState extends State<_GifHero> {
  bool _error = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background
            Container(color: const Color(0xFF0D1829)),

            // GIF or fallback
            if (widget.url != null && !_error)
              Image.network(
                widget.url!,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _Shimmer();
                },
                errorBuilder: (context, e, s) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _error = true);
                  });
                  return _NoMediaPlaceholder(name: widget.exerciseName);
                },
              )
            else
              _NoMediaPlaceholder(name: widget.exerciseName),

            // Gradient overlay at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      EgColors.navy900.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Expand icon
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.expanded
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1829),
      child: Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: EgColors.accent.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

class _NoMediaPlaceholder extends StatelessWidget {
  const _NoMediaPlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1829),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 52,
            color: EgColors.accent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: EgFonts.style(
              fontSize: 15,
              color: EgColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Muscle chip
// ─────────────────────────────────────────────────────────────────────────────

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: EgColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: EgColors.success.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: EgFonts.style(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: EgColors.success,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.exercise});

  final AetherWorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    final set = exercise.sets.isNotEmpty ? exercise.sets.first : null;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (set != null) ...[
          _StatChip(
            icon: Icons.layers_rounded,
            label: '${exercise.sets.length} sets',
            color: EgColors.accentBright,
          ),
          _StatChip(
            icon: Icons.repeat_rounded,
            label: set.repsLabel,
            color: EgColors.accentBright,
          ),
          if (set.restSeconds != null)
            _StatChip(
              icon: Icons.timer_outlined,
              label: '${set.restSeconds}s rest',
              color: EgColors.calm,
            ),
        ],
        if (exercise.rpe != null)
          _StatChip(
            icon: Icons.bolt_rounded,
            label: 'RPE ${exercise.rpe}',
            color: EgColors.warning,
          ),
        if (exercise.tempo != null && exercise.tempo != 'continuous' && exercise.tempo != 'hold')
          _StatChip(
            icon: Icons.speed_rounded,
            label: 'Tempo ${exercise.tempo}',
            color: EgColors.slate400,
          ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: EgFonts.style(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Weight nudge
// ─────────────────────────────────────────────────────────────────────────────

class _WeightNudge extends StatelessWidget {
  const _WeightNudge({required this.kg});

  final double kg;

  @override
  Widget build(BuildContext context) {
    final formatted = kg % 1 == 0 ? kg.toInt().toString() : kg.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: EgColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EgColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline_rounded, size: 16, color: EgColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: EgFonts.style(fontSize: 13, color: EgColors.textMuted),
                children: [
                  const TextSpan(text: 'Suggested starting weight: '),
                  TextSpan(
                    text: '$formatted kg',
                    style: EgFonts.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: EgColors.warning,
                    ),
                  ),
                  const TextSpan(text: '  (adjust based on how you feel)'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Instructions card
// ─────────────────────────────────────────────────────────────────────────────

class _InstructionsCard extends StatefulWidget {
  const _InstructionsCard({this.notes});

  final String? notes;

  @override
  State<_InstructionsCard> createState() => _InstructionsCardState();
}

class _InstructionsCardState extends State<_InstructionsCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final text = widget.notes;

    if (text == null || text.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EgColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: EgColors.borderSubtle),
        ),
        child: Text(
          'Focus on proper form. Control the movement throughout each rep.',
          style: EgFonts.style(fontSize: 14, color: EgColors.textMuted, height: 1.6),
        ),
      );
    }

    final sentences = text.split('. ').where((s) => s.trim().isNotEmpty).toList();
    final preview = sentences.isNotEmpty ? '${sentences.first}.' : text;
    final hasMore = sentences.length > 1;

    return GestureDetector(
      onTap: hasMore ? () => setState(() => _expanded = !_expanded) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: EgColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: EgColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                preview,
                style: EgFonts.style(fontSize: 14, color: EgColors.textMuted, height: 1.65),
              ),
              secondChild: _BulletPoints(sentences: sentences),
            ),
            if (hasMore) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _expanded ? 'Show less' : 'Show all tips',
                    style: EgFonts.style(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: EgColors.accent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    size: 15,
                    color: EgColors.accent,
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

class _BulletPoints extends StatelessWidget {
  const _BulletPoints({required this.sentences});

  final List<String> sentences;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentences.map((sentence) {
        final text = sentence.endsWith('.') ? sentence : '$sentence.';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 7),
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: EgColors.accent.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: EgFonts.style(
                    fontSize: 14,
                    color: EgColors.textMuted,
                    height: 1.65,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sets overview
// ─────────────────────────────────────────────────────────────────────────────

class _SetsOverview extends StatelessWidget {
  const _SetsOverview({required this.exercise});

  final AetherWorkoutExercise exercise;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.format_list_numbered_rounded, size: 14, color: EgColors.accent),
            const SizedBox(width: 6),
            Text(
              'Your sets today',
              style: EgFonts.style(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: EgColors.accent,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: EgColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EgColors.borderSubtle),
          ),
          child: Column(
            children: exercise.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              final isLast = index == exercise.sets.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : const Border(bottom: BorderSide(color: Color(0x10FFFFFF))),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      // Status dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: set.completed
                              ? EgColors.success
                              : Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Set ${set.setNumber}',
                        style: EgFonts.style(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: set.completed ? EgColors.textMuted : EgColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        set.repsLabel,
                        style: EgFonts.style(
                          fontSize: 13,
                          color: EgColors.slate500,
                        ),
                      ),
                      if (set.weightKg != null) ...[
                        const SizedBox(width: 12),
                        Text(
                          set.weightLabel!,
                          style: EgFonts.style(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: EgColors.accentBright,
                          ),
                        ),
                      ],
                      if (set.completed) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle_rounded, size: 15, color: EgColors.success),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
