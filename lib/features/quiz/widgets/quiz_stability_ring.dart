import 'package:flutter/material.dart';

class QuizStabilityRing extends StatefulWidget {
  const QuizStabilityRing({
    super.key,
    required this.score,
    required this.accent,
  });

  final int score;
  final Color accent;

  @override
  State<QuizStabilityRing> createState() => _QuizStabilityRingState();
}

class _QuizStabilityRingState extends State<QuizStabilityRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final value = widget.score * progress;

        return SizedBox(
          width: 108,
          height: 108,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 108,
                height: 108,
                child: CircularProgressIndicator(
                  value: value / 100,
                  strokeWidth: 8,
                  backgroundColor: widget.accent.withValues(alpha: 0.12),
                  color: widget.accent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: widget.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
