// client/lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:valence/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Manages auth state for the entire app. Wraps AuthService.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthStatus _status = AuthStatus.unknown;
  User? _user;
  bool _firebaseAvailable = false;
  String? _error;
  bool _loading = false;

  AuthProvider({AuthService? authService})
      : _authService = authService ?? AuthService();

  AuthStatus get status => _status;
  User? get user => _user;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get firebaseAvailable => _firebaseAvailable;
  String? get error => _error;
  bool get isLoading => _loading;
  String get displayName => _user?.displayName ?? 'Friend';

  /// Initialize Firebase and listen to auth state changes.
  Future<void> initialize() async {
    _firebaseAvailable = await _authService.initialize();

    if (_firebaseAvailable) {
      _authService.authStateChanges.listen((user) {
        _user = user;
        _status = user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated;
        notifyListeners();
      });
    } else {
      // Firebase not configured — treat as unauthenticated, allow onboarding
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithGoogle();
      _loading = false;
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Google sign-in was cancelled.';
      notifyListeners();
      return false;
    } catch (e) {
      _loading = false;
      _error = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      _loading = false;
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Sign-up failed. Please try again.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _loading = false;
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _error = 'Sign-in failed. Please try again.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _loading = false;
      _error = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    }
  }

  /// Skip auth — for demo/offline mode when Firebase is not configured.
  void skipAuth() {
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
