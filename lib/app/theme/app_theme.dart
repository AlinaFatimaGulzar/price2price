import 'package:flutter/material.dart';

/// Premium dark automotive palette.
///
/// Deep midnight navy surfaces, smoked liquid glass, warm off-white text and a
/// glossy race-red accent used deliberately for CTAs, prices and active states.
abstract final class AppColors {
  /// Primary text — warm off-white.
  static const ink = Color(0xFFF3F5F6);

  /// Secondary text — soft muted gray.
  static const mutedInk = Color(0xFF93A1AB);

  /// App background — deep midnight navy.
  static const paper = Color(0xFF071116);

  /// Elevated dark glass tone used for avatar tiles and chips.
  static const sage = Color(0xFF1B2C34);

  /// Base glass card surface.
  static const surface = Color(0xFF12242C);

  /// Glossy race-red primary accent (full-shine red).
  static const accent = Color(0xFFE5303B);

  /// Deep crimson — gradients, muted highlights, destructive/muted states.
  static const accentDark = Color(0xFFA01420);

  /// Dark text placed on the red accent (readable contrast).
  static const onAccent = Color(0xFF1A070A);

  /// Hairline border for glass surfaces — white at ~13%.
  static const border = Color(0x21FFFFFF);

  /// Soft coral used for reject / warning / destructive states.
  static const warning = Color(0xFFFF7A55);

  /// Muted mint used for approved / positive states.
  static const success = Color(0xFF6FD3A4);

  /// Soft error red that stays readable on midnight backgrounds.
  static const danger = Color(0xFFFF8A80);
}

abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
}

abstract final class AppShadows {
  /// Calm elevated shadow used under glass cards.
  static const card = BoxShadow(
    color: Color(0x3302060A),
    blurRadius: 26,
    offset: Offset(0, 12),
  );

  /// Red glow reserved for the primary CTA and featured hero.
  static const accentGlow = BoxShadow(
    color: Color(0x59E5303B),
    blurRadius: 26,
    offset: Offset(0, 10),
  );
}

/// Glass surface helpers — thin borders, layered depth, restrained translucency.
abstract final class AppGlass {
  static BoxDecoration card({
    double radius = AppRadius.lg,
    Color color = AppColors.surface,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: shadows ?? const [AppShadows.card],
    );
  }

  /// A frosted, mostly-transparent glass tile for floating chips and icons.
  static BoxDecoration tile({
    double radius = AppRadius.md,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: const Color(0x0FFFFFFF),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
    );
  }

  /// Liquid-glass surface for popups — translucent red-tinted frosted depth
  /// with a glossy top sheen and hairline highlight.
  static BoxDecoration liquid({
    double radius = 26,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x8CE5303B),
          Color(0x59FFFFFF),
          Color(0xB30F2027),
          Color(0xF2071116),
        ],
        stops: [0, 0.06, 0.5, 1],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: shadows ?? const [AppShadows.accentGlow],
    );
  }
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: Brightness.dark,
      surface: AppColors.surface,
    );

    final base = ThemeData(
      colorScheme: scheme.copyWith(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accentDark,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.mutedInk,
        outline: Colors.white24,
        error: AppColors.danger,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      fontFamily: 'sans-serif',
    );

    return base.copyWith(
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.ink,
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.08,
          letterSpacing: -0.6,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 16, height: 1.55),
        bodyMedium: TextStyle(
          color: AppColors.mutedInk,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.mutedInk,
          fontSize: 13,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x14FFFFFF),
        hintStyle: const TextStyle(color: AppColors.mutedInk),
        prefixIconColor: AppColors.mutedInk,
        suffixIconColor: AppColors.mutedInk,
        labelStyle: const TextStyle(color: AppColors.mutedInk),
        errorStyle: const TextStyle(color: AppColors.danger),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.danger.withValues(alpha: 0.7),
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          shadowColor: AppColors.accent,
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.border, width: 1.2),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0x14FFFFFF),
        selectedColor: AppColors.accent,
        side: const BorderSide(color: AppColors.border),
        labelStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppColors.onAccent,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: AppColors.onAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm + 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.accent.withValues(alpha: 0.18),
        height: 66,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.accent);
          }
          return const IconThemeData(color: AppColors.mutedInk);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            );
          }
          return const TextStyle(
            color: AppColors.mutedInk,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xF21A2B32),
        behavior: SnackBarBehavior.floating,
        contentTextStyle: const TextStyle(color: AppColors.ink, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: const BorderSide(color: AppColors.border),
        ),
        elevation: 6,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.ink,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.mutedInk,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x1FFFFFFF)),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.accent;
          return AppColors.mutedInk;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.accent.withValues(alpha: 0.35);
          }
          return AppColors.sage;
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
      ),
    );
  }
}
