import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme.dart';
import '../../screens/main_layout.dart';
import '../onboarding/interest_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Toggle: Are we Logging In or Signing Up?
  bool _isLogin = true; 
  
  // Toggle: Student vs Teacher
  bool isStudent = true; 
  
  bool _isLoading = false;

  // --- AUTH LOGIC ---

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- 1. LOGIN MODE ---
        final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        // Check if user exists, then check interests
        if (res.user != null && mounted) {
          await _checkInterestsAndNavigate(res.user!.id);
        }
      } else {
        // --- 2. SIGN UP MODE ---
        final AuthResponse response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Check if email confirmation is required/missing
          if (response.session == null) {
            _showSnackBar("Please check your email to confirm your account.", Colors.blue);
            setState(() => _isLoading = false);
            return;
          }

          // Create the profile row (Safe Insert)
          await Supabase.instance.client.from('profiles').upsert({
            'id': response.user!.id,
            'email': email,
            'role': isStudent ? 'Student' : 'Teacher',
            'created_at': DateTime.now().toIso8601String(),
          });
          
          if (mounted) {
             _showSnackBar("Account created successfully!", Colors.green);
             // New users ALWAYS go to Interest Screen
             Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => InterestScreen(isStudent: isStudent)),
            );
          }
        }
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message, Colors.redAccent);
      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackBar("Error: $e", Colors.redAccent);
      setState(() => _isLoading = false);
    }
  }

  // --- HELPER FUNCTIONS (Placed here, inside the class) ---

  Future<void> _checkInterestsAndNavigate(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('interests')
          .eq('id', userId)
          .maybeSingle();

      bool hasInterests = false;
      if (data != null && data['interests'] != null) {
        final List interests = data['interests'];
        if (interests.isNotEmpty) {
          hasInterests = true;
        }
      }

      if (!mounted) return;

      if (hasInterests) {
        // Existing user -> Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        // Incomplete profile -> Interest Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterestScreen(isStudent: isStudent)),
        );
      }
    } catch (e) {
      debugPrint("Error checking profile: $e");
      // Fallback: If check fails, just go to Interest Screen to be safe
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterestScreen(isStudent: isStudent)),
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // --- UI CODE ---
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                
                Text(
                  _isLogin ? "Welcome Back," : "Create Account,",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                      ? "Let's turn your downtime into growth." 
                      : "Start your learning journey today.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 40),

                // Role Toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildRoleButton("Student", true),
                      _buildRoleButton("Teacher", false),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Inputs
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 40),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isLogin ? "Sign In" : "Sign Up", 
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // Mode Switch Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "New here? " : "Already have an account? ",
                        style: const TextStyle(color: Colors.grey, fontSize: 16),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Create Account" : "Sign In",
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(String text, bool value) {
    bool isSelected = isStudent == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isStudent = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryBlue : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}