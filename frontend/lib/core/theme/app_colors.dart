import 'package:flutter/material.dart';

/// Centralized color palette for the NoBroker Owner Listings app.
/// Warm, editorial palette avoiding AI-generated gradients.
class AppColors {
  AppColors._();

  // Base colors - warm neutral palette
  static const Color background = Color(0xFFFAF9F7); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF5F3F0); // Slightly tinted

  // Text colors
  static const Color textPrimary = Color(0xFF2C2C2C); // Charcoal
  static const Color textSecondary = Color(0xFF6B6B6B); // Muted gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // Accent colors - warm terracotta/coral
  static const Color primary = Color(0xFFD4735A); // Warm terracotta
  static const Color primaryDark = Color(0xFFB85D48); // Darker terracotta
  static const Color primaryLight = Color(0xFFE89580); // Light coral

  // Semantic colors
  static const Color success = Color(0xFF5BA573); // Muted green
  static const Color error = Color(0xFFD45A5A); // Muted red
  static const Color warning = Color(0xFFE8A05D); // Warm orange
  static const Color info = Color(0xFF5A92D4); // Muted blue

  // Border and divider colors
  static const Color border = Color(0xFFE8E3DC); // Warm gray border
  static const Color divider = Color(0xFFF0EBE3); // Very light warm gray

  // Property status colors
  static const Color verified = Color(0xFF5BA573);
  static const Color premium = Color(0xFFD4735A);
  static const Color draft = Color(0xFF9E9E9E);

  // Overlay colors
  static const Color overlay = Color(0x80000000); // Semi-transparent black
  static const Color scrim = Color(0x40000000); // Lighter scrim

  // Gradient (minimal use)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4735A), Color(0xFFE89580)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Alias for consistency across codebase
  static const Color accent = primary;
}
