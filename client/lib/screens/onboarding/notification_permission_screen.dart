// client/lib/screens/onboarding/notification_permission_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/screens/main_shell.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Screen 7 of onboarding — request notification permissions (placeholder).
class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  void _completeOnboarding(BuildContext context) {
    // Real notification permission request added in Phase 7.
    debugPrint('[NotificationPermissionScreen] Requesting notification permission…');
    _navigateToMain(context);
  }

  void _navigateToMain(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

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
              const Spacer(flex: 2),

              // Bell icon at 80px
              Icon(
                PhosphorIcons.bell(),
                size: 80,
                color: colors.accentPrimary,
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // Heading
              Text(
                'Stay in the loop',
                style: typography.h1.copyWith(color: colors.textPrimary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ValenceSpacing.md),

              Text(
                'We\'ll only send you the good stuff:',
                style: typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: ValenceSpacing.lg),

              // Bullet points
              _BulletList(
                items: const [
                  'Friend nudges when someone checks in',
                  'Morning motivation to start your day',
                  'Streak milestones worth celebrating',
                ],
              ),

              const Spacer(flex: 3),

              // Enable Notifications primary button
              ValenceButton(
                label: 'Enable Notifications',
                fullWidth: true,
                onPressed: () => _completeOnboarding(context),
              ),

              const SizedBox(height: ValenceSpacing.md),

              // Maybe Later text link
              TextButton(
                onPressed: () => _navigateToMain(context),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                ),
                child: Text(
                  'Maybe Later',
                  style: typography.body.copyWith(
                    color: colors.textSecondary,
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

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({required this.items});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: ValenceSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(
                  PhosphorIcons.checkCircle(),
                  size: 18,
                  color: colors.accentPrimary,
                ),
              ),
              const SizedBox(width: ValenceSpacing.smMd),
              Expanded(
                child: Text(
                  item,
                  style: typography.body.copyWith(color: colors.textPrimary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
