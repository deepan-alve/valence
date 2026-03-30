import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/group/feed_item_card.dart';
import 'package:valence/widgets/group/leaderboard_row.dart';
import 'package:valence/widgets/group/member_avatar.dart';
import 'package:valence/widgets/group/nudge_sheet.dart';
import 'package:valence/widgets/group/solo_empty_state.dart';
import 'package:valence/widgets/group/streak_freeze_sheet.dart';

/// Full Group screen — requires a [GroupProvider] ancestor.
///
/// Compose at the root level:
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => GroupProvider(),
///   child: const GroupScreen(),
/// )
/// ```
class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupProvider>(
      create: (_) => GroupProvider(),
      child: const _GroupScreenBody(),
    );
  }
}

class _GroupScreenBody extends StatefulWidget {
  const _GroupScreenBody();

  @override
  State<_GroupScreenBody> createState() => _GroupScreenBodyState();
}

class _GroupScreenBodyState extends State<_GroupScreenBody> {
  bool _leaderboardExpanded = true;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final groupProvider = context.watch<GroupProvider>();

    // Solo mode — show empty state instead of group content.
    if (!groupProvider.hasGroup) {
      return Scaffold(
        backgroundColor: colors.surfaceBackground,
        body: SafeArea(
          child: SoloEmptyState(
            onCreateGroup: () {},
            onJoinGroup: () {},
          ),
        ),
      );
    }

    final members = groupProvider.members;
    final feedItems = groupProvider.feedItems;
    final weeklyScores = groupProvider.weeklyScores;
    final copy = groupProvider.copy;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ----------------------------------------------------------------
            // 1. Header: Group name + tier badge + streak + invite button
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group name + tier badge row
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  groupProvider.groupName,
                                  style: tokens.typography.h1.copyWith(
                                    color: colors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: ValenceSpacing.sm),
                              _TierBadge(tier: groupProvider.groupTierEnum),
                            ],
                          ),
                          const SizedBox(height: ValenceSpacing.xs),
                          // Streak count row
                          Row(
                            children: [
                              const Text(
                                '🔥',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: ValenceSpacing.xs),
                              Text(
                                '${groupProvider.groupStreak}-day streak',
                                style: tokens.typography.body.copyWith(
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Invite icon button
                    Semantics(
                      label: 'Invite members',
                      button: true,
                      child: IconButton(
                        icon: Icon(
                          PhosphorIconsRegular.userPlus,
                          color: colors.accentPrimary,
                        ),
                        onPressed: () {
                          // TODO: open invite flow
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // 2. Member status grid — horizontal scroll
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: ValenceSpacing.md,
                  bottom: ValenceSpacing.xs,
                ),
                child: SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.md,
                    ),
                    itemCount: members.length,
                    separatorBuilder: (context, i) =>
                        const SizedBox(width: ValenceSpacing.md),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return MemberAvatar(
                        member: member,
                        onNudge: member.isCurrentUser
                            ? null
                            : () => _openNudgeSheet(context, member),
                        onKudos: member.isCurrentUser
                            ? null
                            : () => context
                                .read<GroupProvider>()
                                .sendKudos(member.id),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // 3. Action bar — streak freeze + personality toggle
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ValenceSpacing.md,
                  vertical: ValenceSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Streak Freeze button with points balance
                    _StreakFreezeButton(
                      points: groupProvider.consistencyPoints,
                      active: groupProvider.freezeActiveToday,
                      tokens: tokens,
                    ),
                    const Spacer(),
                    // Personality toggle
                    _PersonalityToggle(
                      value: groupProvider.personalityOn,
                      onChanged: (_) =>
                          context.read<GroupProvider>().togglePersonality(),
                      tokens: tokens,
                    ),
                  ],
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // 4. Group feed — reverse chronological
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.sm,
                  ValenceSpacing.md,
                  0,
                ),
                child: Text(
                  'Group Activity',
                  style: tokens.typography.h2.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = feedItems[index];
                    return FeedItemCard(
                      item: item,
                      copy: copy,
                      onKudos: item.senderId != 'u1'
                          ? () => context
                              .read<GroupProvider>()
                              .sendKudos(item.senderId)
                          : null,
                    );
                  },
                  childCount: feedItems.length,
                ),
              ),
            ),

            // ----------------------------------------------------------------
            // 5. Weekly leaderboard — collapsible with week/month toggle
            // ----------------------------------------------------------------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.lg,
                  ValenceSpacing.md,
                  0,
                ),
                child: _LeaderboardSection(
                  expanded: _leaderboardExpanded,
                  onToggle: () {
                    setState(() {
                      _leaderboardExpanded = !_leaderboardExpanded;
                    });
                  },
                  weeklyScores: weeklyScores,
                  period: groupProvider.leaderboardPeriod,
                  onPeriodChanged: (p) =>
                      context.read<GroupProvider>().setLeaderboardPeriod(p),
                  baselineCaption: copy.leaderboardCaption,
                  tokens: tokens,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: ValenceSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  void _openNudgeSheet(BuildContext context, GroupMember member) {
    NudgeSheet.show(
      context,
      memberId: member.id,
      memberName: member.name,
    );
  }
}


