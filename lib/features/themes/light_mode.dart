import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    // Colores principales
    primary: Color(0xFF6750A4),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF625B71),
    onSecondary: Color(0xFFFFFFFF),
    
    // Colores de superficie
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1C1B1F),
    onSurfaceVariant: Color(0xFF49454F),
        
    // Colores de error
    error: Color.fromARGB(255, 238, 22, 22),
    onError: Color(0xFFFFFFFF),
    
    // Outline
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFFC4C7C5),
  ),
  
  // Configuraciones adicionales
  scaffoldBackgroundColor: const Color(0xFFFEF7FF),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFFFFF),
    foregroundColor: Color(0xFF1C1B1F),
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF79747E)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF79747E)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF6750A4)),
    ),
  ),
);