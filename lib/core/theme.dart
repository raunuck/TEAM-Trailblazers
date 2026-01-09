import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBlue = Color(0xFF131635);
  static const Color goldAccent = Color(0xFFCCA35E);
  static const Color cardCreamBg = Color(0xFFFDF6E3);
  static const Color innerBlockBg = Color(0xFFFCEFD0);
  
  static const Color textDarkBlue = Color(0xFF131635);
  static const Color primaryBlue = darkBlue;
  static const Color background = Color(0xFFF5F5F5);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: darkBlue,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: darkBlue,
      secondary: goldAccent,
      surface: cardCreamBg, 
      onSurface: darkBlue,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBlue,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkBlue,
    scaffoldBackgroundColor: const Color(0xFF0A0C1D),
    colorScheme: const ColorScheme.dark(
      primary: goldAccent,
      secondary: goldAccent,
      surface: Color(0xFF1C234C),
      onSurface: Color(0xFFE0E0E0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0A0C1D),
      iconTheme: IconThemeData(color: goldAccent),
    ),
    useMaterial3: true,
  );
}