import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController() {
    _load();
  }

  static const _key = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool enabled) async {
    _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, enabled ? 'dark' : 'light');
  }
}
