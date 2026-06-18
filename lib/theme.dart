import 'package:flutter/material.dart';

class ZeloColors {
  static const primary = Color(0xFF1B4F72);
  static const accent = Color(0xFF2ECC71);
  static const surface = Color(0xFFF8F9FA);
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6C757D);
  static const error = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);
  static const divider = Color(0xFFE9ECEF);
}

class ZeloTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ZeloColors.primary,
          primary: ZeloColors.primary,
          secondary: ZeloColors.accent,
          surface: ZeloColors.surface,
        ),
        scaffoldBackgroundColor: ZeloColors.surface,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: ZeloColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ZeloColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZeloColors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ZeloColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: ZeloColors.primary, width: 2),
          ),
          labelStyle:
              const TextStyle(color: ZeloColors.textSecondary, fontSize: 14),
        ),
        cardTheme: CardThemeData(
          color: ZeloColors.cardBg,
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: ZeloColors.surface,
          selectedColor: ZeloColors.primary.withValues(alpha: 0.15),
          labelStyle: const TextStyle(fontSize: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
}
