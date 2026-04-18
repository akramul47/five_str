import 'package:flutter/material.dart';

/// Design system color palette for 5STR.
/// Driven by brand guidelines (Yellow-Orange, Burnt Orange, Navy Black).
class AppColors {
  AppColors._();

  // ── Brand Colors ──
  static const Color primaryYellow = Color(0xFFFFAD1D);
  static const Color secondaryOrange = Color(0xFFDA6317);
  static const Color deepNavy = Color(0xFF09051C);

  // ── Shared Colors ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = primaryYellow;
  static const Color info = Color(0xFF3B82F6);
  static const Color starYellow = primaryYellow;

  // ── Light Theme Defaults ──
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = deepNavy;
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ── Dark Theme Defaults ──
  static const Color darkBackground = deepNavy;
  static const Color darkSurface = Color(0xFF141029); // Slightly lighter than deepNavy
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2D2A43);
}
