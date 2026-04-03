// client/lib/screens/onboarding/group_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Screen 6 of onboarding — choose how to use groups.
class GroupSetupScreen extends StatelessWidget {
  const GroupSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final onboarding = context.watch<OnboardingProvider>();
    final choice = onboarding.groupChoice;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.lg,
            vertical: ValenceSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Mascot / link icon placeholder
              Icon(
                PhosphorIcons.linkSimple(),
                size: 80,
                color: colors.accentPrimary,
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // Heading
              Text(
                'Better with friends',
                style: typography.h1.copyWith(color: colors.textPrimary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ValenceSpacing.sm),

              Text(
                'Accountability makes habits stick.\nJoin or create a group to stay on track.',
                style: typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // "Create a Group" card
              _GroupOptionCard(
                icon: PhosphorIcons.plus(),
                title: 'Create a Group',
                subtitle: 'Start a group and invite friends',
                isSelected: choice == GroupChoice.create,
                onTap: () => context
                    .read<OnboardingProvider>()
                    .setGroupChoice(GroupChoice.create),
              ),

              const SizedBox(height: ValenceSpacing.md),

              // "Join a Group" card
              _GroupOptionCard(
                icon: PhosphorIcons.signIn(),
                title: 'Join a Group',
                subtitle: 'Enter an invite code to join',
                isSelected: choice == GroupChoice.join,
                onTap: () => context
                    .read<OnboardingProvider>()
                    .setGroupChoice(GroupChoice.join),
              ),

              const SizedBox(height: ValenceSpacing.lg),

              // "Go Solo for Now" subtle text link
              TextButton(
                onPressed: () {
                  context
                      .read<OnboardingProvider>()
                      .setGroupChoice(GroupChoice.solo);
                  context.read<OnboardingProvider>().nextPage();
                },
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                ),
                child: Text(
                  'Go Solo for Now',
                  style: typography.body.copyWith(
                    color: colors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: colors.textSecondary,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Continue button — enabled when create or join chosen
              ValenceButton(
                label: 'Continue',
                fullWidth: true,
                onPressed: (choice == GroupChoice.create ||
                        choice == GroupChoice.join)
                    ? () => context.read<OnboardingProvider>().nextPage()
                    : null,
              ),

              const SizedBox(height: ValenceSpacing.sm),
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
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(ValenceSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary.withValues(alpha: 0.08)
              : colors.surfacePrimary,
          borderRadius: ValenceRadii.largeAll,
          border: Border.all(
            color: isSelected ? colors.accentPrimary : colors.borderDefault,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accentPrimary.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accentPrimary.withValues(alpha: 0.15)
                    : colors.surfaceElevated,
                borderRadius: ValenceRadii.mediumAll,
              ),
              child: Icon(
                icon,
                color: isSelected ? colors.accentPrimary : colors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: ValenceSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: typography.body.copyWith(
                      color: isSelected
                          ? colors.accentPrimary
                          : colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: ValenceSpacing.xs),
                  Text(
                    subtitle,
                    style: typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                PhosphorIcons.checkCircle(),
                color: colors.accentPrimary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
