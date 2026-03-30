/// Breakdown of how a member's contribution score was calculated.
/// Shown when tapping a leaderboard row to expand it.
class ContributionBreakdown {
  /// Points from habits completed (e.g. 9 habits x 5 days = 45).
  final int habitsCompleted;

  /// Points from being present for gold/silver chain links.
  final int groupStreakContributions;

  /// Points from kudos received from other members.
  final int kudosReceived;

  /// Bonus points from perfect days (all habits done).
  final int perfectDays;

  const ContributionBreakdown({
    required this.habitsCompleted,
    required this.groupStreakContributions,
    required this.kudosReceived,
    required this.perfectDays,
  });

  /// Sum of all contribution categories.
  int get totalPoints =>
      habitsCompleted + groupStreakContributions + kudosReceived + perfectDays;
}

/// A single row in the weekly leaderboard.
/// Primary metric is % of personal baseline (not raw score).
class WeeklyScore {
  final int rank;
  final String memberId;
  final String memberName;

  /// Consistency as percentage of the member's own historical baseline.
  /// A beginner doing 3/3 (100%) ranks equally with an expert doing 8/8 (100%).
  final int consistencyPercent;

  /// Whether this rank is shared with another member (tied).
  final bool isTied;

  /// Detailed contribution breakdown, shown on row expansion.
  final ContributionBreakdown breakdown;

  const WeeklyScore({
    required this.rank,
    required this.memberId,
    required this.memberName,
    required this.consistencyPercent,
    this.isTied = false,
    required this.breakdown,
  });

  /// Formatted percentage label.
  String get consistencyLabel => '$consistencyPercent%';
}
