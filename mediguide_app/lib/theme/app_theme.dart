import 'package:flutter/material.dart';

class AppTheme {
  // Lavender/Purple Premium Palette
  static const Color primary = Color(0xFF8B78E6);
  static const Color primaryLight = Color(0xFFD6C8FF);
  static const Color primaryDark = Color(0xFF3B3B58);
  static const Color accent = Color(0xFFF9A825); // Gold/Orange for accents
  
  static const Color background = Color(0xFFF8F7FF);
  static const Color textMain = Color(0xFF333344);
  static const Color textSecondary = Color(0xFF8B8B9E);
  static const Color surface = Colors.white;
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF8B78E6), Color(0xFFA191EF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: textMain, fontWeight: FontWeight.w900, fontSize: 32),
        headlineMedium: TextStyle(color: textMain, fontWeight: FontWeight.w800, fontSize: 24),
        titleLarge: TextStyle(color: textMain, fontWeight: FontWeight.w700, fontSize: 20),
        bodyLarge: TextStyle(color: textMain, fontSize: 16),
        bodyMedium: TextStyle(color: textMain, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: surface,
      ),
    );
  }
}
