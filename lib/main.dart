import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kyros/firebase_options.dart';
import 'package:kyros/screens/main_screen.dart';
import 'package:kyros/splash_screen.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ColorScheme lightColorScheme;
              ColorScheme darkColorScheme;

              if (lightDynamic != null && darkDynamic != null && themeProvider.isDynamic) {
                lightColorScheme = lightDynamic;
                darkColorScheme = darkDynamic;
              } else {
                lightColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                );
                darkColorScheme = ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                );
              }

              final textTheme = TextTheme(
                displayLarge: GoogleFonts.oswald(
                  fontSize: 57,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(
                      color: lightColorScheme.onPrimaryContainer),
                ),
                titleLarge: GoogleFonts.roboto(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  textStyle: TextStyle(
                      color: lightColorScheme.onSecondaryContainer),
                ),
                bodyMedium: GoogleFonts.openSans(
                  fontSize: 14,
                  textStyle:
                      TextStyle(color: lightColorScheme.onTertiaryContainer),
                ),
              );

              return MaterialApp(
                title: 'Kyros',
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: lightColorScheme,
                  textTheme: textTheme,
                  appBarTheme: AppBarTheme(
                    backgroundColor: lightColorScheme.primary,
                    foregroundColor: lightColorScheme.onPrimary,
                    titleTextStyle: GoogleFonts.oswald(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: lightColorScheme.onPrimary,
                      backgroundColor: lightColorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                darkTheme: ThemeData(
                  useMaterial3: true,
                  colorScheme: darkColorScheme,
                  textTheme: textTheme,
                  appBarTheme: AppBarTheme(
                    backgroundColor: darkColorScheme.primary,
                    foregroundColor: darkColorScheme.onPrimary,
                    titleTextStyle: GoogleFonts.oswald(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: darkColorScheme.onPrimary,
                      backgroundColor: darkColorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                themeMode: themeProvider.themeMode,
                home: const SplashScreen(),
                routes: {
                  '/main': (context) => const MainScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}