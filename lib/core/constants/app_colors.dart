import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class AppColors {
  AppColors._();

  static Color get background => ThemeService.instance.current.background;
  static Color get surface => ThemeService.instance.current.surface;
  static Color get surfaceLight => ThemeService.instance.current.surfaceLight;
  static Color get cardBackground =>
      ThemeService.instance.current.cardBackground;

  static Color get gold => ThemeService.instance.current.gold;
  static Color get goldLight => ThemeService.instance.current.goldLight;
  static Color get goldDark => ThemeService.instance.current.goldDark;
  static Color get purple => ThemeService.instance.current.purple;
  static Color get purpleLight => ThemeService.instance.current.purpleLight;
  static Color get midnightBlue => ThemeService.instance.current.midnightBlue;
  static Color get action =>
      ThemeService.instance.current.brightness == Brightness.light
          ? purple
          : gold;
  static Color get actionLight =>
      ThemeService.instance.current.brightness == Brightness.light
          ? purpleLight
          : goldLight;
  static Color get onAction =>
      ThemeService.instance.current.brightness == Brightness.light
          ? Colors.white
          : background;

  static LinearGradient get backgroundGradient =>
      ThemeService.instance.current.backgroundGradient;
  static LinearGradient get goldGradient =>
      ThemeService.instance.current.goldGradient;
  static LinearGradient get purpleGradient =>
      ThemeService.instance.current.purpleGradient;
  static LinearGradient get actionGradient =>
      ThemeService.instance.current.brightness == Brightness.light
          ? purpleGradient
          : goldGradient;
  static LinearGradient get cardGradient =>
      ThemeService.instance.current.cardGradient;
  static LinearGradient get deepSpaceGradient =>
      ThemeService.instance.current.deepSpaceGradient;

  static Color get textPrimary => ThemeService.instance.current.textPrimary;
  static Color get textSecondary => ThemeService.instance.current.textSecondary;
  static Color get textMuted => ThemeService.instance.current.textMuted;
  static Color get textGold => ThemeService.instance.current.textGold;

  static Color get success => ThemeService.instance.current.success;
  static Color get error => ThemeService.instance.current.error;
  static Color get warning => ThemeService.instance.current.warning;

  static Color get border => ThemeService.instance.current.border;
  static Color get borderGold => ThemeService.instance.current.borderGold;

  static List<Color> get pinDigitColors =>
      ThemeService.instance.current.pinDigitColors;
}
