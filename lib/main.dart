import 'package:flutter/material.dart';
import 'package:adaptive_student_time/core/theme.dart';
import 'package:adaptive_student_time/screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Student Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Using our custom theme
      home: const LoginScreen(),  // Starting with the login screen
    );
  }
}