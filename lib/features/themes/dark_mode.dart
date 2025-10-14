import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFBB86FC),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFF03DAC6),
    onSecondary: Color(0xFF000000),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFFFFFFF),
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
    outline: Color(0xFF79747E),
  ),
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white60),
  ),
);