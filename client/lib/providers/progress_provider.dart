import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/habit_progress.dart';
import 'package:valence/models/overview_stats.dart';
import 'package:valence/utils/constants.dart';

/// Manages all Progress screen state using mock data.
///
/// Covers:
///  - Per-habit stats (streak, heatmap, frequency, failure insights)
///  - Overview aggregation
///  - Evening reflection (gated behind Foundation stage)
class ProgressProvider extends ChangeNotifier {
  // Seeded RNG for deterministic mock data during development.
  static final _rng = Random(42);

  // The 6 canonical habits mirrored from HomeProvider (same ids, names, colors).
  late final List<Habit> _habits;

  /// Index into [habitProgresses] for the currently viewed habit.
  int _selectedHabitIndex = 0;

  /// Per-habit rich progress objects (one per habit, same order as [_habits]).
  late List<HabitProgress> habitProgresses;

  /// Aggregated overview data.
  late OverviewStats overviewStats;

  /// Last submitted reflection difficulty per habitId (1–5 scale).
  final Map<String, int> reflections = {};

  ProgressProvider() {
    _habits = _mockHabits();
    habitProgresses = _buildHabitProgresses();
    overviewStats = _buildOverviewStats();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  int get selectedHabitIndex => _selectedHabitIndex;

  /// The [HabitProgress] currently shown on the Per-Habit tab.
  HabitProgress get selectedHabitProgress =>
      habitProgresses[_selectedHabitIndex];

  /// Expose habits for chip selector and other consumers.
  List<Habit> get habits => List.unmodifiable(_habits);

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Switch the active habit on the Per-Habit tab.
  void selectHabit(int index) {
    assert(index >= 0 && index < habitProgresses.length);
    if (_selectedHabitIndex == index) return;
    _selectedHabitIndex = index;
    notifyListeners();
  }

  /// Record a reflection for [habitId].
  ///
  /// [difficulty] is 1–5 (maps to ReflectionDifficulty.value).
  /// [note] is an optional free-text note.
  void submitReflection(String habitId, int difficulty, String? note) {
    assert(difficulty >= 1 && difficulty <= 5);
    reflections[habitId] = difficulty;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Mock data helpers
  // ---------------------------------------------------------------------------

  static List<Habit> _mockHabits() {
    return [
      Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: HabitColors.blue,
        iconName: 'code',
        trackingType: TrackingType.plugin,
        pluginName: 'LeetCode',
        streakDays: 23,
      ),
      Habit(
        id: '2',
        name: 'Exercise',
        subtitle: '30 min workout',
        color: HabitColors.lime,
        iconName: 'barbell',
        trackingType: TrackingType.manual,
        intensity: HabitIntensity.intense,
        streakDays: 12, // Foundation
      ),
      Habit(
        id: '3',
        name: 'Read',
        subtitle: 'Read 20 pages',
        color: HabitColors.amber,
        iconName: 'book-open',
        trackingType: TrackingType.manual,
        streakDays: 25, // Momentum
      ),
      Habit(
        id: '4',
        name: 'Meditate',
        subtitle: '10 min session',
        color: HabitColors.pink,
        iconName: 'brain',
        trackingType: TrackingType.manualPhoto,
        intensity: HabitIntensity.light,
        streakDays: 5, // Ignition
      ),
      Habit(
        id: '5',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: HabitColors.teal,
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
        streakDays: 7, // Ignition
      ),
      Habit(
        id: '6',
        name: 'Journal',
        subtitle: 'Write 1 entry',
        color: HabitColors.purple,
        iconName: 'pencil-simple',
        trackingType: TrackingType.manual,
        intensity: HabitIntensity.light,
        streakDays: 3, // Ignition
      ),
    ];
  }

  List<HabitProgress> _buildHabitProgresses() {
    return _habits.map((habit) => _progressFor(habit)).toList();
  }

  HabitProgress _progressFor(Habit habit) {
    // Base completion rate scales with streak — longer streaks = more disciplined.
    final baseRate = (habit.streakDays / 66.0).clamp(0.30, 0.92);

    // --- Heatmap (84 days = 12 weeks) ---
    final today = DateTime.now();
    final heatmap = <DateTime, int>{};
    for (int i = 83; i >= 0; i--) {
      final raw = today.subtract(Duration(days: i));
      final day = DateTime(raw.year, raw.month, raw.day);
      // Weekday bias: slight dip on weekends.
      final isWeekend = day.weekday >= DateTime.saturday;
      final rate = isWeekend ? baseRate * 0.75 : baseRate;
      heatmap[day] = _rng.nextDouble() < rate ? 1 : 0;
    }

    // --- Frequency by weekday (1=Mon … 7=Sun) ---
    final freqCompletions = <int, int>{};
    final freqTotal = <int, int>{};
    heatmap.forEach((day, done) {
      final wd = day.weekday;
      freqTotal[wd] = (freqTotal[wd] ?? 0) + 1;
      freqCompletions[wd] = (freqCompletions[wd] ?? 0) + done;
    });
    final frequencyByDay = <int, double>{};
    for (int wd = 1; wd <= 7; wd++) {
      final total = freqTotal[wd] ?? 0;
      final done = freqCompletions[wd] ?? 0;
      frequencyByDay[wd] = total == 0 ? 0.0 : done / total;
    }

    // --- Streak stats derived from heatmap ---
    final sortedDays = heatmap.keys.toList()..sort();
    int currentStreak = 0;
    int longestStreak = 0;
    int run = 0;
    for (final day in sortedDays) {
      if (heatmap[day] == 1) {
        run++;
        if (run > longestStreak) longestStreak = run;
      } else {
        run = 0;
      }
    }
    // Walk back from today for current streak.
    for (int i = sortedDays.length - 1; i >= 0; i--) {
      if (heatmap[sortedDays[i]] == 1) {
        currentStreak++;
      } else {
        break;
      }
    }
    // Honour the model's streakDays as the authoritative lower bound.
    currentStreak = max(currentStreak, habit.streakDays);
    longestStreak = max(longestStreak, currentStreak);

    final totalDaysCompleted = heatmap.values.fold(0, (s, v) => s + v);
    final completionRate = heatmap.isEmpty
        ? 0.0
        : totalDaysCompleted / heatmap.length;

    // --- Goal stage ---
    final goalStage = GoalStage.stageFor(currentStreak);
    final daysToNextStage = GoalStage.daysToNext(currentStreak);

    // --- Failure insights (only when enough data) ---
    final List<String> failureInsights = [];
    if (heatmap.length >= 14) {
      // Find the worst weekday.
      final worstWd = frequencyByDay.entries
          .reduce((a, b) => a.value <= b.value ? a : b)
          .key;
      const dayLabels = {
        1: 'Monday',
        2: 'Tuesday',
        3: 'Wednesday',
        4: 'Thursday',
        5: 'Friday',
        6: 'Saturday',
        7: 'Sunday',
      };
      final worstDay = dayLabels[worstWd] ?? 'that day';

      // PersonalityCopy-style: encouraging, never shaming.
      final insightTemplates = [
        'You tend to miss on $worstDay evenings. Try front-loading it earlier that day.',
        '$worstDay seems to be your trickiest day. A small prep the night before can change everything.',
        'Most of your misses land on $worstDay. No judgment — just awareness. You\'ve got this.',
        '$worstDay is your kryptonite. But knowing that? That\'s literally half the battle.',
      ];
      failureInsights.add(insightTemplates[_rng.nextInt(insightTemplates.length)]);

      // Mock reason breakdown copy.
      final reasons = [
        'Most common reason: No energy (45%)',
        'You\'re more likely to skip when you haven\'t prepped the night before.',
        'Evenings are tough for this one — morning might work better for you.',
      ];
      failureInsights.add(reasons[_rng.nextInt(reasons.length)]);
    }

    // Reflection unlocked at Foundation stage (10+ days).
    final reflectionUnlocked = goalStage != GoalStage.ignition;

    return HabitProgress(
      habitId: habit.id,
      habitName: habit.name,
      habitColor: habit.color,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      totalDaysCompleted: totalDaysCompleted,
      goalStage: goalStage,
      daysToNextStage: daysToNextStage,
      completionRate: completionRate,
      heatmapData: heatmap,
      frequencyByDay: frequencyByDay,
      failureInsights: failureInsights,
      reflectionUnlocked: reflectionUnlocked,
    );
  }

  OverviewStats _buildOverviewStats() {
    // Aggregate across all habit progresses.
    int totalCompleted = 0;
    int totalPossible = 0;
    int perfectDays = 0;
    int habitsGraduated = 0;

    for (final hp in habitProgresses) {
      totalCompleted += hp.totalDaysCompleted;
      totalPossible += hp.heatmapData.length;
      if (hp.goalStage == GoalStage.formed) habitsGraduated++;
    }

    final overallRate =
        totalPossible == 0 ? 0.0 : totalCompleted / totalPossible;

    // Count "perfect days" = days where all habits were completed.
    final today = DateTime.now();
    for (int i = 0; i < 84; i++) {
      final raw = today.subtract(Duration(days: i));
      final day = DateTime(raw.year, raw.month, raw.day);
      final allDone = habitProgresses.every(
        (hp) => (hp.heatmapData[day] ?? 0) == 1,
      );
      if (allDone) perfectDays++;
    }

    // --- Weekly completion data for chart (Mon–Sun this week) ---
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final weeklyCompletionData = <String, List<double>>{};
    for (final hp in habitProgresses) {
      final rates = <double>[];
      for (int d = 0; d < 7; d++) {
        final raw = monday.add(Duration(days: d));
        final day = DateTime(raw.year, raw.month, raw.day);
        rates.add((hp.heatmapData[day] ?? 0).toDouble());
      }
      weeklyCompletionData[hp.habitName] = rates;
    }

    // Current week rate.
    int weekDone = 0;
    int weekTotal = 0;
    for (int d = 0; d < 7; d++) {
      final raw = monday.add(Duration(days: d));
      final day = DateTime(raw.year, raw.month, raw.day);
      if (!day.isAfter(today)) {
        for (final hp in habitProgresses) {
          weekTotal++;
          weekDone += hp.heatmapData[day] ?? 0;
        }
      }
    }
    final currentWeekRate =
        weekTotal == 0 ? 0.0 : weekDone / weekTotal;

    // Mock: best week rate is the highest of (overall + 0.15) and current week.
    // This guarantees bestWeekRate >= currentWeekRate in all scenarios.
    final bestWeekRate =
        max(currentWeekRate, overallRate + 0.15).clamp(0.0, 1.0);

    // XP: 10 per completion, capped mock.
    final totalXP = min(totalCompleted * 10, 9999);

    // Rank thresholds (mock).
    const rankThresholds = [
      (0, 'Bronze', 500),
      (500, 'Silver', 1500),
      (1500, 'Gold', 3000),
      (3000, 'Platinum', 5000),
      (5000, 'Diamond', 10000),
    ];
    String currentRank = 'Bronze';
    int xpToNextRank = 500;
    int xpForNextRank = 500;
    for (final (min_, rank, next) in rankThresholds) {
      if (totalXP >= min_) {
        currentRank = rank;
        xpToNextRank = next - totalXP;
        xpForNextRank = next - min_;
      }
    }
    xpToNextRank = xpToNextRank.clamp(0, xpForNextRank);

    return OverviewStats(
      overallCompletionRate: overallRate,
      totalXP: totalXP,
      currentRank: currentRank,
      xpToNextRank: xpToNextRank,
      xpForNextRank: xpForNextRank,
      totalHabitsTracked: _habits.length,
      totalDaysCompleted: totalCompleted,
      perfectDays: perfectDays,
      habitsGraduated: habitsGraduated,
      bestWeekRate: bestWeekRate,
      currentWeekRate: currentWeekRate,
      weeklyCompletionData: weeklyCompletionData,
    );
  }
}
