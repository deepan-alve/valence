// client/lib/widgets/gamification/rank_badge.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/shop_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Displays a rank badge with icon and label.
/// Used in Shop header, Profile header, and ShopItemCard lock labels.
class RankBadge extends StatelessWidget {
  final Rank rank;
  final bool compact;

  const RankBadge({
    super.key,
    required this.rank,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final rankColor = _colorForRank(rank, colors);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? ValenceSpacing.sm : ValenceSpacing.smMd,
        vertical: compact ? ValenceSpacing.xs : ValenceSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: rankColor.withValues(alpha: 0.15),
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(color: rankColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.shield(PhosphorIconsStyle.fill),
            size: compact ? 14 : 18,
            color: rankColor,
          ),
          SizedBox(width: compact ? ValenceSpacing.xs : ValenceSpacing.sm),
          Text(
            rank.displayName,
            style: (compact ? tokens.typography.caption : tokens.typography.body)
                .copyWith(color: rankColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _colorForRank(Rank rank, dynamic colors) {
    return switch (rank) {
      Rank.bronze => colors.rankBronze,
      Rank.silver => colors.rankSilver,
      Rank.gold => colors.rankGold,
      Rank.platinum => colors.rankPlatinum,
      Rank.diamond => colors.rankDiamond,
    };
  }
}
