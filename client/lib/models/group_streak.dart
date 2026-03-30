import 'package:valence/models/habit.dart';

/// A single day's chain link in the group streak.
class ChainLink {
  final DateTime date;
  final ChainLinkType type;

  const ChainLink({
    required this.date,
    required this.type,
  });
}

/// Group streak data displayed on the Home screen chain strip.
class GroupStreak {
  final String groupName;
  final int currentStreak;
  final GroupTier tier;
  final List<ChainLink> last7Days;

  const GroupStreak({
    required this.groupName,
    required this.currentStreak,
    required this.tier,
    required this.last7Days,
  });
}
