import 'package:flutter/material.dart';

enum TempoTheme {
  light,
  dark,
  highContrast,
}

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorSchemeSeed: Colors.blue,
  useMaterial3: true,
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorSchemeSeed: Colors.blue,
  useMaterial3: true,
);

ThemeData highContrastTheme = ThemeData(
  brightness: Brightness.dark,

  scaffoldBackgroundColor: Colors.black,

  colorScheme: const ColorScheme.dark(
    primary: Colors.yellow,
    secondary: Colors.cyan,
    surface: Colors.black,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),

  useMaterial3: true,
);