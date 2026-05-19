import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Ana renkler
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111828);
  static const Color surfaceLight = Color(0xFF1A2236);
  static const Color cardBackground = Color(0xFF141C2E);

  // Vurgu renkleri
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C84A);
  static const Color goldDark = Color(0xFFA88B20);
  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleLight = Color(0xFF9D5FF0);
  static const Color midnightBlue = Color(0xFF1E3A5F);

  // Gradient'lar
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0E1A), Color(0xFF0D1520)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8C84A), Color(0xFFD4AF37), Color(0xFFA88B20)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9D5FF0), Color(0xFF7C3AED), Color(0xFF5B21B6)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2236), Color(0xFF141C2E)],
  );

  static const LinearGradient deepSpaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A0E1A), Color(0xFF1E3A5F), Color(0xFF0A0E1A)],
  );

  // Metin renkleri
  static const Color textPrimary = Color(0xFFF0EAD6);
  static const Color textSecondary = Color(0xFFB0A890);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textGold = Color(0xFFD4AF37);

  // Durum renkleri
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Kenarlık
  static const Color border = Color(0xFF2D3748);
  static const Color borderGold = Color(0xFF5A4A1E);

  // Pin kodu haneleri için renkler
  static const List<Color> pinDigitColors = [
    Color(0xFFD4AF37), // 1. hane - altın
    Color(0xFF9D5FF0), // 2. hane - mor
    Color(0xFF60A5FA), // 3. hane - mavi
    Color(0xFF34D399), // 4. hane - yeşil
    Color(0xFFD4AF37), // 5. hane - altın
    Color(0xFFF472B6), // 6. hane - pembe
    Color(0xFF9D5FF0), // 7. hane - mor
    Color(0xFF60A5FA), // 8. hane - mavi
    Color(0xFFD4AF37), // 9. hane - altın
  ];
}
