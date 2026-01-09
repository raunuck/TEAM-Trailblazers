import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'login_screen.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final Color mainTextColor = isDark ? Colors.white : AppTheme.darkBlue;
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              
              Image.asset(
                'assets/logo.png',
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.hive_outlined, size: 100, color: AppTheme.goldAccent);
                },
              ),
              
              const SizedBox(height: 24),
              const Text("PlanBEE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.goldAccent, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text("Organize your life, like a hive.", style: TextStyle(fontSize: 16, color: isDark ? Colors.white : AppTheme.darkBlue)),
              const Spacer(flex: 2),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  icon: const Icon(Icons.arrow_forward, color: AppTheme.darkBlue),
                  label: const Text("Get Started", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.darkBlue)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}