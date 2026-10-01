import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color screenBg = Color(0xFFF4F5F6);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static const Color brandGreen = Color(0xFF146B3A);
  static const Color brandGreenDark = Color(0xFF0E4F2A);
  static const Color brandGreenTint = Color(0xFFDCEFE1);

  static const Color dangerRed = Color(0xFFD23B3B);

  static const Color meterOrange = Color(0xFFE8873A);
  static const Color meterOrangeBg = Color(0xFFF6D9C3);
  static const Color profilePurple = Color(0xFF8B5CF6);
  static const Color profilePurpleBg = Color(0xFFE3D9FB);

  static const Color econet = Color(0xFF1AA34A);
  static const Color econetDark = Color(0xFF0E7A36);
  static const Color netone = Color(0xFF1E6FD9);
  static const Color netoneDark = Color(0xFF144E9C);
  static const Color telecel = Color(0xFFE2231A);
  static const Color telecelDark = Color(0xFFA81712);

  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkMuted = Color(0xFF8A8F98);
  static const Color rowBg = Color(0xFFF0F1F2);
  static const Color warning = Color(0xFFE8893A);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brandGreen,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.screenBg,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}
