import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF008080); // Teal
const Color secondaryColor = Color(0xFFC8A2C8); // Lilac
const Color lightBackgroundColor = Color(0xFFF0F8FF); // Alice Blue
const Color darkBackgroundColor = Color(0xFF29465B); // Dark Slate Blue

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.light,
        surface: lightBackgroundColor,
      ),
      textTheme: GoogleFonts.latoTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
        surface: darkBackgroundColor,
      ),
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackgroundColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
