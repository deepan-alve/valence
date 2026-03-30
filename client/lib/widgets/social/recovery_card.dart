// client/lib/widgets/social/recovery_card.dart
import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Recovery card shown the day after a missed habit (spec 2.29).
///
/// Displays standard copy for a single miss or escalated copy for 3+ consecutive
/// missed days. Users can dismiss the card or jump straight back in.
class RecoveryCard extends StatelessWidget {
  final int consecutiveMissDays;
  final VoidCallback onDismiss;
  final VoidCallback onLetSGo;

  const RecoveryCard({
    super.key,
    required this.consecutiveMissDays,
    required this.onDismiss,
    required this.onLetSGo,
  });

  String get _headline {
    if (consecutiveMissDays >= 3) {
      return "It's been $consecutiveMissDays days. Your group still has your back.";
    }
    return "Yesterday didn't go as planned. That's okay.";
  }

  @override
  Widget build(BuildContext context) {
    // Use theme tokens when available, fall back to safe defaults otherwise.
    final ValenceTokens? tokens = Theme.of(context).extension<ValenceTokens>();

    final Color cardBackground =
        tokens?.colors.surfacePrimary ?? Colors.white;
    final Color borderColor =
        tokens?.colors.accentSocial ?? const Color(0xFFFC8FC6);
    final Color textPrimary =
        tokens?.colors.textPrimary ?? const Color(0xFF1A1A2E);
    final Color textSecondary =
        tokens?.colors.textSecondary ?? const Color(0xFF6B6B7B);
    final Color accentPrimary =
        tokens?.colors.accentPrimary ?? const Color(0xFF4E55E0);

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: ValenceRadii.largeAll,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      padding: const EdgeInsets.all(ValenceSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              size: 20,
              color: borderColor,
            ),
          ),
          const SizedBox(width: ValenceSpacing.smMd),

          // Text column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _headline,
                  style: tokens?.typography.body.copyWith(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                      ) ??
                      TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
                const SizedBox(height: ValenceSpacing.xs),
                Text(
                  consecutiveMissDays >= 3
                      ? 'Log what happened and get back on track.'
                      : "One step at a time. Your group is with you.",
                  style: tokens?.typography.caption.copyWith(
                        color: textSecondary,
                      ) ??
                      TextStyle(
                        color: textSecondary,
                        fontSize: 12,
                      ),
                ),
                const SizedBox(height: ValenceSpacing.smMd),

                // "Let's go" button
                SizedBox(
                  height: 36,
                  child: ElevatedButton(
                    onPressed: onLetSGo,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: accentPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: ValenceRadii.mediumAll,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: ValenceSpacing.md,
                      ),
                    ),
                    child: Text(
                      "Let's go",
                      style: tokens?.typography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ) ??
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ValenceSpacing.xs),

          // Dismiss button
          Tooltip(
            message: 'Dismiss',
            child: GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 18,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
