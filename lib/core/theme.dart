import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors based on the Academic/Growth concept
  static const Color primaryBlue = Color(0xFF2563EB); // For academic schedules
  static const Color growthGreen = Color(0xFF10B981); // For free-time opportunities
  static const Color background = Color(0xFFF8FAFC);  // Clean off-white
  static const Color textDark = Color(0xFF1E293B);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primaryBlue,
      
      // Text Theme using Google Fonts (Poppins)
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textDark,
        displayColor: textDark,
      ),

      // Button Styles
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      
      // Input Field Styles
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}