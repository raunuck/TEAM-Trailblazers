import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vault/vault_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/onboarding/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_PROJECT_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // --- NEW: Sign in anonymously if not already logged in ---
  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    try {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint("Logged in anonymously!");
    } catch (e) {
      debugPrint("Error logging in: $e");
    }
  }
  // ---------------------------------------------------------

  runApp(const MyApp());
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
      
      home: const WelcomeScreen(),
    );
  }
}