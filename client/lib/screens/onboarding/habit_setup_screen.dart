// client/lib/screens/onboarding/habit_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/onboarding_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

class _HabitTemplate {
  final String id;
  final String label;
  final IconData icon;

  const _HabitTemplate({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Screen 5 of onboarding — pick initial habit templates.
class HabitSetupScreen extends StatelessWidget {
  const HabitSetupScreen({super.key});

  static final List<_HabitTemplate> _templates = [
    _HabitTemplate(
      id: 'coding',
      label: 'Coding',
      icon: PhosphorIcons.code(),
    ),
    _HabitTemplate(
      id: 'exercise',
      label: 'Exercise',
      icon: PhosphorIcons.barbell(),
    ),
    _HabitTemplate(
      id: 'reading',
      label: 'Reading',
      icon: PhosphorIcons.bookOpen(),
    ),
    _HabitTemplate(
      id: 'meditation',
      label: 'Meditation',
      icon: PhosphorIcons.flower(),
    ),
    _HabitTemplate(
      id: 'language',
      label: 'Language',
      icon: PhosphorIcons.globe(),
    ),
    _HabitTemplate(
      id: 'custom',
      label: 'Custom',
      icon: PhosphorIcons.plus(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final onboarding = context.watch<OnboardingProvider>();
    final selected = onboarding.selectedHabits;
    final hasSelection = selected.isNotEmpty;

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
                'What do you want to build?',
                style: typography.h1.copyWith(color: colors.textPrimary),
              ),

              const SizedBox(height: ValenceSpacing.sm),

              Text(
                'Pick one or more habits to kick things off.',
                style: typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),

              const SizedBox(height: ValenceSpacing.xl),

              // 2-column grid of habit template cards
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: ValenceSpacing.md,
                crossAxisSpacing: ValenceSpacing.md,
                childAspectRatio: 1.25,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: _templates.map((template) {
                  final isSelected = selected.contains(template.id);
                  return _HabitTemplateCard(
                    template: template,
                    isSelected: isSelected,
                    onTap: () {
                      if (isSelected) {
                        context.read<OnboardingProvider>().removeHabit(template.id);
                      } else {
                        context.read<OnboardingProvider>().addHabit(template.id);
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: ValenceSpacing.md),

              // "Add another habit" link
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Placeholder — habit creation added in later phase
                  },
                  icon: Icon(
                    PhosphorIcons.plusCircle(),
                    color: colors.accentPrimary,
                    size: 18,
                  ),
                  label: Text(
                    'Add another habit',
                    style: typography.body.copyWith(
                      color: colors.accentPrimary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: colors.accentPrimary,
                  ),
                ),
              ),

              const SizedBox(height: ValenceSpacing.sm),

              // Caption
              Center(
                child: Text(
                  'You can customize these later',
                  style: typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Continue button — enabled only when at least 1 habit selected
              ValenceButton(
                label: 'Continue',
                fullWidth: true,
                onPressed: hasSelection
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

class _HabitTemplateCard extends StatelessWidget {
  final _HabitTemplate template;
  final bool isSelected;
  final VoidCallback onTap;

  const _HabitTemplateCard({
    required this.template,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              template.icon,
              size: 36,
              color: isSelected ? colors.accentPrimary : colors.textSecondary,
            ),
            const SizedBox(height: ValenceSpacing.sm),
            Text(
              template.label,
              style: typography.body.copyWith(
                color: isSelected ? colors.accentPrimary : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
