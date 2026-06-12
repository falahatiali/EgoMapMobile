import 'package:flutter/material.dart';

import 'eg_colors.dart';
import 'eg_fonts.dart';

abstract final class EgText {
  static TextStyle display(BuildContext context, {Color? color}) {
    return EgFonts.style(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.12,
      letterSpacing: -0.6,
      color: color ?? EgColors.textPrimary,
    );
  }

  static TextStyle displayAccent(BuildContext context) {
    return display(context, color: EgColors.accentBright);
  }

  static TextStyle body(BuildContext context, {Color? color}) {
    return EgFonts.style(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.55,
      color: color ?? EgColors.textMuted,
    );
  }

  static TextStyle label({Color color = EgColors.textMuted}) {
    return EgFonts.style(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: color,
    );
  }

  static TextStyle caption({Color color = EgColors.slate500}) {
    return EgFonts.style(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }

  static TextStyle kicker() {
    return EgFonts.style(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      color: EgColors.slate500,
    );
  }

  static TextStyle sectionTitle(BuildContext context) {
    return EgFonts.style(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      height: 1.2,
      letterSpacing: -0.3,
      color: EgColors.textPrimary,
    );
  }
}
