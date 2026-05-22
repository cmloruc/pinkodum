import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppThemeId { geceRitueli, lavanta }

class AppThemeData {
  final AppThemeId id;
  final String name;
  final String description;

  // Arka plan
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color cardBackground;

  // Gradyanlar
  final LinearGradient backgroundGradient;
  final LinearGradient cardGradient;
  final LinearGradient goldGradient;
  final LinearGradient purpleGradient;
  final LinearGradient deepSpaceGradient;

  // Vurgu
  final Color gold;
  final Color goldLight;
  final Color goldDark;
  final Color purple;
  final Color purpleLight;
  final Color midnightBlue;

  // Metin
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textGold;

  // Durum
  final Color success;
  final Color error;
  final Color warning;

  // Kenarlık
  final Color border;
  final Color borderGold;

  // Pin haneleri
  final List<Color> pinDigitColors;

  // Sistem UI
  final Brightness brightness;
  final SystemUiOverlayStyle systemUiOverlayStyle;

  const AppThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.cardBackground,
    required this.backgroundGradient,
    required this.cardGradient,
    required this.goldGradient,
    required this.purpleGradient,
    required this.deepSpaceGradient,
    required this.gold,
    required this.goldLight,
    required this.goldDark,
    required this.purple,
    required this.purpleLight,
    required this.midnightBlue,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textGold,
    required this.success,
    required this.error,
    required this.warning,
    required this.border,
    required this.borderGold,
    required this.pinDigitColors,
    required this.brightness,
    required this.systemUiOverlayStyle,
  });
}

// Tema 1: Gece Ritueli
const geceRitueliTheme = AppThemeData(
  id: AppThemeId.geceRitueli,
  name: 'Gece Ritüeli',
  description: 'Derin gece, mor isik, sampanya altin',
  background: Color(0xFF0D0A1F),
  surface: Color(0xFF15102D),
  surfaceLight: Color(0xFF24164A),
  cardBackground: Color(0xFF130D2D),
  backgroundGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF171036), Color(0xFF0D0A1F), Color(0xFF070716)],
  ),
  cardGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xAA3B216B), Color(0xCC171033)],
  ),
  goldGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD9A0), Color(0xFFF0BC76), Color(0xFFC98C47)],
  ),
  purpleGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC06CFF), Color(0xFF8D43D5), Color(0xFF4B267E)],
  ),
  deepSpaceGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF21104A), Color(0xFF0D0A1F), Color(0xFF050611)],
  ),
  gold: Color(0xFFF0BC76),
  goldLight: Color(0xFFFFD9A0),
  goldDark: Color(0xFFC98C47),
  purple: Color(0xFF8D43D5),
  purpleLight: Color(0xFFC06CFF),
  midnightBlue: Color(0xFF18143A),
  textPrimary: Color(0xFFF6F0FF),
  textSecondary: Color(0xFFD0C3E6),
  textMuted: Color(0xFF8E81AB),
  textGold: Color(0xFFFFD09A),
  success: Color(0xFF4CAF82),
  error: Color(0xFFEF5350),
  warning: Color(0xFFFFB74D),
  border: Color(0xFF3D2C65),
  borderGold: Color(0xFF8A5C38),
  pinDigitColors: [
    Color(0xFFD4A054),
    Color(0xFF8B40BF),
    Color(0xFF60A5FA),
    Color(0xFF4CAF82),
    Color(0xFFD4A054),
    Color(0xFFF472B6),
    Color(0xFF8B40BF),
    Color(0xFF60A5FA),
    Color(0xFFD4A054),
  ],
  brightness: Brightness.dark,
  systemUiOverlayStyle: SystemUiOverlayStyle.light,
);

// Tema 2: Lavanta
const lavantaTheme = AppThemeData(
  id: AppThemeId.lavanta,
  name: 'Lavanta',
  description: 'Isikli lavanta, mor ve antik altin',
  background: Color(0xFFF9F5FF),
  surface: Color(0xFFF0E8FF),
  surfaceLight: Color(0xFFE6D8FA),
  cardBackground: Color(0xEFFFFFFF),
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFBF7), Color(0xFFF4ECFF), Color(0xFFEDE6FF)],
  ),
  cardGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xF7FFFFFF), Color(0xE8F2E8FF)],
  ),
  goldGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD8A15A), Color(0xFFB7752D), Color(0xFF874811)],
  ),
  purpleGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D82EA), Color(0xFF6D47C4), Color(0xFF4D248D)],
  ),
  deepSpaceGradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5EEF8), Color(0xFFE8DDF5), Color(0xFFF5EEF8)],
  ),
  gold: Color(0xFFA9641C),
  goldLight: Color(0xFFD8A15A),
  goldDark: Color(0xFF75410D),
  purple: Color(0xFF5B32AE),
  purpleLight: Color(0xFF8B68DE),
  midnightBlue: Color(0xFF4B4A7A),
  textPrimary: Color(0xFF29144A),
  textSecondary: Color(0xFF5E5479),
  textMuted: Color(0xFF8C80AA),
  textGold: Color(0xFF8F5314),
  success: Color(0xFF2E7D52),
  error: Color(0xFFC62828),
  warning: Color(0xFFE65100),
  border: Color(0xFFD8C7F2),
  borderGold: Color(0xFFC48A43),
  pinDigitColors: [
    Color(0xFFA9641C),
    Color(0xFF7C4DB0),
    Color(0xFF3B82F6),
    Color(0xFF2E7D52),
    Color(0xFFA9641C),
    Color(0xFFEC4899),
    Color(0xFF7C4DB0),
    Color(0xFF3B82F6),
    Color(0xFFA9641C),
  ],
  brightness: Brightness.light,
  systemUiOverlayStyle: SystemUiOverlayStyle.dark,
);

const List<AppThemeData> allThemes = [
  geceRitueliTheme,
  lavantaTheme,
];
