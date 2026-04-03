import 'package:flutter/material.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal strip of 7 chain link indicators plus a streak label.
///
/// Each link is a small colored pill:
///   - Gold: all group members completed (chainGold)
///   - Silver: most completed (chainSilver)
///   - Broken: chain broken (chainBroken) with an X mark
///   - Future: muted gray, no fill
///
/// Below the links: "[streak] day streak 🔥" text and a tier badge.
class ChainStrip extends StatelessWidget {
  final List<ChainLink> links;
  final int currentStreak;

  /// Group tier label (e.g. "ember", "flame").
  final String tier;

  final VoidCallback? onTap;

  const ChainStrip({
    super.key,
    required this.links,
    required this.currentStreak,
    required this.tier,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final typography = tokens.typography;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chain link row
        Row(
          children: links.map((link) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ValenceSpacing.xs / 2,
                ),
                child: _ChainLinkPill(link: link, colors: colors),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: ValenceSpacing.sm),

        // Streak label + tier badge row
        Row(
          children: [
            Text(
              '$currentStreak day streak 🔥',
              style: typography.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: ValenceSpacing.sm),
            _TierBadge(tier: tier, colors: colors, typography: typography),
          ],
        ),
      ],
    );

    if (onTap != null) {
      return Semantics(
        label: '$currentStreak day group streak, $tier tier. Tap for details.',
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return Semantics(
      label: '$currentStreak day group streak, $tier tier.',
      child: content,
    );
  }
}

/// A single chain link pill in the strip.
class _ChainLinkPill extends StatelessWidget {
  final ChainLink link;
  final dynamic colors; // ValenceColors

  const _ChainLinkPill({required this.link, required this.colors});

  @override
  Widget build(BuildContext context) {
    final Color fillColor;
    final bool isBroken = link.type == ChainLinkType.broken;
    final bool isFuture = link.type == ChainLinkType.future;

    switch (link.type) {
      case ChainLinkType.gold:
        fillColor = colors.chainGold;
      case ChainLinkType.silver:
        fillColor = colors.chainSilver;
      case ChainLinkType.broken:
        fillColor = colors.chainBroken;
      case ChainLinkType.future:
        fillColor = colors.borderDefault;
    }

    return Semantics(
      label: _semanticLabel(link.type),
      excludeSemantics: true,
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          color: isFuture ? Colors.transparent : fillColor,
          borderRadius: ValenceRadii.smallAll,
          border: isFuture
              ? Border.all(color: colors.borderDefault, width: 1.5)
              : null,
        ),
        child: isBroken
            ? Center(
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                  semanticLabel: 'broken',
                ),
              )
            : null,
      ),
    );
  }

  String _semanticLabel(ChainLinkType type) {
    switch (type) {
      case ChainLinkType.gold:
        return 'Gold — all completed';
      case ChainLinkType.silver:
        return 'Silver — most completed';
      case ChainLinkType.broken:
        return 'Broken chain';
      case ChainLinkType.future:
        return 'Upcoming';
    }
  }
}

/// Small pill badge showing the group tier name.
class _TierBadge extends StatelessWidget {
  final String tier;
  final dynamic colors; // ValenceColors
  final dynamic typography; // ValenceTypography

  const _TierBadge({
    required this.tier,
    required this.colors,
    required this.typography,
  });

  Color _tierColor(String tier, dynamic colors) {
    switch (tier.toLowerCase()) {
      case 'spark':
        return colors.rankBronze;
      case 'ember':
        return colors.rankSilver;
      case 'flame':
        return colors.rankGold;
      case 'blaze':
        return colors.rankPlatinum;
      default:
        return colors.accentSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = _tierColor(tier, colors);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(color: badgeColor.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        tier.toUpperCase(),
        style: typography.overline.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
