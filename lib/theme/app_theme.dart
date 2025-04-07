import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFFF2F0EF),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFCCCBCA),
      foregroundColor: Color(0xFF2E2E2E),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFCCCBCA),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF2E2E2E)),
      bodyMedium: TextStyle(color: Color(0xFF2E2E2E)),
      titleLarge: TextStyle(color: Color(0xFF2E2E2E), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFF2E2E2E), fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Color(0xFF2E2E2E), fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E2E2E),
        foregroundColor: Colors.white,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E2E2E),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Color(0xFFCCCBCA), // Warna background TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF2E2E2E)),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFCCCBCA),
      selectedItemColor: Color(0xFF2E2E2E),
      unselectedItemColor: Colors.grey,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFF2F0EF),
      titleTextStyle: TextStyle(color: Color(0xFF2E2E2E), fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Color(0xFF2E2E2E)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2E2E2E),
      foregroundColor: Colors.white,
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF2E2E2E),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1E1E),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1E1E1E),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Color(0xFF2E2E2E), // Warna background TextField
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2E2E2E),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF2E2E2E),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}