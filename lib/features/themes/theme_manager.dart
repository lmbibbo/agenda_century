import 'package:flutter/material.dart';

class ThemeManager {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _currentThemeMode = ThemeMode.system;
  
  ThemeMode get currentThemeMode => _currentThemeMode;
  
  void setThemeMode(ThemeMode themeMode) {
    _currentThemeMode = themeMode;
  }
  
  void toggleTheme() {
    _currentThemeMode = _currentThemeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
  }
}

// Instancia global
final themeManager = ThemeManager();