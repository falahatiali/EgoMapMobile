import 'package:flutter/material.dart';

class LandingAtmosphere extends StatelessWidget {
  const LandingAtmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0B1020),
                Color(0xFF0F172A),
                Color(0xFF111827),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.7, -0.55),
              radius: 0.85,
              colors: [
                Color(0x3834D399),
                Colors.transparent,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1.0, -0.65),
              radius: 0.75,
              colors: [
                Color(0x2960A5FA),
                Colors.transparent,
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.5, 1.1),
              radius: 0.65,
              colors: [
                Color(0x1434D399),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}
