import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_spacing.dart';

/// Maps a habit's [iconName] string to a [PhosphorIconData].
PhosphorIconData habitIconData(String iconName) {
  switch (iconName) {
    case 'code':       return PhosphorIcons.code();
    case 'barbell':    return PhosphorIcons.barbell();
    case 'book-open':  return PhosphorIcons.bookOpen();
    case 'brain':      return PhosphorIcons.brain();
    case 'globe':      return PhosphorIcons.globe();
    case 'pencil-simple': return PhosphorIcons.pencilSimple();
    case 'flame':      return PhosphorIcons.flame();
    case 'heart':      return PhosphorIcons.heart();
    case 'music-note': return PhosphorIcons.musicNote();
    case 'lightning':  return PhosphorIcons.lightning();
    case 'leaf':       return PhosphorIcons.leaf();
    case 'sun':        return PhosphorIcons.sun();
    case 'moon':       return PhosphorIcons.moon();
    case 'pencil':     return PhosphorIcons.pencil();
    case 'camera':     return PhosphorIcons.camera();
    default:           return PhosphorIcons.star();
  }
}

/// Full-color habit card matching the Valence UI reference design.
/// Icon + completion indicator on top row, name + subtitle at the bottom.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleVisibility;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onTap,
    required this.onComplete,
    this.onLongPress,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final isMinimal = habit.visibility == HabitVisibility.minimal;

    // Completed cards get desaturated — mix color toward grey
    final baseColor = habit.color;
    final cardColor = habit.isCompleted
        ? Color.lerp(baseColor, const Color(0xFFE0E0E0), 0.45)!
        : baseColor;

    // Text always dark on these light habit colors
    const textDark = Color(0xFF1A1A2E);
    const textMuted = Color(0xFF4A4A5E);

    return Semantics(
      label: '${habit.name}. ${habit.isCompleted ? "Completed" : "Not completed"}',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(ValenceSpacing.md),
          child: isMinimal
              ? _MinimalContent(
                  habit: habit,
                  onComplete: onComplete,
                  textDark: textDark,
                )
              : _FullContent(
                  habit: habit,
                  onComplete: onComplete,
                  onToggleVisibility: onToggleVisibility,
                  textDark: textDark,
                  textMuted: textMuted,
                ),
        ),
      ),
    );
  }
}

class _FullContent extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback? onToggleVisibility;
  final Color textDark;
  final Color textMuted;

  const _FullContent({
    required this.habit,
    required this.onComplete,
    required this.onToggleVisibility,
    required this.textDark,
    required this.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = habitIconData(habit.iconName);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: icon left, actions right
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: PhosphorIcon(iconData, size: 20, color: textDark),
              ),
            ),
            const Spacer(),
            // Visibility toggle (subtle)
            if (onToggleVisibility != null)
              GestureDetector(
                onTap: onToggleVisibility,
                child: Padding(
                  padding: const EdgeInsets.only(right: 6, top: 2),
                  child: PhosphorIcon(
                    habit.visibility == HabitVisibility.minimal
                        ? PhosphorIcons.lock()
                        : PhosphorIcons.lockOpen(),
                    size: 14,
                    color: textDark.withValues(alpha: 0.4),
                  ),
                ),
              ),
            // Completion indicator
            _CompletionButton(
              habit: habit,
              onComplete: onComplete,
              textDark: textDark,
            ),
          ],
        ),

        const Spacer(),

        // Bottom: name + subtitle
        Text(
          habit.name,
          style: TextStyle(
            fontFamily: 'Obviously',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textDark,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          habit.subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textMuted,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _MinimalContent extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final Color textDark;

  const _MinimalContent({
    required this.habit,
    required this.onComplete,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = habitIconData(habit.iconName);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PhosphorIcon(iconData, size: 22, color: textDark.withValues(alpha: 0.5)),
        _CompletionButton(
          habit: habit,
          onComplete: onComplete,
          textDark: textDark,
        ),
      ],
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final Color textDark;

  const _CompletionButton({
    required this.habit,
    required this.onComplete,
    required this.textDark,
  });

  @override
  Widget build(BuildContext context) {
    // Plugin: lock + auto label
    if (habit.isPlugin) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(PhosphorIcons.lock(), size: 16,
              color: textDark.withValues(alpha: 0.5)),
          const SizedBox(height: 2),
          Text('Auto',
              style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: textDark.withValues(alpha: 0.5))),
        ],
      );
    }

    return Semantics(
      label: habit.isCompleted ? 'Completed. Tap to undo.' : 'Mark as complete',
      button: true,
      child: GestureDetector(
        onTap: onComplete,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: habit.isCompleted ? textDark : Colors.transparent,
            border: Border.all(
              color: habit.isCompleted
                  ? textDark
                  : textDark.withValues(alpha: 0.35),
              width: 2,
            ),
          ),
          child: habit.isCompleted
              ? Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : habit.requiresPhoto
                  ? Center(
                      child: PhosphorIcon(PhosphorIcons.camera(),
                          size: 12,
                          color: textDark.withValues(alpha: 0.5)))
                  : null,
        ),
      ),
    );
  }
}
