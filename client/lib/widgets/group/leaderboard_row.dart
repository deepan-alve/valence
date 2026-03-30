import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// A single tappable row in the weekly leaderboard.
///
/// Collapsed: Rank | Avatar | Name | Consistency % | Progress bar
/// Expanded: adds a ContributionBreakdown panel below the main row.
///
/// Primary metric is % of personal baseline, displayed in the Obviously font.
class LeaderboardRow extends StatefulWidget {
  final WeeklyScore score;

  /// Caption shown when the row is expanded (personality-aware, from GroupProvider.copy).
  final String baselineCaption;

  const LeaderboardRow({
    super.key,
    required this.score,
    this.baselineCaption = 'Based on your personal consistency',
  });

  @override
  State<LeaderboardRow> createState() => _LeaderboardRowState();
}

class _LeaderboardRowState extends State<LeaderboardRow> {
  bool _expanded = false;

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final score = widget.score;

    return Semantics(
      label: _semanticLabel(score),
      button: true,
      expanded: _expanded,
      child: GestureDetector(
        onTap: _toggle,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: ValenceSpacing.xs),
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            borderRadius: ValenceRadii.mediumAll,
            border: Border.all(
              color: _expanded ? colors.borderFocus : colors.borderDefault,
              width: _expanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MainRow(score: score, tokens: tokens, expanded: _expanded),
              // Animated expansion panel — conditionally shown so it is
              // fully absent from the widget tree when collapsed.
              if (_expanded)
                _BreakdownPanel(
                  score: score,
                  tokens: tokens,
                  caption: widget.baselineCaption,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _semanticLabel(WeeklyScore score) {
    return 'Rank ${score.rank}, ${score.memberName}, ${score.consistencyPercent}% consistency. '
        '${_expanded ? 'Tap to collapse' : 'Tap to expand breakdown'}';
  }
}

// ---------------------------------------------------------------------------
// Main collapsed row
// ---------------------------------------------------------------------------

class _MainRow extends StatelessWidget {
  final WeeklyScore score;
  final ValenceTokens tokens;
  final bool expanded;

  const _MainRow({
    required this.score,
    required this.tokens,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final typography = tokens.typography;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.md,
        vertical: ValenceSpacing.smMd,
      ),
      child: Row(
        children: [
          // Rank number
          SizedBox(
            width: 28,
            child: Text(
              '#${score.rank}',
              style: typography.caption.copyWith(
                color: _rankColor(score.rank, colors),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),

          // Avatar circle
          _RankAvatar(score: score, colors: colors),
          const SizedBox(width: ValenceSpacing.sm),

          // Name
          Expanded(
            child: Text(
              score.memberName,
              style: typography.body.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),

          // Consistency % + progress bar column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.consistencyLabel,
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _consistencyColor(score.consistencyPercent, colors),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              _ConsistencyBar(
                percent: score.consistencyPercent,
                color: _consistencyColor(score.consistencyPercent, colors),
              ),
            ],
          ),
          const SizedBox(width: ValenceSpacing.sm),

          // Expand chevron
          AnimatedRotation(
            turns: expanded ? 0.5 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Icon(
              PhosphorIconsRegular.caretDown,
              size: 16,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(int rank, dynamic colors) {
    switch (rank) {
      case 1:
        return colors.rankGold;
      case 2:
        return colors.rankSilver;
      case 3:
        return colors.rankBronze;
      default:
        return colors.textSecondary;
    }
  }

  Color _consistencyColor(int percent, dynamic colors) {
    if (percent >= 90) return colors.accentSuccess;
    if (percent >= 60) return colors.accentWarning;
    return colors.accentError;
  }
}

class _RankAvatar extends StatelessWidget {
  final WeeklyScore score;
  final dynamic colors;

  const _RankAvatar({required this.score, required this.colors});

  @override
  Widget build(BuildContext context) {
    final initials = score.memberName.isNotEmpty
        ? score.memberName.substring(0, score.memberName.length >= 2 ? 2 : 1).toUpperCase()
        : '?';

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.accentSecondary.withValues(alpha: 0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Obviously',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.accentSecondary,
          height: 1.0,
        ),
      ),
    );
  }
}

/// A thin horizontal progress bar showing consistency percentage.
class _ConsistencyBar extends StatelessWidget {
  final int percent;
  final Color color;

  const _ConsistencyBar({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 4,
      child: ClipRRect(
        borderRadius: ValenceRadii.roundAll,
        child: LinearProgressIndicator(
          value: (percent / 100).clamp(0.0, 1.0),
          backgroundColor: color.withValues(alpha: 0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Breakdown panel (shown when expanded)
// ---------------------------------------------------------------------------

class _BreakdownPanel extends StatelessWidget {
  final WeeklyScore score;
  final ValenceTokens tokens;
  final String caption;

  const _BreakdownPanel({
    required this.score,
    required this.tokens,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final breakdown = score.breakdown;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(ValenceRadii.medium),
          bottomRight: Radius.circular(ValenceRadii.medium),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        ValenceSpacing.md,
        ValenceSpacing.sm,
        ValenceSpacing.md,
        ValenceSpacing.smMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colors.borderDefault, height: 1),
          const SizedBox(height: ValenceSpacing.sm),
          _BreakdownRow(
            icon: PhosphorIconsRegular.checkSquare,
            label: 'Habits Completed',
            value: breakdown.habitsCompleted,
            tokens: tokens,
          ),
          _BreakdownRow(
            icon: PhosphorIconsRegular.link,
            label: 'Group Contributions',
            value: breakdown.groupStreakContributions,
            tokens: tokens,
          ),
          _BreakdownRow(
            icon: PhosphorIconsRegular.heart,
            label: 'Kudos Received',
            value: breakdown.kudosReceived,
            tokens: tokens,
          ),
          _BreakdownRow(
            icon: PhosphorIconsRegular.star,
            label: 'Perfect Days',
            value: breakdown.perfectDays,
            tokens: tokens,
          ),
          const SizedBox(height: ValenceSpacing.xs),
          Divider(color: colors.borderDefault, height: 1),
          const SizedBox(height: ValenceSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total points',
                style: tokens.typography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${breakdown.totalPoints}',
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.accentPrimary,
                  height: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.sm),
          Text(
            caption,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final ValenceTokens tokens;

  const _BreakdownRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: ValenceSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: tokens.typography.caption.copyWith(color: colors.textSecondary),
            ),
          ),
          Text(
            '$value',
            style: tokens.typography.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
