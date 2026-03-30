import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Difficulty levels for a reflection, each with an emoji and a text label.
///
/// Text labels are ALWAYS rendered alongside emojis to meet accessibility
/// requirements (visible text, not just decorative glyphs).
enum _Difficulty {
  easy(1, '😊', 'Easy'),
  okay(2, '🙂', 'Okay'),
  moderate(3, '😐', 'Moderate'),
  hard(4, '😓', 'Hard'),
  brutal(5, '😵', 'Brutal');

  final int value;
  final String emoji;
  final String label;

  const _Difficulty(this.value, this.emoji, this.label);
}

/// Evening reflection bottom sheet — gated behind Foundation stage (10+ days).
///
/// Shows:
/// - Habit name + color chip header
/// - 5-face difficulty selector with visible text labels (accessibility)
/// - Optional free-text note field
/// - Primary "Done" button → calls [ProgressProvider.submitReflection]
///
/// Call [ReflectionSheet.show] to open. Returns without showing anything if
/// [habitProgress.reflectionUnlocked] is false.
class ReflectionSheet extends StatefulWidget {
  final HabitProgress habitProgress;

  const ReflectionSheet({super.key, required this.habitProgress});

  /// Convenience method. Does nothing (silently) if reflection is not yet
  /// unlocked for this habit (< Foundation stage, i.e. < 10 days).
  static void show(BuildContext context, HabitProgress habitProgress) {
    if (!habitProgress.reflectionUnlocked) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<ProgressProvider>(),
        child: ReflectionSheet(habitProgress: habitProgress),
      ),
    );
  }

  @override
  State<ReflectionSheet> createState() => _ReflectionSheetState();
}

class _ReflectionSheetState extends State<ReflectionSheet> {
  _Difficulty? _selected;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected == null) return;
    context.read<ProgressProvider>().submitReflection(
          widget.habitProgress.habitId,
          _selected!.value,
          _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomPad),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ValenceRadii.xl),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        ValenceSpacing.lg,
        ValenceSpacing.mdLg,
        ValenceSpacing.lg,
        ValenceSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: ValenceRadii.roundAll,
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.md),

          // Header row: habit chip + sheet title
          Row(
            children: [
              _HabitChip(
                name: widget.habitProgress.habitName,
                color: widget.habitProgress.habitColor,
                tokens: tokens,
              ),
              const SizedBox(width: ValenceSpacing.sm),
              Expanded(
                child: Text(
                  'Evening Reflection',
                  style: tokens.typography.h3.copyWith(
                    color: colors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Difficulty question
          Text(
            'How difficult was it today?',
            style: tokens.typography.body.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ValenceSpacing.md),

          // 5-face selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _Difficulty.values
                .map((d) => _FaceOption(
                      difficulty: d,
                      isSelected: _selected == d,
                      onTap: () => setState(() => _selected = d),
                      tokens: tokens,
                      colors: colors,
                    ))
                .toList(),
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Optional note
          Text(
            'Anything on your mind?',
            style: tokens.typography.body.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ValenceSpacing.sm),
          TextField(
            controller: _noteController,
            maxLines: 1,
            style: tokens.typography.body.copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Optional note…',
              hintStyle:
                  tokens.typography.body.copyWith(color: colors.textSecondary),
              filled: true,
              fillColor: colors.surfaceSunken,
              border: OutlineInputBorder(
                borderRadius: ValenceRadii.mediumAll,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: ValenceRadii.mediumAll,
                borderSide:
                    BorderSide(color: colors.borderFocus, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.md,
                vertical: ValenceSpacing.smMd,
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Done button
          ValenceButton(
            label: 'Done',
            onPressed: _selected != null ? _submit : null,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

/// Colored pill chip showing the habit name.
class _HabitChip extends StatelessWidget {
  final String name;
  final Color color;
  final ValenceTokens tokens;

  const _HabitChip({
    required this.name,
    required this.color,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.smMd,
        vertical: ValenceSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        name,
        style: tokens.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A single face option with emoji + visible text label.
class _FaceOption extends StatelessWidget {
  final _Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;
  final ValenceTokens tokens;
  final dynamic colors;

  const _FaceOption({
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: '${difficulty.label} (${difficulty.value} of 5)',
        selected: isSelected,
        button: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Face with optional highlight ring
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? colors.accentPrimary.withValues(alpha: 0.12)
                    : colors.surfaceSunken,
                border: isSelected
                    ? Border.all(
                        color: colors.accentPrimary,
                        width: 2.5,
                      )
                    : Border.all(
                        color: Colors.transparent,
                        width: 2.5,
                      ),
              ),
              child: Center(
                child: Text(
                  difficulty.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.xs),
            // Visible text label — required for accessibility
            Text(
              difficulty.label,
              style: tokens.typography.caption.copyWith(
                color: isSelected ? colors.accentPrimary : colors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
