import 'package:flutter/material.dart';

/// Ultra-premium, Apple-style dark palette for the Director control room.
///
/// Kept as plain constants (no external font/theming packages) so this app
/// has the same dependency footprint as the other three - flutter, provider,
/// and the shared api_client.
class AppColors {
  AppColors._();

  static const background = Color(0xFF0A0A0C);
  static const surface = Color(0xFF16161A);
  static const surfaceRaised = Color(0xFF1E1E23);
  static const border = Color(0x1FFFFFFF); // white @ 12%
  static const divider = Color(0x14FFFFFF); // white @ 8%

  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFFA1A1A6);
  static const textTertiary = Color(0xFF6E6E73);

  /// Warm gold accent - the one deliberately "luxury beauty brand" note in
  /// an otherwise restrained Apple-style dark palette.
  static const gold = Color(0xFFD9B65C);
  static const goldMuted = Color(0xFF8A7434);

  static const positive = Color(0xFF32D74B);
  static const warning = Color(0xFFFF9F0A);
  static const danger = Color(0xFFFF453A);
  static const info = Color(0xFF0A84FF);
}

ThemeData buildSuperAdminTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: base.colorScheme.copyWith(
      surface: AppColors.background,
      primary: AppColors.gold,
      secondary: AppColors.gold,
      error: AppColors.danger,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    textTheme: base.textTheme
        .apply(
          bodyColor: AppColors.textPrimary,
          displayColor: AppColors.textPrimary,
        )
        .copyWith(
          headlineMedium: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: AppColors.textPrimary,
          ),
          titleLarge: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: AppColors.textPrimary,
          ),
          titleMedium: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyMedium: const TextStyle(color: AppColors.textSecondary),
          bodySmall: const TextStyle(color: AppColors.textTertiary),
        ),
    dividerColor: AppColors.divider,
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceRaised,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    iconTheme: const IconThemeData(color: AppColors.textSecondary),
    dialogTheme: const DialogThemeData(backgroundColor: AppColors.surfaceRaised),
  );
}
