import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Central theme configuration for the 5STR app.
class AppTheme {
  AppTheme._();

  // Typography defined by the brand guidelines
  static const String _fontFamily = 'BentonSans';

  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w900, // Black
        color: textColor,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w800, // Extra Bold
        color: textColor,
        height: 1.15,
      ),
      displaySmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w600, // Semi Bold
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      labelSmall: TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }

  // ── Light Theme ──
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryYellow,
      onPrimary: AppColors.deepNavy,
      secondary: AppColors.secondaryOrange,
      onSecondary: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: _buildTextTheme(AppColors.lightTextPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.deepNavy),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shadowColor: AppColors.deepNavy.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.deepNavy,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );

  // ── Dark Theme ──
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryYellow,
      onPrimary: AppColors.deepNavy,
      secondary: AppColors.secondaryOrange,
      onSecondary: AppColors.white,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: _buildTextTheme(AppColors.darkTextPrimary),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground, // using navy for deep dark headers
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.primaryYellow),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shadowColor: AppColors.deepNavy,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.primaryYellow,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.deepNavy,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: _fontFamily),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}
