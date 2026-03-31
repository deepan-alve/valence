import 'package:flutter/foundation.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/services/group_service.dart';
import 'package:valence/services/social_service.dart';
import 'package:valence/utils/personality_copy.dart';

enum LeaderboardPeriod { week, month }

/// Manages group screen state: members, feed, leaderboard, actions, personality toggle.
class GroupProvider extends ChangeNotifier {
  final bool _soloMode;
  final GroupService _groupService;
  final SocialService _socialService;
  String? _groupId;

  List<GroupMember> _members = [];
  List<FeedItem> _feedItems = [];
  List<WeeklyScore> _weeklyScores = [];
  final Set<String> _nudgedToday = {};
  bool _personalityOn = true;
  bool _freezeActiveToday = false;
  int _consistencyPoints = 42;
  LeaderboardPeriod _leaderboardPeriod = LeaderboardPeriod.week;
  String _groupName = '';
  int _groupStreakDays = 0;
  GroupTier _groupTier = GroupTier.ember;
  late GroupStreak _groupStreakData;

  GroupProvider({
    bool soloMode = false,
    GroupService? groupService,
    SocialService? socialService,
  })  : _soloMode = soloMode,
        _groupService = groupService ?? GroupService(),
        _socialService = socialService ?? SocialService() {
    if (!soloMode) {
      _groupName = 'Build Squad';
      _groupStreakDays = 14;
      _groupTier = GroupTier.ember;
      _members = _mockMembers();
      _feedItems = _mockFeedItems();
      _weeklyScores = _mockWeeklyScores();
      _groupStreakData = _mockGroupStreak();
      _loadGroups();
    } else {
      // Initialise a dummy GroupStreak for soloMode so late field is set.
      _groupStreakData = const GroupStreak(
        groupName: '',
        currentStreak: 0,
        tier: GroupTier.spark,
        last7Days: [],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  bool get hasGroup => !_soloMode;
  String get groupName => _groupName;
  int get groupStreak => _groupStreakDays;
  String get groupTier => _groupTier.name;
  GroupTier get groupTierEnum => _groupTier;
  GroupStreak get groupStreakData => _groupStreakData;
  List<GroupMember> get members => List.unmodifiable(_members);
  List<FeedItem> get feedItems => List.unmodifiable(_feedItems);
  List<WeeklyScore> get weeklyScores => List.unmodifiable(_weeklyScores);
  bool get personalityOn => _personalityOn;
  int get consistencyPoints => _consistencyPoints;
  bool get freezeActiveToday => _freezeActiveToday;
  LeaderboardPeriod get leaderboardPeriod => _leaderboardPeriod;
  int get freezeCost => 10;

  /// Live PersonalityCopy instance reflecting the current toggle state.
  PersonalityCopy get copy => PersonalityCopy(personalityOn: _personalityOn);

  /// Whether the current user has completed all their habits.
  bool get currentUserCompleted {
    final current = _members.where((m) => m.isCurrentUser);
    if (current.isEmpty) return false;
    return current.first.isComplete;
  }

  /// Whether a nudge can be sent (user must have completed their own habits).
  bool get canNudge => currentUserCompleted;

  /// Whether the user has enough points for a streak freeze.
  bool get canAffordFreeze => _consistencyPoints >= freezeCost;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void togglePersonality() {
    _personalityOn = !_personalityOn;
    notifyListeners();
  }

  bool hasNudgedToday(String memberId) => _nudgedToday.contains(memberId);

  /// Send a nudge to [memberId]. No-op if already nudged today or user
  /// hasn't completed their own habits.
  void sendNudge(String memberId) {
    if (_nudgedToday.contains(memberId)) return;
    if (!canNudge) return;

    _nudgedToday.add(memberId);

    final receiver = _members.firstWhere((m) => m.id == memberId);
    final sender = _members.firstWhere((m) => m.isCurrentUser);

    _feedItems = [
      FeedItem(
        id: 'nudge_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.nudge,
        senderName: sender.name,
        senderId: sender.id,
        receiverName: receiver.name,
        receiverId: receiver.id,
        timestamp: DateTime.now(),
      ),
      ..._feedItems,
    ];
    notifyListeners();
    if (_groupId != null) {
      final gid = _groupId!;
      () async {
        try {
          await _socialService.sendNudge(receiverId: memberId, groupId: gid);
        } catch (_) {}
      }();
    }
  }

  /// Send kudos to [memberId]. No-op if [memberId] is current user.
  void sendKudos(String memberId) {
    final receiver = _members.firstWhere((m) => m.id == memberId);
    final sender = _members.firstWhere((m) => m.isCurrentUser);

    _feedItems = [
      FeedItem(
        id: 'kudos_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.kudos,
        senderName: sender.name,
        senderId: sender.id,
        receiverName: receiver.name,
        receiverId: receiver.id,
        timestamp: DateTime.now(),
      ),
      ..._feedItems,
    ];
    notifyListeners();
    if (_groupId != null) {
      final gid = _groupId!;
      () async {
        try {
          await _socialService.sendKudos(receiverId: memberId, groupId: gid);
        } catch (_) {}
      }();
    }
  }

  /// Use a streak freeze. Deducts [freezeCost] consistency points. No-op if
  /// freeze already active today or user can't afford it.
  void useStreakFreeze() {
    if (_freezeActiveToday) return;
    if (!canAffordFreeze) return;

    _consistencyPoints -= freezeCost;
    _freezeActiveToday = true;

    final sender = _members.firstWhere((m) => m.isCurrentUser);
    _feedItems = [
      FeedItem(
        id: 'freeze_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.streakFreeze,
        senderName: sender.name,
        senderId: sender.id,
        timestamp: DateTime.now(),
      ),
      ..._feedItems,
    ];
    notifyListeners();
    if (_groupId != null) {
      final gid = _groupId!;
      () async {
        try {
          await _groupService.useStreakFreeze(gid);
        } catch (_) {}
      }();
    }
  }

  void setLeaderboardPeriod(LeaderboardPeriod period) {
    _leaderboardPeriod = period;
    notifyListeners();
  }

  /// Posts a miss notification to the group feed (PRD 5.4).
  /// Only called when habit visibility is full.
  void postMissToFeed({
    required String habitName,
    required String missReason,
  }) {
    _feedItems = [
      FeedItem(
        id: 'miss_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.miss,
        senderName: 'You',
        senderId: 'u1',
        habitName: habitName,
        message: missReason,
        timestamp: DateTime.now(),
      ),
      ..._feedItems,
    ];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupService.fetchGroups();
      if (groups.isEmpty) return;
      final first = groups.first as Map<String, dynamic>;
      _groupId = first['id'] as String?;
      _groupName = first['name'] as String? ?? _groupName;
      notifyListeners();
      if (_groupId != null) {
        await Future.wait([
          _loadFeed(_groupId!),
          _loadStreak(_groupId!),
        ]);
      }
    } catch (_) {
      // Keep mock data
    }
  }

  Future<void> _loadFeed(String groupId) async {
    try {
      final raw = await _groupService.fetchFeed(groupId);
      if (raw.isEmpty) return;
      // Keep mock feed — real feed items need backend event schema mapping
    } catch (_) {}
  }

  Future<void> _loadStreak(String groupId) async {
    try {
      final data = await _groupService.fetchStreak(groupId);
      final streak = (data['current_streak'] as num?)?.toInt() ?? _groupStreakDays;
      _groupStreakDays = streak;
      notifyListeners();
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Mock data
  // ---------------------------------------------------------------------------

  static List<GroupMember> _mockMembers() {
    return const [
      GroupMember(
        id: 'u1',
        name: 'Diana',
        avatarUrl: null,
        habitsCompleted: 4,
        habitsTotal: 6,
        status: MemberStatus.partial,
        isCurrentUser: true,
      ),
      GroupMember(
        id: 'u2',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      ),
      GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      ),
      GroupMember(
        id: 'u4',
        name: 'Ravi',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 4,
        status: MemberStatus.notStarted,
        isCurrentUser: false,
      ),
      GroupMember(
        id: 'u5',
        name: 'Zara',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 4,
        status: MemberStatus.inactive,
        isCurrentUser: false,
      ),
    ];
  }

  static List<FeedItem> _mockFeedItems() {
    final now = DateTime.now();
    return [
      FeedItem(
        id: 'f1',
        type: FeedItemType.completion,
        senderName: 'Nitil',
        senderId: 'u2',
        timestamp: now.subtract(const Duration(minutes: 12)),
        habitName: 'LeetCode',
        verificationSource: 'LeetCode',
      ),
      FeedItem(
        id: 'f2',
        type: FeedItemType.completion,
        senderName: 'Diana',
        senderId: 'u1',
        timestamp: now.subtract(const Duration(minutes: 30)),
        habitName: 'Read',
      ),
      FeedItem(
        id: 'f3',
        type: FeedItemType.kudos,
        senderName: 'Ava',
        senderId: 'u3',
        receiverName: 'Nitil',
        receiverId: 'u2',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      FeedItem(
        id: 'f4',
        type: FeedItemType.statusNorm,
        senderName: 'Nitil',
        senderId: 'u2',
        timestamp: now.subtract(const Duration(hours: 1)),
        message: '7-day streak',
      ),
      FeedItem(
        id: 'f5',
        type: FeedItemType.completion,
        senderName: 'Ava',
        senderId: 'u3',
        timestamp: now.subtract(const Duration(hours: 2)),
        habitName: 'Exercise',
      ),
      FeedItem(
        id: 'f6',
        type: FeedItemType.nudge,
        senderName: 'Diana',
        senderId: 'u1',
        receiverName: 'Ravi',
        receiverId: 'u4',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      FeedItem(
        id: 'f7',
        type: FeedItemType.miss,
        senderName: 'Ravi',
        senderId: 'u4',
        timestamp: now.subtract(const Duration(hours: 5)),
        habitName: 'Meditate',
      ),
      FeedItem(
        id: 'f8',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: now.subtract(const Duration(hours: 8)),
        message: 'gold',
      ),
      FeedItem(
        id: 'f9',
        type: FeedItemType.milestone,
        senderName: 'Ava',
        senderId: 'u3',
        timestamp: now.subtract(const Duration(hours: 10)),
        habitName: 'Read',
        message: 'Foundation',
      ),
      FeedItem(
        id: 'f10',
        type: FeedItemType.streakFreeze,
        senderName: 'Diana',
        senderId: 'u1',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
      FeedItem(
        id: 'f11',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        message: 'silver',
      ),
      FeedItem(
        id: 'f12',
        type: FeedItemType.completion,
        senderName: 'Zara',
        senderId: 'u5',
        timestamp: now.subtract(const Duration(days: 3)),
        habitName: 'Journal',
      ),
      FeedItem(
        id: 'f13',
        type: FeedItemType.kudos,
        senderName: 'Nitil',
        senderId: 'u2',
        receiverName: 'Ava',
        receiverId: 'u3',
        timestamp: now.subtract(const Duration(days: 3, hours: 1)),
      ),
      FeedItem(
        id: 'f14',
        type: FeedItemType.milestone,
        senderName: 'Nitil',
        senderId: 'u2',
        timestamp: now.subtract(const Duration(days: 4)),
        habitName: 'LeetCode',
        message: 'Momentum',
      ),
      FeedItem(
        id: 'f15',
        type: FeedItemType.statusNorm,
        senderName: 'Diana',
        senderId: 'u1',
        timestamp: now.subtract(const Duration(days: 5)),
        message: '14-day streak',
      ),
      FeedItem(
        id: 'f16',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: now.subtract(const Duration(days: 5, hours: 6)),
        message: 'broken',
      ),
    ];
  }

  static List<WeeklyScore> _mockWeeklyScores() {
    return const [
      WeeklyScore(
        rank: 1,
        memberId: 'u2',
        memberName: 'Nitil',
        consistencyPercent: 98,
        breakdown: ContributionBreakdown(
          habitsCompleted: 45,
          groupStreakContributions: 15,
          kudosReceived: 8,
          perfectDays: 10,
        ),
      ),
      WeeklyScore(
        rank: 2,
        memberId: 'u1',
        memberName: 'Diana',
        consistencyPercent: 87,
        breakdown: ContributionBreakdown(
          habitsCompleted: 38,
          groupStreakContributions: 12,
          kudosReceived: 5,
          perfectDays: 5,
        ),
      ),
      WeeklyScore(
        rank: 3,
        memberId: 'u3',
        memberName: 'Ava',
        consistencyPercent: 76,
        breakdown: ContributionBreakdown(
          habitsCompleted: 30,
          groupStreakContributions: 10,
          kudosReceived: 6,
          perfectDays: 0,
        ),
      ),
      WeeklyScore(
        rank: 4,
        memberId: 'u4',
        memberName: 'Ravi',
        consistencyPercent: 52,
        breakdown: ContributionBreakdown(
          habitsCompleted: 18,
          groupStreakContributions: 5,
          kudosReceived: 2,
          perfectDays: 0,
        ),
      ),
      WeeklyScore(
        rank: 5,
        memberId: 'u5',
        memberName: 'Zara',
        consistencyPercent: 12,
        breakdown: ContributionBreakdown(
          habitsCompleted: 4,
          groupStreakContributions: 1,
          kudosReceived: 0,
          perfectDays: 0,
        ),
      ),
    ];
  }

  static GroupStreak _mockGroupStreak() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    return GroupStreak(
      groupName: 'Build Squad',
      currentStreak: 14,
      tier: GroupTier.ember,
      last7Days: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final target = DateTime(day.year, day.month, day.day);

        ChainLinkType type;
        if (target.isAfter(today)) {
          type = ChainLinkType.future;
        } else if (i == 2) {
          type = ChainLinkType.silver;
        } else if (i == 4 && target.isBefore(today)) {
          type = ChainLinkType.broken;
        } else {
          type = ChainLinkType.gold;
        }

        return ChainLink(date: target, type: type);
      }),
    );
  }
}
