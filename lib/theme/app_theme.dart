import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFF080C10);
  static const Color bgCard = Color(0xFF0F1620);
  static const Color bgCard2 = Color(0xFF141D28);
  static const Color accent = Color(0xFFFF6B2B);       // orange
  static const Color accentGreen = Color(0xFF00E676);  // neon green
  static const Color accentBlue = Color(0xFF2979FF);   // electric blue
  static const Color textPrimary = Color(0xFFEEF2F7);
  static const Color textSecondary = Color(0xFF6B7FA3);
  static const Color border = Color(0xFF1E2D40);

  static ThemeData get theme => ThemeData(
    scaffoldBackgroundColor: bg,
    fontFamily: 'Rajdhani',
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: accentGreen,
      surface: bgCard,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: bgCard,
      selectedItemColor: accent,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
