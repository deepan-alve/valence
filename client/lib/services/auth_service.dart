// client/lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Low-level Firebase Auth wrapper. Providers call this — screens never call it directly.
class AuthService {
  FirebaseAuth? _auth;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize Firebase. Call once at app start.
  /// Returns false if Firebase is not configured (no google-services.json / GoogleService-Info.plist).
  Future<bool> initialize() async {
    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _initialized = true;
      return true;
    } catch (e) {
      // Firebase not configured — app runs in offline/demo mode
      _initialized = false;
      return false;
    }
  }

  /// Current Firebase user, or null if not signed in / not initialized.
  User? get currentUser => _auth?.currentUser;

  /// Stream of auth state changes. Emits null when signed out.
  Stream<User?> get authStateChanges =>
      _auth?.authStateChanges() ?? const Stream.empty();

  /// Sign in with Google. Returns the User on success, null on cancel/failure.
  Future<User?> signInWithGoogle() async {
    if (_auth == null) return null;
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth!.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  /// Sign up with email and password. Returns the User on success.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    if (_auth == null) return null;
    try {
      final result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (displayName != null && result.user != null) {
        await result.user!.updateDisplayName(displayName);
      }
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign in with email and password.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_auth == null) return null;
    try {
      final result = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Sign out from Firebase and Google.
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth?.signOut();
  }
}
