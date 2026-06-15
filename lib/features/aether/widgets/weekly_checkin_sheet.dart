import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';
import '../models/aether_checkin_models.dart';
import '../providers/aether_provider.dart';

/// 3-step weekly re-calibration sheet.
///
/// Shows after the first full program week and collects:
///   Step 1 — sessions completed (0–7 stepper)
///   Step 2 — intensity rating  (too easy / just right / too hard)
///   Step 3 — pain / injury flag + optional notes
///
/// Returns an [AetherCheckInResult] (coaching message) on success, or null
/// if the user dismisses without submitting.
class WeeklyCheckInSheet extends ConsumerStatefulWidget {
  const WeeklyCheckInSheet({
    super.key,
    required this.programUuid,
    required this.currentWeek,
  });

  final String programUuid;
  final int currentWeek;

  static Future<AetherCheckInResult?> show(
    BuildContext context, {
    required String programUuid,
    required int currentWeek,
  }) {
    return showModalBottomSheet<AetherCheckInResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      useRootNavigator: true,
      builder: (_) => WeeklyCheckInSheet(
        programUuid: programUuid,
        currentWeek: currentWeek,
      ),
    );
  }

  @override
  ConsumerState<WeeklyCheckInSheet> createState() => _WeeklyCheckInSheetState();
}

