import 'package:flutter/material.dart';

class AppTheme {
  static const Color deepBlue = Color(0xFF1A237E);
  static const Color accentOrange = Color(0xFFFF6F00);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: deepBlue,
      brightness: Brightness.light,
      primary: deepBlue,
      secondary: accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F8FC),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardTheme(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      ),
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: deepBlue,
      brightness: Brightness.dark,
      primary: const Color(0xFF90A4FF),
      secondary: accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0D1020),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardTheme(
        elevation: 0,
        color: const Color(0xFF171B31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: const Color(0xFF171B31),
      ),
    );
  }
}
