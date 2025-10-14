import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFBFF),
    onSurface: Color(0xFF1C1B1F),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFF79747E),
  ),
  scaffoldBackgroundColor: const Color(0xFFF5F5F5),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF1C1B1F),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF1C1B1F)),
    bodyMedium: TextStyle(color: Color(0xFF3C3B42)),
    bodySmall: TextStyle(color: Color(0xFF605D66)),
  ),
);