import 'package:flutter/material.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/screens/auth/login_screen.dart';
import 'package:assignment2/screens/auth/verify_email_screen.dart';
import 'package:assignment2/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

/// Central Authentication Gate
///
/// This widget controls all authentication-based navigation:
/// - NOT logged in → LoginScreen
/// - Logged in BUT email NOT verified → VerifyEmailScreen
/// - Logged in AND email verified → MainNavigationScreen
///
/// Uses Consumer to rebuild when AuthProvider state changes,
/// including email verification status updates.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final isEmailVerified = authProvider.isEmailVerified;

        // Show loading spinner during initial auth check
        if (authProvider.isLoading && user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User not logged in → Show Login Screen
        if (user == null) {
          return const LoginScreen();
        }

        // User logged in but email not verified → Show Verify Email Screen
        if (!isEmailVerified) {
          return const VerifyEmailScreen();
        }

        // User logged in and email verified → Show Main App
        return const MainNavigationScreen();
      },
    );
  }
}