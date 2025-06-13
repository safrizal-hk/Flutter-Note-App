import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF000000), // Black
      onPrimary: Color(0xFFFFFFFF), // White
      surface: Color(0xFFFAFAFA), // Very light gray
      onSurface: Color(0xFF212121), // Dark gray
      surfaceTint: Colors.transparent, // Menghilangkan tint ungu
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0), // Abu-abu tipis untuk mode terang
      thickness: 1.0,
      space: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F5F5),
      foregroundColor: Color(0xFF212121),
      elevation: 0,
      shadowColor: Color(0x1A000000),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFFFFFFFF),
      elevation: 1,
      shadowColor: Color(0x1A000000),
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121)),
      bodyMedium: TextStyle(color: Color(0xFF424242)),
      titleLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFF000000), fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Color(0xFF212121), fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 2,
        shadowColor: Color(0x1A000000),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF000000),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 4,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xFF616161)),
      filled: true,
      fillColor: Color(0xFFFAFAFA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF000000), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0xFF000000),
      unselectedItemColor: Color(0xFF757575),
      elevation: 8,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFFFFFFFF),
      titleTextStyle: TextStyle(color: Color(0xFF000000), fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Color(0xFF212121)),
      elevation: 8,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF), // White
      onPrimary: Color(0xFF000000), // Black
      surface: Color(0xFF2C2C2C), // Dark gray
      onSurface: Color(0xFFE0E0E0), // Light gray
      surfaceTint: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242), // Abu-abu tipis untuk mode gelap
      thickness: 1.0,
      space: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      shadowColor: Color(0x1AFFFFFF),
    ),
    cardTheme: const CardTheme(
      color: Color(0xFF1E1E1E),
      elevation: 1,
      shadowColor: Color(0x1AFFFFFF),
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontSize: 18, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: Color(0xFFE0E0E0), fontSize: 24, fontWeight: FontWeight.w600),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFFFFF),
        foregroundColor: Color(0xFF000000),
        elevation: 2,
        shadowColor: Color(0x1AFFFFFF),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF000000),
      elevation: 4,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF424242)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: Color(0xFF424242)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      selectedItemColor: Color(0xFFFFFFFF),
      unselectedItemColor: Color(0xFF757575),
      elevation: 8,
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: Color(0xFF1E1E1E),
      titleTextStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 20, fontWeight: FontWeight.bold),
      contentTextStyle: TextStyle(color: Color(0xFFE0E0E0)),
      elevation: 8,
    ),
  );
}