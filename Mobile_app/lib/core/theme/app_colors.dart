import 'package:flutter/material.dart';

/// Centralized Color Palette for Quick Money Application.
/// Designed for a modern, vibrant, colorful, and animated financial investment experience.
class AppColors {
  // Brand / Primary Palette (Royal Blue & Deep Indigo)
  static const Color brandPrimary = Color(0xFF1A44B8);
  static const Color brandPrimaryDark = Color(0xFF0F2B82);
  static const Color brandPrimaryLight = Color(0xFF3B67E8);
  static const Color brandAccent = Color(0xFF2563EB);
  static const Color brandGradientStart = Color(0xFF1E3A8A);
  static const Color brandGradientEnd = Color(0xFF2563EB);

  // Secondary & Accent Colors
  static const Color goldAccent = Color(0xFFFFB800);
  static const Color goldLight = Color(0xFFFEF3C7);
  static const Color amberAccent = Color(0xFFF59E0B);
  static const Color purpleAccent = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFFEDE9FE);
  static const Color cyanAccent = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFFCFFAFE);

  // Financial Status Colors
  static const Color profitGreen = Color(0xFF00C853);
  static const Color profitGreenBg = Color(0xFFDCFCE7);
  static const Color profitGreenLight = Color(0xFF22C55E);
  static const Color lossRed = Color(0xFFEF4444);
  static const Color lossRedBg = Color(0xFFFEE2E2);

  // Status Indicator Colors
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusSuccessBg = Color(0xFFECFDF5);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusWarningBg = Color(0xFFFFFBEB);
  static const Color statusCritical = Color(0xFFEF4444);
  static const Color statusCriticalBg = Color(0xFFFEF2F2);
  static const Color statusInfo = Color(0xFF0284C7);
  static const Color statusInfoBg = Color(0xFFE0F2FE);

  // Payment Brand Colors
  static const Color phonePePurple = Color(0xFF5F259F);
  static const Color gPayBlue = Color(0xFF1A73E8);
  static const Color paytmCyan = Color(0xFF00BAF2);
  static const Color usdtTeal = Color(0xFF26A17B);
  static const Color trxRed = Color(0xFFEF0027);

  // Light Theme Neutrals
  static const Color lightBg = Color(0xFFF4F6F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E7EB);
  static const Color lightText = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);

  // Dark Theme Neutrals
  static const Color darkBg = Color(0xFF0A0F1D);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkCardBorder = Color(0xFF334155);
  static const Color darkText = Color(0xFFF9FAFB);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1E293B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandPrimaryDark, brandPrimary, brandPrimaryLight],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F2B82), Color(0xFF1A44B8)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF059669), Color(0xFF10B981)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x1A1A44B8), Color(0x052563EB)],
  );
}

