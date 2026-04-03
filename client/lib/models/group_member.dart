/// Status of a group member for the current day.
enum MemberStatus {
  /// All habits completed today.
  allDone,

  /// Some habits completed today.
  partial,

  /// No habits started today.
  notStarted,

  /// 3+ consecutive days of zero activity — auto-excluded from group %.
  inactive,
}

/// A single member displayed in the group screen member grid.
class GroupMember {
  final String id;
  final String name;
  final String? avatarUrl;
  final int habitsCompleted;
  final int habitsTotal;
  final MemberStatus status;
  final bool isCurrentUser;

  const GroupMember({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.habitsCompleted,
    required this.habitsTotal,
    required this.status,
    required this.isCurrentUser,
  });

  /// First 1–2 characters of the name, uppercased.
  String get initials {
    if (name.isEmpty) return '?';
    if (name.length == 1) return name.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  /// Whether all habits are completed today.
  bool get isComplete => habitsCompleted >= habitsTotal && habitsTotal > 0;

  /// Fraction label like "3/5" for the badge on partial members.
  String get progressLabel => '$habitsCompleted/$habitsTotal';

  GroupMember copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    int? habitsCompleted,
    int? habitsTotal,
    MemberStatus? status,
    bool? isCurrentUser,
  }) {
    return GroupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      habitsCompleted: habitsCompleted ?? this.habitsCompleted,
      habitsTotal: habitsTotal ?? this.habitsTotal,
      status: status ?? this.status,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
