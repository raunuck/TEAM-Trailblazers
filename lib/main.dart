import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_layout.dart'; // <--- IMPORT THIS (Your frame)
// import 'screens/dashboard/home_screen.dart'; // <--- REMOVE OR IGNORE THIS

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
      debugShowCheckedModeBanner: false,
      title: 'Adaptive Student Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      // CRITICAL CHANGE: Point to MainLayout, NOT HomeScreen
      home: const MainLayout(), 
    );
  }
}