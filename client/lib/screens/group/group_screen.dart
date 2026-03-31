import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/group/feed_item_card.dart';
import 'package:valence/widgets/group/member_avatar.dart';
import 'package:valence/widgets/group/nudge_sheet.dart';
import 'package:valence/widgets/group/solo_empty_state.dart';

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

class _GroupScreenBody extends StatelessWidget {
  const _GroupScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final group = context.watch<GroupProvider>();

    if (!group.hasGroup) {
      return Scaffold(
        backgroundColor: colors.surfaceBackground,
        body: SafeArea(
          child: SoloEmptyState(onCreateGroup: () {}, onJoinGroup: () {}),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── Header ──────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ValenceSpacing.md,
                        ValenceSpacing.md,
                        ValenceSpacing.md,
                        0,
                      ),
                      child: _Header(group: group, tokens: tokens),
                    ),
                  ),

                  // ── Member avatars ───────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: ValenceSpacing.md),
                      child: SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: ValenceSpacing.md,
                          ),
                          itemCount: group.members.length,
                          separatorBuilder: (context, i) =>
                              const SizedBox(width: ValenceSpacing.md),
                          itemBuilder: (context, i) {
                            final m = group.members[i];
                            return MemberAvatar(
                              member: m,
                              onNudge: m.isCurrentUser
                                  ? null
                                  : () => NudgeSheet.show(
                                        context,
                                        memberId: m.id,
                                        memberName: m.name,
                                      ),
                              onKudos: m.isCurrentUser
                                  ? null
                                  : () => context
                                      .read<GroupProvider>()
                                      .sendKudos(m.id),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // ── Leaderboard card ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ValenceSpacing.md,
                        ValenceSpacing.lg,
                        ValenceSpacing.md,
                        0,
                      ),
                      child: _LeaderboardCard(
                        scores: group.weeklyScores,
                        tokens: tokens,
                      ),
                    ),
                  ),

                  // ── Activity Feed label ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        ValenceSpacing.md,
                        ValenceSpacing.lg,
                        ValenceSpacing.md,
                        ValenceSpacing.sm,
                      ),
                      child: Text(
                        'Group Activity',
                        style: tokens.typography.h2
                            .copyWith(color: tokens.colors.textPrimary),
                      ),
                    ),
                  ),

                  // ── Feed items ───────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.md,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final item = group.feedItems[i];
                          return FeedItemCard(
                            item: item,
                            copy: group.copy,
                            onKudos: item.senderId != 'u1'
                                ? () => context
                                    .read<GroupProvider>()
                                    .sendKudos(item.senderId)
                                : null,
                          );
                        },
                        childCount: group.feedItems.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: ValenceSpacing.xl),
                  ),
                ],
              ),
            ),

            // ── Bottom action buttons ─────────────────────────────────────
            _BottomActions(group: group, tokens: tokens),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final GroupProvider group;
  final ValenceTokens tokens;

  const _Header({required this.group, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.groupName,
                style: tokens.typography.display.copyWith(
                  color: colors.textPrimary,
                  fontSize: 28,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${group.groupStreak}-day streak',
                    style: tokens.typography.caption.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _TierBadge(tier: group.groupTierEnum, tokens: tokens),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tier badge
// ---------------------------------------------------------------------------

class _TierBadge extends StatelessWidget {
  final GroupTier tier;
  final ValenceTokens tokens;

  const _TierBadge({required this.tier, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final color = _tierColor(tier, colors);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        _tierLabel(tier),
        style: tokens.typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _tierLabel(GroupTier tier) => switch (tier) {
        GroupTier.spark => 'Spark',
        GroupTier.ember => 'Ember',
        GroupTier.flame => 'Flame',
        GroupTier.blaze => 'Blaze',
      };

  Color _tierColor(GroupTier tier, dynamic colors) => switch (tier) {
        GroupTier.spark => colors.accentSecondary,
        GroupTier.ember => colors.accentWarning,
        GroupTier.flame => colors.accentError,
        GroupTier.blaze => colors.rankGold,
      };
}

// ---------------------------------------------------------------------------
// Leaderboard card
// ---------------------------------------------------------------------------

class _LeaderboardCard extends StatelessWidget {
  final List<WeeklyScore> scores;
  final ValenceTokens tokens;

  const _LeaderboardCard({required this.scores, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.largeAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Leaderboard',
                style: tokens.typography.h3
                    .copyWith(color: colors.textPrimary),
              ),
              const Spacer(),
              Text(
                'This Week',
                style: tokens.typography.caption
                    .copyWith(color: colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.md),
          ...scores.take(3).toList().asMap().entries.map((e) {
            return _LeaderboardRow(
              rank: e.key + 1,
              score: e.value,
              tokens: tokens,
            );
          }),
          if (scores.length > 3) ...[
            const SizedBox(height: ValenceSpacing.sm),
            Center(
              child: Text(
                '+ ${scores.length - 3} more',
                style: tokens.typography.caption.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final WeeklyScore score;
  final ValenceTokens tokens;

  const _LeaderboardRow({
    required this.rank,
    required this.score,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final pct = score.consistencyPercent / 100.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
      child: Row(
        children: [
          // Rank medal
          SizedBox(
            width: 24,
            child: Text(
              _rankEmoji(rank),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Name
          SizedBox(
            width: 56,
            child: Text(
              score.memberName,
              style: tokens.typography.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: ValenceRadii.roundAll,
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: colors.surfaceSunken,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colors.accentPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Percentage
          SizedBox(
            width: 36,
            child: Text(
              '${score.consistencyPercent}%',
              style: tokens.typography.caption.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _rankEmoji(int rank) => switch (rank) {
        1 => '🥇',
        2 => '🥈',
        3 => '🥉',
        _ => '$rank.',
      };
}

// ---------------------------------------------------------------------------
// Bottom action buttons
// ---------------------------------------------------------------------------

class _BottomActions extends StatelessWidget {
  final GroupProvider group;
  final ValenceTokens tokens;

  const _BottomActions({required this.group, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    // Pick first non-current member to nudge/kudos
    final others = group.members.where((m) => !m.isCurrentUser).toList();

    return Container(
      padding: EdgeInsets.fromLTRB(
        ValenceSpacing.md,
        ValenceSpacing.sm,
        ValenceSpacing.md,
        ValenceSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceBackground,
        border: Border(
          top: BorderSide(color: colors.borderDefault, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Send Nudge — filled
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (others.isNotEmpty) {
                  NudgeSheet.show(
                    context,
                    memberId: others.first.id,
                    memberName: others.first.name,
                  );
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: colors.accentPrimary,
                  borderRadius: ValenceRadii.roundAll,
                ),
                child: Center(
                  child: Text(
                    'Send Nudge 🫡',
                    style: tokens.typography.body.copyWith(
                      color: colors.textInverse,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Kudos — outlined
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (others.isNotEmpty) {
                  context.read<GroupProvider>().sendKudos(others.first.id);
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: ValenceRadii.roundAll,
                  border: Border.all(
                    color: colors.accentPrimary,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Kudos ⭐',
                    style: tokens.typography.body.copyWith(
                      color: colors.accentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
