import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../models/person_model.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _selectedRole = 'User';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final result = await ApiService().login(
        _phoneController.text.trim(),
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final user = result['user'];
        final role = user['role'] ?? 'User';

        if (_selectedRole == 'Admin' && role != 'Admin') {
          _showErrorSnackBar('Access Denied: This account does not have Admin privileges.');
          return;
        }

        // Authenticate inside AppState
        await AppState().login(user['fullName'], role: role);
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Login failed. Check your mobile number and password.');
      }
    }
  }



  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        Timer(const Duration(seconds: 2), () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 600),
            ),
          );
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.favorite, color: AppTheme.primary, size: 44),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Welcome to Soulmate',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Logged in Successfully ❤️',
                        style: TextStyle(fontSize: 16, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF5C0632), // Deep velvet maroon
                  Color(0xFF880E4F), // Velvet Pink
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Floating Hearts animation
          ...List.generate(8, (index) {
            final double left = (index * (size.width / 8)) + 15;
            final double baseSpeed = 5.0 + (index % 3) * 2;
            final double sizeValue = 18.0 + (index % 4) * 6;
            final double opacity = 0.15 + (index % 3) * 0.08;
            final double delay = index * 400.0;

            return Positioned(
              bottom: -50,
              left: left,
              child: Icon(
                Icons.favorite,
                color: Colors.white.withOpacity(opacity),
                size: sizeValue,
              )
              .animate(onPlay: (controller) => controller.repeat())
              .move(
                begin: const Offset(0, 0),
                end: Offset(0, -size.height - 100),
                duration: baseSpeed.seconds,
                delay: delay.ms,
                curve: Curves.linear,
              )
              .fade(begin: 1.0, end: 0.0, curve: Curves.easeIn),
            );
          }),

          // Content Wrapper
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 32,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),
                      
                      // Circle Logo
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.secondary.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.favorite,
                                    color: AppTheme.primary,
                                    size: 38,
                                  );
                                },
                              ),
                            ),
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      ),
                      const SizedBox(height: 16),
                      
                      // Titles
                      Center(
                        child: Text(
                          'Soulmate',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                            fontSize: 42,
                            letterSpacing: 2,
                          ),
                        ).animate().fade(duration: 500.ms).slideY(begin: 0.2, end: 0.0),
                      ),
                      Center(
                        child: Text(
                          'Find Your Heavenly Union',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w300,
                          ),
                        ).animate().fade(delay: 200.ms, duration: 500.ms),
                      ),
                      const SizedBox(height: 32),

                      // Glassmorphic Login Form
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.5),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Sign In',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Enter your credentials to find your match',
                                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                                  ),
                                  const SizedBox(height: 20),

                                  // Role Selector Segmented Tab
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _selectedRole = 'User'),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: _selectedRole == 'User' ? AppTheme.primary : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Candidate',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: _selectedRole == 'User' ? FontWeight.bold : FontWeight.normal,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => setState(() => _selectedRole = 'Admin'),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              decoration: BoxDecoration(
                                                color: _selectedRole == 'Admin' ? AppTheme.primary : Colors.transparent,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Admin',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: _selectedRole == 'Admin' ? FontWeight.bold : FontWeight.normal,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Full Name
                                  const Text('  Full Name', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nameController,
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                    decoration: const InputDecoration(hintText: 'Enter your full name', prefixIcon: Icon(Icons.person, color: AppTheme.primary, size: 20)),
                                    validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your name' : null,
                                  ),
                                  const SizedBox(height: 16),

                                  // Mobile Number
                                  const Text('  Mobile Number', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                    decoration: const InputDecoration(hintText: 'Enter 10-digit number', prefixIcon: Icon(Icons.phone, color: AppTheme.primary, size: 20)),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) return 'Please enter mobile number';
                                      if (value.trim().length != 10) return 'Please enter exactly 10 digits';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // Password
                                  const Text('  Password', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your password',
                                      prefixIcon: const Icon(Icons.lock, color: AppTheme.primary, size: 20),
                                      suffixIcon: IconButton(
                                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
                                    ),
                                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter password' : null,
                                  ),
                                  const SizedBox(height: 12),

                                  // Remember Me & Forgot Password
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              activeColor: AppTheme.primary,
                                              side: const BorderSide(color: Colors.white, width: 1.2),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              onChanged: (value) => setState(() => _rememberMe = value ?? false),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text('Remember Me', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link sent (Demo only)'), behavior: SnackBarBehavior.floating));
                                        },
                                        child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: AppTheme.secondary, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  // Submit button
                                  _isLoading
                                      ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                                      : CustomButton(onPressed: _handleLogin, text: 'Sign In Successfully'),


                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fade(delay: 150.ms, duration: 600.ms).slideY(begin: 0.1, end: 0.0),
                      
                      const SizedBox(height: 24),

                      // Sign Up text
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const SignupPage()),
                            );
                          },
                          child: RichText(
                            text: const TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
                                    color: AppTheme.secondary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
