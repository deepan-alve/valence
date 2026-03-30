# Phase 2: Navigation Shell & Auth — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the 5-tab bottom navigation shell, splash screen, 7-screen onboarding flow, and Firebase Auth integration — turning the design system preview into a real navigable app.

**Architecture:** `SplashScreen` checks auth state and routes to either `OnboardingFlow` (PageView with 7 screens) or `MainShell` (Scaffold with BottomNavigationBar + IndexedStack for tab persistence). An `AuthProvider` wraps Firebase Auth. An `OnboardingProvider` tracks flow state. Navigation uses Flutter's Navigator 1.0 with named routes.

**Tech Stack:** Flutter, Provider, Phosphor Icons (`phosphor_flutter`), Firebase Auth (`firebase_auth` + `firebase_core`), Google Sign-In (`google_sign_in`)

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` — Section 2.0 (Onboarding), Section 4 (Navigation Architecture)

---

## File Map

```
client/lib/
├── app.dart                              # UPDATE: Replace preview with routing
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart            # Auth state check → route
│   ├── onboarding/
│   │   ├── onboarding_flow.dart          # PageView wrapper for 7 screens
│   │   ├── welcome_screen.dart           # Screen 1: Splash/Welcome
│   │   ├── pitch_carousel.dart           # Screen 2: 3-page carousel
│   │   ├── theme_picker_screen.dart      # Screen 3: Theme selection
│   │   ├── auth_screen.dart              # Screen 4: Sign up / Login
│   │   ├── habit_setup_screen.dart       # Screen 5: Habit template picker
│   │   ├── group_setup_screen.dart       # Screen 6: Create/Join/Solo
│   │   └── notification_screen.dart      # Screen 7: Notification permission
│   └── main_shell.dart                   # 5-tab scaffold with IndexedStack
├── providers/
│   ├── auth_provider.dart                # Firebase Auth wrapper (ChangeNotifier)
│   └── onboarding_provider.dart          # Onboarding flow state
├── services/
│   └── auth_service.dart                 # Firebase Auth + Google Sign-In calls
└── screens/
    ├── home/
    │   └── home_screen.dart              # Placeholder tab
    ├── group/
    │   └── group_screen.dart             # Placeholder tab
    ├── progress/
    │   └── progress_screen.dart          # Placeholder tab
    ├── shop/
    │   └── shop_screen.dart              # Placeholder tab
    └── profile/
        └── profile_screen.dart           # Placeholder tab

client/test/
├── providers/
│   ├── auth_provider_test.dart
│   └── onboarding_provider_test.dart
└── screens/
    └── main_shell_test.dart
```

---

### Task 1: Add Firebase Auth dependencies to pubspec.yaml

**Files:**
- Modify: `client/pubspec.yaml`

- [ ] **Step 1: Add Firebase and Google Sign-In dependencies**

Add these to the `dependencies:` section of `client/pubspec.yaml`, after the existing `# Extra Features` section:

```yaml
  # Auth
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  google_sign_in: ^6.2.2
```

- [ ] **Step 2: Run flutter pub get**

```bash
cd client && flutter pub get
```

Expected: Resolves dependencies with no errors. If Firebase is not configured for the project yet, the packages will still install — runtime initialization will fail gracefully (we handle this in AuthService).

- [ ] **Step 3: Commit**

```bash
git add client/pubspec.yaml client/pubspec.lock
git commit -m "chore: add firebase_auth, firebase_core, google_sign_in deps for Phase 2"
```

---

### Task 2: Create AuthService — Firebase Auth wrapper

**Files:**
- Create: `client/lib/services/auth_service.dart`

- [ ] **Step 1: Write AuthService**

```dart
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

  /// Sign out.
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth?.signOut();
  }
}
```

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/services
git add client/lib/services/auth_service.dart
git commit -m "feat: add AuthService — Firebase Auth + Google Sign-In wrapper"
```

---

### Task 3: Create AuthProvider and OnboardingProvider

**Files:**
- Create: `client/lib/providers/auth_provider.dart`
- Create: `client/lib/providers/onboarding_provider.dart`
- Test: `client/test/providers/onboarding_provider_test.dart`

- [ ] **Step 1: Write AuthProvider**

```dart
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
  bool get loading => _loading;
  String get displayName => _user?.displayName ?? 'Friend';

  /// Initialize Firebase and listen to auth state.
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
```

- [ ] **Step 2: Write OnboardingProvider**

```dart
// client/lib/providers/onboarding_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks onboarding flow state: current page, selections, completion.
class OnboardingProvider extends ChangeNotifier {
  static const String _onboardingCompleteKey = 'onboarding_complete';

  int _currentPage = 0;
  String _selectedTheme = 'daybreak';
  final List<String> _selectedHabits = [];
  String? _groupChoice; // 'create', 'join', or 'solo'
  bool _notificationsEnabled = false;
  bool _onboardingComplete = false;

  int get currentPage => _currentPage;
  String get selectedTheme => _selectedTheme;
  List<String> get selectedHabits => List.unmodifiable(_selectedHabits);
  String? get groupChoice => _groupChoice;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get isOnboardingComplete => _onboardingComplete;
  int get totalPages => 7;

  /// Check if onboarding was already completed (persisted).
  Future<void> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingComplete = prefs.getBool(_onboardingCompleteKey) ?? false;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void selectTheme(String themeId) {
    _selectedTheme = themeId;
    notifyListeners();
  }

  void toggleHabit(String habitName) {
    if (_selectedHabits.contains(habitName)) {
      _selectedHabits.remove(habitName);
    } else {
      if (_selectedHabits.length < 5) {
        _selectedHabits.add(habitName);
      }
    }
    notifyListeners();
  }

  void setGroupChoice(String choice) {
    _groupChoice = choice;
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Mark onboarding as complete and persist.
  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
    notifyListeners();
  }

  /// Reset onboarding (for testing or re-onboarding).
  Future<void> resetOnboarding() async {
    _currentPage = 0;
    _selectedTheme = 'daybreak';
    _selectedHabits.clear();
    _groupChoice = null;
    _notificationsEnabled = false;
    _onboardingComplete = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_onboardingCompleteKey);
    notifyListeners();
  }
}
```

- [ ] **Step 3: Write OnboardingProvider test**

```dart
// client/test/providers/onboarding_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/providers/onboarding_provider.dart';

