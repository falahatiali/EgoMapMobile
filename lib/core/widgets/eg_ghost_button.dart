import 'package:flutter/material.dart';

import '../theme/eg_colors.dart';
import '../theme/eg_fonts.dart';
import '../theme/eg_spacing.dart';

class EgGhostButton extends StatelessWidget {
  const EgGhostButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: EgColors.textMuted,
        padding: const EdgeInsets.symmetric(horizontal: EgSpacing.sm, vertical: EgSpacing.sm),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: EgFonts.style(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
