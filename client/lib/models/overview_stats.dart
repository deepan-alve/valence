/// Aggregated stats across all habits for the Overview tab of the Progress screen.
///
/// [weeklyCompletionData] maps habit name to a list of 7 daily completion
/// rates (0.0–1.0, Mon–Sun) for the stacked/grouped bar chart.
class OverviewStats {
  /// 0.0–1.0 across all habits and all tracked days.
  final double overallCompletionRate;

  // XP and rank
  final int totalXP;
  final String currentRank;
  final int xpToNextRank;
  final int xpForNextRank;

  // Counts
  final int totalHabitsTracked;
  final int totalDaysCompleted;
  final int perfectDays;
  final int habitsGraduated;

  // Week comparison
  final double bestWeekRate;
  final double currentWeekRate;

  /// habitName → list of 7 daily rates (Mon–Sun) for chart rendering.
  final Map<String, List<double>> weeklyCompletionData;

  const OverviewStats({
    required this.overallCompletionRate,
    required this.totalXP,
    required this.currentRank,
    required this.xpToNextRank,
    required this.xpForNextRank,
    required this.totalHabitsTracked,
    required this.totalDaysCompleted,
    required this.perfectDays,
    required this.habitsGraduated,
    required this.bestWeekRate,
    required this.currentWeekRate,
    required this.weeklyCompletionData,
  });

  /// Fraction of XP progress toward the next rank, clamped 0.0–1.0.
  double get rankProgress {
    if (xpForNextRank <= 0) return 1.0;
    return ((xpForNextRank - xpToNextRank) / xpForNextRank).clamp(0.0, 1.0);
  }

  OverviewStats copyWith({
    double? overallCompletionRate,
    int? totalXP,
    String? currentRank,
    int? xpToNextRank,
    int? xpForNextRank,
    int? totalHabitsTracked,
    int? totalDaysCompleted,
    int? perfectDays,
    int? habitsGraduated,
    double? bestWeekRate,
    double? currentWeekRate,
    Map<String, List<double>>? weeklyCompletionData,
  }) {
    return OverviewStats(
      overallCompletionRate: overallCompletionRate ?? this.overallCompletionRate,
      totalXP: totalXP ?? this.totalXP,
      currentRank: currentRank ?? this.currentRank,
      xpToNextRank: xpToNextRank ?? this.xpToNextRank,
      xpForNextRank: xpForNextRank ?? this.xpForNextRank,
      totalHabitsTracked: totalHabitsTracked ?? this.totalHabitsTracked,
      totalDaysCompleted: totalDaysCompleted ?? this.totalDaysCompleted,
      perfectDays: perfectDays ?? this.perfectDays,
      habitsGraduated: habitsGraduated ?? this.habitsGraduated,
      bestWeekRate: bestWeekRate ?? this.bestWeekRate,
      currentWeekRate: currentWeekRate ?? this.currentWeekRate,
      weeklyCompletionData: weeklyCompletionData ?? this.weeklyCompletionData,
    );
  }
}
