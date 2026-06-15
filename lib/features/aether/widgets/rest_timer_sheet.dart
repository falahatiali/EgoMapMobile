import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';
import '../../../core/theme/eg_spacing.dart';

/// Shows a rest-timer bottom sheet that auto-dismisses when the countdown
/// reaches zero. The caller provides [seconds] (from the set's rest_seconds
/// field, or a sensible default), and an optional [exerciseName] and
/// [nextSetLabel] for context labels.
///
/// Usage (fire-and-forget):
/// ```dart
/// RestTimerSheet.show(context, seconds: set.restSeconds ?? 90);
/// ```
class RestTimerSheet extends StatefulWidget {
  const RestTimerSheet({
    super.key,
    required this.totalSeconds,
    required this.exerciseName,
    this.nextSetLabel,
    this.onDone,
  });

  final int totalSeconds;
  final String exerciseName;
  final String? nextSetLabel;
  final VoidCallback? onDone;

  /// Canonical entry point — shows the sheet and returns when dismissed.
  static Future<void> show(
    BuildContext context, {
    required int seconds,
    required String exerciseName,
    String? nextSetLabel,
    VoidCallback? onDone,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => RestTimerSheet(
        totalSeconds: seconds,
        exerciseName: exerciseName,
        nextSetLabel: nextSetLabel,
        onDone: onDone,
      ),
    );
  }

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet>
    with TickerProviderStateMixin {
  late int _remaining;
  Timer? _countdown;
  bool _finished = false;
  bool _paused = false;

  late AnimationController _ringController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.totalSeconds;

    // Ring sweeps backward as time elapses.
    _ringController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.totalSeconds),
    )..forward();

    // Subtle pulse on the number when ≤ 5 seconds remain.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdown();
  }

  void _startCountdown() {
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      if (_paused) {
        return;
      }
      if (_remaining <= 1) {
        _onFinish();
        return;
      }
      setState(() => _remaining--);

      if (_remaining <= 5) {
        _pulseController.repeat(reverse: true);
        HapticFeedback.lightImpact();
      }
    });
  }

  void _onFinish() {
    _countdown?.cancel();
    setState(() {
      _remaining = 0;
      _finished = true;
    });
    _pulseController.stop();
    HapticFeedback.heavyImpact();
    // Two pulses to signal "go" — matches gym watch behaviour.
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        HapticFeedback.heavyImpact();
      }
    });
    widget.onDone?.call();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _skip() {
    _countdown?.cancel();
    HapticFeedback.mediumImpact();
    widget.onDone?.call();
    Navigator.of(context).pop();
  }

  void _addTime(int extra) {
    if (_finished) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _remaining += extra);
    // Extend the ring animation proportionally.
    _ringController
      ..stop()
      ..duration = Duration(seconds: _remaining + (widget.totalSeconds - _remaining))
      ..forward(
        from: _ringController.value -
            (extra / (widget.totalSeconds + extra)).clamp(0.0, 1.0),
      );
  }

  void _togglePause() {
    HapticFeedback.selectionClick();
    setState(() => _paused = !_paused);
    if (_paused) {
      _ringController.stop();
    } else {
      _ringController.forward();
    }
  }

  String _formatTime(int seconds) {
    if (seconds >= 60) {
      final m = seconds ~/ 60;
      final s = (seconds % 60).toString().padLeft(2, '0');
      return '$m:$s';
    }
    return '$seconds';
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fraction =
        widget.totalSeconds == 0 ? 0.0 : _remaining / widget.totalSeconds;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(EgSpacing.page, 20, EgSpacing.page, EgSpacing.page),
        decoration: const BoxDecoration(
          color: EgColors.navy900,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),

            // Label
            Text(
              _finished ? 'Go! 💪' : 'Rest',
              style: EgFonts.style(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08,
                color: EgColors.slate400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.exerciseName,
              style: EgFonts.style(fontSize: 17, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            if (widget.nextSetLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.nextSetLabel!,
                style: EgFonts.style(fontSize: 13, color: EgColors.success),
              ),
            ],

            const SizedBox(height: 28),

            // Ring + number
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 10,
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  // Animated ring
                  AnimatedBuilder(
                    animation: _ringController,
                    builder: (_, __) {
                      return SizedBox.expand(
                        child: CustomPaint(
                          painter: _RingPainter(
                            fraction: fraction.clamp(0.0, 1.0),
                            finished: _finished,
                          ),
                        ),
                      );
                    },
                  ),
                  // Countdown number
                  ScaleTransition(
                    scale: _remaining <= 5 && !_finished
                        ? _pulseAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: _finished
                          ? const Icon(
                              Icons.fitness_center_rounded,
                              key: ValueKey('done'),
                              size: 52,
                              color: EgColors.success,
                            )
                          : Text(
                              _formatTime(_remaining),
                              key: ValueKey(_remaining),
                              style: EgFonts.style(
                                fontSize: _remaining >= 60 ? 46 : 64,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -2,
                                color: _remaining <= 5
                                    ? EgColors.warning
                                    : EgColors.textPrimary,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // +15 / +30 quick-add
            if (!_finished)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _AddTimeButton(label: '+15s', onTap: () => _addTime(15)),
                  const SizedBox(width: 12),
                  _AddTimeButton(label: '+30s', onTap: () => _addTime(30)),
                ],
              ),

            if (!_finished) const SizedBox(height: 20),

            // Action buttons
            if (!_finished)
              Row(
                children: [
                  // Pause / Resume
                  Expanded(
                    child: _OutlineButton(
                      icon: _paused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                      label: _paused ? 'Resume' : 'Pause',
                      onTap: _togglePause,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Skip
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _skip,
                      style: FilledButton.styleFrom(
                        backgroundColor: EgColors.success,
                        foregroundColor: const Color(0xFF041016),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(EgSpacing.radius),
                        ),
                      ),
                      child: Text(
                        'Skip rest',
                        style: EgFonts.style(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter — arc that sweeps from top, shrinks as time elapses
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.finished});

  final double fraction;
  final bool finished;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 5;
    final stroke = 10.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    if (finished) {
      paint.color = EgColors.success;
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Gradient arc: green → indigo
    final rect = Rect.fromCircle(center: center, radius: radius);
    paint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: -math.pi / 2 + 2 * math.pi * fraction,
      colors: fraction > 0.25
          ? [const Color(0xFF34D399), const Color(0xFF818CF8)]
          : [EgColors.warning, EgColors.danger],
      tileMode: TileMode.clamp,
    ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.fraction != fraction || old.finished != finished;
}

// ---------------------------------------------------------------------------
// Small reusable sub-widgets
// ---------------------------------------------------------------------------

class _AddTimeButton extends StatelessWidget {
  const _AddTimeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(
          label,
          style: EgFonts.style(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: EgColors.slate400,
          ),
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(EgSpacing.radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          color: Colors.white.withValues(alpha: 0.04),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: EgColors.slate400),
            const SizedBox(width: 6),
            Text(label, style: EgFonts.style(fontSize: 15, fontWeight: FontWeight.w700, color: EgColors.slate400)),
          ],
        ),
      ),
    );
  }
}
