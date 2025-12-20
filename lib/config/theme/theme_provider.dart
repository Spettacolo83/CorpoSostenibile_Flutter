import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modalità tema disponibili
enum ThemeModeOption {
  light(Icons.light_mode, 'Chiaro'),
  dark(Icons.dark_mode, 'Scuro'),
  system(Icons.brightness_auto, 'Auto');

  final IconData icon;
  final String label;

  const ThemeModeOption(this.icon, this.label);

  ThemeMode toThemeMode() {
    switch (this) {
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
      case ThemeModeOption.system:
        return ThemeMode.system;
    }
  }
}

/// Provider per la gestione del tema
final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeModeOption>((ref) {
  return ThemeNotifier();
});

/// Notifier per gestire lo stato del tema
class ThemeNotifier extends StateNotifier<ThemeModeOption> {
  static const _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeModeOption.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 2; // Default: system
    state = ThemeModeOption.values[themeIndex];
  }

  Future<void> setTheme(ThemeModeOption mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Cicla tra le modalità: light -> dark -> system -> light...
  Future<void> cycleTheme() async {
    final nextIndex = (state.index + 1) % ThemeModeOption.values.length;
    await setTheme(ThemeModeOption.values[nextIndex]);
  }
}
