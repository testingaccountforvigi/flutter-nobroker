import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Typography system using system fonts with proper hierarchy.
/// Focuses on readability and premium feel.
class AppTypography {
  AppTypography._();

  // Font weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Display - Large hero text
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.3,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15,
    fontWeight: regular,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    fontWeight: regular,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // Labels and captions
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: medium,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: regular,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 11,
    fontWeight: regular,
    height: 1.3,
    color: AppColors.textTertiary,
  );

  // Special purpose
  static const TextStyle price = TextStyle(
    fontSize: 24,
    fontWeight: bold,
    height: 1.2,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 18,
    fontWeight: bold,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.25,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13,
    fontWeight: semiBold,
    height: 1.2,
    letterSpacing: 0.25,
  );
  
  // Alias for consistency
  static const TextStyle body = bodyMedium;
}
