import 'package:flutter/material.dart';
import 'package:assignment2/core/utils/validators.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/screens/auth/login_screen.dart';
import 'package:assignment2/widgets/custom_textfield.dart';
import 'package:assignment2/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();

    // Clear any previous errors when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Join Our Community',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Create an account to explore Kigali',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

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

                  // Name field
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    prefixIcon: Icons.person,
                    validator: Validators.validateName,
                    textInputAction: TextInputAction.next,
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

                  // Password field
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
                    textInputAction: TextInputAction.next,
                  ),

                  const SizedBox(height: 16),

                  // Confirm password field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                    onSuffixTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignUp(authProvider),
                  ),

                  const SizedBox(height: 16),

                  // Terms and conditions
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptedTerms = !_acceptedTerms;
                            });
                          },
                          child: const Text(
                            'I agree to the Terms and Conditions',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sign up button
                  if (authProvider.isLoading)
                    const LoadingWidget()
                  else
                    ElevatedButton(
                      onPressed: _acceptedTerms
                          ? () => _handleSignUp(authProvider)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Sign In',
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

  Future<void> _handleSignUp(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
    );

    if (success && mounted) {
      // Pop the signup screen off the stack.
      // The home route (App widget) will now show VerifyEmailScreen
      // because the user exists but email is not yet verified.
      Navigator.of(context).pop();
    }
  }
}