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

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _user?.emailVerified ?? false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  AuthProvider() {
    _isLoading = true;

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isLoading = false;

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
      debugPrint('Error loading user model: $e');
    }

    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final firebaseUser = userCredential.user!;

      await firebaseUser.updateDisplayName(displayName);

      await firebaseUser.sendEmailVerification();

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        notificationsEnabled: true,
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(userModel.toMap());

      await firebaseUser.reload();
      _user = _auth.currentUser;

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);

      _isLoading = false;
      notifyListeners();

      return false;
    } catch (e) {
      _error = 'Unexpected error: ${e.toString()}';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _isLoading = false;
      notifyListeners();

      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);

      _isLoading = false;
      notifyListeners();

      return false;
    } catch (e) {
      _error = 'Unexpected error occurred';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> checkEmailVerification() async {
    try {
      final currentUser = _auth.currentUser;

      if (currentUser == null) {
        return false;
      }

      await currentUser.reload();

      _user = _auth.currentUser;

      notifyListeners();

      return _user?.emailVerified ?? false;
    } catch (e) {
      debugPrint("Verification check error: $e");
      return false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      debugPrint("Resend verification error: $e");
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _handleAuthError(e);
      return false;
    } catch (e) {
      _error = 'Unexpected error occurred';
      return false;
    }
  }

  Future<void> updateNotificationsPreference(bool enabled) async {
    if (_user == null) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .update({'notificationsEnabled': enabled});

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
      debugPrint('Error updating notifications: $e');
    }
  }

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
      debugPrint('Error getting user profile: $e');
    }

    return null;
  }

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

        if (displayName != null) {
          await _user!.updateDisplayName(displayName);
          await _user!.reload();
        }

        await _loadUserModel(_user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update profile';

      _isLoading = false;
      notifyListeners();

      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (_user == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(_user!.uid)
          .delete();

      await _user!.delete();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
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
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Try later.';
      case 'network-request-failed':
        return 'Network error. Check internet connection.';
      case 'user-disabled':
        return 'This account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}