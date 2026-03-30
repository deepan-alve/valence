// client/lib/widgets/gamification/xp_progress.dart
import 'package:flutter/material.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Displays XP progress bar between current rank and next rank.
class XPProgress extends StatelessWidget {
  final Rank currentRank;
  final double progress;
  final int xpRemaining;

  const XPProgress({
    super.key,
    required this.currentRank,
    required this.progress,
    required this.xpRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final nextRank = currentRank.nextRank;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              currentRank.displayName,
              style: tokens.typography.caption.copyWith(
                color: colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (nextRank != null)
              Text(
                nextRank.displayName,
                style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.xs),
        ClipRRect(
          borderRadius: ValenceRadii.roundAll,
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: colors.surfaceSunken,
            valueColor: AlwaysStoppedAnimation(colors.accentPrimary),
          ),
        ),
        const SizedBox(height: ValenceSpacing.xs),
        if (nextRank != null)
          Text(
            '$xpRemaining XP to ${nextRank.displayName}',
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          )
        else
          Text(
            'Max rank achieved!',
            style: tokens.typography.caption.copyWith(
              color: colors.accentSuccess,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
