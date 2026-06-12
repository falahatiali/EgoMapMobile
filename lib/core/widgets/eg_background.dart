import 'package:flutter/material.dart';

import '../theme/eg_colors.dart';

class EgBackground extends StatelessWidget {
  const EgBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: EgColors.navy950),
      child: _AmbientGlow(child: child),
    );
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.85, -0.9),
              radius: 1.1,
              colors: [
                Color(0x1A6366F1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
