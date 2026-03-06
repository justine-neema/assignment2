import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:assignment2/core/constants/app_constants.dart';
import 'package:assignment2/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserModel(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        _userModel = UserModel.fromMap(uid, doc.data()!);
      }
    } catch (e) {
      print('Error loading user model: $e');
    }
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting to create user: $email');
      
      // Create user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('User created successfully: ${userCredential.user?.uid}');

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // Create user profile in Firestore
      final userModel = UserModel(
        uid: userCredential.user!.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        notificationsEnabled: true,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      print('User profile created in Firestore');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Attempting to sign in: $email');
      
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      print('Sign in successful: ${userCredential.user?.uid}');
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      _error = _handleAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      _error = 'An unexpected error occurred: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      return user?.emailVerified ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      return false;
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Error resending verification email: $e');
      rethrow;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      return false;
    }
  }

  // Update notifications preference - ADD THIS METHOD
  Future<void> updateNotificationsPreference(bool enabled) async {
    if (_user == null) return;
    
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .update({'notificationsEnabled': enabled});
      
      // Update local user model
      if (_userModel != null) {
        _userModel = UserModel(
          uid: _userModel!.uid,
          email: _userModel!.email,
          displayName: _userModel!.displayName,
          photoURL: _userModel!.photoURL,
          createdAt: _userModel!.createdAt,
          notificationsEnabled: enabled,
        );
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating notifications: $e');
    }
  }

  // Get user profile
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data()!);
      }
    } catch (e) {
      print('Error getting user profile: $e');
    }
    return null;
  }

  // Update user profile
  Future<bool> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> updates = {};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(_user!.uid)
            .update(updates);
        
        // Update Firebase Auth display name if changed
        if (displayName != null) {
          await _user!.updateDisplayName(displayName);
          await _user!.reload();
        }
        
        // Reload user model
        await _loadUserModel(_user!.uid);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _error = 'Failed to update profile';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete account
  Future<bool> deleteAccount() async {
    if (_user == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .delete();
      
      // Delete user listings (you might want to implement this)
      // await _firestore
      //     .collection(AppConstants.listingsCollection)
      //     .where('userId', isEqualTo: _user!.uid)
      //     .get()
      //     .then((snapshot) {
      //       for (var doc in snapshot.docs) {
      //         doc.reference.delete();
      //       }
      //     });
      
      // Delete user from Firebase Auth
      await _user!.delete();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting account: $e');
      _error = 'Failed to delete account';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'operation-not-allowed':
        return 'Email/password sign in is not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent login. Please sign out and sign in again.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}