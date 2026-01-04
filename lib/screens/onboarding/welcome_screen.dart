import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'login_screen.dart'; // Navigation to next step


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              
              // --- FIX 1: CUSTOM LOGO ---
              // Uses the image you added to assets
              Image.asset(
                'assets/logo.png',
                height: 150, // Adjust size as needed
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image isn't found yet
                  return const Icon(Icons.hive_outlined, size: 100, color: AppTheme.goldAccent);
                },
              ),
              
              const SizedBox(height: 24),
              const Text("PlanBEE", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.goldAccent, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text("Organize your life, like a hive.", style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7))),
              const Spacer(flex: 2),
              
              // --- BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to the NEW Auth Screen (User/Pass)
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