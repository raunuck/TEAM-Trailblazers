import 'package:flutter/material.dart';
import 'screens/main_layout.dart'; // <--- IMPORT THIS (Your frame)
// import 'screens/dashboard/home_screen.dart'; // <--- REMOVE OR IGNORE THIS

void main() {
  runApp(const MyApp());
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