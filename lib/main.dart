import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart'; // <--- Import the new controller
import 'screens/login_screen.dart';

void main() {
  initializeDateFormatting().then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Listen to the controller. When it changes, rebuild the app.
    themeController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PlanBEE',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // CRITICAL CHANGE: Use the controller's value instead of just 'system'
      themeMode: themeController.themeMode, 
      
      home: const LoginScreen(),
    );
  }
}