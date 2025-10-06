
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/highlight_service.dart';
import 'package:kyros/screens/main_screen.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        Provider(create: (context) => HighlightService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Define the custom color palette
        const Color primaryColor = Color(0xFF008080); // Teal
        const Color secondaryColor = Color(0xFFC8A2C8); // Lilac
        const Color lightBackgroundColor = Color(0xFFF0F8FF); // Alice Blue
        const Color darkBackgroundColor = Color(0xFF29465B); // Dark Slate Blue

        // Define a common TextTheme
        final TextTheme appTextTheme = _buildTextTheme(themeProvider.fontScaleFactor);

        // --- Static Light Theme ---
        final ColorScheme lightColorScheme = ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          secondary: secondaryColor,
        ).copyWith(
          surface: lightBackgroundColor, // Use surface for main background
        );

        final ThemeData lightTheme = ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
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

        // --- Static Dark Theme ---
        final ColorScheme darkColorScheme = ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.dark,
          secondary: secondaryColor,
        ).copyWith(
          surface: darkBackgroundColor,
        );

        final ThemeData darkTheme = ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          scaffoldBackgroundColor: darkBackgroundColor,
          textTheme: appTextTheme,
          appBarTheme: AppBarTheme(
            backgroundColor: darkBackgroundColor,
            foregroundColor: Colors.white,
            titleTextStyle: GoogleFonts.oswald(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: darkColorScheme.onPrimaryContainer,
              backgroundColor: darkColorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        );

        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            ThemeData activeLightTheme = lightTheme;
            ThemeData activeDarkTheme = darkTheme;

            if (themeProvider.isDynamic && lightDynamic != null && darkDynamic != null) {
              activeLightTheme = ThemeData(
                useMaterial3: true,
                colorScheme: lightDynamic,
                textTheme: appTextTheme,
              );
              activeDarkTheme = ThemeData(
                useMaterial3: true,
                colorScheme: darkDynamic,
                textTheme: appTextTheme,
              );
            }

            return MaterialApp(
              title: 'Kyros',
              theme: activeLightTheme,
              darkTheme: activeDarkTheme,
              themeMode: themeProvider.themeMode,
              home: const MainScreen(),
              debugShowCheckedModeBanner: false,
            );
          },
        );
      },
    );
  }

  TextTheme _buildTextTheme(double scale) {
    return TextTheme(
      displayLarge: GoogleFonts.oswald(fontSize: 57 * scale, fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.roboto(fontSize: 22 * scale, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14 * scale),
    );
  }
}
