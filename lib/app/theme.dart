import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';
import '../core/services/theme_service.dart';

ThemeData buildAppTheme() {
  final selectedTheme = ThemeService.instance.current;
  final baseTheme = selectedTheme.brightness == Brightness.dark
      ? ThemeData.dark(useMaterial3: true)
      : ThemeData.light(useMaterial3: true);
  final colorScheme = ColorScheme(
    brightness: selectedTheme.brightness,
    primary: AppColors.action,
    secondary: AppColors.purple,
    tertiary: AppColors.purpleLight,
    inversePrimary: AppColors.actionLight,
    surface: AppColors.surface,
    error: AppColors.error,
    onPrimary: AppColors.onAction,
    onSecondary: AppColors.textPrimary,
    onSurface: AppColors.textPrimary,
    onError: AppColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.cardBackground,
    dividerColor: AppColors.border,
    textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textGold, fontWeight: FontWeight.w600),
      headlineLarge: GoogleFonts.playfairDisplay(
          color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.inter(color: AppColors.textPrimary, height: 1.6),
      bodyMedium:
          GoogleFonts.inter(color: AppColors.textSecondary, height: 1.5),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: selectedTheme.systemUiOverlayStyle,
      titleTextStyle: GoogleFonts.playfairDisplay(
        color: AppColors.textGold,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.action,
        foregroundColor: AppColors.onAction,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textGold,
        side: BorderSide(color: AppColors.borderGold, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.action, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.error),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
      hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 14),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.action,
      unselectedItemColor: AppColors.textMuted,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceLight,
      contentTextStyle: GoogleFonts.inter(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.action;
        return Colors.transparent;
      }),
      side: BorderSide(color: AppColors.borderGold, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}
