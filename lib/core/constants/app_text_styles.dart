import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get displayLarge => GoogleFonts.cinzel(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textGold,
        letterSpacing: 1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textGold,
        letterSpacing: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 0.8,
      );

  static TextStyle get headlineMedium => GoogleFonts.cinzel(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
        height: 1.4,
      );

  static TextStyle get pinDigit => GoogleFonts.cinzel(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textGold,
        letterSpacing: 2,
      );

  static TextStyle get pinDigitSmall => GoogleFonts.cinzel(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textGold,
        letterSpacing: 1.5,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.background,
        letterSpacing: 0.5,
      );

  static TextStyle get buttonTextSecondary => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textGold,
        letterSpacing: 0.5,
      );

  static TextStyle get disclaimer => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
        height: 1.5,
      );
}
