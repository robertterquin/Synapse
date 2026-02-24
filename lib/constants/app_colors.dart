import 'package:flutter/material.dart';

class AppColors {
  // Primary palette from the monochromatic color palette
  static const Color nightIndigo = Color(0xFF1B003F);
  static const Color twilightPurple = Color(0xFF4B0082);
  static const Color midnightBlue = Color(0xFF191970);
  static const Color lavenderHaze = Color(0xFFE6E6FA);
  static const Color duskyBlue = Color(0xFF6495ED);

  // Hospital status pin colors
  static const Color pinPink = Color(0xFFFF69B4);
  static const Color pinRed = Color(0xFFE53935);
  static const Color pinOrange = Color(0xFFFF9800);
  static const Color pinBlue = Color(0xFF2196F3);
  static const Color pinYellow = Color(0xFFFDD835);
  static const Color pinGreen = Color(0xFF4CAF50);

  // UI helpers
  static const Color cardBackground = Color(0xFFF5F3FF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color inputFill = Color(0x1A4B0082);
  static const Color divider = Color(0xFFD1C4E9);

  // Gradient used in backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2D1B69),
      Color(0xFF1B003F),
      Color(0xFF191970),
    ],
  );

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4B0082),
      Color(0xFF1B003F),
      Color(0xFF191970),
      Color(0xFF6495ED),
    ],
  );
}
