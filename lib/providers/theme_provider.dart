import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load saved theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String mode = prefs.getString(Constants.keyThemeMode) ?? 'dark';
    _themeMode = mode == 'light' ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Toggle between dark and light mode
  Future<void> toggleTheme() async {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      Constants.keyThemeMode,
      isDarkMode ? 'dark' : 'light',
    );
  }
}
