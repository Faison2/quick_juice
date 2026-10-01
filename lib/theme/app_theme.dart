import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core glass/gradient identity
  static const Color navyDeep = Color(0xFF060F22);
  static const Color navyMid = Color(0xFF123A66);
  static const Color blueMid = Color(0xFF1C6FA8);
  static const Color blueLight = Color(0xFF3FA0DC);
  static const Color glow = Color(0xFF4FD1E8);

  static const LinearGradient backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [navyDeep, navyMid, blueMid, blueLight],
    stops: [0.0, 0.38, 0.72, 1.0],
  );

  // Cards & surfaces
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color rowBg = Color(0xFFF0F1F2);

  // Network brand colors
  static const Color econet = Color(0xFF1AA34A);
  static const Color econetDark = Color(0xFF0E7A36);
  static const Color netone = Color(0xFF1E6FD9);
  static const Color netoneDark = Color(0xFF144E9C);
  static const Color telecel = Color(0xFFE2231A);
  static const Color telecelDark = Color(0xFFA81712);

  // Domain accents
  static const Color warning = Color(0xFFE8893A);
  static const Color warningDark = Color(0xFFB4651F);
  static const Color dangerRed = Color(0xFFD23B3B);
  static const Color meterOrange = Color(0xFFE8873A);
  static const Color meterOrangeBg = Color(0xFFF6D9C3);
  static const Color profilePurple = Color(0xFF8B5CF6);
  static const Color profilePurpleBg = Color(0xFFE3D9FB);

  // Text
  static const Color ink = Color(0xFF13293D);
  static const Color inkMuted = Color(0xFF6C8296);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navyMid,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.navyDeep,
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}
