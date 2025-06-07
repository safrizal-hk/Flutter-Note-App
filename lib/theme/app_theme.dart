import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFFFFFFFF), // Putih
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF), // Putih
      foregroundColor: Color(0xFF000000), // Hitam
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFFFFFFF), // Putih
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF000000)),
      bodyMedium: TextStyle(color: Color(0xFF000000)),
      titleLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFF000000), fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Color(0xFF000000), fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000), // Hitam
        foregroundColor: Color(0xFFFFFFFF), // Putih
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF000000), // Hitam
      foregroundColor: Color(0xFFFFFFFF), // Putih
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xFF000000)),
      filled: true,
      fillColor: Color(0xFFFFFFFF), // Putih
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF000000)), // Hitam
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF), // Putih
      selectedItemColor: Color(0xFF000000), // Hitam
      unselectedItemColor: Color(0xFF000000), // Hitam
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFFFFFFF), // Putih
      titleTextStyle: TextStyle(color: Color(0xFF000000), fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Color(0xFF000000)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFF000000), // Hitam
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000), // Hitam
      foregroundColor: Color(0xFFFFFFFF), // Putih
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF000000), // Hitam
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFFFFF), // Putih
        foregroundColor: Color(0xFF000000), // Hitam
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFFFFF), // Putih
      foregroundColor: Color(0xFF000000), // Hitam
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xFFFFFFFF)),
      filled: true,
      fillColor: Color(0xFF000000), // Hitam
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFFFFF)), // Putih
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF000000), // Hitam
      selectedItemColor: Color(0xFFFFFFFF), // Putih
      unselectedItemColor: Color(0xFFFFFFFF), // Putih
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF000000), // Hitam
      titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
    ),
  );
}