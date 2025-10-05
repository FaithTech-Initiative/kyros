
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/screens/main_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const KyrosApp(),
    ),
  );
}

// ThemeProvider class to manage the theme state
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setSystemTheme() {
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}

class KyrosApp extends StatelessWidget {
  const KyrosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Custom color palette
    const Color primaryColor = Color(0xFF008080); // Teal
    const Color secondaryColor = Color(0xFFC8A2C8); // Lilac
    const Color lightBackgroundColor = Color(0xFFF0F8FF); // Alice Blue
    const Color darkBackgroundColor = Color(0xFF29465B); // Dark Slate Blue

    // Define a common TextTheme
    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
    );

    // Light Theme
    final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    // Dark Theme
    final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      textTheme: appTextTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor.withBlue(100),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkBackgroundColor,
          backgroundColor: secondaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kyros',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}
