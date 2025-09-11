import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: Colors.grey.shade500,
    onPrimary: Colors.white,
    secondary: Colors.grey.shade200,
    onSecondary: Colors.black,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black,
  ),

  scaffoldBackgroundColor: Colors.grey.shade300,
);