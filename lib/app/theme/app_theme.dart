import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF17212B);
  static const mutedInk = Color(0xFF68737D);
  static const paper = Color(0xFFF7F8F6);
  static const surface = Colors.white;
  static const accent = Color(0xFFE66A3C);
  static const accentDark = Color(0xFFB84725);
  static const sage = Color(0xFFDCE8DF);
  static const border = Color(0xFFE0E0E0);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    return ThemeData(
      colorScheme: scheme.copyWith(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'sans-serif',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.ink,
          fontSize: 38,
          fontWeight: FontWeight.w700,
          height: 1.05,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.mutedInk,
          fontSize: 16,
          height: 1.5,
        ),
        labelLarge: TextStyle(fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
