import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: const Color(0xFF141414), // Netflix-like background
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: const ColorScheme.dark(
      primary: Colors.redAccent,
      secondary: Colors.white,
      surface: Color(0xFF2A2A2A),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF333333),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: Colors.white54),
    ),
  );
}
