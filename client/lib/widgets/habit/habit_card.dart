import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_card.dart';

/// Maps a habit's [iconName] string (from mock data) to a [PhosphorIconData].
///
/// Falls back to [PhosphorIcons.star] for unknown icon names.
PhosphorIconData habitIconData(String iconName) {
  switch (iconName) {
    case 'code':
      return PhosphorIcons.code();
    case 'barbell':
      return PhosphorIcons.barbell();
    case 'book-open':
      return PhosphorIcons.bookOpen();
    case 'brain':
      return PhosphorIcons.brain();
    case 'globe':
      return PhosphorIcons.globe();
    case 'pencil-simple':
      return PhosphorIcons.pencilSimple();
    case 'flame':
      return PhosphorIcons.flame();
    case 'heart':
      return PhosphorIcons.heart();
    case 'music-note':
      return PhosphorIcons.musicNote();
    case 'lightning':
      return PhosphorIcons.lightning();
    case 'leaf':
      return PhosphorIcons.leaf();
    case 'sun':
      return PhosphorIcons.sun();
    case 'moon':
      return PhosphorIcons.moon();
    case 'pencil':
      return PhosphorIcons.pencil();
    case 'check-circle':
      return PhosphorIcons.checkCircle();
    case 'lock':
      return PhosphorIcons.lock();
    case 'camera':
      return PhosphorIcons.camera();
    case 'arrow-square-out':
      return PhosphorIcons.arrowSquareOut();
    default:
      return PhosphorIcons.star();
  }
}

/// A card representing a single habit on the Home screen.
///
/// Follows the gesture matrix:
/// | Gesture       | Manual       | ManualPhoto  | Plugin   | Redirect  |
/// |---------------|--------------|--------------|----------|-----------|
/// | Tap checkbox  | Complete     | Photo sheet  | Disabled | Complete  |
/// | Tap card body | Detail       | Detail       | Detail   | Open URL  |
class HabitCard extends StatelessWidget {
  final Habit habit;

  /// Called when the user taps the card body.
  final VoidCallback onTap;

  /// Called when the user taps the checkbox (manual/redirect habits).
  /// Also called for manualPhoto habits (caller is responsible for the photo sheet).
  final VoidCallback onComplete;

  /// Called when the user long-presses the card (optional).
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onComplete,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    final iconData = habitIconData(habit.iconName);

    return Semantics(
      label: '${habit.name}: ${habit.subtitle}. '
          '${habit.isCompleted ? "Completed" : "Not completed"}',
      child: ValenceCard(
        accentColor: habit.color,
        onTap: onTap,
        onLongPress: onLongPress,
        padding: const EdgeInsets.all(ValenceSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: habit icon
            _HabitIcon(
              iconData: iconData,
              color: habit.color,
            ),
            const SizedBox(width: ValenceSpacing.smMd),

            // Center: name + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    style: typography.h3.copyWith(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    habit.subtitle,
                    style: typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: ValenceSpacing.smMd),

            // Right: completion indicator
            _CompletionIndicator(
              habit: habit,
              tokens: tokens,
              onComplete: onComplete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded icon container on the left side of the card.
class _HabitIcon extends StatelessWidget {
  final PhosphorIconData iconData;
  final Color color;

  const _HabitIcon({required this.iconData, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: PhosphorIcon(
          iconData,
          size: 22,
          color: color,
        ),
      ),
    );
  }
}

/// Right-side indicator that varies by [TrackingType].
///
/// - Manual / Redirect: tappable circle checkbox
/// - ManualPhoto: tappable circle (triggers photo sheet via [onComplete])
/// - Plugin: lock icon + "Auto" label (not tappable)
class _CompletionIndicator extends StatelessWidget {
  final Habit habit;
  final ValenceTokens tokens;
  final VoidCallback onComplete;

  const _CompletionIndicator({
    required this.habit,
    required this.tokens,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final typography = tokens.typography;

    // Plugin habits are auto-tracked — show lock icon, not tappable
    if (habit.isPlugin) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIcons.lock(),
            size: 18,
            color: colors.textSecondary,
          ),
          const SizedBox(height: 2),
          Text(
            'Auto',
            style: typography.overline.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      );
    }

    // Completed state
    if (habit.isCompleted) {
      return Semantics(
        label: 'Completed. Tap to undo.',
        button: true,
        child: GestureDetector(
          onTap: onComplete,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.accentSuccess,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 18,
              color: colors.textInverse,
            ),
          ),
        ),
      );
    }

    // Manual / ManualPhoto / Redirect: tappable empty circle
    final String semanticLabel;
    if (habit.requiresPhoto) {
      semanticLabel = 'Complete with photo';
    } else {
      semanticLabel = 'Mark as complete';
    }

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        onTap: onComplete,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.borderDefault,
              width: 2,
            ),
          ),
          // ManualPhoto: show a small camera hint icon inside the circle
          child: habit.requiresPhoto
              ? Center(
                  child: PhosphorIcon(
                    PhosphorIcons.camera(),
                    size: 14,
                    color: colors.textSecondary,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
