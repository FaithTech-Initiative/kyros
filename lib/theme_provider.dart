import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDynamic = false; // Default to false, so the custom theme is the default
  double _fontScaleFactor = 1.0;

  ThemeMode get themeMode => _themeMode;
  bool get isDynamic => _isDynamic;
  double get fontScaleFactor => _fontScaleFactor;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void toggleDynamicColor() {
    _isDynamic = !_isDynamic;
    notifyListeners();
  }

  void setFontScaleFactor(double factor) {
    _fontScaleFactor = factor;
    notifyListeners();
  }

  void reset() {
    _themeMode = ThemeMode.system;
    _isDynamic = false;
    _fontScaleFactor = 1.0;
    notifyListeners();
  }
}
