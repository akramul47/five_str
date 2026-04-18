import 'package:flutter/material.dart';

/// Design system color palette for 5STR.
/// Mirrors the React Native Colors.ts theming.
class AppColors {
  AppColors._();

  // ── Light Theme ──
  static const Color lightText = Color(0xFF11181C);
  static const Color lightBackground = Color(0xFFF4FAFC);
  static const Color lightTint = Color(0xFF0A7EA4);
  static const Color lightIcon = Color(0xFF687076);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightHeaderGradientStart = Color(0xFF6366F1);
  static const Color lightHeaderGradientEnd = Color(0xFF8B5CF6);
  static const Color lightButtonPrimary = Color(0xFF6366F1);
  static const Color lightButtonText = Color(0xFFFFFFFF);
  static const Color lightTabBackground = Color(0xFFFFFFFF);
  static const Color lightTabBorder = Color(0xFFE2E8F0);
  static const Color lightTabIconDefault = Color(0xFF94A3B8);
  static const Color lightTabIconSelected = Color(0xFF0A7EA4);
  static const Color lightTabActiveBackground = Color(0xFFF1F5F9);

  // ── Dark Theme ──
  static const Color darkText = Color(0xFFECEDEE);
  static const Color darkBackground = Color(0xFF151718);
  static const Color darkTint = Color(0xFF3B82F6);
  static const Color darkIcon = Color(0xFF9BA1A6);
  static const Color darkCard = Color(0xFF1F2937);
  static const Color darkBorder = Color(0xFF374151);
  static const Color darkHeaderGradientStart = Color(0xFF1F2937);
  static const Color darkHeaderGradientEnd = Color(0xFF374151);
  static const Color darkButtonPrimary = Color(0xFF3B82F6);
  static const Color darkButtonText = Color(0xFFFFFFFF);
  static const Color darkTabBackground = Color(0xFF1E293B);
  static const Color darkTabBorder = Color(0xFF334155);
  static const Color darkTabIconDefault = Color(0xFF64748B);
  static const Color darkTabIconSelected = Color(0xFF3B82F6);
  static const Color darkTabActiveBackground = Color(0xFF334155);

  // ── Semantic Colors (shared) ──
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
  static const Color starYellow = Color(0xFFFBBF24);
}