class _WeeklyCheckInSheetState extends ConsumerState<WeeklyCheckInSheet>
    with SingleTickerProviderStateMixin {
  int _step = 0; // 0, 1, 2
  static const int _totalSteps = 3;

  // Answers
  int _sessionsCompleted = 3;
  int _intensityRating = 2; // 1=easy, 2=just right, 3=hard
  bool _hadPain = false;
  final _painController = TextEditingController();
  bool _submitting = false;

  late AnimationController _anim;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _painController.dispose();
    super.dispose();
  }

  void _nextStep() {
    HapticFeedback.selectionClick();
    if (_step < _totalSteps - 1) {
      _anim.reverse().then((_) {
        setState(() => _step++);
        _anim.forward();
      });
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_step > 0) {
      HapticFeedback.selectionClick();
      _anim.reverse().then((_) {
        setState(() => _step--);
        _anim.forward();
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);

    try {
      final result = await ref.read(aetherRepositoryProvider).submitCheckIn(
            programUuid: widget.programUuid,
            payload: AetherCheckInPayload(
              sessionsCompleted: _sessionsCompleted,
              intensityRating: _intensityRating,
              hadPain: _hadPain,
              painNotes: _hadPain && _painController.text.trim().isNotEmpty
                  ? _painController.text.trim()
                  : null,
            ),
          );

      // Refresh the check-in status so the prompt won't show again.
      ref.invalidate(checkInStatusProvider(widget.programUuid));

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save check-in. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: EgColors.navy900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // ── Drag handle ────────────────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // ── Header ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(EgSpacing.page, 8, EgSpacing.page, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week ${widget.currentWeek - 1} check-in',
                            style: EgFonts.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: EgColors.accentBright,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'How did it go?',
                            style: EgFonts.style(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Step dots
                    Row(
                      children: List.generate(_totalSteps, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: i == _step ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: i == _step
                                ? EgColors.accentBright
                                : Colors.white.withValues(alpha: 0.15),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

              // ── Step progress bar ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(EgSpacing.page, 16, EgSpacing.page, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (_step + 1) / _totalSteps,
                    minHeight: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    color: EgColors.accentBright,
                  ),
                ),
              ),

              // ── Step content ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(EgSpacing.page),
                  child: FadeTransition(
                    opacity: _fade,
                    child: _buildStep(),
                  ),
                ),
              ),

              // ── Navigation buttons ─────────────────────────────────────
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EgSpacing.page, 0, EgSpacing.page, EgSpacing.md,
                  ),
                  child: Row(
                    children: [
                      if (_step > 0)
                        IconButton(
                          onPressed: _submitting ? null : _prevStep,
                          icon: const Icon(Icons.arrow_back_rounded),
                          color: EgColors.slate400,
                        ),
                      if (_step > 0) const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submitting ? null : _nextStep,
                          style: FilledButton.styleFrom(
                            backgroundColor: EgColors.accentBright,
                            foregroundColor: EgColors.navy950,
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(EgSpacing.radius),
                            ),
                          ),
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: EgColors.navy950,
                                  ),
                                )
                              : Text(
                                  _step == _totalSteps - 1 ? 'Submit' : 'Continue',
                                  style: EgFonts.style(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _StepSessions(
          value: _sessionsCompleted,
          onChanged: (v) => setState(() => _sessionsCompleted = v),
        ),
      1 => _StepIntensity(
          value: _intensityRating,
          onChanged: (v) => setState(() => _intensityRating = v),
        ),
      2 => _StepPain(
          hadPain: _hadPain,
          controller: _painController,
          onToggle: (v) => setState(() => _hadPain = v),
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ─── Step 1: Sessions completed ──────────────────────────────────────────────

class _StepSessions extends StatelessWidget {
  const _StepSessions({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How many sessions did you complete?',
          style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Count every training day you showed up, even short ones.',
          style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400),
        ),
        const SizedBox(height: 40),

        // Big stepper
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepperButton(
              icon: Icons.remove_rounded,
              onTap: value > 0 ? () => onChanged(value - 1) : null,
            ),
            const SizedBox(width: 32),
            Column(
              children: [
                Text(
                  '$value',
                  style: EgFonts.style(
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -3,
                    color: EgColors.accentBright,
                  ),
                ),
                Text(
                  value == 1 ? 'session' : 'sessions',
                  style: EgFonts.style(fontSize: 14, color: EgColors.slate400),
                ),
              ],
            ),
            const SizedBox(width: 32),
            _StepperButton(
              icon: Icons.add_rounded,
              onTap: value < 7 ? () => onChanged(value + 1) : null,
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Quick tap grid
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(8, (i) {
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(EgSpacing.radius),
                  color: i == value
                      ? EgColors.accentBright.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: i == value
                        ? EgColors.accentBright
                        : Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Text(
                  '$i',
                  style: EgFonts.style(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: i == value ? EgColors.accentBright : EgColors.slate400,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Step 2: Intensity ────────────────────────────────────────────────────────

class _StepIntensity extends StatelessWidget {
  const _StepIntensity({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'How did the workouts feel?',
          style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Be honest — this helps calibrate your next week.',
          style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400),
        ),
        const SizedBox(height: 28),
        _IntensityCard(
          rating: 1,
          emoji: '😌',
          title: 'Too easy',
          subtitle: 'I could do more sets or heavier weights',
          selected: value == 1,
          color: EgColors.calm,
          onTap: () => onChanged(1),
        ),
        const SizedBox(height: 10),
        _IntensityCard(
          rating: 2,
          emoji: '💪',
          title: 'Just right',
          subtitle: 'Challenging but manageable — I felt the progress',
          selected: value == 2,
          color: EgColors.success,
          onTap: () => onChanged(2),
        ),
        const SizedBox(height: 10),
        _IntensityCard(
          rating: 3,
          emoji: '🔥',
          title: 'Too hard',
          subtitle: 'Exhausted most of the time, struggled to recover',
          selected: value == 3,
          color: EgColors.danger,
          onTap: () => onChanged(3),
        ),
      ],
    );
  }
}

// ─── Step 3: Pain / injury ────────────────────────────────────────────────────

class _StepPain extends StatelessWidget {
  const _StepPain({
    required this.hadPain,
    required this.controller,
    required this.onToggle,
  });

  final bool hadPain;
  final TextEditingController controller;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Any pain or discomfort?',
          style: EgFonts.style(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Not soreness — real pain that limited your movement.',
          style: EgFonts.style(fontSize: 14, height: 1.5, color: EgColors.slate400),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: _PainToggleCard(
                emoji: '✅',
                label: 'No pain',
                selected: !hadPain,
                color: EgColors.success,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(false);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PainToggleCard(
                emoji: '⚠️',
                label: 'Had pain',
                selected: hadPain,
                color: EgColors.warning,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onToggle(true);
                },
              ),
            ),
          ],
        ),
        if (hadPain) ...[
          const SizedBox(height: 20),
          Text(
            'Where / what kind of pain? (optional)',
            style: EgFonts.style(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: EgColors.slate400,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: 3,
            style: EgFonts.style(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'e.g. left knee when squatting…',
              hintStyle: EgFonts.style(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(EgSpacing.radius),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(EgSpacing.radius),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(EgSpacing.radius),
                borderSide: const BorderSide(color: EgColors.accentBright, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Shared sub-widgets ───────────────────────────────────────────────────────

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.selectionClick();
          onTap!();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap != null
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: Colors.white.withValues(alpha: onTap != null ? 0.14 : 0.06),
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: onTap != null ? EgColors.textPrimary : EgColors.slate500,
        ),
      ),
    );
  }
}

class _IntensityCard extends StatelessWidget {
  const _IntensityCard({
    required this.rating,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final int rating;
  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
          color: selected ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: EgFonts.style(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? color : EgColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: EgFonts.style(
                      fontSize: 12,
                      height: 1.4,
                      color: EgColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 22),
          ],
        ),
      ),
    );
  }
}

class _PainToggleCard extends StatelessWidget {
  const _PainToggleCard({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EgSpacing.radiusLg),
          color: selected ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: EgFonts.style(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: selected ? color : EgColors.slate400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
