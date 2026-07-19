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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _selectedRole = 'User';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await ApiService().signup(
        fullName: _nameController.text.trim(),
        mobile: _phoneController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        final user = result['user'];
        // Authenticate inside AppState
        await AppState().login(user['fullName'], role: user['role'] ?? 'User');
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(result['message'] ?? 'Failed to register account.');
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
            MaterialPageRoute(builder: (context) => const HomePage()),
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
                          child: Icon(Icons.check, color: AppTheme.primary, size: 44),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Account Created!',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Welcome to Soulmate ❤️',
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
          // Background Gradient matching login
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'Soulmate',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 38,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Glassmorphic Card
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
                                  'Sign Up',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Create a new profile account',
                                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.7)),
                                ),
                                const SizedBox(height: 20),

                                Container(
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final tabWidth = (constraints.maxWidth - 8) / 2;
                                      return Stack(
                                        children: [
                                          // Sliding active indicator
                                          AnimatedPositioned(
                                            duration: const Duration(milliseconds: 250),
                                            curve: Curves.easeInOut,
                                            left: _selectedRole == 'User' ? 4 : 4 + tabWidth,
                                            top: 4,
                                            bottom: 4,
                                            width: tabWidth,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppTheme.primary,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          // Active clickable headers
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () => setState(() => _selectedRole = 'User'),
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
                                              Expanded(
                                                child: GestureDetector(
                                                  behavior: HitTestBehavior.opaque,
                                                  onTap: () => setState(() => _selectedRole = 'Admin'),
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
                                            ],
                                          ),
                                        ],
                                      );
                                    },
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
                                const SizedBox(height: 12),

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
                                const SizedBox(height: 12),

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
                                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                                ),
                                const SizedBox(height: 12),

                                // Confirm Password
                                const Text('  Confirm Password', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
                                  decoration: InputDecoration(
                                    hintText: 'Re-enter your password',
                                    prefixIcon: const Icon(Icons.lock_clock, color: AppTheme.primary, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please confirm password';
                                    if (value != _passwordController.text) return 'Passwords do not match';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),

                                // Submit Button
                                _isLoading
                                    ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                                    : CustomButton(
                                        onPressed: _handleSignup,
                                        text: 'Sign Up',
                                      ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Navigation Back to Login
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                            children: [
                              TextSpan(
                                text: 'Sign In',
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
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
