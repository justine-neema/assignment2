import 'package:flutter/material.dart';
import 'package:assignment2/core/utils/validators.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/screens/auth/signup_screen.dart';
import 'package:assignment2/screens/auth/forgot_password_screen.dart';
import 'package:assignment2/widgets/custom_textfield.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    // Clear any previous errors when screen clear loads and navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  // Logo/Title
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.location_city,
                      size: 80,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sign in to continue discovering Kigali',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Error message
                  if (authProvider.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        authProvider.error!,
                        style: TextStyle(color: Colors.red.shade800),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    prefixIcon: Icons.email,
                    validator: Validators.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Password field to add
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    prefixIcon: Icons.lock,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    obscureText: _obscurePassword,
                    validator: Validators.validatePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(authProvider),
                  ),

                  // Forgot password page
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login button
                  if (authProvider.isLoading)
                    const LoadingWidget()
                  else
                    ElevatedButton(
                      onPressed: () => _handleLogin(authProvider),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Sign up link if user has no account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

// navigate in other parts

    if (success && mounted) {
      // Optional: Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Login successful!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }
}