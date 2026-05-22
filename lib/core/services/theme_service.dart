import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme_data.dart';

const _kThemeKey = 'selected_theme_id';

class ThemeService {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  final ValueNotifier<AppThemeData> notifier = ValueNotifier(geceRitueliTheme);

  AppThemeData get current => notifier.value;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    // Eski tema ID'leri artik gecersiz; yalnizca yeni iki tema okunur.
    final validIds = allThemes.map((t) => t.id.name).toSet();
    final theme = (saved != null && validIds.contains(saved))
        ? allThemes.firstWhere((t) => t.id.name == saved)
        : geceRitueliTheme;
    _apply(theme);
  }

  Future<void> setTheme(AppThemeData theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, theme.id.name);
    _apply(theme);
  }

  void _apply(AppThemeData t) {
    SystemChrome.setSystemUIOverlayStyle(
      t.systemUiOverlayStyle.copyWith(statusBarColor: Colors.transparent),
    );
    notifier.value = t;
  }
}
