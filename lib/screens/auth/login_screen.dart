import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:adaptive_student_time/core/theme.dart';
import '../onboarding/interest_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLogin = true; 
  
  bool isStudent = true; 
  
  bool _isLoading = false;

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
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } else {
        final AuthResponse response = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          if (response.session == null) {
            _showSnackBar("Please check your email to confirm your account.", Colors.blue);
            setState(() => _isLoading = false);
            return;
          }

          await Supabase.instance.client.from('profiles').upsert({
            'id': response.user!.id,
            'email': email,
            'role': isStudent ? 'Student' : 'Teacher',
            'created_at': DateTime.now().toIso8601String(),
          });
          
          if (mounted) _showSnackBar("Account created successfully!", Colors.green);
        }
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterestScreen(isStudent: isStudent),
          ),
        );
      }

    } on AuthException catch (e) {
      _showSnackBar(e.message, Colors.redAccent);
    } catch (e) {
      _showSnackBar("Error: $e", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

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