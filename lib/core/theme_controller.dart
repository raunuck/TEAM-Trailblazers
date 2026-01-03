import 'package:flutter/material.dart';

// A simple global controller to switch themes
class ThemeController with ChangeNotifier {
  // Start with System default
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners(); // Tells the app to update!
  }
}

// Global instance so we can access it anywhere
final themeController = ThemeController();