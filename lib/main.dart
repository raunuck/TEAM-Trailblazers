import 'package:flutter/material.dart';
import 'package:adaptive_student_time/core/theme.dart';
import 'package:adaptive_student_time/screens/auth/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dgramltguzqwpxwwpdyw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRncmFtbHRndXpxd3B4d3dwZHl3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjcwOTExNzgsImV4cCI6MjA4MjY2NzE3OH0.UG09iFMcYbDgPSQ3kKB0T3X4EWJwS11DPjHsdt_W5uw',
  );
  runApp(MyApp());
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
