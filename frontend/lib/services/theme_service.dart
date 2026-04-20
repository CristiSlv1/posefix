import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _prefsKey = 'theme_mode';
  ThemeMode _mode = ThemeMode.dark;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);
    if (stored == 'light') {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  Future<void> toggle() async {
    await setMode(_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }
}
