// client/lib/screens/onboarding/theme_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/theme_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Screen 3 of onboarding — choose dark (Nocturnal Sanctuary) or
/// light (Daybreak) theme.
class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final themeProvider = context.watch<ThemeProvider>();
    final onboarding = context.watch<OnboardingProvider>();

    final selectedId = onboarding.selectedThemeId ?? themeProvider.activeThemeId;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.lg,
            vertical: ValenceSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              // Heading
              Text(
                'Pick your vibe',
                style: typography.h1.copyWith(color: colors.textPrimary),
              ),

              const SizedBox(height: ValenceSpacing.sm),

              Text(
                'Choose a look that feels right. You can change this anytime.',
                style: typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // Theme preview cards side by side
              Row(
                children: [
                  Expanded(
                    child: _ThemePreviewCard(
                      themeId: 'nocturnal_sanctuary',
                      label: 'Nocturnal',
                      previewBg: const Color(0xFF121220),
                      previewAccent: const Color(0xFFF4A261), // amber
                      previewText: const Color(0xFFF0E6D3),
                      isSelected: selectedId == 'nocturnal_sanctuary',
                      onTap: () {
                        themeProvider.setTheme('nocturnal_sanctuary');
                        onboarding.setTheme('nocturnal_sanctuary');
                      },
                    ),
                  ),
                  const SizedBox(width: ValenceSpacing.md),
                  Expanded(
                    child: _ThemePreviewCard(
                      themeId: 'daybreak',
                      label: 'Daybreak',
                      previewBg: const Color(0xFFFFF8F0), // cream
                      previewAccent: const Color(0xFF4E55E0), // blue/indigo
                      previewText: const Color(0xFF1A1A2E),
                      isSelected: selectedId == 'daybreak',
                      onTap: () {
                        themeProvider.setTheme('daybreak');
                        onboarding.setTheme('daybreak');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: ValenceSpacing.md),

              // Caption
              Center(
                child: Text(
                  'You can always change this later',
                  style: typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Continue button
              ValenceButton(
                label: 'Continue',
                fullWidth: true,
                onPressed: () => context.read<OnboardingProvider>().nextPage(),
              ),

              const SizedBox(height: ValenceSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tappable preview card showing a miniature theme mock-up.
class _ThemePreviewCard extends StatelessWidget {
  final String themeId;
  final String label;
  final Color previewBg;
  final Color previewAccent;
  final Color previewText;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.themeId,
    required this.label,
    required this.previewBg,
    required this.previewAccent,
    required this.previewText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: ValenceRadii.largeAll,
          border: Border.all(
            color: isSelected ? colors.accentPrimary : colors.borderDefault,
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors.accentPrimary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: ValenceRadii.largeAll,
          child: Column(
            children: [
              // Mini preview area
              Container(
                height: 160,
                color: previewBg,
                padding: const EdgeInsets.all(ValenceSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fake top bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: previewText.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: previewAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: ValenceSpacing.smMd),
                    // Fake habit rows
                    ..._fakeRows(previewText, previewAccent),
                    const Spacer(),
                    // Accent button preview
                    Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: previewAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),

              // Label area
              Container(
                width: double.infinity,
                color: isSelected
                    ? colors.accentPrimary.withValues(alpha: 0.08)
                    : colors.surfacePrimary,
                padding: const EdgeInsets.symmetric(
                  vertical: ValenceSpacing.smMd,
                ),
                child: Center(
                  child: Text(
                    label,
                    style: tokens.typography.body.copyWith(
                      color: isSelected
                          ? colors.accentPrimary
                          : colors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _fakeRows(Color text, Color accent) {
    return [
      _fakeRow(text, accent, accentFill: true),
      const SizedBox(height: ValenceSpacing.xs),
      _fakeRow(text, accent),
      const SizedBox(height: ValenceSpacing.xs),
      _fakeRow(text, accent),
    ];
  }

  Widget _fakeRow(Color text, Color accent, {bool accentFill = false}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: accentFill ? accent : text.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: ValenceSpacing.xs),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: text.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
