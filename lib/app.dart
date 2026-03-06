import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:assignment2/providers/auth_provider.dart' as app; // Use alias to avoid conflict
import 'package:assignment2/screens/auth/login_screen.dart';
import 'package:assignment2/screens/auth/verify_email_screen.dart';
import 'package:assignment2/screens/main_navigation_screen.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the alias here
    final authProvider = Provider.of<app.AuthProvider>(context);

    return StreamBuilder<User?>(
      stream: authProvider.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Handle errors
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Authentication Error',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(snapshot.error.toString()),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // You can add retry logic here
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // Check authentication state
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          
          if (user == null) {
            return const LoginScreen();
          }
          
          // Check if email is verified
          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }
          
          return const MainNavigationScreen();
        }
        
        // Loading state
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}