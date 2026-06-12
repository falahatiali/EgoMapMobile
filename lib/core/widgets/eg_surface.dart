import 'package:flutter/material.dart';

import '../theme/eg_colors.dart';
import '../theme/eg_spacing.dart';

class EgSurface extends StatelessWidget {
  const EgSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(EgSpacing.lg),
    this.margin,
    this.radius = EgSpacing.radiusLg,
  });

  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: EgColors.navy900.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: EgColors.borderSubtle),
      ),
      child: child,
    );
  }
}
