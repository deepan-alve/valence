import 'package:flutter/material.dart';

/// Goal graduation stages based on consecutive completion days.
/// Ignition (3d) → Foundation (10d) → Momentum (21d) → Formed (66d).
enum GoalStage {
  ignition(3, 'Ignition', 'Just getting started'),
  foundation(10, 'Foundation', 'Building the base'),
  momentum(21, 'Momentum', 'It\'s becoming automatic'),
  formed(66, 'Formed', 'This is now part of you');

  final int targetDays;
  final String displayName;
  final String tagline;

  const GoalStage(this.targetDays, this.displayName, this.tagline);

  /// Returns the current stage for the given streak count.
  /// Stages are sequential: you are IN the stage once you exceed its threshold.
  static GoalStage stageFor(int days) {
    if (days >= formed.targetDays) return formed;
    if (days >= momentum.targetDays) return momentum;
    if (days >= foundation.targetDays) return foundation;
    return ignition;
  }

  /// Days remaining to the next stage, or 0 if already Formed.
  static int daysToNext(int days) {
    if (days >= formed.targetDays) return 0;
    if (days >= momentum.targetDays) return formed.targetDays - days;
    if (days >= foundation.targetDays) return momentum.targetDays - days;
    if (days >= ignition.targetDays) return foundation.targetDays - days;
    return ignition.targetDays - days;
  }

  /// Whether Foundation or beyond (gates evening reflection).
  static bool hasReachedFoundation(int days) =>
      days >= foundation.targetDays;
}

/// Per-habit progress data for the Progress screen.
///
/// [heatmapData] maps a normalized date (time cleared to midnight) to a
/// completion count: 0 = missed, 1 = completed.
///
/// [frequencyByDay] maps weekday index (1 = Mon … 7 = Sun) to a completion
/// rate 0.0–1.0 over the tracked window.
class HabitProgress {
  final String habitId;
  final String habitName;
  final Color habitColor;

  // Streak stats
  final int currentStreak;
  final int longestStreak;
  final int totalDaysCompleted;

  // Goal graduation
  final GoalStage goalStage;
  final int daysToNextStage;

  // Overall rate
  final double completionRate; // 0.0–1.0

  // Heatmap: day → 0 (missed) or 1 (completed), 84 days (12 weeks)
  final Map<DateTime, int> heatmapData;

  // Frequency by weekday: 1 (Mon)–7 (Sun) → rate 0.0–1.0
  final Map<int, double> frequencyByDay;

  // Failure insights (empty list = not enough data)
  final List<String> failureInsights;

  // Reflection gated behind Foundation stage
  final bool reflectionUnlocked;

  const HabitProgress({
    required this.habitId,
    required this.habitName,
    required this.habitColor,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalDaysCompleted,
    required this.goalStage,
    required this.daysToNextStage,
    required this.completionRate,
    required this.heatmapData,
    required this.frequencyByDay,
    required this.failureInsights,
    required this.reflectionUnlocked,
  });

  HabitProgress copyWith({
    String? habitId,
    String? habitName,
    Color? habitColor,
    int? currentStreak,
    int? longestStreak,
    int? totalDaysCompleted,
    GoalStage? goalStage,
    int? daysToNextStage,
    double? completionRate,
    Map<DateTime, int>? heatmapData,
    Map<int, double>? frequencyByDay,
    List<String>? failureInsights,
    bool? reflectionUnlocked,
  }) {
    return HabitProgress(
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      habitColor: habitColor ?? this.habitColor,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalDaysCompleted: totalDaysCompleted ?? this.totalDaysCompleted,
      goalStage: goalStage ?? this.goalStage,
      daysToNextStage: daysToNextStage ?? this.daysToNextStage,
      completionRate: completionRate ?? this.completionRate,
      heatmapData: heatmapData ?? this.heatmapData,
      frequencyByDay: frequencyByDay ?? this.frequencyByDay,
      failureInsights: failureInsights ?? this.failureInsights,
      reflectionUnlocked: reflectionUnlocked ?? this.reflectionUnlocked,
    );
  }
}
