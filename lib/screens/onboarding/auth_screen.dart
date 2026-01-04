import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'interest_screen.dart'; // Navigation to next step

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // Ensure background matches theme
      backgroundColor: isDark ? AppTheme.darkBlue : AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : AppTheme.darkBlue),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isDark ? AppTheme.goldAccent : AppTheme.darkBlue)),
            const SizedBox(height: 8),
            Text("Please sign in to continue.", style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
            const SizedBox(height: 40),
            
            // User ID Field
            _buildTextField("User ID", Icons.person, isDark),
            const SizedBox(height: 20),
            
            // Password Field
            _buildTextField("Password", Icons.lock, isDark, obscure: true),
            const SizedBox(height: 40),
            
            // Login Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Interest Screen
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => const InterestScreen(isStudent: true) // Pass 'true' or your state variable here
                    )
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: AppTheme.darkBlue,
                ),
                child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, bool isDark, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}