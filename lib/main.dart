import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kyros/app_theme.dart';
import 'package:kyros/firebase_options.dart';
import 'package:kyros/screens/get_started_screen.dart';
import 'package:kyros/screens/main_screen.dart';
import 'package:kyros/splash_screen.dart';
import 'package:kyros/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  final prefs = await SharedPreferences.getInstance();
  final hasSeenGetStarted = prefs.getBool('hasSeenGetStarted') ?? false;

  runApp(MyApp(hasSeenGetStarted: hasSeenGetStarted));
}

class MyApp extends StatelessWidget {
  final bool hasSeenGetStarted;
  const MyApp({super.key, required this.hasSeenGetStarted});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              ThemeData lightTheme;
              ThemeData darkTheme;

              if (lightDynamic != null && darkDynamic != null && themeProvider.isDynamic) {
                lightTheme = ThemeData(
                  useMaterial3: true,
                  colorScheme: lightDynamic,
                );
                darkTheme = ThemeData(
                  useMaterial3: true,
                  colorScheme: darkDynamic,
                );
              } else {
                lightTheme = AppTheme.lightTheme;
                darkTheme = AppTheme.darkTheme;
              }

              return MaterialApp(
                title: 'Kyros',
                //debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: themeProvider.themeMode,
                home: hasSeenGetStarted
                    ? const SplashScreen()
                    : const GetStartedScreen(),
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
