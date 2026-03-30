import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/models/overview_stats.dart';
import 'package:valence/providers/progress_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/progress/frequency_chart.dart';
import 'package:valence/widgets/progress/goal_progress.dart';
import 'package:valence/widgets/progress/heatmap.dart';
import 'package:valence/widgets/progress/reflection_sheet.dart';

/// Full Progress screen with two top-level tabs:
///   1. Per-Habit — streaks, goal graduation, heatmap, frequency chart,
///      failure insights, and an optional Reflect FAB.
///   2. Overview — completion rate, XP/rank, stats grid, week comparison,
///      and personality-aware encouragement.
///
/// Self-scoped [ProgressProvider] so this screen's state is independent of
/// any app-level provider tree.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressProvider(),
      child: const _ProgressScreenBody(),
    );
  }
}

class _ProgressScreenBody extends StatelessWidget {
  const _ProgressScreenBody();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surfaceBackground,
        appBar: AppBar(
          backgroundColor: colors.surfacePrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            'Progress',
            style: tokens.typography.h2.copyWith(color: colors.textPrimary),
          ),
          bottom: TabBar(
            labelColor: colors.accentPrimary,
            unselectedLabelColor: colors.textSecondary,
            indicatorColor: colors.accentPrimary,
            indicatorWeight: 2.5,
            labelStyle: tokens.typography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: tokens.typography.body,
            tabs: const [
              Tab(text: 'Per-Habit'),
              Tab(text: 'Overview'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PerHabitTab(),
            _OverviewTab(),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Per-Habit Tab
// =============================================================================

class _PerHabitTab extends StatelessWidget {
  const _PerHabitTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();
    final selected = provider.selectedHabitProgress;
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(
            left: ValenceSpacing.md,
            right: ValenceSpacing.md,
            top: ValenceSpacing.md,
            bottom: 80, // space for FAB
          ),
          children: [
            // ── 1. Habit chip selector ───────────────────────────────────
            _HabitChipSelector(
              provider: provider,
              tokens: tokens,
              colors: colors,
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // ── 2. Streak section ─────────────────────────────────────────
            _StreakSection(
              habitProgress: selected,
              tokens: tokens,
              colors: colors,
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // ── 3. Goal progress ──────────────────────────────────────────
            _SectionCard(
              tokens: tokens,
              colors: colors,
              title: 'Goal Progress',
              child: GoalProgress(
                goalStage: selected.goalStage,
                daysToNextStage: selected.daysToNextStage,
                totalDaysCompleted: selected.totalDaysCompleted,
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // ── 4. Heatmap ────────────────────────────────────────────────
            _SectionCard(
              tokens: tokens,
              colors: colors,
              title: 'Activity (12 weeks)',
              child: ValenceHeatmap(
                data: selected.heatmapData,
                color: selected.habitColor,
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // ── 5. Frequency chart ────────────────────────────────────────
            _SectionCard(
              tokens: tokens,
              colors: colors,
              title: 'Completion by Day',
              child: FrequencyChart(
                frequencyByDay: selected.frequencyByDay,
                color: selected.habitColor,
              ),
            ),
            const SizedBox(height: ValenceSpacing.md),

            // ── 6. Failure insights ───────────────────────────────────────
            if (selected.failureInsights.isNotEmpty)
              _FailureInsightsSection(
                insights: selected.failureInsights,
                tokens: tokens,
                colors: colors,
              ),
          ],
        ),

        // ── 7. Reflect FAB ─────────────────────────────────────────────────
        if (selected.reflectionUnlocked)
          Positioned(
            bottom: ValenceSpacing.lg,
            right: ValenceSpacing.md,
            child: _ReflectFab(habitProgress: selected),
          ),
      ],
    );
  }
}

// =============================================================================
// Overview Tab
// =============================================================================

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<ProgressProvider>().overviewStats;
    final tokens = context.tokens;
    final colors = tokens.colors;

    return ListView(
      padding: const EdgeInsets.all(ValenceSpacing.md),
      children: [
        // ── 1. Large completion rate ────────────────────────────────────
        _CompletionRateCard(stats: stats, tokens: tokens, colors: colors),
        const SizedBox(height: ValenceSpacing.md),

        // ── 2. XP + Rank progress bar ───────────────────────────────────
        _XpRankCard(stats: stats, tokens: tokens, colors: colors),
        const SizedBox(height: ValenceSpacing.md),

        // ── 3. Stats grid ───────────────────────────────────────────────
        _StatsGrid(stats: stats, tokens: tokens, colors: colors),
        const SizedBox(height: ValenceSpacing.md),

        // ── 4. Best week vs current week ────────────────────────────────
        _WeekComparisonRow(stats: stats, tokens: tokens, colors: colors),
        const SizedBox(height: ValenceSpacing.lg),

        // ── 5. Personality-aware encouragement ──────────────────────────
        _EncouragementCard(stats: stats, tokens: tokens, colors: colors),
        const SizedBox(height: ValenceSpacing.xl),
      ],
    );
  }
}

// =============================================================================
// Per-Habit Sub-widgets
// =============================================================================

/// Horizontal scrollable row of habit color chips.
class _HabitChipSelector extends StatelessWidget {
  final ProgressProvider provider;
  final ValenceTokens tokens;
  final dynamic colors;

  const _HabitChipSelector({
    required this.provider,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: provider.habits.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: ValenceSpacing.sm),
        itemBuilder: (context, i) {
          final habit = provider.habits[i];
          final isSelected = provider.selectedHabitIndex == i;

          return GestureDetector(
            onTap: () => provider.selectHabit(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.smMd,
                vertical: ValenceSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? habit.color.withValues(alpha: 0.18)
                    : colors.surfaceSunken,
                borderRadius: ValenceRadii.roundAll,
                border: Border.all(
                  color: isSelected ? colors.accentPrimary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Text(
                habit.name,
                style: tokens.typography.caption.copyWith(
                  color: isSelected ? colors.accentPrimary : colors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Large streak number with flame + stat cards row.
class _StreakSection extends StatelessWidget {
  final HabitProgress habitProgress;
  final ValenceTokens tokens;
  final dynamic colors;

  const _StreakSection({
    required this.habitProgress,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large streak display
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${habitProgress.currentStreak}',
              style: tokens.typography.numbersDisplay.copyWith(
                color: colors.textPrimary,
                fontSize: 56,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: ValenceSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '🔥',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'day streak',
                style: tokens.typography.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Stat cards row: Current / Longest / Total
        Row(
          children: [
            Expanded(
              child: _SmallStatCard(
                label: 'Current',
                value: '${habitProgress.currentStreak}',
                tokens: tokens,
                colors: colors,
              ),
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Expanded(
              child: _SmallStatCard(
                label: 'Longest',
                value: '${habitProgress.longestStreak}',
                tokens: tokens,
                colors: colors,
              ),
            ),
            const SizedBox(width: ValenceSpacing.sm),
            Expanded(
              child: _SmallStatCard(
                label: 'Total Days',
                value: '${habitProgress.totalDaysCompleted}',
                tokens: tokens,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Failure insights section with encouraging personality-aware text.
class _FailureInsightsSection extends StatelessWidget {
  final List<String> insights;
  final ValenceTokens tokens;
  final dynamic colors;

  const _FailureInsightsSection({
    required this.insights,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights',
          style: tokens.typography.h3.copyWith(color: colors.textPrimary),
        ),
        const SizedBox(height: ValenceSpacing.sm),
        ...insights.map(
          (insight) => Padding(
            padding: const EdgeInsets.only(bottom: ValenceSpacing.sm),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ValenceSpacing.md),
              decoration: BoxDecoration(
                color: colors.accentWarning.withValues(alpha: 0.12),
                borderRadius: ValenceRadii.mediumAll,
                border: Border.all(
                  color: colors.accentWarning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                insight,
                style: tokens.typography.body.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small floating action button for opening the ReflectionSheet.
class _ReflectFab extends StatelessWidget {
  final HabitProgress habitProgress;

  const _ReflectFab({required this.habitProgress});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return GestureDetector(
      onTap: () => ReflectionSheet.show(context, habitProgress),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.md,
          vertical: ValenceSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.accentPrimary,
          borderRadius: ValenceRadii.roundAll,
          boxShadow: [
            BoxShadow(
              color: colors.accentPrimary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✍️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: ValenceSpacing.xs),
            Text(
              'Reflect',
              style: tokens.typography.body.copyWith(
                color: colors.textInverse,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Overview Sub-widgets
// =============================================================================

class _CompletionRateCard extends StatelessWidget {
  final OverviewStats stats;
  final ValenceTokens tokens;
  final dynamic colors;

  const _CompletionRateCard({
    required this.stats,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (stats.overallCompletionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.largeAll,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Completion',
                  style: tokens.typography.overline.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: ValenceSpacing.xs),
                Text(
                  '$pct%',
                  style: tokens.typography.numbersDisplay.copyWith(
                    color: colors.textPrimary,
                    fontSize: 52,
                  ),
                ),
                Text(
                  'across all habits (84 days)',
                  style: tokens.typography.caption.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Simple circular indicator
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              value: stats.overallCompletionRate,
              strokeWidth: 6,
              backgroundColor: colors.surfaceSunken,
              valueColor:
                  AlwaysStoppedAnimation<Color>(colors.accentPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _XpRankCard extends StatelessWidget {
  final OverviewStats stats;
  final ValenceTokens tokens;
  final dynamic colors;

  const _XpRankCard({
    required this.stats,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rank: ${stats.currentRank}',
                style: tokens.typography.body.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final OverviewStats stats;
  final ValenceTokens tokens;
  final dynamic colors;

  const _StatsGrid({
    required this.stats,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total Habits', '${stats.totalHabitsTracked}'),
      ('Total Days', '${stats.totalDaysCompleted}'),
      ('Perfect Days', '${stats.perfectDays}'),
      ('Graduated', '${stats.habitsGraduated}'),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: ValenceSpacing.sm,
      mainAxisSpacing: ValenceSpacing.sm,
      childAspectRatio: 1.7,
      children: items
          .map(
            (item) => _StatGridCell(
              label: item.$1,
              value: item.$2,
              tokens: tokens,
              colors: colors,
            ),
          )
          .toList(),
    );
  }
}

class _WeekComparisonRow extends StatelessWidget {
  final OverviewStats stats;
  final ValenceTokens tokens;
  final dynamic colors;

  const _WeekComparisonRow({
    required this.stats,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bestPct = (stats.bestWeekRate * 100).round();
    final currPct = (stats.currentWeekRate * 100).round();

    return Row(
      children: [
        Expanded(
          child: _SmallStatCard(
            label: 'Best Week',
            value: '$bestPct%',
            tokens: tokens,
            colors: colors,
            accent: colors.accentSuccess,
          ),
        ),
        const SizedBox(width: ValenceSpacing.sm),
        Expanded(
          child: _SmallStatCard(
            label: 'This Week',
            value: '$currPct%',
            tokens: tokens,
            colors: colors,
            accent: colors.accentPrimary,
          ),
        ),
      ],
    );
  }
}

class _EncouragementCard extends StatelessWidget {
  final OverviewStats stats;
  final ValenceTokens tokens;
  final dynamic colors;

  const _EncouragementCard({
    required this.stats,
    required this.tokens,
    required this.colors,
  });

  String get _message {
    final rate = stats.overallCompletionRate;
    if (rate >= 0.8) {
      return "You're absolutely crushing it. ${stats.totalDaysCompleted} completions across all habits — that's not luck, that's discipline. Keep going.";
    } else if (rate >= 0.6) {
      return "Solid consistency. Most people quit before 10 days — you've got ${stats.perfectDays} perfect days. Don't stop now.";
    } else if (rate >= 0.4) {
      return "You're showing up, and that matters. ${stats.totalHabitsTracked} habits in motion. Small wins compound into big change.";
    } else {
      return "Every streak starts with a single day. Today is that day. Your future self is counting on you.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ValenceSpacing.md),
      decoration: BoxDecoration(
        color: colors.accentPrimary.withValues(alpha: 0.08),
        borderRadius: ValenceRadii.largeAll,
        border: Border.all(
          color: colors.accentPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        _message,
        style: tokens.typography.body.copyWith(
          color: colors.textPrimary,
          height: 1.6,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// =============================================================================
// Shared card primitives
// =============================================================================

/// A labelled section card with a title and child widget.
class _SectionCard extends StatelessWidget {
  final ValenceTokens tokens;
  final dynamic colors;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.tokens,
    required this.colors,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.largeAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tokens.typography.overline.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: ValenceSpacing.smMd),
          child,
        ],
      ),
    );
  }
}

/// Small stat card with a label + bold value.
class _SmallStatCard extends StatelessWidget {
  final String label;
  final String value;
  final ValenceTokens tokens;
  final dynamic colors;
  final Color? accent;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.tokens,
    required this.colors,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor = accent ?? colors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.smMd,
        vertical: ValenceSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: tokens.typography.numbersBody.copyWith(color: valueColor),
          ),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 2-column grid cell.
class _StatGridCell extends StatelessWidget {
  final String label;
  final String value;
  final ValenceTokens tokens;
  final dynamic colors;

  const _StatGridCell({
    required this.label,
    required this.value,
    required this.tokens,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        borderRadius: ValenceRadii.mediumAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: tokens.typography.numbersBody.copyWith(
              color: colors.textPrimary,
            ),
          ),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