void main() {
  group('OnboardingProvider', () {
    late OnboardingProvider provider;

    setUp(() {
      provider = OnboardingProvider();
    });

    test('initial state is page 0 with daybreak theme', () {
      expect(provider.currentPage, 0);
      expect(provider.selectedTheme, 'daybreak');
      expect(provider.selectedHabits, isEmpty);
      expect(provider.groupChoice, isNull);
      expect(provider.isOnboardingComplete, false);
      expect(provider.totalPages, 7);
    });

    test('nextPage increments current page', () {
      provider.nextPage();
      expect(provider.currentPage, 1);
      provider.nextPage();
      expect(provider.currentPage, 2);
    });

    test('nextPage does not go past total pages', () {
      for (int i = 0; i < 10; i++) {
        provider.nextPage();
      }
      expect(provider.currentPage, 6); // totalPages - 1
    });

    test('previousPage decrements current page', () {
      provider.nextPage();
      provider.nextPage();
      provider.previousPage();
      expect(provider.currentPage, 1);
    });

    test('previousPage does not go below 0', () {
      provider.previousPage();
      expect(provider.currentPage, 0);
    });

    test('selectTheme updates selected theme', () {
      provider.selectTheme('nocturnal_sanctuary');
      expect(provider.selectedTheme, 'nocturnal_sanctuary');
    });

    test('toggleHabit adds and removes habits', () {
      provider.toggleHabit('Coding');
      expect(provider.selectedHabits, ['Coding']);
      provider.toggleHabit('Exercise');
      expect(provider.selectedHabits, ['Coding', 'Exercise']);
      provider.toggleHabit('Coding');
      expect(provider.selectedHabits, ['Exercise']);
    });

    test('toggleHabit enforces max 5 habits', () {
      for (final h in ['A', 'B', 'C', 'D', 'E']) {
        provider.toggleHabit(h);
      }
      expect(provider.selectedHabits.length, 5);
      provider.toggleHabit('F');
      expect(provider.selectedHabits.length, 5);
      expect(provider.selectedHabits.contains('F'), false);
    });

    test('setGroupChoice updates group choice', () {
      provider.setGroupChoice('create');
      expect(provider.groupChoice, 'create');
      provider.setGroupChoice('solo');
      expect(provider.groupChoice, 'solo');
    });
  });
}
```

- [ ] **Step 4: Run tests**

```bash
cd client && flutter test test/providers/onboarding_provider_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
mkdir -p client/lib/providers client/lib/services client/test/providers
git add client/lib/providers/auth_provider.dart client/lib/providers/onboarding_provider.dart client/lib/services/auth_service.dart client/test/providers/onboarding_provider_test.dart
git commit -m "feat: add AuthProvider, OnboardingProvider, and AuthService"
```

---

### Task 4: Create placeholder tab screens (Home, Group, Progress, Shop, Profile)

**Files:**
- Create: `client/lib/screens/home/home_screen.dart`
- Create: `client/lib/screens/group/group_screen.dart`
- Create: `client/lib/screens/progress/progress_screen.dart`
- Create: `client/lib/screens/shop/shop_screen.dart`
- Create: `client/lib/screens/profile/profile_screen.dart`

- [ ] **Step 1: Write all five placeholder screens**

```dart
// client/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/shared/empty_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfaceBackground,
        elevation: 0,
        title: Text(
          'Good morning, Friend',
          style: tokens.typography.h2.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: PhosphorIcons.house(PhosphorIconsStyle.duotone),
        title: 'Home',
        message: 'Your habits will appear here. Coming in Phase 3.',
      ),
    );
  }
}
```

```dart
// client/lib/screens/group/group_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/shared/empty_state.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfaceBackground,
        elevation: 0,
        title: Text(
          'Group',
          style: tokens.typography.h2.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: PhosphorIcons.usersThree(PhosphorIconsStyle.duotone),
        title: 'No Group Yet',
        message: 'Join or create a group to track habits together. Coming in Phase 4.',
      ),
    );
  }
}
```

```dart
// client/lib/screens/progress/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/shared/empty_state.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfaceBackground,
        elevation: 0,
        title: Text(
          'Progress',
          style: tokens.typography.h2.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.duotone),
        title: 'No Data Yet',
        message: 'Your streaks, heatmaps, and insights will appear here. Coming in Phase 5.',
      ),
    );
  }
}
```

```dart
// client/lib/screens/shop/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/shared/empty_state.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfaceBackground,
        elevation: 0,
        title: Text(
          'Shop',
          style: tokens.typography.h2.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
      body: EmptyState(
        icon: PhosphorIcons.storefront(PhosphorIconsStyle.duotone),
        title: 'Shop Coming Soon',
        message: 'Themes, flames, animations, and more. Coming in Phase 6.',
      ),
    );
  }
}
```

```dart
// client/lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/theme_provider.dart';
import 'package:valence/widgets/core/valence_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: tokens.colors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: tokens.colors.surfaceBackground,
        elevation: 0,
        title: Text(
          'Profile',
          style: tokens.typography.h2.copyWith(
            color: tokens.colors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(ValenceSpacing.md),
        child: Column(
          children: [
            // Avatar placeholder
            CircleAvatar(
              radius: 40,
              backgroundColor: tokens.colors.accentPrimary,
              child: Icon(
                PhosphorIcons.user(PhosphorIconsStyle.bold),
                size: 40,
                color: tokens.colors.textInverse,
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),
            Text(
              authProvider.displayName,
              style: tokens.typography.h2.copyWith(
                color: tokens.colors.textPrimary,
              ),
            ),
            const SizedBox(height: ValenceSpacing.xl),
            // Theme toggle
            ValenceCard(
              child: ListTile(
                leading: Icon(
                  themeProvider.isDark
                      ? PhosphorIcons.moon(PhosphorIconsStyle.duotone)
                      : PhosphorIcons.sun(PhosphorIconsStyle.duotone),
                  color: tokens.colors.accentPrimary,
                ),
                title: Text(
                  'Theme',
                  style: tokens.typography.bodyLarge.copyWith(
                    color: tokens.colors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  themeProvider.isDark ? 'Nocturnal Sanctuary' : 'Daybreak',
                  style: tokens.typography.body.copyWith(
                    color: tokens.colors.textSecondary,
                  ),
                ),
                trailing: Switch(
                  value: themeProvider.isDark,
                  activeColor: tokens.colors.accentPrimary,
                  onChanged: (isDark) {
                    themeProvider.setTheme(
                      isDark ? 'nocturnal_sanctuary' : 'daybreak',
                    );
                  },
                ),
              ),
            ),
            const Spacer(),
            // Sign out
            if (authProvider.isAuthenticated)
              ValenceButton(
                label: 'Sign Out',
                variant: ValenceButtonVariant.ghost,
                fullWidth: true,
                onPressed: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/splash',
                      (route) => false,
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Minimal ValenceCard stand-in — uses the existing ValenceCard from Phase 1.
/// This import is just for the ListTile wrapper pattern. If ValenceCard doesn't
/// support `child`, use a plain Container with theme-aware decoration instead.
class ValenceCard extends StatelessWidget {
  final Widget child;
  const ValenceCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: tokens.colors.surfacePrimary,
        borderRadius: BorderRadius.circular(16),
        border: tokens.isDark
            ? Border.all(color: tokens.colors.borderDefault)
            : null,
        boxShadow: tokens.isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: child,
    );
  }
}
```

Note: The `ProfileScreen` uses a local `ValenceCard` wrapper because the Phase 1 `ValenceCard` may have a different API (it uses `variant` + named params, not a `child` slot). If the Phase 1 `ValenceCard` supports `child`, remove the local wrapper and import `package:valence/widgets/core/valence_card.dart` instead.

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/screens/home client/lib/screens/group client/lib/screens/progress client/lib/screens/shop client/lib/screens/profile
git add client/lib/screens/
git commit -m "feat: add placeholder screens for all 5 tabs (Home, Group, Progress, Shop, Profile)"
```

---

### Task 5: Create MainShell — 5-tab bottom navigation with IndexedStack

**Files:**
- Create: `client/lib/screens/main_shell.dart`
- Test: `client/test/screens/main_shell_test.dart`

- [ ] **Step 1: Write MainShell**

```dart
// client/lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/screens/home/home_screen.dart';
import 'package:valence/screens/group/group_screen.dart';
import 'package:valence/screens/progress/progress_screen.dart';
import 'package:valence/screens/shop/shop_screen.dart';
import 'package:valence/screens/profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GroupScreen(),
    ProgressScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border(
            top: BorderSide(
              color: tokens.isDark
                  ? colors.borderDefault
                  : colors.borderDefault.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          boxShadow: tokens.isDark
              ? [
                  BoxShadow(
                    color: colors.accentPrimary.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _TabItem(
                  icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _onTabTapped(0),
                  tokens: tokens,
                ),
                _TabItem(
                  icon: PhosphorIcons.usersThree(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                  label: 'Group',
                  isActive: _currentIndex == 1,
                  onTap: () => _onTabTapped(1),
                  tokens: tokens,
                ),
                _TabItem(
                  icon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.chartLineUp(PhosphorIconsStyle.fill),
                  label: 'Progress',
                  isActive: _currentIndex == 2,
                  onTap: () => _onTabTapped(2),
                  tokens: tokens,
                  isCenter: true,
                ),
                _TabItem(
                  icon: PhosphorIcons.storefront(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.storefront(PhosphorIconsStyle.fill),
                  label: 'Shop',
                  isActive: _currentIndex == 3,
                  onTap: () => _onTabTapped(3),
                  tokens: tokens,
                ),
                _TabItem(
                  icon: PhosphorIcons.userCircle(PhosphorIconsStyle.regular),
                  activeIcon: PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                  label: 'Profile',
                  isActive: _currentIndex == 4,
                  onTap: () => _onTabTapped(4),
                  tokens: tokens,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final ValenceTokens tokens;
  final bool isCenter;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.tokens,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? tokens.colors.accentPrimary
        : tokens.colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: color,
              size: isCenter ? 28 : 24,
            ),
            if (isActive) ...[
              const SizedBox(height: 2),
              Text(
                label,
                style: tokens.typography.caption.copyWith(
                  color: color,
                  fontSize: 10,
                ),
              ),
            ] else
              const SizedBox(height: 14), // Reserve space for label
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write MainShell widget test**

```dart
// client/test/screens/main_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/screens/main_shell.dart';
import 'package:valence/theme/theme_provider.dart';

void main() {
  Widget createTestApp() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            theme: themeProvider.themeData,
            home: const MainShell(),
          );
        },
      ),
    );
  }

  group('MainShell', () {
    testWidgets('shows 5 tab icons', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Should show Home tab label (active by default)
      expect(find.text('Home'), findsOneWidget);
      // All 5 tab items should be present (as GestureDetectors)
      expect(find.byType(GestureDetector), findsNWidgets(5));
    });

    testWidgets('tapping Group tab switches to Group screen', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap the second tab (Group)
      final groupTab = find.text('No Group Yet');
      // Group text is in the IndexedStack but not visible until selected
      // Instead, tap by finding all GestureDetectors and tapping the second one
      final tabs = find.byType(GestureDetector);
      await tester.tap(tabs.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Group'), findsWidgets); // label + app bar
    });
  });
}
```

- [ ] **Step 3: Run test**

```bash
cd client && flutter test test/screens/main_shell_test.dart
```

Expected: All tests PASS.

- [ ] **Step 4: Commit**

```bash
mkdir -p client/test/screens
git add client/lib/screens/main_shell.dart client/test/screens/main_shell_test.dart
git commit -m "feat: add MainShell with 5-tab bottom navigation and IndexedStack"
```

---

### Task 6: Create SplashScreen — auth check and routing

**Files:**
- Create: `client/lib/screens/splash/splash_screen.dart`

- [ ] **Step 1: Write SplashScreen**

```dart
// client/lib/screens/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_tokens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _initializeAndRoute();
  }

  Future<void> _initializeAndRoute() async {
    final authProvider = context.read<AuthProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    // Initialize auth + check onboarding status in parallel
    await Future.wait([
      authProvider.initialize(),
      onboardingProvider.checkOnboardingStatus(),
    ]);

    // Ensure splash shows for at least 1.5s for the animation
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final isOnboarded = onboardingProvider.isOnboardingComplete;
    final isAuthenticated = authProvider.isAuthenticated;

    if (isOnboarded && isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.accentPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Valence',
                      style: tokens.typography.display.copyWith(
                        color: tokens.colors.textInverse,
                        fontSize: 48,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build habits with friends',
                      style: tokens.typography.bodyLarge.copyWith(
                        color: tokens.colors.textInverse.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

Note: `AnimatedBuilder` should be `AnimatedBuilder` — actually the correct Flutter widget is `AnimatedBuilder`. However, the standard approach uses `FadeTransition` and `ScaleTransition` directly since they already take `Animation` objects. Let me correct — the widget should use `AnimatedBuilder` which is actually just wrapping around `_controller`. The correct Flutter class name is `AnimatedBuilder`. Let me simplify this:

Actually, `FadeTransition` and `ScaleTransition` already accept `Animation<double>` and rebuild automatically. The wrapper `AnimatedBuilder` is not a real Flutter widget — the correct name is `AnimatedBuilder` from `package:flutter/widgets.dart`. But since `FadeTransition` and `ScaleTransition` handle animation internally, we can nest them directly without a builder:

Replace the `AnimatedBuilder` block in `build` with:

```dart
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.colors.accentPrimary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Valence',
                  style: tokens.typography.display.copyWith(
                    color: tokens.colors.textInverse,
                    fontSize: 48,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Build habits with friends',
                  style: tokens.typography.bodyLarge.copyWith(
                    color: tokens.colors.textInverse.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
```

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/screens/splash
git add client/lib/screens/splash/splash_screen.dart
git commit -m "feat: add SplashScreen with auth check and route to onboarding or main shell"
```

---

### Task 7: Create Onboarding Flow — PageView wrapper + Welcome + Pitch Carousel

**Files:**
- Create: `client/lib/screens/onboarding/onboarding_flow.dart`
- Create: `client/lib/screens/onboarding/welcome_screen.dart`
- Create: `client/lib/screens/onboarding/pitch_carousel.dart`

- [ ] **Step 1: Write OnboardingFlow (PageView wrapper)**

```dart
// client/lib/screens/onboarding/onboarding_flow.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/screens/onboarding/welcome_screen.dart';
import 'package:valence/screens/onboarding/pitch_carousel.dart';
import 'package:valence/screens/onboarding/theme_picker_screen.dart';
import 'package:valence/screens/onboarding/auth_screen.dart';
import 'package:valence/screens/onboarding/habit_setup_screen.dart';
import 'package:valence/screens/onboarding/group_setup_screen.dart';
import 'package:valence/screens/onboarding/notification_screen.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  void _nextPage() {
    final provider = context.read<OnboardingProvider>();
    if (provider.currentPage < provider.totalPages - 1) {
      provider.nextPage();
      _goToPage(provider.currentPage);
    }
  }

  void _skipToAuth() {
    final provider = context.read<OnboardingProvider>();
    provider.setPage(3); // Auth screen is index 3
    _goToPage(3);
  }

  Future<void> _completeOnboarding() async {
    final provider = context.read<OnboardingProvider>();
    await provider.completeOnboarding();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              provider.setPage(index);
            },
            children: [
              WelcomeScreen(
                onGetStarted: _nextPage,
                onHaveAccount: _skipToAuth,
              ),
              PitchCarousel(
                onContinue: _nextPage,
                onSkip: _nextPage,
              ),
              ThemePickerScreen(onContinue: _nextPage),
              AuthScreen(onContinue: _nextPage),
              HabitSetupScreen(onContinue: _nextPage),
              GroupSetupScreen(onContinue: _nextPage),
              NotificationScreen(onComplete: _completeOnboarding),
            ],
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: Write WelcomeScreen (Screen 1)**

```dart
// client/lib/screens/onboarding/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGetStarted;
  final VoidCallback onHaveAccount;

  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onHaveAccount,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.accentPrimary,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Mascot placeholder — replace with actual illustration later
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: colors.textInverse.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.smiley(PhosphorIconsStyle.duotone),
                  size: 80,
                  color: colors.textInverse,
                ),
              ),
              const SizedBox(height: ValenceSpacing.xl),
              Text(
                'Valence',
                style: tokens.typography.display.copyWith(
                  color: colors.textInverse,
                  fontSize: 48,
                ),
              ),
              const SizedBox(height: ValenceSpacing.sm),
              Text(
                'Build habits with friends,\nnot willpower',
                style: tokens.typography.bodyLarge.copyWith(
                  color: colors.textInverse.withOpacity(0.85),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              ValenceButton(
                label: 'Get Started',
                fullWidth: true,
                variant: ValenceButtonVariant.secondary,
                onPressed: onGetStarted,
              ),
              const SizedBox(height: ValenceSpacing.md),
              GestureDetector(
                onTap: onHaveAccount,
                child: Text(
                  'I have an account',
                  style: tokens.typography.body.copyWith(
                    color: colors.textInverse.withOpacity(0.7),
                    decoration: TextDecoration.underline,
                    decorationColor: colors.textInverse.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write PitchCarousel (Screen 2)**

```dart
// client/lib/screens/onboarding/pitch_carousel.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class PitchCarousel extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const PitchCarousel({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<PitchCarousel> createState() => _PitchCarouselState();
}

class _PitchCarouselState extends State<PitchCarousel> {
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;

  static const _pages = [
    _PitchPage(
      icon: PhosphorIconsData(0xf3c3), // placeholder, replaced below
      title: 'Track Together',
      description:
          'Your group keeps you accountable.\nNo guilt, just support.',
    ),
    _PitchPage(
      icon: PhosphorIconsData(0xf3c3),
      title: 'Auto-Verify',
      description:
          'Connect LeetCode, GitHub, Duolingo —\nwe track for you.',
    ),
    _PitchPage(
      icon: PhosphorIconsData(0xf3c3),
      title: 'Never Reset',
      description:
          'Miss a day? Your streak pauses,\nnever resets. Grace > guilt.',
    ),
  ];

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    // Actual icons to use (can't use const constructor with Phosphor methods)
    final pageIcons = [
      PhosphorIcons.usersThree(PhosphorIconsStyle.duotone),
      PhosphorIcons.plugsConnected(PhosphorIconsStyle.duotone),
      PhosphorIcons.shieldCheck(PhosphorIconsStyle.duotone),
    ];

    final pageTitles = [
      'Track Together',
      'Auto-Verify',
      'Never Reset',
    ];

    final pageDescriptions = [
      'Your group keeps you accountable.\nNo guilt, just support.',
      'Connect LeetCode, GitHub, Duolingo —\nwe track for you.',
      'Miss a day? Your streak pauses,\nnever resets. Grace > guilt.',
    ];

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(ValenceSpacing.md),
                child: GestureDetector(
                  onTap: widget.onSkip,
                  child: Text(
                    'Skip',
                    style: tokens.typography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
            // Carousel
            Expanded(
              child: PageView.builder(
                controller: _carouselController,
                itemCount: 3,
                onPageChanged: (index) {
                  setState(() => _currentCarouselPage = index);
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colors.accentPrimary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            pageIcons[index],
                            size: 56,
                            color: colors.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: ValenceSpacing.xl),
                        Text(
                          pageTitles[index],
                          style: tokens.typography.h1.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: ValenceSpacing.sm),
                        Text(
                          pageDescriptions[index],
                          style: tokens.typography.bodyLarge.copyWith(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentCarouselPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentCarouselPage == index
                        ? colors.accentPrimary
                        : colors.borderDefault,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: ValenceSpacing.xl),
            // Continue button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.lg,
              ),
              child: ValenceButton(
                label: _currentCarouselPage == 2 ? 'Continue' : 'Next',
                fullWidth: true,
                onPressed: () {
                  if (_currentCarouselPage < 2) {
                    _carouselController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    widget.onContinue();
                  }
                },
              ),
            ),
            const SizedBox(height: ValenceSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// Not used at runtime — was placeholder for const constructor.
class _PitchPage {
  final PhosphorIconsData icon;
  final String title;
  final String description;
  const _PitchPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
```

- [ ] **Step 4: Commit**

```bash
mkdir -p client/lib/screens/onboarding
git add client/lib/screens/onboarding/onboarding_flow.dart client/lib/screens/onboarding/welcome_screen.dart client/lib/screens/onboarding/pitch_carousel.dart
git commit -m "feat: add OnboardingFlow, WelcomeScreen, and PitchCarousel (screens 1-2)"
```

---

### Task 8: Create ThemePickerScreen and AuthScreen (onboarding screens 3-4)

**Files:**
- Create: `client/lib/screens/onboarding/theme_picker_screen.dart`
- Create: `client/lib/screens/onboarding/auth_screen.dart`

- [ ] **Step 1: Write ThemePickerScreen (Screen 3)**

```dart
// client/lib/screens/onboarding/theme_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/theme_provider.dart';
import 'package:valence/widgets/core/valence_button.dart';

class ThemePickerScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const ThemePickerScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final onboarding = context.watch<OnboardingProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final selected = onboarding.selectedTheme;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: ValenceSpacing.xxl),
              Text(
                'Pick your vibe',
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.xl),
              Expanded(
                child: Row(
                  children: [
                    // Nocturnal Sanctuary preview
                    Expanded(
                      child: _ThemePreviewCard(
                        themeId: 'nocturnal_sanctuary',
                        label: 'Nocturnal\nSanctuary',
                        backgroundColor: const Color(0xFF121220),
                        accentColor: const Color(0xFFF4A261),
                        textColor: const Color(0xFFF0E6D3),
                        cardColor: const Color(0xFF1E1E35),
                        isSelected: selected == 'nocturnal_sanctuary',
                        onTap: () {
                          onboarding.selectTheme('nocturnal_sanctuary');
                          themeProvider.setTheme('nocturnal_sanctuary');
                        },
                        tokens: tokens,
                      ),
                    ),
                    const SizedBox(width: ValenceSpacing.md),
                    // Daybreak preview
                    Expanded(
                      child: _ThemePreviewCard(
                        themeId: 'daybreak',
                        label: 'Daybreak',
                        backgroundColor: const Color(0xFFFFF8F0),
                        accentColor: const Color(0xFF4E55E0),
                        textColor: const Color(0xFF1A1A2E),
                        cardColor: const Color(0xFFFFFFFF),
                        isSelected: selected == 'daybreak',
                        onTap: () {
                          onboarding.selectTheme('daybreak');
                          themeProvider.setTheme('daybreak');
                        },
                        tokens: tokens,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: ValenceSpacing.md),
              Text(
                'You can always change this later',
                style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),
              ValenceButton(
                label: 'Continue',
                fullWidth: true,
                onPressed: onContinue,
              ),
              const SizedBox(height: ValenceSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final String themeId;
  final String label;
  final Color backgroundColor;
  final Color accentColor;
  final Color textColor;
  final Color cardColor;
  final bool isSelected;
  final VoidCallback onTap;
  final ValenceTokens tokens;

  const _ThemePreviewCard({
    required this.themeId,
    required this.label,
    required this.backgroundColor,
    required this.accentColor,
    required this.textColor,
    required this.cardColor,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(ValenceSpacing.md),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        transform: isSelected
            ? (Matrix4.identity()..scale(1.02))
            : Matrix4.identity(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mini habit card mock
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: backgroundColor == const Color(0xFF121220)
                    ? Border.all(
                        color: const Color(0xFF2D2D4A),
                        width: 1,
                      )
                    : null,
                boxShadow: backgroundColor != const Color(0xFF121220)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 8,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 6,
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Obviously',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected) ...[
              const SizedBox(height: 8),
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write AuthScreen (Screen 4)**

```dart
// client/lib/screens/onboarding/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const AuthScreen({super.key, required this.onContinue});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      widget.onContinue();
    }
  }

  Future<void> _handleEmailSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    bool success;
    if (_isLogin) {
      success = await auth.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      success = await auth.signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }

    if (success && mounted) {
      widget.onContinue();
    }
  }

  void _skipAuth() {
    final auth = context.read<AuthProvider>();
    auth.skipAuth();
    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: ValenceSpacing.xxl),
              Text(
                _isLogin ? 'Welcome back' : 'Create your account',
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.sm),
              Text(
                _isLogin
                    ? 'Sign in to continue your streak'
                    : 'Join your friends in building habits',
                style: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.xl),

              // Google Sign-In button
              if (auth.firebaseAvailable) ...[
                OutlinedButton.icon(
                  onPressed: auth.loading ? null : _handleGoogleSignIn,
                  icon: Icon(
                    PhosphorIcons.googleLogo(PhosphorIconsStyle.bold),
                    size: 20,
                    color: colors.textPrimary,
                  ),
                  label: Text(
                    'Continue with Google',
                    style: tokens.typography.bodyLarge.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: colors.borderDefault),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ValenceRadii.md),
                    ),
                  ),
                ),
                const SizedBox(height: ValenceSpacing.md),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: colors.borderDefault),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ValenceSpacing.md,
                      ),
                      child: Text(
                        'or',
                        style: tokens.typography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: colors.borderDefault),
                    ),
                  ],
                ),
                const SizedBox(height: ValenceSpacing.md),
              ],

              // Email form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin)
                      _buildTextField(
                        controller: _nameController,
                        label: 'Name',
                        icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                        tokens: tokens,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    if (!_isLogin) const SizedBox(height: ValenceSpacing.md),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: PhosphorIcons.envelope(PhosphorIconsStyle.regular),
                      tokens: tokens,
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || !val.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: ValenceSpacing.md),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: PhosphorIcons.lock(PhosphorIconsStyle.regular),
                      tokens: tokens,
                      obscureText: true,
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (auth.error != null) ...[
                const SizedBox(height: ValenceSpacing.sm),
                Text(
                  auth.error!,
                  style: tokens.typography.caption.copyWith(
                    color: colors.accentError,
                  ),
                ),
              ],

              const SizedBox(height: ValenceSpacing.lg),

              ValenceButton(
                label: auth.loading
                    ? 'Please wait...'
                    : (_isLogin ? 'Sign In' : 'Create Account'),
                fullWidth: true,
                onPressed: auth.loading ? null : _handleEmailSubmit,
              ),

              const SizedBox(height: ValenceSpacing.md),

              // Toggle login/signup
              GestureDetector(
                onTap: () {
                  setState(() => _isLogin = !_isLogin);
                  auth.clearError();
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: tokens.typography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                    children: [
                      TextSpan(
                        text: _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                      ),
                      TextSpan(
                        text: _isLogin ? 'Sign Up' : 'Sign In',
                        style: TextStyle(
                          color: colors.textLink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // Skip (demo mode) — shown when Firebase is not configured
              if (!auth.firebaseAvailable)
                GestureDetector(
                  onTap: _skipAuth,
                  child: Text(
                    'Skip for now (demo mode)',
                    style: tokens.typography.caption.copyWith(
                      color: colors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Terms
              const SizedBox(height: ValenceSpacing.lg),
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy',
                style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ValenceSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValenceTokens tokens,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = tokens.colors;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: tokens.typography.body.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: tokens.typography.body.copyWith(
          color: colors.textSecondary,
        ),
        prefixIcon: Icon(icon, color: colors.textSecondary, size: 20),
        filled: true,
        fillColor: colors.surfaceSunken,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ValenceRadii.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ValenceRadii.md),
          borderSide: BorderSide(color: colors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ValenceRadii.md),
          borderSide: BorderSide(color: colors.accentError),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.md,
          vertical: ValenceSpacing.smMd,
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add client/lib/screens/onboarding/theme_picker_screen.dart client/lib/screens/onboarding/auth_screen.dart
git commit -m "feat: add ThemePickerScreen and AuthScreen (onboarding screens 3-4)"
```

---

### Task 9: Create HabitSetupScreen, GroupSetupScreen, NotificationScreen (onboarding screens 5-7)

**Files:**
- Create: `client/lib/screens/onboarding/habit_setup_screen.dart`
- Create: `client/lib/screens/onboarding/group_setup_screen.dart`
- Create: `client/lib/screens/onboarding/notification_screen.dart`

- [ ] **Step 1: Write HabitSetupScreen (Screen 5)**

```dart
// client/lib/screens/onboarding/habit_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/constants.dart';
import 'package:valence/widgets/core/valence_button.dart';

class _HabitTemplate {
  final String name;
  final IconData icon;
  final Color color;
  const _HabitTemplate(this.name, this.icon, this.color);
}

class HabitSetupScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const HabitSetupScreen({super.key, required this.onContinue});

  static final _templates = [
    _HabitTemplate('Coding', PhosphorIcons.code(PhosphorIconsStyle.duotone), HabitColors.blue),
    _HabitTemplate('Exercise', PhosphorIcons.barbell(PhosphorIconsStyle.duotone), HabitColors.lime),
    _HabitTemplate('Reading', PhosphorIcons.bookOpen(PhosphorIconsStyle.duotone), HabitColors.amber),
    _HabitTemplate('Meditation', PhosphorIcons.flower(PhosphorIconsStyle.duotone), HabitColors.pink),
    _HabitTemplate('Language', PhosphorIcons.globe(PhosphorIconsStyle.duotone), HabitColors.teal),
    _HabitTemplate('Custom', PhosphorIcons.plus(PhosphorIconsStyle.bold), HabitColors.slate),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final onboarding = context.watch<OnboardingProvider>();
    final selected = onboarding.selectedHabits;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: ValenceSpacing.xxl),
              Text(
                'What do you want\nto build?',
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.sm),
              Text(
                'Pick 1-5 habits to start. You can add more later.',
                style: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: ValenceSpacing.md,
                    crossAxisSpacing: ValenceSpacing.md,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    final isSelected = selected.contains(template.name);
                    return _HabitTemplateCard(
                      template: template,
                      isSelected: isSelected,
                      onTap: () => onboarding.toggleHabit(template.name),
                      tokens: tokens,
                    );
                  },
                ),
              ),
              if (selected.isNotEmpty) ...[
                Text(
                  '${selected.length}/5 selected',
                  style: tokens.typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: ValenceSpacing.sm),
              ],
              ValenceButton(
                label: selected.isEmpty ? 'Skip for now' : 'Continue',
                fullWidth: true,
                variant: selected.isEmpty
                    ? ValenceButtonVariant.ghost
                    : ValenceButtonVariant.primary,
                onPressed: onContinue,
              ),
              const SizedBox(height: ValenceSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitTemplateCard extends StatelessWidget {
  final _HabitTemplate template;
  final bool isSelected;
  final VoidCallback onTap;
  final ValenceTokens tokens;

  const _HabitTemplateCard({
    required this.template,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? template.color.withOpacity(tokens.isDark ? 0.15 : 0.08)
              : colors.surfacePrimary,
          borderRadius: BorderRadius.circular(ValenceRadii.lg),
          border: Border.all(
            color: isSelected ? template.color : colors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              template.icon,
              size: 36,
              color: isSelected ? template.color : colors.textSecondary,
            ),
            const SizedBox(height: ValenceSpacing.sm),
            Text(
              template.name,
              style: tokens.typography.h3.copyWith(
                color: isSelected ? colors.textPrimary : colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Write GroupSetupScreen (Screen 6)**

```dart
// client/lib/screens/onboarding/group_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class GroupSetupScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const GroupSetupScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final onboarding = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: ValenceSpacing.xxl),
              // Mascot placeholder
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colors.accentSocial.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.linkSimple(PhosphorIconsStyle.duotone),
                  size: 48,
                  color: colors.accentSocial,
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),
              Text(
                'Better with friends',
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.sm),
              Text(
                'Groups keep you 3x more likely to stick with habits.',
                style: tokens.typography.body.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: ValenceSpacing.xxl),

              // Create a Group
              _GroupOptionCard(
                icon: PhosphorIcons.plus(PhosphorIconsStyle.bold),
                title: 'Create a Group',
                description: 'Start a new group and invite your friends',
                isSelected: onboarding.groupChoice == 'create',
                onTap: () => onboarding.setGroupChoice('create'),
                tokens: tokens,
              ),
              const SizedBox(height: ValenceSpacing.md),

              // Join a Group
              _GroupOptionCard(
                icon: PhosphorIcons.signIn(PhosphorIconsStyle.bold),
                title: 'Join a Group',
                description: 'Enter an invite link or scan a QR code',
                isSelected: onboarding.groupChoice == 'join',
                onTap: () => onboarding.setGroupChoice('join'),
                tokens: tokens,
              ),

              const Spacer(),

              ValenceButton(
                label: 'Continue',
                fullWidth: true,
                onPressed: onboarding.groupChoice != null ? onContinue : null,
              ),
              const SizedBox(height: ValenceSpacing.md),

              // Go Solo option (de-emphasized)
              GestureDetector(
                onTap: () {
                  onboarding.setGroupChoice('solo');
                  onContinue();
                },
                child: Text(
                  'Go solo for now',
                  style: tokens.typography.body.copyWith(
                    color: colors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;
  final ValenceTokens tokens;

  const _GroupOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(ValenceSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withOpacity(0.08)
              : colors.surfacePrimary,
          borderRadius: BorderRadius.circular(ValenceRadii.lg),
          border: Border.all(
            color: isSelected ? colors.accentPrimary : colors.borderDefault,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accentPrimary.withOpacity(0.15)
                    : colors.surfaceSunken,
                borderRadius: BorderRadius.circular(ValenceRadii.sm),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? colors.accentPrimary
                    : colors.textSecondary,
              ),
            ),
            const SizedBox(width: ValenceSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tokens.typography.h3.copyWith(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: tokens.typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colors.accentPrimary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Write NotificationScreen (Screen 7)**

```dart
// client/lib/screens/onboarding/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class NotificationScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const NotificationScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final onboarding = context.read<OnboardingProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Mascot with bell placeholder
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.accentPrimary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIcons.bellRinging(PhosphorIconsStyle.duotone),
                  size: 56,
                  color: colors.accentPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.xl),
              Text(
                'Stay in the loop',
                style: tokens.typography.h1.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: ValenceSpacing.lg),
              // Bullet points
              _BulletPoint(
                icon: PhosphorIcons.handWaving(PhosphorIconsStyle.duotone),
                text: 'Friend nudges to keep you going',
                tokens: tokens,
              ),
              const SizedBox(height: ValenceSpacing.md),
              _BulletPoint(
                icon: PhosphorIcons.sunHorizon(PhosphorIconsStyle.duotone),
                text: 'Morning motivation to start your day',
                tokens: tokens,
              ),
              const SizedBox(height: ValenceSpacing.md),
              _BulletPoint(
                icon: PhosphorIcons.fire(PhosphorIconsStyle.duotone),
                text: 'Streak milestones and celebrations',
                tokens: tokens,
              ),
              const Spacer(flex: 3),
              ValenceButton(
                label: 'Enable Notifications',
                fullWidth: true,
                onPressed: () async {
                  // TODO: Request actual notification permission via
                  // flutter_local_notifications or firebase_messaging.
                  // For now, we just mark it and continue.
                  onboarding.setNotificationsEnabled(true);
                  onComplete();
                },
              ),
              const SizedBox(height: ValenceSpacing.md),
              GestureDetector(
                onTap: () {
                  onboarding.setNotificationsEnabled(false);
                  onComplete();
                },
                child: Text(
                  'Maybe later',
                  style: tokens.typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: ValenceSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final IconData icon;
  final String text;
  final ValenceTokens tokens;

  const _BulletPoint({
    required this.icon,
    required this.text,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Row(
      children: [
        Icon(icon, color: colors.accentPrimary, size: 24),
        const SizedBox(width: ValenceSpacing.md),
        Expanded(
          child: Text(
            text,
            style: tokens.typography.bodyLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Commit**

```bash
git add client/lib/screens/onboarding/habit_setup_screen.dart client/lib/screens/onboarding/group_setup_screen.dart client/lib/screens/onboarding/notification_screen.dart
git commit -m "feat: add HabitSetup, GroupSetup, and NotificationScreen (onboarding screens 5-7)"
```

---

### Task 10: Update app.dart — wire routing, providers, and splash entry point

**Files:**
- Modify: `client/lib/app.dart`

- [ ] **Step 1: Rewrite app.dart with full routing**

Replace the entire contents of `client/lib/app.dart` with:

```dart
// client/lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/screens/main_shell.dart';
import 'package:valence/screens/onboarding/onboarding_flow.dart';
import 'package:valence/screens/splash/splash_screen.dart';
import 'package:valence/theme/theme_provider.dart';

class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<OnboardingProvider>(
          create: (_) => OnboardingProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            initialRoute: '/splash',
            routes: {
              '/splash': (_) => const SplashScreen(),
              '/onboarding': (_) => const OnboardingFlow(),
              '/main': (_) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Verify the app compiles**

```bash
cd client && flutter analyze lib/app.dart lib/screens/ lib/providers/ lib/services/ 2>&1 | tail -10
```

Expected: No errors. Warnings about unused imports or deprecated APIs are OK at this stage.

- [ ] **Step 3: Commit**

```bash
git add client/lib/app.dart
git commit -m "feat: wire routing in app.dart — splash → onboarding → main shell"
```

---

### Task 11: Verify PhosphorIcons API and fix any import issues

The PhosphorIcons Flutter package (`phosphor_flutter: ^2.1.0`) changed its API across versions. In v2.x, icons are accessed via `PhosphorIcons.iconName(PhosphorIconsStyle.regular)` or `PhosphorIcons.iconName(PhosphorIconsStyle.fill)`. Verify this works.

**Files:**
- Possibly modify: any screen files with incorrect PhosphorIcon API usage

- [ ] **Step 1: Check PhosphorIcons API by running analysis**

```bash
cd client && flutter analyze lib/screens/ 2>&1 | head -30
```

If there are errors about `PhosphorIcons`, the API may differ. Common fixes:
- If `PhosphorIcons.house()` does not exist, try `PhosphorIconsRegular.house` or `PhosphorIcons.house`
- Consult `flutter pub run build_runner build` or check the installed package source

- [ ] **Step 2: Fix any PhosphorIcon errors found in Step 1**

Adjust icon references across all screen files to match the installed package API. If the package uses `PhosphorIconsRegular` / `PhosphorIconsFill` / `PhosphorIconsDuotone` classes instead:

```dart
// Example fix — use whichever API the installed version supports:
// Option A (v2.x method-based): PhosphorIcons.house(PhosphorIconsStyle.regular)
// Option B (v2.x class-based): PhosphorIconsRegular.house
// Option C (v1.x): PhosphorIcons.house
```

- [ ] **Step 3: Commit any fixes**

```bash
git add client/lib/screens/
git commit -m "fix: correct PhosphorIcons API usage across all screens"
```

---

### Task 12: Run all tests and verify full flow compiles

- [ ] **Step 1: Run all existing Phase 1 tests**

```bash
cd client && flutter test test/theme/ test/widgets/
```

Expected: All existing tests still PASS (Phase 1 changes are not broken).

- [ ] **Step 2: Run Phase 2 tests**

```bash
cd client && flutter test test/providers/ test/screens/
```

Expected: All new tests PASS.

- [ ] **Step 3: Run full analysis**

```bash
cd client && flutter analyze lib/
```

Expected: No errors. Warnings are acceptable.

- [ ] **Step 4: Verify app compiles**

```bash
cd client && flutter build apk --debug 2>&1 | tail -10
```

Expected: BUILD SUCCESSFUL. Firebase may show a warning about missing `google-services.json` — this is expected if Firebase is not yet configured for the project. The app handles this gracefully via `AuthService.initialize()` returning `false`.

- [ ] **Step 5: Final commit for Phase 2 completion**

```bash
git add -A && git commit -m "feat: complete Phase 2 — navigation shell and auth

Includes:
- 5-tab bottom navigation shell (Home, Group, Progress, Shop, Profile)
- IndexedStack for tab persistence
- Custom TabBar with Phosphor icons (active/inactive states)
- SplashScreen with fade+scale animation and auth routing
- 7-screen onboarding flow via PageView:
  1. Welcome (accent-colored splash with CTA)
  2. Pitch Carousel (3-page swipeable with dot indicators)
  3. Theme Picker (live preview cards, calls ThemeProvider.setTheme)
  4. Auth (Google Sign-In + email/password + skip for demo mode)
  5. Habit Setup (6 template cards in 2-col grid, max 5 selection)
  6. Group Setup (Create/Join/Solo paths)
  7. Notification Permission (bullet points + enable/skip)
- AuthProvider wrapping Firebase Auth with error handling
- OnboardingProvider with persisted completion state
- AuthService with Google Sign-In + email auth + graceful Firebase fallback
- Named routes: /splash, /onboarding, /main
- 10+ unit and widget tests"
```

---

## Phase 2 Complete

After this phase, you have:
- A working 5-tab bottom navigation shell with IndexedStack
- A splash screen that checks auth and routes accordingly
- A 7-screen onboarding flow that the user can walk through end-to-end
- Theme picker that actually changes the app theme via ThemeProvider
- Firebase Auth integration (or graceful fallback to demo mode)
- Persisted onboarding completion state via SharedPreferences
- Placeholder screens for all 5 tabs, ready for Phase 3-6 content

**Next:** Phase 3 — Home Screen (habit cards, day selector, daily progress bar, gesture matrix)

---

Here are the key findings from my exploration and key decisions embedded in the plan:

1. **Package name is `valence`**, not `mhabit`. The pubspec says `name: valence` and all existing imports use `package:valence/...`.

2. **Firebase is NOT in the project yet** -- needs `firebase_core`, `firebase_auth`, and `google_sign_in` added to pubspec.yaml. The AuthService is designed to gracefully handle the case where Firebase is not configured (no google-services.json) by returning `false` from `initialize()`, letting the app run in demo mode.

3. **The design spec shows 7 onboarding screens** (Section 2.0), while the navigation architecture (Section 4) shows 6 in the PageView (it omits NotificationPermission). The plan follows the spec's 7 screens since the user explicitly asked for 7.

4. **`ValenceSpacing.xxl`** is referenced but I need to verify it exists. The Phase 1 plan created spacing values up to `xxl` (48) and `xxxl` (64). Similarly, `ValenceSpacing.lg` (24) is used. These should exist from Phase 1.

5. **The ProfileScreen uses a local `ValenceCard` wrapper** because the Phase 1 `ValenceCard` API uses `variant`/`title`/`subtitle` params rather than a generic `child` slot. The local wrapper provides a simple container with theme-aware decoration.

### Critical Files for Implementation
- `D:/@home/deepan/Downloads/valence/client/lib/app.dart` -- must be rewritten from design preview to full routing
- `D:/@home/deepan/Downloads/valence/client/lib/screens/main_shell.dart` -- the 5-tab navigation shell, central to the whole app
- `D:/@home/deepan/Downloads/valence/client/lib/screens/onboarding/onboarding_flow.dart` -- PageView wrapper that orchestrates all 7 onboarding screens
- `D:/@home/deepan/Downloads/valence/client/lib/providers/auth_provider.dart` -- Firebase Auth state management
- `D:/@home/deepan/Downloads/valence/client/lib/screens/onboarding/theme_picker_screen.dart` -- the screen that actually calls `ThemeProvider.setTheme()` and demonstrates the token system working end-to-end