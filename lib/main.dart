import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/theme_controller.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/vault/vault_screen.dart';
import 'screens/onboarding/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dgramltguzqwpxwwpdyw.supabase.co',
    anonKey: 'sb_publishable_NEgKaz6XBa3evK7AQjAUEQ_apXKv_k_',
  );

  final session = Supabase.instance.client.auth.currentSession;
  if (session == null) {
    try {
      await Supabase.instance.client.auth.signInAnonymously();
      debugPrint("Logged in anonymously!");
    } catch (e) {
      debugPrint("Error logging in: $e");
    }
  }

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
      
      themeMode: themeController.themeMode, 
      
      home: const WelcomeScreen(),
    );
  }
}