// client/lib/screens/onboarding/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/valence_spacing.dart';
/// Screen 1 of onboarding — full-bleed accent.primary welcome splash.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Scaffold(
      backgroundColor: colors.accentPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.lg,
            vertical: ValenceSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Mascot placeholder — Phosphor smiley at 120px
              Icon(
                PhosphorIcons.smiley(),
                size: 120,
                color: colors.textInverse.withValues(alpha: 0.9),
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // App title in Display typography
              Text(
                'Valence',
                style: typography.display.copyWith(
                  color: colors.textInverse,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ValenceSpacing.md),

              // Tagline
              Text(
                'Build habits with friends,\nnot willpower',
                style: typography.bodyLarge.copyWith(
                  color: colors.textInverse.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // "Get Started" primary button
              _InverseButton(
                label: 'Get Started',
                onPressed: () {
                  context.read<OnboardingProvider>().nextPage();
                },
              ),

              const SizedBox(height: ValenceSpacing.md),

              // "I have an account" — jump straight to AuthScreen (page 3)
              TextButton(
                onPressed: () {
                  context.read<OnboardingProvider>().goToPage(3);
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.textInverse.withValues(alpha: 0.75),
                ),
                child: Text(
                  'I have an account',
                  style: typography.body.copyWith(
                    color: colors.textInverse.withValues(alpha: 0.75),
                  ),
                ),
              ),

              const SizedBox(height: ValenceSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full-width elevated button styled for the accent-background context.
/// Uses white fill with accent-colored text so it pops on the accent background.
class _InverseButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _InverseButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.textInverse,
          foregroundColor: colors.accentPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: tokens.typography.body.copyWith(
            color: colors.accentPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
