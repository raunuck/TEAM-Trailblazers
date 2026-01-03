import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'main_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldAccent, width: 2),
                  color: AppTheme.goldAccent.withOpacity(0.1),
                ),
                child: const Icon(Icons.hive_outlined, size: 60, color: AppTheme.goldAccent),
              ),
              const SizedBox(height: 24),
              const Text("PlanBEE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.goldAccent, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text("Organize your life, like a hive.", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainLayout())),
                  icon: const Icon(Icons.login, color: AppTheme.darkBlue),
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