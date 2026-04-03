import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: const _ProgressBody(),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final provider = context.watch<ProgressProvider>();
    final stats = provider.overviewStats;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Title ───────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  ValenceSpacing.sm,
                ),
                child: Text(
                  'Progress',
                  style: tokens.typography.display.copyWith(
                    color: colors.textPrimary,
                    fontSize: 32,
                  ),
                ),
              ),
            ),

            // ── Rank card ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ValenceSpacing.md,
                ),
                child: _RankCard(stats: stats, tokens: tokens),
              ),
            ),

            // ── 4 stat tiles ────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  ValenceSpacing.md,
                  0,
                ),
                child: _StatTileRow(stats: stats, tokens: tokens),
              ),
            ),

            // ── Habit Activity ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.lg,
                  ValenceSpacing.md,
                  ValenceSpacing.sm,
                ),
                child: Text(
                  'Habit Activity',
                  style: tokens.typography.h2
                      .copyWith(color: colors.textPrimary),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.md,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final hp = provider.habitProgresses[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: ValenceSpacing.sm),
                      child: _HabitActivityCard(hp: hp, tokens: tokens),
                    );
                  },
                  childCount: provider.habitProgresses.length,
                ),
              ),
            ),

            // ── 66-Day Journey ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  ValenceSpacing.md,
                  ValenceSpacing.lg,
                  ValenceSpacing.md,
                  ValenceSpacing.sm,
                ),
                child: Text(
                  '66-Day Journey',
                  style: tokens.typography.h2
                      .copyWith(color: colors.textPrimary),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                ValenceSpacing.md,
                0,
                ValenceSpacing.md,
                ValenceSpacing.xxl,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final hp = provider.habitProgresses[i];
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: ValenceSpacing.sm),
                      child: _MasteryBar(hp: hp, tokens: tokens),
                    );
                  },
                  childCount: provider.habitProgresses.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Rank card
// ---------------------------------------------------------------------------

class _RankCard extends StatelessWidget {
  final dynamic stats;
  final ValenceTokens tokens;

  const _RankCard({required this.stats, required this.tokens});

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
              // Rank badge pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAFF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(PhosphorIcons.medal(),
                        size: 14, color: const Color(0xFFC0C0C0)),
                    const SizedBox(width: 4),
                    Text(
                      stats.currentRank,
                      style: tokens.typography.caption.copyWith(
                        color: colors.accentPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${stats.totalXP} XP',
                style: tokens.typography.numbersBody.copyWith(
                  color: colors.accentPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.sm),
          ClipRRect(
            borderRadius: ValenceRadii.roundAll,
            child: LinearProgressIndicator(
              value: stats.rankProgress,
              minHeight: 8,
              backgroundColor: colors.surfaceSunken,
              valueColor:
                  AlwaysStoppedAnimation<Color>(colors.accentPrimary),
            ),
          ),
          const SizedBox(height: ValenceSpacing.xs),
          Text(
            '${stats.xpToNextRank} XP to next rank',
            style: tokens.typography.caption
                .copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4 stat tiles in a row
// ---------------------------------------------------------------------------

class _StatTileRow extends StatelessWidget {
  final dynamic stats;
  final ValenceTokens tokens;

  const _StatTileRow({required this.stats, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (
        'Best Streak',
        '${_bestStreak(stats)}',
        PhosphorIcons.flame(),
        const Color(0xFFFF6B2B),
      ),
      (
        'Days Done',
        '${stats.totalDaysCompleted}',
        PhosphorIcons.checkCircle(),
        const Color(0xFF22C55E),
      ),
      (
        'Perfect Days',
        '${stats.perfectDays}',
        PhosphorIcons.star(),
        const Color(0xFFF59E0B),
      ),
      (
        'Graduated',
        '${stats.habitsGraduated}',
        PhosphorIcons.graduationCap(),
        const Color(0xFF6366F1),
      ),
    ];

    return Row(
      children: tiles.asMap().entries.map((e) {
        final isLast = e.key == tiles.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : ValenceSpacing.xs),
            child: _StatTile(
              label: e.value.$1,
              value: e.value.$2,
              icon: e.value.$3,
              iconColor: e.value.$4,
              tokens: tokens,
            ),
          ),
        );
      }).toList(),
    );
  }

  int _bestStreak(dynamic stats) {
    // Use best week rate * 7 as a proxy for best streak days if no direct field
    return (stats.bestWeekRate * 7).round();
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final PhosphorIconData icon;
  final Color iconColor;
  final ValenceTokens tokens;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.xs,
        vertical: ValenceSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
      ),
      child: Column(
        children: [
          PhosphorIcon(icon, size: 18, color: iconColor),
          const SizedBox(height: 2),
          Text(
            value,
            style: tokens.typography.numbersBody.copyWith(
              color: colors.textPrimary,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Habit Activity card — mini 7-day bar chart
// ---------------------------------------------------------------------------

class _HabitActivityCard extends StatelessWidget {
  final HabitProgress hp;
  final ValenceTokens tokens;

  const _HabitActivityCard({required this.hp, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    // Build 7-day completion array from heatmap data
    final now = DateTime.now();
    final bars = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final key = DateTime(day.year, day.month, day.day);
      final val = hp.heatmapData[key] ?? 0;
      return val > 0 ? 1.0 : 0.0;
    });
    final daysLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.largeAll,
      ),
      child: Row(
        children: [
          // Left: habit info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: hp.habitColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        hp.habitName,
                        style: tokens.typography.body.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    PhosphorIcon(PhosphorIcons.flame(),
                        size: 12, color: const Color(0xFFFF6B2B)),
                    const SizedBox(width: 2),
                    Text(
                      '${hp.currentStreak} day streak',
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Right: mini bar chart
          Expanded(
            flex: 4,
            child: Column(
              children: [
                // Bars
                SizedBox(
                  height: 32,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (i) {
                      final filled = bars[i] > 0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filled
                                  ? hp.habitColor
                                  : hp.habitColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            height: filled ? 28 : 14,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 3),
                // Day labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    return Expanded(
                      child: Text(
                        daysLabels[i],
                        style: tokens.typography.caption.copyWith(
                          fontSize: 8,
                          color: colors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 66-Day mastery progress bar
// ---------------------------------------------------------------------------

class _MasteryBar extends StatelessWidget {
  final HabitProgress hp;
  final ValenceTokens tokens;

  const _MasteryBar({required this.hp, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final progress = (hp.totalDaysCompleted / 66.0).clamp(0.0, 1.0);
    final pct = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.md,
        vertical: ValenceSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.largeAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: hp.habitColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    hp.habitName,
                    style: tokens.typography.body.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: tokens.typography.caption.copyWith(
                  color: colors.accentPrimary,
                  fontWeight: FontWeight.w700,
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
              valueColor: AlwaysStoppedAnimation<Color>(hp.habitColor),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '${hp.totalDaysCompleted} / 66 days  •  ${hp.goalStage.displayName}',
            style: tokens.typography.caption
                .copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
