import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../core/services/auth_services.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final _authService = AuthService();

  User? _user;
  String? error;
  bool isLoading = false;

  bool get isAuthenticated => _user != null;
  User? get user => _user;

  Future<bool> signIn(String email, String password) async {
    _set(loading: true, error: null);
    try {
      await _authService.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _set(error: _message(e.code));
      return false;
    } finally {
      _set(loading: false);
    }
  }

  Future<bool> register(String email, String password) async {
    _set(loading: true, error: null);
    try {
      await _authService.register(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _set(error: _message(e.code));
      return false;
    } finally {
      _set(loading: false);
    }
  }

  Future<void> signOut() => _authService.signOut();

  Future<bool> resetPassword(String email) async {
    _set(loading: true, error: null);
    try {
      await _authService.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _set(error: _message(e.code));
      return false;
    } finally {
      _set(loading: false);
    }
  }

  void clearError() => _set(error: null);

  // ─────────────────────────────────────────────────────────────────────────

  void _set({bool? loading, String? error}) {
    if (loading != null) isLoading = loading;
    this.error = error;
    notifyListeners();
  }

  String _message(String code) => switch (code) {
    'user-not-found' => 'No account found for this email.',
    'wrong-password' => 'Incorrect password.',
    'invalid-credential' => 'Invalid email or password.',
    'invalid-email' => 'Enter a valid email address.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' => 'Too many attempts. Try again later.',
    'network-request-failed' => 'Network error. Check your connection.',
    _ => 'Something went wrong. Please try again.',
  };
}
