import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    // Colores principales
    primary: Color(0xFFBB86FC),
    onPrimary: Color(0xFF000000),
    secondary: Color(0xFF03DAC6),
    onSecondary: Color(0xFF000000),
    
    // Colores de superficie
    surface: Color(0xFF1E1E1E),
    onSurface: Color(0xFFFFFFFF),
    onSurfaceVariant: Color(0xFFC8C8C8),
        
    // Colores de error
    error: Color.fromARGB(255, 252, 99, 127),
    onError: Color(0xFF000000),
    
    // Outline
    outline: Color(0xFF79747E),
    outlineVariant: Color(0xFF444444),
  ),
  
  // Configuraciones adicionales
  scaffoldBackgroundColor: const Color(0xFF121212),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Colors.white,
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
      borderSide: const BorderSide(color: Color(0xFFBB86FC)),
    ),
  ),
);