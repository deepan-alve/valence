// client/lib/screens/onboarding/pitch_carousel.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/widgets/core/valence_button.dart';

class _PitchPage {
  final IconData icon;
  final String title;
  final String description;

  const _PitchPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}

/// Screen 2 of onboarding — a 3-page internal carousel with dot indicator.
class PitchCarousel extends StatefulWidget {
  const PitchCarousel({super.key});

  @override
  State<PitchCarousel> createState() => _PitchCarouselState();
}

class _PitchCarouselState extends State<PitchCarousel> {
  final PageController _innerController = PageController();
  int _innerPage = 0;

  static final List<_PitchPage> _pitchPages = [
    _PitchPage(
      icon: PhosphorIcons.usersThree(),
      title: 'Track Together',
      description:
          'Habits stick when friends hold you accountable. Share streaks, '
          'celebrate milestones, and keep each other going every single day.',
    ),
    _PitchPage(
      icon: PhosphorIcons.plugsConnected(),
      title: 'Auto-Verify',
      description:
          'Connect apps you already use — fitness trackers, journals, '
          'timers — and let Valence verify your habits automatically.',
    ),
    _PitchPage(
      icon: PhosphorIcons.shieldCheck(),
      title: 'Never Reset',
      description:
          'Miss a day? Use a grace token. Life happens — our system '
          'protects your streak so one slip never erases months of progress.',
    ),
  ];

  bool get _isLastPage => _innerPage == _pitchPages.length - 1;

  void _nextInner() {
    if (!_isLastPage) {
      _innerController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;
    final onboarding = context.read<OnboardingProvider>();

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with Skip button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ValenceSpacing.md,
                ValenceSpacing.sm,
                ValenceSpacing.md,
                0,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onboarding.nextPage(),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.textSecondary,
                  ),
                  child: Text(
                    'Skip',
                    style: typography.body.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Inner PageView
            Expanded(
              child: PageView.builder(
                controller: _innerController,
                itemCount: _pitchPages.length,
                onPageChanged: (i) => setState(() => _innerPage = i),
                itemBuilder: (context, index) {
                  final page = _pitchPages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.lg,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          page.icon,
                          size: 96,
                          color: colors.accentPrimary,
                        ),
                        const SizedBox(height: ValenceSpacing.xl),
                        Text(
                          page.title,
                          style: typography.h1.copyWith(
                            color: colors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: ValenceSpacing.md),
                        Text(
                          page.description,
                          style: typography.bodyLarge.copyWith(
                            color: colors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dot indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: ValenceSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pitchPages.length, (i) {
                  final isActive = i == _innerPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.xs,
                    ),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? colors.accentPrimary
                          : colors.borderDefault,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Continue / Next button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ValenceSpacing.lg,
                0,
                ValenceSpacing.lg,
                ValenceSpacing.xl,
              ),
              child: ValenceButton(
                label: _isLastPage ? 'Continue' : 'Next',
                fullWidth: true,
                onPressed: _isLastPage
                    ? () => onboarding.nextPage()
                    : _nextInner,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
