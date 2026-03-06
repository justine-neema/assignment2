import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:assignment2/app.dart';
import 'package:assignment2/providers/auth_provider.dart';
import 'package:assignment2/providers/listing_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase with proper configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1976D2); // blue
    const accentColor = Color(0xFFFF9800); // orange

    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      fontFamily: 'Roboto',
    );

    return MultiProvider(
      providers: [
        // Auth provider must be initialized first
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Listing provider depends on auth state
        ChangeNotifierProxyProvider<AuthProvider, ListingProvider>(
          create: (ctx) => ListingProvider(),
          update: (ctx, authProvider, previousListingProvider) {
            final listingProvider =
                previousListingProvider ?? ListingProvider();

            if (authProvider.user != null) {
              listingProvider.listenToUserListings(authProvider.user!.uid);
            }

            return listingProvider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'Kigali City Services',
        debugShowCheckedModeBanner: false,
        theme: baseTheme.copyWith(
          appBarTheme: baseTheme.appBarTheme.copyWith(
            backgroundColor: primaryColor,
            elevation: 1,
            centerTitle: true,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: Colors.white,
            labelStyle: const TextStyle(color: Colors.black87),
            hintStyle: const TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
          ),
          textTheme: baseTheme.textTheme.apply(
            bodyColor: Colors.black87,
            displayColor: Colors.black87,
          ),
        ),
        home: const App(),
      ),
    );
  }
}