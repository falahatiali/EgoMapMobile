import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/eg_colors.dart';
import '../../../core/theme/eg_fonts.dart';

class QuizCompletingOverlay extends StatefulWidget {
  const QuizCompletingOverlay({super.key});

  @override
  State<QuizCompletingOverlay> createState() => _QuizCompletingOverlayState();
}

class _QuizCompletingOverlayState extends State<QuizCompletingOverlay>
    with SingleTickerProviderStateMixin {
  static const _steps = [
    'Saving your answers',
    'Reading your pattern',
    'Building your snapshot',
  ];

  late final AnimationController _pulseController;
  int _stepIndex = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _stepTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _stepIndex = (_stepIndex + 1).clamp(0, _steps.length - 1);
      });
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xF0070B14),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1 + (_pulseController.value * 0.08);

                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              EgColors.success.withValues(alpha: 0.35),
                              EgColors.success.withValues(alpha: 0.05),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: EgColors.success.withValues(alpha: 0.25),
                              blurRadius: 32,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: EgColors.success,
                          size: 36,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Almost there',
                  style: EgFonts.style(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your personal recovery snapshot is on the way.',
                  textAlign: TextAlign.center,
                  style: EgFonts.style(fontSize: 15, height: 1.55, color: EgColors.slate400),
                ),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _steps[_stepIndex],
                    key: ValueKey(_stepIndex),
                    style: EgFonts.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: EgColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: EgColors.success,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