// ---------------------------------------------------------------------------
// Tier badge pill
// ---------------------------------------------------------------------------

class _TierBadge extends StatelessWidget {
  final GroupTier tier;

  const _TierBadge({required this.tier});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = _tierColor(tier, context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Text(
        _tierLabel(tier),
        style: tokens.typography.overline.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _tierLabel(GroupTier tier) {
    switch (tier) {
      case GroupTier.spark:
        return 'Spark';
      case GroupTier.ember:
        return 'Ember';
      case GroupTier.flame:
        return 'Flame';
      case GroupTier.blaze:
        return 'Blaze';
    }
  }

  Color _tierColor(GroupTier tier, BuildContext context) {
    final colors = context.tokens.colors;
    switch (tier) {
      case GroupTier.spark:
        return colors.accentSecondary;
      case GroupTier.ember:
        return colors.accentWarning;
      case GroupTier.flame:
        return colors.accentError;
      case GroupTier.blaze:
        return colors.rankGold;
    }
  }
}

// ---------------------------------------------------------------------------
// Streak Freeze button
// ---------------------------------------------------------------------------

class _StreakFreezeButton extends StatelessWidget {
  final int points;
  final bool active;
  final ValenceTokens tokens;

  const _StreakFreezeButton({
    required this.points,
    required this.active,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final freezeColor = active ? colors.accentSecondary : colors.textSecondary;

    return Semantics(
      label: 'Streak Freeze. $points points available.',
      button: true,
      child: GestureDetector(
        onTap: () => StreakFreezeSheet.show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.smMd,
            vertical: ValenceSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: active
                ? colors.accentSecondary.withValues(alpha: 0.10)
                : colors.surfacePrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? colors.accentSecondary.withValues(alpha: 0.4)
                  : colors.borderDefault,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(PhosphorIconsRegular.snowflake, size: 16, color: freezeColor),
              const SizedBox(width: ValenceSpacing.xs),
              Text(
                active ? 'Freeze Active ❄️' : '$points pts',
                style: tokens.typography.caption.copyWith(
                  color: freezeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Personality toggle
// ---------------------------------------------------------------------------

class _PersonalityToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final ValenceTokens tokens;

  const _PersonalityToggle({
    required this.value,
    required this.onChanged,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Semantics(
      label: value ? 'Personality copy on' : 'Personality copy off',
      toggled: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIconsRegular.sparkle,
            size: 14,
            color: value ? colors.accentSecondary : colors.textSecondary,
          ),
          const SizedBox(width: ValenceSpacing.xs),
          Text(
            'Personality',
            style: tokens.typography.caption.copyWith(
              color: value ? colors.accentSecondary : colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: ValenceSpacing.xs),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: colors.accentSecondary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Leaderboard collapsible section
// ---------------------------------------------------------------------------

class _LeaderboardSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final List<dynamic> weeklyScores;
  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;
  final String baselineCaption;
  final ValenceTokens tokens;

  const _LeaderboardSection({
    required this.expanded,
    required this.onToggle,
    required this.weeklyScores,
    required this.period,
    required this.onPeriodChanged,
    required this.baselineCaption,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with collapse toggle
        Semantics(
          label: expanded
              ? 'Weekly Leaderboard, tap to collapse'
              : 'Weekly Leaderboard, tap to expand',
          button: true,
          expanded: expanded,
          child: GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Weekly Leaderboard',
                    style: tokens.typography.h2.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.0 : -0.25,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    PhosphorIconsRegular.caretDown,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (expanded) ...[
          const SizedBox(height: ValenceSpacing.sm),

          // Week / Month toggle chips
          _PeriodToggle(
            period: period,
            onChanged: onPeriodChanged,
            tokens: tokens,
          ),
          const SizedBox(height: ValenceSpacing.sm),

          // Leaderboard rows
          ...weeklyScores.map((score) => LeaderboardRow(
                score: score,
                baselineCaption: baselineCaption,
              )),

          const SizedBox(height: ValenceSpacing.xs),

          // Caption
          Text(
            baselineCaption,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Period toggle (Week / Month chips)
// ---------------------------------------------------------------------------

class _PeriodToggle extends StatelessWidget {
  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardPeriod> onChanged;
  final ValenceTokens tokens;

  const _PeriodToggle({
    required this.period,
    required this.onChanged,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chip(
          label: 'This Week',
          selected: period == LeaderboardPeriod.week,
          onTap: () => onChanged(LeaderboardPeriod.week),
          tokens: tokens,
          colors: colors,
        ),
        const SizedBox(width: ValenceSpacing.sm),
        _Chip(
          label: 'This Month',
          selected: period == LeaderboardPeriod.month,
          onTap: () => onChanged(LeaderboardPeriod.month),
          tokens: tokens,
          colors: colors,
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ValenceTokens tokens;
  final dynamic colors;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.smMd,
            vertical: ValenceSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: selected
                ? colors.accentPrimary.withValues(alpha: 0.12)
                : colors.surfacePrimary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colors.accentPrimary.withValues(alpha: 0.5)
                  : colors.borderDefault,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: selected ? colors.accentPrimary : colors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
