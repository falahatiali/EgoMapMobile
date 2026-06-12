import 'package:flutter/material.dart';

import 'eg_colors.dart';
import 'eg_fonts.dart';
import 'eg_spacing.dart';

abstract final class EgTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EgColors.navy950,
      fontFamily: EgFonts.family,
      colorScheme: const ColorScheme.dark(
        primary: EgColors.accent,
        onPrimary: Colors.white,
        surface: EgColors.navy900,
        onSurface: EgColors.textPrimary,
        error: EgColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: EgColors.textPrimary,
      ),
      dividerColor: EgColors.borderSubtle,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EgColors.surface,
        isDense: true,
        hintStyle: EgFonts.style(color: EgColors.slate500, fontSize: 17),
        labelStyle: EgFonts.style(color: EgColors.slate500, fontSize: 16),
        floatingLabelStyle: EgFonts.style(color: EgColors.slate400, fontSize: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EgSpacing.radius),
          borderSide: const BorderSide(color: EgColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EgSpacing.radius),
          borderSide: const BorderSide(color: EgColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EgSpacing.radius),
          borderSide: const BorderSide(color: EgColors.accent, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EgSpacing.radius),
          borderSide: const BorderSide(color: EgColors.danger),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: EgColors.accentBright),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: EgColors.navy800,
        contentTextStyle: EgFonts.style(color: EgColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(EgSpacing.radius)),
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: EgFonts.family,
        bodyColor: EgColors.textPrimary,
        displayColor: EgColors.textPrimary,
      ),
    );
  }
}
