import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadPersistedTheme();
    return ThemeMode.system;
  }

  Future<void> _loadPersistedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(AppConstants.themeKey);
      if (savedMode == 'dark') {
        state = ThemeMode.dark;
      } else if (savedMode == 'light') {
        state = ThemeMode.light;
      } else {
        state = ThemeMode.system;
      }
    } catch (_) {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.dark:
          await prefs.setString(AppConstants.themeKey, 'dark');
          break;
        case ThemeMode.light:
          await prefs.setString(AppConstants.themeKey, 'light');
          break;
        case ThemeMode.system:
          await prefs.setString(AppConstants.themeKey, 'system');
          break;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
