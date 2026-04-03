// client/lib/screens/onboarding/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/screens/main_shell.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Screen 4 of onboarding — sign up or sign in with email / Google.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignUp = true;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();

    bool success;
    if (_isSignUp) {
      success = await auth.signUpWithEmail(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        onboarding.nextPage();
      }
    } else {
      success = await auth.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success && mounted) {
        _navigateToMain();
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();

    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      if (_isSignUp) {
        onboarding.nextPage();
      } else {
        _navigateToMain();
      }
    }
  }

  void _handleSkip() {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();
    auth.skipAuth();
    onboarding.nextPage();
  }

  void _navigateToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
    context.read<AuthProvider>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.lg,
            vertical: ValenceSpacing.xl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: ValenceSpacing.xl),

                // Heading
                Text(
                  'Create your account',
                  style: typography.h1.copyWith(color: colors.textPrimary),
                ),

                const SizedBox(height: ValenceSpacing.sm),

                Text(
                  _isSignUp
                      ? 'Join Valence and start building habits with friends.'
                      : 'Welcome back — sign in to continue.',
                  style: typography.bodyLarge.copyWith(
                    color: colors.textSecondary,
                  ),
                ),

                const SizedBox(height: ValenceSpacing.xl),

                // Google Sign-In button
                ValenceButton(
                  label: 'Continue with Google',
                  icon: PhosphorIcons.googleLogo(),
                  variant: ValenceButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: auth.isLoading ? null : _handleGoogleSignIn,
                ),

                const SizedBox(height: ValenceSpacing.lg),

                // "or" divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: colors.borderDefault,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: ValenceSpacing.md,
                      ),
                      child: Text(
                        'or',
                        style: typography.caption.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: colors.borderDefault,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: ValenceSpacing.lg),

                // Display name field — only in sign-up mode
                if (_isSignUp) ...[
                  _FormField(
                    controller: _nameController,
                    label: 'Display name',
                    hint: 'How your friends will see you',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: ValenceSpacing.md),
                ],

                // Email field
                _FormField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!v.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: ValenceSpacing.md),

                // Password field
                _FormField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: _isSignUp ? 'At least 6 characters' : 'Your password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? PhosphorIcons.eye()
                          : PhosphorIcons.eyeSlash(),
                      color: colors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (_isSignUp && v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                // Error message
                if (auth.error != null) ...[
                  const SizedBox(height: ValenceSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(ValenceSpacing.smMd),
                    decoration: BoxDecoration(
                      color: colors.accentError.withValues(alpha: 0.1),
                      borderRadius: ValenceRadii.mediumAll,
                    ),
                    child: Text(
                      auth.error!,
                      style: typography.body.copyWith(
                        color: colors.accentError,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: ValenceSpacing.xl),

                // Submit button
                ValenceButton(
                  label: auth.isLoading
                      ? 'Loading…'
                      : (_isSignUp ? 'Create Account' : 'Sign In'),
                  fullWidth: true,
                  onPressed: auth.isLoading ? null : _handleEmailSubmit,
                ),

                const SizedBox(height: ValenceSpacing.md),

                // Toggle mode
                Center(
                  child: TextButton(
                    onPressed: _toggleMode,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.accentPrimary,
                    ),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Sign In'
                          : 'Create an account',
                      style: typography.body.copyWith(
                        color: colors.accentPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: ValenceSpacing.sm),

                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: _handleSkip,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.textSecondary,
                    ),
                    child: Text(
                      'Skip for now',
                      style: typography.body.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: ValenceSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable styled TextFormField for auth forms.
class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.body.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ValenceSpacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: typography.body.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: typography.body.copyWith(color: colors.textSecondary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: colors.surfacePrimary,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: ValenceSpacing.md,
              vertical: ValenceSpacing.smMd,
            ),
            border: OutlineInputBorder(
              borderRadius: ValenceRadii.mediumAll,
              borderSide: BorderSide(color: colors.borderDefault),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ValenceRadii.mediumAll,
              borderSide: BorderSide(color: colors.borderDefault),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ValenceRadii.mediumAll,
              borderSide: BorderSide(color: colors.accentPrimary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: ValenceRadii.mediumAll,
              borderSide: BorderSide(color: colors.accentError),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: ValenceRadii.mediumAll,
              borderSide: BorderSide(color: colors.accentError, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
