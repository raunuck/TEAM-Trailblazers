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
        final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null && mounted) {
          await _checkInterestsAndNavigate(res.user!.id);
        }
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
          
          if (mounted) {
            _showSnackBar("Account created successfully!", Colors.green);
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
        if (interests.isNotEmpty) hasInterests = true;
      }

      if (!mounted) return;

      if (hasInterests) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterestScreen(isStudent: isStudent)),
        );
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color textColor = isDark ? Colors.white : AppTheme.darkBlue;
    final Color subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;
    final Color containerBg = isDark ? const Color(0xFF2C2C2C) : Colors.grey[200]!;
    final Color inputFillColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color inputBorderColor = isDark ? Colors.grey[700]! : Colors.grey;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: AppTheme.goldAccent,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isLogin 
                      ? "Let's turn your downtime into growth." 
                      : "Start your learning journey today.",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: subTextColor,
                      ),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: containerBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      _buildRoleButton("Student", true, isDark),
                      _buildRoleButton("Teacher", false, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildTextField(
                  controller: _emailController,
                  label: "Email Address",
                  icon: Icons.email_outlined,
                  isDark: isDark,
                  fillColor: inputFillColor,
                  borderColor: inputBorderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isObscure: true,
                  isDark: isDark,
                  fillColor: inputFillColor,
                  borderColor: inputBorderColor,
                  textColor: textColor,
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldAccent,
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
                        style: TextStyle(color: subTextColor, fontSize: 16),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Create Account" : "Sign In",
                            style: TextStyle(
                              color: isDark ? AppTheme.goldAccent : AppTheme.primaryBlue,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    bool isObscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[700]),
        prefixIcon: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[700]),
        filled: true,
        fillColor: fillColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppTheme.goldAccent, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
  }

  Widget _buildRoleButton(String text, bool value, bool isDark) {
    bool isSelected = isStudent == value;
    
    Color activeBg = isDark ? Colors.grey[800]! : Colors.white;
    Color activeText = isDark ? AppTheme.goldAccent : AppTheme.primaryBlue;
    Color inactiveText = isDark ? Colors.grey[400]! : Colors.grey;

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
            color: isSelected ? activeBg : Colors.transparent,
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
              color: isSelected ? activeText : inactiveText,
            ),
          ),
        ),
      ),
    );
  }
}