# Phase 4: Group Screen --- Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Group Screen (Tab 1 in MainShell) with a personality-first group feed, member status grid with per-member nudge/kudos actions, weekly leaderboard with contribution score breakdown, streak freeze flow, group management, and solo mode empty state --- replacing the current placeholder. The Group screen is where personality shines most: "It feels like a group chat, not a clinical tool."

**Architecture:** A `GroupProvider` (ChangeNotifier) manages group membership, feed items, leaderboard data, personality toggle state, nudge/kudos actions, and streak freeze state using mock data. A `PersonalityCopy` utility centralizes all personality-toggle-aware string generation. The screen composes seven key sections: header with tier badge, member status grid (horizontal scroll with avatar rings), action bar (streak freeze + invite), group feed timeline (8 feed item types), weekly leaderboard with expandable contribution breakdown, and solo mode empty state. All colors come from `context.tokens` with zero hardcoded values.

**Tech Stack:** Flutter, Provider, Phosphor Icons (`phosphor_flutter`), Google Fonts (`google_fonts`)

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` --- Sections 2.2 (Group Screen), 2.8 (Nudge Flow), 2.12 (Solo Mode UX), 2.18 (Group Tier-Up), 2.20 (Streak Freeze), 2.21 (Group Management), 2.24 (Personality Layer), 2.30 (Contribution Score Breakdown)

---

## File Map

```
client/lib/
├── models/
│   ├── feed_item.dart                         # FeedItem model with 8 type enum
│   ├── group_member.dart                      # GroupMember model with status
│   └── weekly_score.dart                      # WeeklyScore + ContributionBreakdown
├── utils/
│   └── personality_copy.dart                  # Personality toggle ON/OFF string pairs
├── providers/
│   └── group_provider.dart                    # GroupProvider with all mock data
├── screens/
│   └── group/
│       └── group_screen.dart                  # REPLACE: Full group screen layout
├── widgets/
│   └── group/
│       ├── member_avatar.dart                 # Single member avatar with status ring
│       ├── member_grid.dart                   # Horizontal scroll of MemberAvatars
│       ├── feed_item_card.dart                # 8-variant feed timeline card
│       ├── group_header.dart                  # Group name + tier badge + streak + invite
│       ├── weekly_leaderboard.dart            # Leaderboard with expandable rows
│       ├── nudge_sheet.dart                   # Nudge confirmation bottom sheet
│       ├── streak_freeze_sheet.dart           # Streak freeze confirmation bottom sheet
│       └── solo_empty_state.dart              # Solo mode empty state

client/test/
├── models/
│   ├── feed_item_test.dart
│   ├── group_member_test.dart
│   └── weekly_score_test.dart
├── utils/
│   └── personality_copy_test.dart
├── providers/
│   └── group_provider_test.dart
└── widgets/
    └── group/
        ├── member_avatar_test.dart
        ├── feed_item_card_test.dart
        └── weekly_leaderboard_test.dart
```

---

### Task 1: Create the GroupMember model

**Files:**
- Create: `client/lib/models/group_member.dart`
- Create: `client/test/models/group_member_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/models/group_member_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/group_member.dart';

void main() {
  group('MemberStatus', () {
    test('all values exist', () {
      expect(MemberStatus.values.length, 4);
      expect(MemberStatus.values, contains(MemberStatus.allDone));
      expect(MemberStatus.values, contains(MemberStatus.partial));
      expect(MemberStatus.values, contains(MemberStatus.notStarted));
      expect(MemberStatus.values, contains(MemberStatus.inactive));
    });
  });

  group('GroupMember', () {
    test('constructs with required fields', () {
      final member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      );

      expect(member.id, 'u1');
      expect(member.name, 'Nitil');
      expect(member.habitsCompleted, 5);
      expect(member.status, MemberStatus.allDone);
    });

    test('initials returns first two characters of name', () {
      final member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      );

      expect(member.initials, 'NI');
    });

    test('initials handles single-char names', () {
      final member = GroupMember(
        id: 'u2',
        name: 'X',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 3,
        status: MemberStatus.notStarted,
        isCurrentUser: false,
      );

      expect(member.initials, 'X');
    });

    test('isComplete returns true when all habits done', () {
      final member = GroupMember(
        id: 'u1',
        name: 'Diana',
        avatarUrl: null,
        habitsCompleted: 6,
        habitsTotal: 6,
        status: MemberStatus.allDone,
        isCurrentUser: true,
      );

      expect(member.isComplete, isTrue);
    });

    test('isComplete returns false when partial', () {
      final member = GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      expect(member.isComplete, isFalse);
    });

    test('progressLabel returns fraction string', () {
      final member = GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      expect(member.progressLabel, '3/5');
    });

    test('copyWith overrides specified fields', () {
      final member = GroupMember(
        id: 'u1',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      );

      final updated = member.copyWith(
        habitsCompleted: 5,
        status: MemberStatus.allDone,
      );

      expect(updated.habitsCompleted, 5);
      expect(updated.status, MemberStatus.allDone);
      expect(updated.name, 'Nitil'); // unchanged
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/models/group_member_test.dart
```

Expected: FAIL --- `package:valence/models/group_member.dart` not found.

- [ ] **Step 3: Write the GroupMember model**

```dart
// client/lib/models/group_member.dart

/// Status of a group member for the current day.
enum MemberStatus {
  /// All habits completed today.
  allDone,

  /// Some habits completed today.
  partial,

  /// No habits started today.
  notStarted,

  /// 3+ consecutive days of zero activity --- auto-excluded from group %.
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

  /// First 1-2 characters of the name, uppercased.
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/models/group_member_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/models/group_member.dart client/test/models/group_member_test.dart
git commit -m "feat: add GroupMember model with MemberStatus enum for group screen member grid"
```

---

### Task 2: Create the FeedItem model

**Files:**
- Create: `client/lib/models/feed_item.dart`
- Create: `client/test/models/feed_item_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/models/feed_item_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';

void main() {
  group('FeedItemType', () {
    test('all 8 values exist', () {
      expect(FeedItemType.values.length, 8);
      expect(FeedItemType.values, contains(FeedItemType.completion));
      expect(FeedItemType.values, contains(FeedItemType.miss));
      expect(FeedItemType.values, contains(FeedItemType.nudge));
      expect(FeedItemType.values, contains(FeedItemType.kudos));
      expect(FeedItemType.values, contains(FeedItemType.statusNorm));
      expect(FeedItemType.values, contains(FeedItemType.chainLink));
      expect(FeedItemType.values, contains(FeedItemType.milestone));
      expect(FeedItemType.values, contains(FeedItemType.streakFreeze));
    });
  });

  group('FeedItem', () {
    test('constructs a completion feed item', () {
      final item = FeedItem(
        id: 'f1',
        type: FeedItemType.completion,
        senderName: 'Nitil',
        senderId: 'u1',
        timestamp: DateTime(2026, 3, 30, 14, 30),
        habitName: 'LeetCode',
        verificationSource: 'LeetCode',
      );

      expect(item.type, FeedItemType.completion);
      expect(item.senderName, 'Nitil');
      expect(item.habitName, 'LeetCode');
      expect(item.verificationSource, 'LeetCode');
    });

    test('constructs a nudge feed item with receiver', () {
      final item = FeedItem(
        id: 'f2',
        type: FeedItemType.nudge,
        senderName: 'Diana',
        senderId: 'u2',
        receiverName: 'Ava',
        receiverId: 'u3',
        timestamp: DateTime(2026, 3, 30, 15, 0),
      );

      expect(item.type, FeedItemType.nudge);
      expect(item.senderName, 'Diana');
      expect(item.receiverName, 'Ava');
    });

    test('constructs a chain link feed item with message', () {
      final item = FeedItem(
        id: 'f3',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: DateTime(2026, 3, 30, 23, 0),
        message: 'Gold! Everyone showed up.',
      );

      expect(item.type, FeedItemType.chainLink);
      expect(item.message, contains('Gold'));
    });

    test('constructs a miss item (supportive, never punitive)', () {
      final item = FeedItem(
        id: 'f4',
        type: FeedItemType.miss,
        senderName: 'Ava',
        senderId: 'u3',
        timestamp: DateTime(2026, 3, 29, 22, 0),
        habitName: 'Exercise',
      );

      expect(item.type, FeedItemType.miss);
      expect(item.habitName, 'Exercise');
    });

    test('timeAgo returns a relative time string', () {
      final now = DateTime.now();
      final item = FeedItem(
        id: 'f5',
        type: FeedItemType.kudos,
        senderName: 'Nitil',
        senderId: 'u1',
        receiverName: 'Diana',
        receiverId: 'u2',
        timestamp: now.subtract(const Duration(minutes: 5)),
      );

      expect(item.timeAgo, contains('min'));
    });

    test('timeAgo handles hours', () {
      final now = DateTime.now();
      final item = FeedItem(
        id: 'f6',
        type: FeedItemType.completion,
        senderName: 'Ravi',
        senderId: 'u4',
        timestamp: now.subtract(const Duration(hours: 3)),
        habitName: 'Read',
      );

      expect(item.timeAgo, contains('h'));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/models/feed_item_test.dart
```

Expected: FAIL --- `package:valence/models/feed_item.dart` not found.

- [ ] **Step 3: Write the FeedItem model**

```dart
// client/lib/models/feed_item.dart

/// The 8 types of events that appear in the group feed timeline.
enum FeedItemType {
  /// A member completed a habit. May include plugin verification badge.
  completion,

  /// A member missed a habit. Framing is always supportive, never punitive.
  /// Only shown for habits with Full visibility.
  miss,

  /// A member nudged another member. The actual LLM-generated message is
  /// private --- the feed only shows that a nudge was sent.
  nudge,

  /// A member sent kudos to another member.
  kudos,

  /// A status+norm message (e.g. streak milestone + group norm).
  statusNorm,

  /// End-of-day chain link result (Gold/Silver/Broken).
  chainLink,

  /// A habit reached a goal graduation milestone (Foundation, Momentum, etc.).
  milestone,

  /// A member used a streak freeze to protect the chain.
  streakFreeze,
}

/// A single event in the group feed timeline.
class FeedItem {
  final String id;
  final FeedItemType type;
  final String senderName;
  final String senderId;
  final String? receiverName;
  final String? receiverId;
  final DateTime timestamp;
  final String? habitName;
  final String? verificationSource;
  final String? message;

  const FeedItem({
    required this.id,
    required this.type,
    required this.senderName,
    required this.senderId,
    this.receiverName,
    this.receiverId,
    required this.timestamp,
    this.habitName,
    this.verificationSource,
    this.message,
  });

  /// Relative time label: "2m", "3h", "1d", "3d".
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/models/feed_item_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/models/feed_item.dart client/test/models/feed_item_test.dart
git commit -m "feat: add FeedItem model with 8-type enum for group feed timeline"
```

---

### Task 3: Create the WeeklyScore model

**Files:**
- Create: `client/lib/models/weekly_score.dart`
- Create: `client/test/models/weekly_score_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/models/weekly_score_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/weekly_score.dart';

void main() {
  group('ContributionBreakdown', () {
    test('totalPoints sums all categories', () {
      final breakdown = ContributionBreakdown(
        habitsCompleted: 45,
        groupStreakContributions: 15,
        kudosReceived: 8,
        perfectDays: 10,
      );

      expect(breakdown.totalPoints, 78);
    });
  });

  group('WeeklyScore', () {
    test('constructs with required fields', () {
      final score = WeeklyScore(
        rank: 1,
        memberId: 'u1',
        memberName: 'Nitil',
        consistencyPercent: 95,
        breakdown: const ContributionBreakdown(
          habitsCompleted: 45,
          groupStreakContributions: 15,
          kudosReceived: 8,
          perfectDays: 10,
        ),
      );

      expect(score.rank, 1);
      expect(score.memberName, 'Nitil');
      expect(score.consistencyPercent, 95);
      expect(score.breakdown.totalPoints, 78);
    });

    test('consistencyLabel returns percentage string', () {
      final score = WeeklyScore(
        rank: 2,
        memberId: 'u2',
        memberName: 'Diana',
        consistencyPercent: 87,
        breakdown: const ContributionBreakdown(
          habitsCompleted: 30,
          groupStreakContributions: 10,
          kudosReceived: 5,
          perfectDays: 5,
        ),
      );

      expect(score.consistencyLabel, '87%');
    });

    test('isTied flag works', () {
      final score = WeeklyScore(
        rank: 1,
        memberId: 'u3',
        memberName: 'Ava',
        consistencyPercent: 95,
        isTied: true,
        breakdown: const ContributionBreakdown(
          habitsCompleted: 42,
          groupStreakContributions: 15,
          kudosReceived: 10,
          perfectDays: 10,
        ),
      );

      expect(score.isTied, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/models/weekly_score_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the WeeklyScore model**

```dart
// client/lib/models/weekly_score.dart

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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/models/weekly_score_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/models/weekly_score.dart client/test/models/weekly_score_test.dart
git commit -m "feat: add WeeklyScore and ContributionBreakdown models for group leaderboard"
```

---

### Task 4: Create the PersonalityCopy utility

This is the soul of the Group screen. Every piece of text runs through this utility. When personality is ON, the app feels like a college friend group chat. When OFF, it is clean and informational.

**Files:**
- Create: `client/lib/utils/personality_copy.dart`
- Create: `client/test/utils/personality_copy_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/utils/personality_copy_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/utils/personality_copy.dart';

void main() {
  group('PersonalityCopy — personality ON', () {
    const copy = PersonalityCopy(personalityOn: true);

    test('completion message is witty', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode');
      // Should contain the name and be fun, not clinical
      expect(msg, contains('Nitil'));
      expect(msg.length, greaterThan(10));
    });

    test('completion with plugin shows verification flavor', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode', plugin: 'LeetCode');
      expect(msg, contains('Nitil'));
    });

    test('miss message is supportive and never punitive', () {
      final msg = copy.missMessage('Ava', 'Exercise');
      expect(msg, contains('Ava'));
      // Must not contain shaming words
      expect(msg.toLowerCase(), isNot(contains('failed')));
      expect(msg.toLowerCase(), isNot(contains('lazy')));
      expect(msg.toLowerCase(), isNot(contains('disappointed')));
    });

    test('nudge message is playful', () {
      final msg = copy.nudgeFeedMessage('Diana', 'Ravi');
      expect(msg, contains('Diana'));
      expect(msg, contains('Ravi'));
    });

    test('kudos message is fun', () {
      final msg = copy.kudosFeedMessage('Nitil', 'Diana');
      expect(msg, contains('Nitil'));
      expect(msg, contains('Diana'));
    });

    test('streak norm message is hype', () {
      final msg = copy.statusNormMessage('Nitil', 7);
      expect(msg, contains('Nitil'));
      expect(msg, contains('7'));
    });

    test('chain link gold message is celebratory', () {
      final msg = copy.chainLinkMessage('gold', 5, 5);
      expect(msg.toLowerCase(), contains('gold'));
    });

    test('chain link broken message is empathetic', () {
      final msg = copy.chainLinkMessage('broken', 2, 5);
      expect(msg.toLowerCase(), contains('broken'));
    });

    test('milestone message is exciting', () {
      final msg = copy.milestoneMessage('Ava', 'Read', 'Foundation', 10);
      expect(msg, contains('Ava'));
      expect(msg, contains('10'));
    });

    test('streak freeze message is contextual', () {
      final msg = copy.streakFreezeMessage('Ravi');
      expect(msg, contains('Ravi'));
    });

    test('completion toast is fun and varied', () {
      final toasts = List.generate(20, (_) => copy.completionToast());
      // Should have variety (not all the same)
      expect(toasts.toSet().length, greaterThan(1));
    });

    test('empty state group is playful', () {
      final msg = copy.emptyStateGroupTitle;
      expect(msg, isNotEmpty);
    });

    test('empty state group body is playful', () {
      final msg = copy.emptyStateGroupBody;
      expect(msg, isNotEmpty);
    });
  });

  group('PersonalityCopy — personality OFF', () {
    const copy = PersonalityCopy(personalityOn: false);

    test('completion message is neutral', () {
      final msg = copy.completionMessage('Nitil', 'LeetCode');
      expect(msg, contains('Nitil'));
      expect(msg, contains('LeetCode'));
      // Should be factual, not playful
      expect(msg, contains('completed'));
    });

    test('miss message is neutral and supportive', () {
      final msg = copy.missMessage('Ava', 'Exercise');
      expect(msg, contains('Ava'));
      expect(msg.toLowerCase(), isNot(contains('failed')));
    });

    test('completion toast is simple', () {
      final toast = copy.completionToast();
      expect(toast, 'Habit completed');
    });

    test('empty state group is straightforward', () {
      final msg = copy.emptyStateGroupTitle;
      expect(msg, isNotEmpty);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/utils/personality_copy_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the PersonalityCopy utility**

```dart
// client/lib/utils/personality_copy.dart
import 'dart:math';

/// Centralizes all personality-toggle-aware copy for the Group screen.
///
/// When personality is ON (default): WhatsApp group chat energy ---
/// witty, supportive, the kind of messages a college friend would send.
/// When personality is OFF: clean, informational, zero fluff.
///
/// NEVER shaming. NEVER punitive. Even "miss" events are supportive.
class PersonalityCopy {
  final bool personalityOn;

  const PersonalityCopy({required this.personalityOn});

  static final _random = Random();

  // ---------------------------------------------------------------------------
  // Feed messages
  // ---------------------------------------------------------------------------

  /// Completion event in the feed.
  String completionMessage(String name, String habitName, {String? plugin}) {
    if (!personalityOn) {
      final suffix = plugin != null ? ' (verified via $plugin)' : '';
      return '$name completed $habitName$suffix';
    }

    final templates = [
      '$name just crushed $habitName. Respect. 🫡',
      '$name knocked out $habitName like it was nothing',
      '$name is LOCKED IN --- $habitName done ✅',
      'Another one. $name x $habitName. You already know. 🔥',
      '$name said "$habitName? Easy." and meant it',
      '$name checked off $habitName before most people check their phone',
      '$habitName? Handled. $name doesn\'t miss. 💪',
      '$name just did $habitName. That\'s called showing up.',
    ];
    final msg = templates[_random.nextInt(templates.length)];
    if (plugin != null) {
      return '$msg  ·  verified via $plugin';
    }
    return msg;
  }

  /// Miss event in the feed. ALWAYS supportive, NEVER shaming.
  String missMessage(String name, String habitName) {
    if (!personalityOn) {
      return '$name missed $habitName today. Send some support?';
    }

    final templates = [
      '$name had a rough one with $habitName. We all have those days --- drop a kudos? 💛',
      'Off day for $name on $habitName. Rest is part of the process. Send love?',
      '$name took an L on $habitName today but we don\'t judge here. Support?',
      '$habitName didn\'t happen for $name today. Tomorrow is a reset. 🤍',
      '$name missed $habitName but honestly? Consistency > perfection. Send a vibe?',
      'No $habitName from $name today. It happens. They\'ll bounce back. 💪',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Nudge event in the feed. The actual LLM message is private ---
  /// the feed only reveals that a nudge happened.
  String nudgeFeedMessage(String senderName, String receiverName) {
    if (!personalityOn) {
      return '$senderName nudged $receiverName';
    }

    final templates = [
      '$senderName just gave $receiverName the look 👀💪',
      '$senderName nudged $receiverName. Accountability hits different.',
      '$senderName said "yo $receiverName, we need you" 💬',
      '$senderName → $receiverName: gentle push incoming 🫳',
      '$receiverName just got the friendliest nudge from $senderName 🤝',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Kudos event in the feed.
  String kudosFeedMessage(String senderName, String receiverName) {
    if (!personalityOn) {
      return '$senderName sent kudos to $receiverName';
    }

    final templates = [
      '$senderName is hyping up $receiverName rn 🔥',
      '$senderName → $receiverName: absolute legend status confirmed',
      '$senderName gave $receiverName their flowers 💐',
      '$receiverName is getting the recognition they deserve from $senderName',
      '$senderName said "$receiverName, you\'re different." 👏',
      '$senderName just threw $receiverName some major props 🙌',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Status+Norm message (streak milestone + group comparison).
  String statusNormMessage(String name, int streakDays) {
    if (!personalityOn) {
      return '$name reached a $streakDays-day streak. Most of the group is staying consistent this week.';
    }

    final templates = [
      '$name is COOKING 🔥 $streakDays-day streak! Most of y\'all are keeping up too. Squad goals.',
      '$streakDays days straight for $name. That\'s not luck, that\'s discipline. The rest of the group is vibing too 📈',
      'Yo $name is on a $streakDays-day tear and honestly the whole group is eating rn 🍽️',
      '$name: $streakDays days. No breaks. The group energy is immaculate this week.',
      '$streakDays-day streak from $name! And the group? Also crushing it. We love to see it. 🫶',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  /// Chain link result at end of day.
  String chainLinkMessage(String linkType, int completed, int total) {
    if (!personalityOn) {
      switch (linkType.toLowerCase()) {
        case 'gold':
          return 'Today\'s link: Gold. All $total members completed.';
        case 'silver':
          return 'Today\'s link: Silver. $completed/$total completed.';
        case 'broken':
          return 'Chain broken today. $completed/$total completed.';
        default:
          return 'Chain link update: $completed/$total completed.';
      }
    }

    switch (linkType.toLowerCase()) {
      case 'gold':
        return 'Today\'s link: 🥇 GOLD! Every single person showed up. $total/$total. We are HIM. 🔥';
      case 'silver':
        final templates = [
          'Silver link today --- $completed/$total pulled through. So close to gold. Tomorrow? 💪',
          '$completed/$total ain\'t bad. Silver link earned. Gold is RIGHT THERE though. 🥈',
        ];
        return templates[_random.nextInt(templates.length)];
      case 'broken':
        final templates = [
          'Chain broke today. $completed/$total. It stings but we reset tomorrow. Together. 🤝',
          'Broken link. $completed/$total. We\'ve bounced back before and we will again. 💪',
        ];
        return templates[_random.nextInt(templates.length)];
      default:
        return 'Chain update: $completed/$total completed.';
    }
  }

  /// Milestone: a habit reached a goal graduation stage.
  String milestoneMessage(String name, String habitName, String stage, int days) {
    if (!personalityOn) {
      return '$name\'s $habitName reached $stage ($days days).';
    }

    final templates = {
      'Ignition': [
        '$name just lit the fuse on $habitName --- $days days in! Ignition unlocked 🚀',
        '$habitName is officially a thing for $name. $days days. Ignition. 🔥',
      ],
      'Foundation': [
        '$name hit Foundation on $habitName. $days days. This is where it gets real. 🧱',
        '$days days of $habitName from $name. Foundation locked in. Building something fr. 💪',
      ],
      'Momentum': [
        '$days DAYS. $name\'s $habitName hit Momentum. Unstoppable energy. 🌊',
        '$name x $habitName = $days days of Momentum. This is not a drill. 📈',
      ],
      'Formed': [
        '$name GRADUATED $habitName at $days days. That\'s a whole identity shift. 🎓🔥',
        'SIXTY-SIX DAYS. $name\'s $habitName is now part of their DNA. Formed. 🏆',
      ],
    };

    final stageTemplates = templates[stage] ?? [
      '$name\'s $habitName reached $stage at $days days!'
    ];
    return stageTemplates[_random.nextInt(stageTemplates.length)];
  }

  /// Streak freeze used.
  String streakFreezeMessage(String name) {
    if (!personalityOn) {
      return '$name used a streak freeze to protect the chain.';
    }

    final templates = [
      '$name activated the streak freeze. Chain protected. Smart move ❄️🛡️',
      '$name pulled out the freeze card. The streak lives another day. ❄️',
      'Streak freeze deployed by $name. Crisis averted. The chain is safe. 🧊',
      '$name said "not today, broken chain" and used a streak freeze ❄️💪',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  // ---------------------------------------------------------------------------
  // Toasts
  // ---------------------------------------------------------------------------

  /// Toast shown when user completes a habit on the Group screen.
  String completionToast() {
    if (!personalityOn) return 'Habit completed';

    final templates = [
      'Beast mode activated 🔥',
      'One more in the bag 💰',
      'That\'s how it\'s done 💪',
      'You\'re different. Fr. 🫡',
      'No days off mentality 📈',
      'Stack those W\'s 🏆',
      'Built different ✅',
      'Another one 🔑',
      'Lock in era continues 🔒',
      'Main character energy 🎬',
    ];
    return templates[_random.nextInt(templates.length)];
  }

  // ---------------------------------------------------------------------------
  // Empty states
  // ---------------------------------------------------------------------------

  /// Solo mode empty state: title.
  String get emptyStateGroupTitle {
    if (!personalityOn) return 'No group yet';
    return 'Your habits are lonely. Give them friends.';
  }

  /// Solo mode empty state: body.
  String get emptyStateGroupBody {
    if (!personalityOn) {
      return 'Create or join a group of 2-6 friends to track habits together.';
    }
    return 'Habits hit different when your whole squad is grinding together. Create a crew or jump into one.';
  }

  /// Solo mode social proof line.
  String get emptyStateSocialProof {
    if (!personalityOn) {
      return 'Groups with 4+ members have 3x better retention.';
    }
    return 'Groups with 4+ people are literally 3x more likely to stick with it. Just saying. 📊';
  }

  // ---------------------------------------------------------------------------
  // Nudge sheet
  // ---------------------------------------------------------------------------

  /// Nudge confirmation title.
  String nudgeSheetTitle(String receiverName) {
    if (!personalityOn) return 'Nudge $receiverName?';
    return 'Give $receiverName a friendly push? 🫳';
  }

  /// Nudge confirmation body.
  String nudgeSheetBody(String receiverName) {
    if (!personalityOn) {
      return 'An AI-generated motivational message will be sent privately to $receiverName.';
    }
    return 'We\'ll craft a personalized message for $receiverName. They\'ll only see it in their notifications --- no one else will know what it says. 🤫';
  }

  /// Toast after sending a nudge.
  String nudgeSentToast(String receiverName) {
    if (!personalityOn) return 'Nudge sent to $receiverName';
    return 'Nudge deployed to $receiverName 💪 you\'re a real one';
  }

  /// Already nudged today.
  String get nudgeAlreadySent {
    if (!personalityOn) return 'Already nudged today';
    return 'Easy tiger --- you already nudged them today 😂';
  }

  /// Nudge disabled (user hasn\'t completed their own habits).
  String get nudgeDisabledReason {
    if (!personalityOn) return 'Complete your habits first';
    return 'Finish your own habits first, then you can nudge 😏';
  }

  // ---------------------------------------------------------------------------
  // Streak freeze sheet
  // ---------------------------------------------------------------------------

  /// Streak freeze title.
  String get freezeSheetTitle {
    if (!personalityOn) return 'Use a Streak Freeze?';
    return 'Deploy the freeze? ❄️🛡️';
  }

  /// Streak freeze body.
  String freezeSheetBody(int cost) {
    if (!personalityOn) {
      return 'This will protect today\'s group chain if the group falls below 75%. Cost: $cost consistency points.';
    }
    return 'This bad boy protects the chain even if the group doesn\'t hit 75% today. It\'ll cost you $cost consistency points though. Worth it? 🤔';
  }

  /// Streak freeze success toast.
  String get freezeActivatedToast {
    if (!personalityOn) return 'Streak freeze activated. Chain protected today.';
    return 'Freeze activated! The streak is safe. You\'re the group MVP today. ❄️🏆';
  }

  /// Insufficient points for freeze.
  String freezeInsufficientPoints(int needed) {
    if (!personalityOn) return 'You need $needed more consistency points.';
    return 'You\'re $needed points short. Keep completing habits to stack those points! 💰';
  }

  // ---------------------------------------------------------------------------
  // Leaderboard
  // ---------------------------------------------------------------------------

  /// Last week\'s MVP card.
  String lastWeekMvp(String name) {
    if (!personalityOn) return 'Last week\'s #1: $name';
    return 'Last week\'s MVP: $name 👑 bow down';
  }

  /// Leaderboard baseline caption.
  String get leaderboardCaption {
    if (!personalityOn) return 'Based on each member\'s personal baseline';
    return 'Based on YOUR baseline --- so no excuses 😤📈';
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/utils/personality_copy_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/utils/personality_copy.dart client/test/utils/personality_copy_test.dart
git commit -m "feat: add PersonalityCopy utility with witty ON/neutral OFF copy for all group screen text"
```

---

### Task 5: Create the GroupProvider with mock data

**Files:**
- Create: `client/lib/providers/group_provider.dart`
- Create: `client/test/providers/group_provider_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/providers/group_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/providers/group_provider.dart';

void main() {
  group('GroupProvider', () {
    late GroupProvider provider;

    setUp(() {
      provider = GroupProvider();
    });

    test('initializes with a group', () {
      expect(provider.hasGroup, isTrue);
      expect(provider.groupName, isNotEmpty);
    });

    test('has mock members', () {
      expect(provider.members.length, greaterThanOrEqualTo(4));
      expect(
        provider.members.any((m) => m.isCurrentUser),
        isTrue,
      );
    });

    test('has mock feed items', () {
      expect(provider.feedItems.length, greaterThanOrEqualTo(8));
      // Should contain variety of types
      final types = provider.feedItems.map((f) => f.type).toSet();
      expect(types.length, greaterThanOrEqualTo(4));
    });

    test('feed items are in reverse chronological order', () {
      for (var i = 0; i < provider.feedItems.length - 1; i++) {
        expect(
          provider.feedItems[i].timestamp.isAfter(
            provider.feedItems[i + 1].timestamp,
          ) ||
          provider.feedItems[i].timestamp.isAtSameMomentAs(
            provider.feedItems[i + 1].timestamp,
          ),
          isTrue,
        );
      }
    });

    test('has mock leaderboard data', () {
      expect(provider.weeklyScores.length, greaterThanOrEqualTo(4));
      // Should be sorted by rank
      for (var i = 0; i < provider.weeklyScores.length - 1; i++) {
        expect(
          provider.weeklyScores[i].rank,
          lessThanOrEqualTo(provider.weeklyScores[i + 1].rank),
        );
      }
    });

    test('personality is ON by default', () {
      expect(provider.personalityOn, isTrue);
    });

    test('toggling personality notifies listeners', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.togglePersonality();
      expect(provider.personalityOn, isFalse);
      expect(notified, isTrue);
    });

    test('currentUserCompleted reflects mock data', () {
      expect(provider.currentUserCompleted, isA<bool>());
    });

    test('sendNudge marks member as nudged today', () {
      final incompleteMember = provider.members.firstWhere(
        (m) => !m.isComplete && !m.isCurrentUser,
      );
      provider.sendNudge(incompleteMember.id);
      expect(provider.hasNudgedToday(incompleteMember.id), isTrue);
    });

    test('sendNudge cannot nudge same member twice', () {
      final incompleteMember = provider.members.firstWhere(
        (m) => !m.isComplete && !m.isCurrentUser,
      );
      provider.sendNudge(incompleteMember.id);
      // Second nudge should be a no-op
      final feedCountBefore = provider.feedItems.length;
      provider.sendNudge(incompleteMember.id);
      expect(provider.feedItems.length, feedCountBefore);
    });

    test('sendKudos adds a kudos feed item', () {
      final completeMember = provider.members.firstWhere(
        (m) => m.isComplete && !m.isCurrentUser,
      );
      final feedCountBefore = provider.feedItems.length;
      provider.sendKudos(completeMember.id);
      expect(provider.feedItems.length, feedCountBefore + 1);
      expect(provider.feedItems.first.type, FeedItemType.kudos);
    });

    test('streak freeze reduces points', () {
      final pointsBefore = provider.consistencyPoints;
      provider.useStreakFreeze();
      expect(provider.consistencyPoints, lessThan(pointsBefore));
      expect(provider.freezeActiveToday, isTrue);
    });

    test('cannot use streak freeze twice in one day', () {
      provider.useStreakFreeze();
      final pointsAfterFirst = provider.consistencyPoints;
      provider.useStreakFreeze(); // no-op
      expect(provider.consistencyPoints, pointsAfterFirst);
    });

    test('groupTier returns correct tier name', () {
      expect(provider.groupTier, isNotEmpty);
    });

    test('groupStreak returns a positive number', () {
      expect(provider.groupStreak, isNonNegative);
    });

    test('soloMode provider has no group', () {
      final solo = GroupProvider(soloMode: true);
      expect(solo.hasGroup, isFalse);
      expect(solo.members, isEmpty);
      expect(solo.feedItems, isEmpty);
    });

    test('leaderboardPeriod defaults to week', () {
      expect(provider.leaderboardPeriod, LeaderboardPeriod.week);
    });

    test('toggling leaderboard period notifies', () {
      var notified = false;
      provider.addListener(() => notified = true);
      provider.setLeaderboardPeriod(LeaderboardPeriod.month);
      expect(provider.leaderboardPeriod, LeaderboardPeriod.month);
      expect(notified, isTrue);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/providers/group_provider_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the GroupProvider**

```dart
// client/lib/providers/group_provider.dart
import 'package:flutter/foundation.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/utils/personality_copy.dart';

enum LeaderboardPeriod { week, month }

/// Manages group screen state: members, feed, leaderboard, actions.
/// Uses mock data until the API service layer is built.
class GroupProvider extends ChangeNotifier {
  final bool _soloMode;

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

  GroupProvider({bool soloMode = false}) : _soloMode = soloMode {
    if (!soloMode) {
      _groupName = 'Build Squad';
      _groupStreakDays = 14;
      _groupTier = GroupTier.ember;
      _members = _mockMembers();
      _feedItems = _mockFeedItems();
      _weeklyScores = _mockWeeklyScores();
      _groupStreakData = _mockGroupStreak();
    }
  }

  // --- Getters ---

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

  PersonalityCopy get copy => PersonalityCopy(personalityOn: _personalityOn);

  /// Whether the current user has completed all their habits.
  bool get currentUserCompleted {
    final current = _members.where((m) => m.isCurrentUser);
    if (current.isEmpty) return false;
    return current.first.isComplete;
  }

  /// Whether a nudge can be sent (user has completed all their habits).
  bool get canNudge => currentUserCompleted;

  /// Whether the user has enough points for a streak freeze.
  bool get canAffordFreeze => _consistencyPoints >= freezeCost;

  // --- Actions ---

  void togglePersonality() {
    _personalityOn = !_personalityOn;
    notifyListeners();
  }

  bool hasNudgedToday(String memberId) => _nudgedToday.contains(memberId);

  void sendNudge(String memberId) {
    if (_nudgedToday.contains(memberId)) return;
    if (!canNudge) return;

    _nudgedToday.add(memberId);

    final receiver = _members.firstWhere((m) => m.id == memberId);
    final sender = _members.firstWhere((m) => m.isCurrentUser);

    _feedItems.insert(
      0,
      FeedItem(
        id: 'nudge_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.nudge,
        senderName: sender.name,
        senderId: sender.id,
        receiverName: receiver.name,
        receiverId: receiver.id,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void sendKudos(String memberId) {
    final receiver = _members.firstWhere((m) => m.id == memberId);
    final sender = _members.firstWhere((m) => m.isCurrentUser);

    _feedItems.insert(
      0,
      FeedItem(
        id: 'kudos_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.kudos,
        senderName: sender.name,
        senderId: sender.id,
        receiverName: receiver.name,
        receiverId: receiver.id,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void useStreakFreeze() {
    if (_freezeActiveToday) return;
    if (!canAffordFreeze) return;

    _consistencyPoints -= freezeCost;
    _freezeActiveToday = true;

    final sender = _members.firstWhere((m) => m.isCurrentUser);
    _feedItems.insert(
      0,
      FeedItem(
        id: 'freeze_${DateTime.now().millisecondsSinceEpoch}',
        type: FeedItemType.streakFreeze,
        senderName: sender.name,
        senderId: sender.id,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void setLeaderboardPeriod(LeaderboardPeriod period) {
    _leaderboardPeriod = period;
    notifyListeners();
  }

  // --- Mock Data ---

  static List<GroupMember> _mockMembers() {
    return [
      const GroupMember(
        id: 'u1',
        name: 'Diana',
        avatarUrl: null,
        habitsCompleted: 4,
        habitsTotal: 6,
        status: MemberStatus.partial,
        isCurrentUser: true,
      ),
      const GroupMember(
        id: 'u2',
        name: 'Nitil',
        avatarUrl: null,
        habitsCompleted: 5,
        habitsTotal: 5,
        status: MemberStatus.allDone,
        isCurrentUser: false,
      ),
      const GroupMember(
        id: 'u3',
        name: 'Ava',
        avatarUrl: null,
        habitsCompleted: 3,
        habitsTotal: 5,
        status: MemberStatus.partial,
        isCurrentUser: false,
      ),
      const GroupMember(
        id: 'u4',
        name: 'Ravi',
        avatarUrl: null,
        habitsCompleted: 0,
        habitsTotal: 4,
        status: MemberStatus.notStarted,
        isCurrentUser: false,
      ),
      const GroupMember(
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
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/providers/group_provider_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/providers/group_provider.dart client/test/providers/group_provider_test.dart
git commit -m "feat: add GroupProvider with mock members, feed, leaderboard, nudge/kudos/freeze actions"
```

---

### Task 6: Create the MemberAvatar widget

**Files:**
- Create: `client/lib/widgets/group/member_avatar.dart`
- Create: `client/test/widgets/group/member_avatar_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/group/member_avatar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/widgets/group/member_avatar.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('MemberAvatar', () {
    const allDoneMember = GroupMember(
      id: 'u1',
      name: 'Nitil',
      avatarUrl: null,
      habitsCompleted: 5,
      habitsTotal: 5,
      status: MemberStatus.allDone,
      isCurrentUser: false,
    );

    const partialMember = GroupMember(
      id: 'u2',
      name: 'Ava',
      avatarUrl: null,
      habitsCompleted: 3,
      habitsTotal: 5,
      status: MemberStatus.partial,
      isCurrentUser: false,
    );

    const inactiveMember = GroupMember(
      id: 'u3',
      name: 'Zara',
      avatarUrl: null,
      habitsCompleted: 0,
      habitsTotal: 4,
      status: MemberStatus.inactive,
      isCurrentUser: false,
    );

    testWidgets('shows member name', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: allDoneMember,
          onNudge: null,
          onKudos: null,
        ),
      ));

      expect(find.text('Nitil'), findsOneWidget);
    });

    testWidgets('shows initials when no avatar', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: allDoneMember,
          onNudge: null,
          onKudos: null,
        ),
      ));

      expect(find.text('NI'), findsOneWidget);
    });

    testWidgets('shows check badge for all-done members', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: allDoneMember,
          onNudge: null,
          onKudos: null,
        ),
      ));

      // Should have a check icon somewhere
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('shows progress badge for partial members', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: partialMember,
          onNudge: null,
          onKudos: null,
        ),
      ));

      expect(find.text('3/5'), findsOneWidget);
    });

    testWidgets('shows sleep badge for inactive members', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: inactiveMember,
          onNudge: null,
          onKudos: null,
        ),
      ));

      expect(find.text('💤'), findsOneWidget);
    });

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(_wrap(
        MemberAvatar(
          member: allDoneMember,
          onNudge: null,
          onKudos: () {},
        ),
      ));

      expect(find.byType(MemberAvatar), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/group/member_avatar_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the MemberAvatar widget**

```dart
// client/lib/widgets/group/member_avatar.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// A single member avatar in the horizontal member grid.
///
/// Shows:
/// - Colored status ring (green=done, amber=partial, gray=not started, muted=inactive)
/// - Status icon/badge for accessibility (never color alone)
/// - Per-member nudge button (on incomplete members, when user has completed theirs)
/// - Per-member kudos button (on completed members)
class MemberAvatar extends StatelessWidget {
  final GroupMember member;
  final VoidCallback? onNudge;
  final VoidCallback? onKudos;
  final bool nudgeDisabled;
  final bool alreadyNudged;

  const MemberAvatar({
    super.key,
    required this.member,
    required this.onNudge,
    required this.onKudos,
    this.nudgeDisabled = false,
    this.alreadyNudged = false,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    final ringColor = _ringColor(colors);
    const double avatarSize = 52;
    const double ringWidth = 2.5;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar with status ring
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarSize + ringWidth * 2,
                height: avatarSize + ringWidth * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ringColor,
                    width: ringWidth,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.surfaceElevated,
                    ),
                    child: Center(
                      child: Text(
                        member.initials,
                        style: tokens.typography.numbersBody.copyWith(
                          color: colors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Status badge (bottom-right)
              Positioned(
                right: 0,
                bottom: 0,
                child: _StatusBadge(
                  member: member,
                  colors: colors,
                  tokens: tokens,
                ),
              ),
            ],
          ),
          const SizedBox(height: ValenceSpacing.xs),

          // Name
          Text(
            member.name,
            style: tokens.typography.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: member.isCurrentUser ? FontWeight.w700 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ValenceSpacing.xs),

          // Action button (nudge or kudos)
          if (!member.isCurrentUser) _buildActionButton(tokens, colors),
        ],
      ),
    );
  }

  Color _ringColor(dynamic colors) {
    switch (member.status) {
      case MemberStatus.allDone:
        return colors.accentSuccess;
      case MemberStatus.partial:
        return colors.accentWarning;
      case MemberStatus.notStarted:
        return colors.textSecondary;
      case MemberStatus.inactive:
        return colors.borderDefault;
    }
  }

  Widget _buildActionButton(ValenceTokens tokens, dynamic colors) {
    if (member.isComplete) {
      // Kudos button for completed members
      return GestureDetector(
        onTap: onKudos,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ValenceSpacing.sm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: colors.accentSocial.withValues(alpha: 0.15),
            borderRadius: ValenceRadii.roundAll,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhosphorIcon(
                PhosphorIcons.handsPraying(),
                size: 12,
                color: colors.accentSocial,
              ),
              const SizedBox(width: 2),
              Text(
                'Kudos',
                style: tokens.typography.overline.copyWith(
                  color: colors.accentSocial,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Nudge button for incomplete members
      final isEnabled = onNudge != null && !nudgeDisabled && !alreadyNudged;
      final Color nudgeColor = isEnabled ? colors.accentPrimary : colors.textSecondary;

      return Tooltip(
        message: alreadyNudged
            ? 'Already nudged today'
            : (nudgeDisabled ? 'Complete your habits first' : 'Send a nudge'),
        child: GestureDetector(
          onTap: isEnabled ? onNudge : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ValenceSpacing.sm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: nudgeColor.withValues(alpha: isEnabled ? 0.15 : 0.08),
              borderRadius: ValenceRadii.roundAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PhosphorIcon(
                  PhosphorIcons.megaphone(),
                  size: 12,
                  color: nudgeColor.withValues(alpha: isEnabled ? 1.0 : 0.4),
                ),
                const SizedBox(width: 2),
                Text(
                  alreadyNudged ? 'Sent' : 'Nudge',
                  style: tokens.typography.overline.copyWith(
                    color: nudgeColor.withValues(alpha: isEnabled ? 1.0 : 0.4),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

/// Small badge overlaid on the avatar showing status.
class _StatusBadge extends StatelessWidget {
  final GroupMember member;
  final dynamic colors;
  final ValenceTokens tokens;

  const _StatusBadge({
    required this.member,
    required this.colors,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    switch (member.status) {
      case MemberStatus.allDone:
        return _badge(colors.accentSuccess, const Icon(Icons.check, size: 10, color: Colors.white));
      case MemberStatus.partial:
        return _badge(
          colors.accentWarning,
          Text(
            member.progressLabel,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      case MemberStatus.notStarted:
        return _badge(
          colors.textSecondary,
          const Text(
            '–',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        );
      case MemberStatus.inactive:
        return Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: colors.surfaceBackground,
            shape: BoxShape.circle,
          ),
          child: const Text('💤', style: TextStyle(fontSize: 12)),
        );
    }
  }

  Widget _badge(Color bgColor, Widget child) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: colors.surfaceBackground, width: 1.5),
      ),
      child: Center(child: child),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/group/member_avatar_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/group/member_avatar.dart client/test/widgets/group/member_avatar_test.dart
git commit -m "feat: add MemberAvatar widget with status ring, badge, and per-member nudge/kudos buttons"
```

---

### Task 7: Create the MemberGrid widget

**Files:**
- Create: `client/lib/widgets/group/member_grid.dart`

- [ ] **Step 1: Write the MemberGrid**

```dart
// client/lib/widgets/group/member_grid.dart
import 'package:flutter/material.dart';
import 'package:valence/models/group_member.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/widgets/group/member_avatar.dart';

/// Horizontal scrollable row of member avatars.
/// Replicates the design spec: "Horizontal scrollable row of member avatars"
/// with per-member nudge/kudos action buttons.
class MemberGrid extends StatelessWidget {
  final List<GroupMember> members;
  final bool canNudge;
  final Set<String> nudgedToday;
  final ValueChanged<String> onNudge;
  final ValueChanged<String> onKudos;

  const MemberGrid({
    super.key,
    required this.members,
    required this.canNudge,
    required this.nudgedToday,
    required this.onNudge,
    required this.onKudos,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
        itemCount: members.length,
        separatorBuilder: (_, __) => const SizedBox(width: ValenceSpacing.sm),
        itemBuilder: (context, index) {
          final member = members[index];
          return MemberAvatar(
            member: member,
            nudgeDisabled: !canNudge,
            alreadyNudged: nudgedToday.contains(member.id),
            onNudge: member.isCurrentUser || member.isComplete || member.status == MemberStatus.inactive
                ? null
                : () => onNudge(member.id),
            onKudos: member.isCurrentUser || !member.isComplete
                ? null
                : () => onKudos(member.id),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/group/member_grid.dart
git commit -m "feat: add MemberGrid horizontal scroll widget composing MemberAvatars with nudge/kudos"
```

---

### Task 8: Create the FeedItemCard widget

**Files:**
- Create: `client/lib/widgets/group/feed_item_card.dart`
- Create: `client/test/widgets/group/feed_item_card_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/group/feed_item_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/group/feed_item_card.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  const copyOn = PersonalityCopy(personalityOn: true);
  const copyOff = PersonalityCopy(personalityOn: false);

  group('FeedItemCard', () {
    testWidgets('renders completion feed item', (tester) async {
      final item = FeedItem(
        id: 'f1',
        type: FeedItemType.completion,
        senderName: 'Nitil',
        senderId: 'u2',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        habitName: 'LeetCode',
        verificationSource: 'LeetCode',
      );

      await tester.pumpWidget(_wrap(
        FeedItemCard(item: item, copy: copyOn),
      ));

      expect(find.byType(FeedItemCard), findsOneWidget);
      // Should contain the sender name somewhere
      expect(find.textContaining('Nitil'), findsWidgets);
    });

    testWidgets('renders miss feed item (supportive)', (tester) async {
      final item = FeedItem(
        id: 'f2',
        type: FeedItemType.miss,
        senderName: 'Ravi',
        senderId: 'u4',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        habitName: 'Meditate',
      );

      await tester.pumpWidget(_wrap(
        FeedItemCard(item: item, copy: copyOn),
      ));

      expect(find.byType(FeedItemCard), findsOneWidget);
    });

    testWidgets('renders nudge feed item (message hidden)', (tester) async {
      final item = FeedItem(
        id: 'f3',
        type: FeedItemType.nudge,
        senderName: 'Diana',
        senderId: 'u1',
        receiverName: 'Ravi',
        receiverId: 'u4',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(_wrap(
        FeedItemCard(item: item, copy: copyOff),
      ));

      // Should show both names
      expect(find.textContaining('Diana'), findsWidgets);
      expect(find.textContaining('Ravi'), findsWidgets);
    });

    testWidgets('renders chain link feed item', (tester) async {
      final item = FeedItem(
        id: 'f4',
        type: FeedItemType.chainLink,
        senderName: 'System',
        senderId: 'system',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        message: 'gold',
      );

      await tester.pumpWidget(_wrap(
        FeedItemCard(item: item, copy: copyOn),
      ));

      expect(find.byType(FeedItemCard), findsOneWidget);
    });

    testWidgets('renders streak freeze feed item', (tester) async {
      final item = FeedItem(
        id: 'f5',
        type: FeedItemType.streakFreeze,
        senderName: 'Diana',
        senderId: 'u1',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(_wrap(
        FeedItemCard(item: item, copy: copyOff),
      ));

      expect(find.textContaining('Diana'), findsWidgets);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/group/feed_item_card_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the FeedItemCard widget**

```dart
// client/lib/widgets/group/feed_item_card.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/feed_item.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';

/// A single card in the group feed timeline.
/// Handles all 8 feed item types with personality-aware copy.
class FeedItemCard extends StatelessWidget {
  final FeedItem item;
  final PersonalityCopy copy;
  final VoidCallback? onKudosTap;

  const FeedItemCard({
    super.key,
    required this.item,
    required this.copy,
    this.onKudosTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ValenceSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading icon
          _LeadingIcon(type: item.type, colors: colors),
          const SizedBox(width: ValenceSpacing.smMd),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message
                Text(
                  _resolveMessage(),
                  style: tokens.typography.body.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
                ),

                // Verification badge (for plugin completions)
                if (item.type == FeedItemType.completion &&
                    item.verificationSource != null)
                  Padding(
                    padding: const EdgeInsets.only(top: ValenceSpacing.xs),
                    child: _VerificationBadge(
                      source: item.verificationSource!,
                      tokens: tokens,
                    ),
                  ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: ValenceSpacing.xs),
                  child: Text(
                    item.timeAgo,
                    style: tokens.typography.caption.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Trailing action: kudos button on completions
          if (item.type == FeedItemType.completion && onKudosTap != null)
            Padding(
              padding: const EdgeInsets.only(left: ValenceSpacing.sm),
              child: GestureDetector(
                onTap: onKudosTap,
                child: PhosphorIcon(
                  PhosphorIcons.handsPraying(),
                  size: 20,
                  color: colors.accentSocial,
                ),
              ),
            ),

          // Trailing action: support button on misses
          if (item.type == FeedItemType.miss && onKudosTap != null)
            Padding(
              padding: const EdgeInsets.only(left: ValenceSpacing.sm),
              child: GestureDetector(
                onTap: onKudosTap,
                child: PhosphorIcon(
                  PhosphorIcons.heart(),
                  size: 20,
                  color: colors.accentSocial,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _resolveMessage() {
    switch (item.type) {
      case FeedItemType.completion:
        return copy.completionMessage(
          item.senderName,
          item.habitName ?? 'a habit',
          plugin: item.verificationSource,
        );
      case FeedItemType.miss:
        return copy.missMessage(
          item.senderName,
          item.habitName ?? 'a habit',
        );
      case FeedItemType.nudge:
        return copy.nudgeFeedMessage(
          item.senderName,
          item.receiverName ?? 'someone',
        );
      case FeedItemType.kudos:
        return copy.kudosFeedMessage(
          item.senderName,
          item.receiverName ?? 'someone',
        );
      case FeedItemType.statusNorm:
        // Parse streak days from message field
        final days = int.tryParse(
          item.message?.replaceAll(RegExp(r'[^0-9]'), '') ?? '0',
        ) ?? 7;
        return copy.statusNormMessage(item.senderName, days);
      case FeedItemType.chainLink:
        return copy.chainLinkMessage(
          item.message ?? 'gold',
          0, // Mock: not used for display derivation
          5,
        );
      case FeedItemType.milestone:
        return copy.milestoneMessage(
          item.senderName,
          item.habitName ?? 'a habit',
          item.message ?? 'Foundation',
          10,
        );
      case FeedItemType.streakFreeze:
        return copy.streakFreezeMessage(item.senderName);
    }
  }
}

/// Leading icon for each feed item type.
class _LeadingIcon extends StatelessWidget {
  final FeedItemType type;
  final dynamic colors;

  const _LeadingIcon({required this.type, required this.colors});

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;

    switch (type) {
      case FeedItemType.completion:
        icon = PhosphorIcons.checkCircle();
        iconColor = colors.accentSuccess;
      case FeedItemType.miss:
        icon = PhosphorIcons.heart();
        iconColor = colors.accentSocial;
      case FeedItemType.nudge:
        icon = PhosphorIcons.megaphone();
        iconColor = colors.accentPrimary;
      case FeedItemType.kudos:
        icon = PhosphorIcons.handsPraying();
        iconColor = colors.accentSocial;
      case FeedItemType.statusNorm:
        icon = PhosphorIcons.flame();
        iconColor = colors.accentWarning;
      case FeedItemType.chainLink:
        icon = PhosphorIcons.linkSimple();
        iconColor = colors.chainGold;
      case FeedItemType.milestone:
        icon = PhosphorIcons.trophy();
        iconColor = colors.accentPrimary;
      case FeedItemType.streakFreeze:
        icon = PhosphorIcons.snowflake();
        iconColor = colors.accentSecondary;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: PhosphorIcon(icon, size: 16, color: iconColor),
      ),
    );
  }
}

/// "Verified via LeetCode" badge for plugin-tracked completions.
class _VerificationBadge extends StatelessWidget {
  final String source;
  final ValenceTokens tokens;

  const _VerificationBadge({
    required this.source,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: tokens.colors.accentSuccess.withValues(alpha: 0.1),
        borderRadius: ValenceRadii.roundAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(
            PhosphorIcons.shieldCheck(),
            size: 12,
            color: tokens.colors.accentSuccess,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified via $source',
            style: tokens.typography.overline.copyWith(
              color: tokens.colors.accentSuccess,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/group/feed_item_card_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/group/feed_item_card.dart client/test/widgets/group/feed_item_card_test.dart
git commit -m "feat: add FeedItemCard widget with 8-type variants and personality-aware copy"
```

---

### Task 9: Create the GroupHeader widget

**Files:**
- Create: `client/lib/widgets/group/group_header.dart`

- [ ] **Step 1: Write the GroupHeader**

```dart
// client/lib/widgets/group/group_header.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Group screen header: group name, tier badge, streak count, invite button.
class GroupHeader extends StatelessWidget {
  final String groupName;
  final String tier;
  final int streakDays;
  final VoidCallback onInvite;
  final VoidCallback? onSettings;

  const GroupHeader({
    super.key,
    required this.groupName,
    required this.tier,
    required this.streakDays,
    required this.onInvite,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ValenceSpacing.md,
        ValenceSpacing.mdLg,
        ValenceSpacing.md,
        ValenceSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Group name + tier + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group name
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        groupName,
                        style: tokens.typography.h1.copyWith(
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: ValenceSpacing.sm),
                    _TierBadge(tier: tier, tokens: tokens),
                  ],
                ),
                const SizedBox(height: ValenceSpacing.xs),
                // Streak
                Row(
                  children: [
                    PhosphorIcon(
                      PhosphorIcons.flame(PhosphorIconsStyle.fill),
                      size: 16,
                      color: colors.accentWarning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays day streak',
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          if (onSettings != null)
            IconButton(
              onPressed: onSettings,
              tooltip: 'Group settings',
              icon: PhosphorIcon(
                PhosphorIcons.gear(),
                size: 22,
                color: colors.textSecondary,
              ),
            ),
          IconButton(
            onPressed: onInvite,
            tooltip: 'Invite members',
            icon: PhosphorIcon(
              PhosphorIcons.shareFat(),
              size: 22,
              color: colors.accentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  final ValenceTokens tokens;

  const _TierBadge({required this.tier, required this.tokens});

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final badgeColor = _tierColor(tier, colors);

    final PhosphorIconData tierIcon;
    switch (tier.toLowerCase()) {
      case 'spark':
        tierIcon = PhosphorIcons.sparkle();
      case 'ember':
        tierIcon = PhosphorIcons.flame();
      case 'flame':
        tierIcon = PhosphorIcons.flame(PhosphorIconsStyle.fill);
      case 'blaze':
        tierIcon = PhosphorIcons.fireTruck();
      default:
        tierIcon = PhosphorIcons.sparkle();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: ValenceRadii.roundAll,
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PhosphorIcon(tierIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            tier.toUpperCase(),
            style: tokens.typography.overline.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _tierColor(String tier, dynamic colors) {
    switch (tier.toLowerCase()) {
      case 'spark':
        return colors.rankBronze;
      case 'ember':
        return colors.rankSilver;
      case 'flame':
        return colors.rankGold;
      case 'blaze':
        return colors.rankPlatinum;
      default:
        return colors.accentSecondary;
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/group/group_header.dart
git commit -m "feat: add GroupHeader widget with group name, tier badge, streak count, and invite button"
```

---

### Task 10: Create the WeeklyLeaderboard widget

**Files:**
- Create: `client/lib/widgets/group/weekly_leaderboard.dart`
- Create: `client/test/widgets/group/weekly_leaderboard_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/group/weekly_leaderboard_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/group/weekly_leaderboard.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  const copy = PersonalityCopy(personalityOn: true);

  final scores = const [
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
  ];

  group('WeeklyLeaderboard', () {
    testWidgets('renders member names', (tester) async {
      await tester.pumpWidget(_wrap(
        WeeklyLeaderboard(
          scores: scores,
          copy: copy,
          period: LeaderboardPeriod.week,
          onPeriodChanged: (_) {},
        ),
      ));

      expect(find.text('Nitil'), findsOneWidget);
      expect(find.text('Diana'), findsOneWidget);
    });

    testWidgets('renders consistency percentages', (tester) async {
      await tester.pumpWidget(_wrap(
        WeeklyLeaderboard(
          scores: scores,
          copy: copy,
          period: LeaderboardPeriod.week,
          onPeriodChanged: (_) {},
        ),
      ));

      expect(find.text('98%'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
    });

    testWidgets('expands row to show breakdown on tap', (tester) async {
      await tester.pumpWidget(_wrap(
        WeeklyLeaderboard(
          scores: scores,
          copy: copy,
          period: LeaderboardPeriod.week,
          onPeriodChanged: (_) {},
        ),
      ));

      // Tap Nitil's row
      await tester.tap(find.text('Nitil'));
      await tester.pumpAndSettle();

      // Should now show breakdown categories
      expect(find.text('Habits Completed'), findsOneWidget);
      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('shows week/month toggle', (tester) async {
      await tester.pumpWidget(_wrap(
        WeeklyLeaderboard(
          scores: scores,
          copy: copy,
          period: LeaderboardPeriod.week,
          onPeriodChanged: (_) {},
        ),
      ));

      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/group/weekly_leaderboard_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the WeeklyLeaderboard widget**

```dart
// client/lib/widgets/group/weekly_leaderboard.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/weekly_score.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';

/// Weekly leaderboard with expandable contribution breakdown.
///
/// Primary metric: % of personal baseline (not raw scores).
/// Tapping a row expands it to show the detailed ContributionBreakdown.
class WeeklyLeaderboard extends StatefulWidget {
  final List<WeeklyScore> scores;
  final PersonalityCopy copy;
  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardPeriod> onPeriodChanged;

  const WeeklyLeaderboard({
    super.key,
    required this.scores,
    required this.copy,
    required this.period,
    required this.onPeriodChanged,
  });

  @override
  State<WeeklyLeaderboard> createState() => _WeeklyLeaderboardState();
}

class _WeeklyLeaderboardState extends State<WeeklyLeaderboard> {
  String? _expandedMemberId;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header + period toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leaderboard',
                style: tokens.typography.h2.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              _PeriodToggle(
                period: widget.period,
                onChanged: widget.onPeriodChanged,
                tokens: tokens,
              ),
            ],
          ),
        ),
        const SizedBox(height: ValenceSpacing.xs),

        // Baseline caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ValenceSpacing.md),
          child: Text(
            widget.copy.leaderboardCaption,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: ValenceSpacing.smMd),

        // Score rows
        ...widget.scores.map((score) {
          final isExpanded = _expandedMemberId == score.memberId;
          return _ScoreRow(
            score: score,
            isExpanded: isExpanded,
            tokens: tokens,
            onTap: () {
              setState(() {
                _expandedMemberId = isExpanded ? null : score.memberId;
              });
            },
          );
        }),
      ],
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  final LeaderboardPeriod period;
  final ValueChanged<LeaderboardPeriod> onChanged;
  final ValenceTokens tokens;

  const _PeriodToggle({
    required this.period,
    required this.onChanged,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: ValenceRadii.roundAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            label: 'Week',
            isSelected: period == LeaderboardPeriod.week,
            tokens: tokens,
            onTap: () => onChanged(LeaderboardPeriod.week),
          ),
          _PeriodChip(
            label: 'Month',
            isSelected: period == LeaderboardPeriod.month,
            tokens: tokens,
            onTap: () => onChanged(LeaderboardPeriod.month),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValenceTokens tokens;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.isSelected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.smMd,
          vertical: ValenceSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.accentPrimary : Colors.transparent,
          borderRadius: ValenceRadii.roundAll,
        ),
        child: Text(
          label,
          style: tokens.typography.caption.copyWith(
            color: isSelected ? colors.textInverse : colors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  final WeeklyScore score;
  final bool isExpanded;
  final ValenceTokens tokens;
  final VoidCallback onTap;

  const _ScoreRow({
    required this.score,
    required this.isExpanded,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ValenceSpacing.md,
          vertical: ValenceSpacing.sm,
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Rank
                SizedBox(
                  width: 28,
                  child: Text(
                    score.rank == 1
                        ? '👑'
                        : '#${score.rank}',
                    style: tokens.typography.numbersBody.copyWith(
                      color: colors.textPrimary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: ValenceSpacing.smMd),

                // Avatar circle (initials)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.surfaceElevated,
                  ),
                  child: Center(
                    child: Text(
                      score.memberName.isNotEmpty
                          ? score.memberName.substring(0, 1).toUpperCase()
                          : '?',
                      style: tokens.typography.caption.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: ValenceSpacing.smMd),

                // Name
                Expanded(
                  child: Text(
                    score.memberName,
                    style: tokens.typography.body.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Consistency percentage (large)
                Text(
                  score.consistencyLabel,
                  style: tokens.typography.numbersBody.copyWith(
                    color: _percentColor(score.consistencyPercent, colors),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: ValenceSpacing.sm),

                // Progress bar (mini)
                SizedBox(
                  width: 48,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: ValenceRadii.roundAll,
                    child: LinearProgressIndicator(
                      value: score.consistencyPercent / 100,
                      backgroundColor: colors.surfaceSunken,
                      color: _percentColor(score.consistencyPercent, colors),
                    ),
                  ),
                ),

                // Expand chevron
                const SizedBox(width: ValenceSpacing.xs),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: PhosphorIcon(
                    PhosphorIcons.caretDown(),
                    size: 14,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),

            // Expanded breakdown
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _BreakdownPanel(
                breakdown: score.breakdown,
                tokens: tokens,
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }

  Color _percentColor(int percent, dynamic colors) {
    if (percent >= 80) return colors.accentSuccess;
    if (percent >= 50) return colors.accentWarning;
    return colors.accentError;
  }
}

class _BreakdownPanel extends StatelessWidget {
  final ContributionBreakdown breakdown;
  final ValenceTokens tokens;

  const _BreakdownPanel({
    required this.breakdown,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.only(
        left: 40 + ValenceSpacing.smMd, // align with name column
        top: ValenceSpacing.sm,
        bottom: ValenceSpacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(ValenceSpacing.smMd),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: ValenceRadii.mediumAll,
        ),
        child: Column(
          children: [
            _BreakdownRow(
              label: 'Habits Completed',
              points: breakdown.habitsCompleted,
              tokens: tokens,
            ),
            _BreakdownRow(
              label: 'Streak Contributions',
              points: breakdown.groupStreakContributions,
              tokens: tokens,
            ),
            _BreakdownRow(
              label: 'Kudos Received',
              points: breakdown.kudosReceived,
              tokens: tokens,
            ),
            _BreakdownRow(
              label: 'Perfect Days',
              points: breakdown.perfectDays,
              tokens: tokens,
            ),
            const Divider(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: tokens.typography.body.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${breakdown.totalPoints}',
                  style: tokens.typography.numbersBody.copyWith(
                    color: colors.accentPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final int points;
  final ValenceTokens tokens;

  const _BreakdownRow({
    required this.label,
    required this.points,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: colors.textSecondary,
            ),
          ),
          Text(
            '$points',
            style: tokens.typography.caption.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/group/weekly_leaderboard_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/group/weekly_leaderboard.dart client/test/widgets/group/weekly_leaderboard_test.dart
git commit -m "feat: add WeeklyLeaderboard widget with expandable contribution breakdown and period toggle"
```

---

### Task 11: Create the NudgeSheet bottom sheet

**Files:**
- Create: `client/lib/widgets/group/nudge_sheet.dart`

- [ ] **Step 1: Write the NudgeSheet**

```dart
// client/lib/widgets/group/nudge_sheet.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Bottom sheet for confirming a nudge to a specific member.
///
/// Shows the personality-aware title and body. The LLM-generated preview
/// message is read-only (users cannot edit it).
class NudgeSheet extends StatelessWidget {
  final String receiverName;
  final PersonalityCopy copy;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const NudgeSheet({
    super.key,
    required this.receiverName,
    required this.copy,
    required this.onSend,
    required this.onCancel,
  });

  /// Show this sheet as a modal bottom sheet.
  static Future<bool?> show(
    BuildContext context, {
    required String receiverName,
    required PersonalityCopy copy,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ValenceRadii.xl)),
      ),
      builder: (_) => NudgeSheet(
        receiverName: receiverName,
        copy: copy,
        onSend: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ValenceRadii.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: ValenceRadii.roundAll,
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Icon
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.accentPrimary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.megaphone(),
                  size: 28,
                  color: colors.accentPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.md),

          // Title
          Center(
            child: Text(
              copy.nudgeSheetTitle(receiverName),
              style: tokens.typography.h2.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: ValenceSpacing.sm),

          // Body
          Text(
            copy.nudgeSheetBody(receiverName),
            style: tokens.typography.body.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ValenceSpacing.md),

          // Mock LLM preview (read-only)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ValenceSpacing.smMd),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: ValenceRadii.mediumAll,
              border: Border.all(color: colors.borderDefault),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview:',
                  style: tokens.typography.overline.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                const SizedBox(height: ValenceSpacing.xs),
                Text(
                  'Hey $receiverName, your group is counting on you today. '
                  'Even one habit done is a win. You got this! 💪',
                  style: tokens.typography.body.copyWith(
                    color: colors.textPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Buttons
          ValenceButton(
            label: 'Send Nudge',
            onPressed: onSend,
            fullWidth: true,
            icon: PhosphorIcons.paperPlaneRight(),
          ),
          const SizedBox(height: ValenceSpacing.sm),
          ValenceButton(
            label: 'Cancel',
            onPressed: onCancel,
            variant: ValenceButtonVariant.ghost,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/group/nudge_sheet.dart
git commit -m "feat: add NudgeSheet bottom sheet with personality-aware copy and LLM preview"
```

---

### Task 12: Create the StreakFreezeSheet bottom sheet

**Files:**
- Create: `client/lib/widgets/group/streak_freeze_sheet.dart`

- [ ] **Step 1: Write the StreakFreezeSheet**

```dart
// client/lib/widgets/group/streak_freeze_sheet.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Bottom sheet for confirming streak freeze usage.
class StreakFreezeSheet extends StatelessWidget {
  final int consistencyPoints;
  final int cost;
  final bool canAfford;
  final PersonalityCopy copy;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const StreakFreezeSheet({
    super.key,
    required this.consistencyPoints,
    required this.cost,
    required this.canAfford,
    required this.copy,
    required this.onConfirm,
    required this.onCancel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required int consistencyPoints,
    required int cost,
    required bool canAfford,
    required PersonalityCopy copy,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ValenceRadii.xl)),
      ),
      builder: (_) => StreakFreezeSheet(
        consistencyPoints: consistencyPoints,
        cost: cost,
        canAfford: canAfford,
        copy: copy,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Container(
      padding: const EdgeInsets.all(ValenceSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ValenceRadii.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: ValenceRadii.roundAll,
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.lg),

          // Icon
          Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.accentSecondary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.snowflake(),
                  size: 28,
                  color: colors.accentSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: ValenceSpacing.md),

          // Title
          Text(
            copy.freezeSheetTitle,
            style: tokens.typography.h2.copyWith(
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ValenceSpacing.sm),

          // Body
          Text(
            copy.freezeSheetBody(cost),
            style: tokens.typography.body.copyWith(
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: ValenceSpacing.md),

          // Points display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ValenceSpacing.smMd),
            decoration: BoxDecoration(
              color: colors.surfaceSunken,
              borderRadius: ValenceRadii.mediumAll,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your balance:',
                  style: tokens.typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  '$consistencyPoints pts',
                  style: tokens.typography.numbersBody.copyWith(
                    color: canAfford ? colors.textPrimary : colors.accentError,
                  ),
                ),
              ],
            ),
          ),

          if (!canAfford) ...[
            const SizedBox(height: ValenceSpacing.sm),
            Text(
              copy.freezeInsufficientPoints(cost - consistencyPoints),
              style: tokens.typography.caption.copyWith(
                color: colors.accentError,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: ValenceSpacing.lg),

          // Buttons
          ValenceButton(
            label: canAfford ? 'Use Freeze' : 'Not Enough Points',
            onPressed: canAfford ? onConfirm : null,
            fullWidth: true,
            icon: PhosphorIcons.snowflake(),
          ),
          const SizedBox(height: ValenceSpacing.sm),
          ValenceButton(
            label: 'Cancel',
            onPressed: onCancel,
            variant: ValenceButtonVariant.ghost,
            fullWidth: true,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/group/streak_freeze_sheet.dart
git commit -m "feat: add StreakFreezeSheet bottom sheet with points balance and personality copy"
```

---

### Task 13: Create the SoloEmptyState widget

**Files:**
- Create: `client/lib/widgets/group/solo_empty_state.dart`

- [ ] **Step 1: Write the SoloEmptyState**

```dart
// client/lib/widgets/group/solo_empty_state.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/personality_copy.dart';
import 'package:valence/widgets/core/valence_button.dart';

/// Full-screen empty state shown on the Group tab when the user has no group.
///
/// Personality ON: playful, fun, nudges you to create/join.
/// Personality OFF: clean, factual, same CTAs.
class SoloEmptyState extends StatelessWidget {
  final PersonalityCopy copy;
  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;

  const SoloEmptyState({
    super.key,
    required this.copy,
    required this.onCreateGroup,
    required this.onJoinGroup,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ValenceSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration (placeholder: large icon)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colors.accentSocial.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: PhosphorIcon(
                  PhosphorIcons.usersThree(),
                  size: 56,
                  color: colors.accentSocial.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Title
            Text(
              copy.emptyStateGroupTitle,
              style: tokens.typography.h2.copyWith(
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ValenceSpacing.sm),

            // Body
            Text(
              copy.emptyStateGroupBody,
              style: tokens.typography.body.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Create group button
            ValenceButton(
              label: 'Create a Group',
              onPressed: onCreateGroup,
              fullWidth: true,
              icon: PhosphorIcons.plus(),
            ),
            const SizedBox(height: ValenceSpacing.smMd),

            // Join button
            ValenceButton(
              label: 'Join with Invite Link',
              onPressed: onJoinGroup,
              variant: ValenceButtonVariant.secondary,
              fullWidth: true,
              icon: PhosphorIcons.linkSimple(),
            ),
            const SizedBox(height: ValenceSpacing.lg),

            // Social proof
            Container(
              padding: const EdgeInsets.all(ValenceSpacing.smMd),
              decoration: BoxDecoration(
                color: colors.surfacePrimary,
                borderRadius: ValenceRadii.mediumAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Row(
                children: [
                  PhosphorIcon(
                    PhosphorIcons.chartLineUp(),
                    size: 20,
                    color: colors.accentSuccess,
                  ),
                  const SizedBox(width: ValenceSpacing.sm),
                  Expanded(
                    child: Text(
                      copy.emptyStateSocialProof,
                      style: tokens.typography.caption.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/widgets/group/solo_empty_state.dart
git commit -m "feat: add SoloEmptyState widget for group tab with personality-aware copy and CTAs"
```

---

### Task 14: Assemble the full Group Screen

**Files:**
- Replace: `client/lib/screens/group/group_screen.dart`

- [ ] **Step 1: Write the full GroupScreen**

```dart
// client/lib/screens/group/group_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/providers/group_provider.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/core/valence_button.dart';
import 'package:valence/widgets/group/chain_strip.dart';
import 'package:valence/widgets/group/feed_item_card.dart';
import 'package:valence/widgets/group/group_header.dart';
import 'package:valence/widgets/group/member_grid.dart';
import 'package:valence/widgets/group/nudge_sheet.dart';
import 'package:valence/widgets/group/solo_empty_state.dart';
import 'package:valence/widgets/group/streak_freeze_sheet.dart';
import 'package:valence/widgets/group/weekly_leaderboard.dart';
import 'package:valence/widgets/shared/valence_toast.dart';

/// Group screen (Tab 1) — member grid, group feed, leaderboard.
/// Shows SoloEmptyState when user has no group.
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

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: SafeArea(
        child: Consumer<GroupProvider>(
          builder: (context, group, _) {
            // Solo mode: show empty state
            if (!group.hasGroup) {
              return SoloEmptyState(
                copy: group.copy,
                onCreateGroup: () {
                  // Phase 7: navigate to group creation flow
                  ValenceToast.show(context, message: 'Group creation coming soon');
                },
                onJoinGroup: () {
                  // Phase 7: navigate to join group flow
                  ValenceToast.show(context, message: 'Join group coming soon');
                },
              );
            }

            // Group mode: full screen
            return CustomScrollView(
              slivers: [
                // --- Header ---
                SliverToBoxAdapter(
                  child: GroupHeader(
                    groupName: group.groupName,
                    tier: group.groupTier,
                    streakDays: group.groupStreak,
                    onInvite: () {
                      ValenceToast.show(
                        context,
                        message: 'Invite link copied! Share it with your squad.',
                        type: ToastType.success,
                      );
                    },
                    onSettings: () {
                      // Phase 7: open group management
                      ValenceToast.show(context, message: 'Group settings coming soon');
                    },
                  ),
                ),

                // --- Member grid ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: ValenceSpacing.sm),
                    child: MemberGrid(
                      members: group.members,
                      canNudge: group.canNudge,
                      nudgedToday: group.feedItems
                          .where((f) => f.type == FeedItemType.nudge)
                          .map((f) => f.receiverId ?? '')
                          .toSet(),
                      onNudge: (memberId) => _handleNudge(context, group, memberId),
                      onKudos: (memberId) => _handleKudos(context, group, memberId),
                    ),
                  ),
                ),

                // --- Action bar (streak freeze + chain strip) ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.md,
                      vertical: ValenceSpacing.sm,
                    ),
                    child: _ActionBar(group: group),
                  ),
                ),

                // --- Chain strip ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.md,
                      vertical: ValenceSpacing.sm,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(ValenceSpacing.md),
                      decoration: BoxDecoration(
                        color: colors.surfacePrimary,
                        borderRadius: ValenceRadii.largeAll,
                      ),
                      child: ChainStrip(
                        links: group.groupStreakData.last7Days,
                        currentStreak: group.groupStreak,
                        tier: group.groupTier,
                      ),
                    ),
                  ),
                ),

                // --- Feed section header ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ValenceSpacing.md,
                      ValenceSpacing.md,
                      ValenceSpacing.md,
                      ValenceSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Group Feed',
                          style: tokens.typography.h2.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        // Personality toggle
                        GestureDetector(
                          onTap: group.togglePersonality,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: ValenceSpacing.sm,
                              vertical: ValenceSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: group.personalityOn
                                  ? colors.accentSocial.withValues(alpha: 0.12)
                                  : colors.surfaceSunken,
                              borderRadius: ValenceRadii.roundAll,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PhosphorIcon(
                                  group.personalityOn
                                      ? PhosphorIcons.smiley(PhosphorIconsStyle.fill)
                                      : PhosphorIcons.smiley(),
                                  size: 14,
                                  color: group.personalityOn
                                      ? colors.accentSocial
                                      : colors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  group.personalityOn ? 'Fun' : 'Clean',
                                  style: tokens.typography.overline.copyWith(
                                    color: group.personalityOn
                                        ? colors.accentSocial
                                        : colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Feed items ---
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ValenceSpacing.md,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = group.feedItems[index];
                        return FeedItemCard(
                          item: item,
                          copy: group.copy,
                          onKudosTap: item.senderId != 'system' &&
                                  !group.members
                                      .firstWhere((m) => m.isCurrentUser)
                                      .id
                                      .contains(item.senderId)
                              ? () => _handleKudos(context, group, item.senderId)
                              : null,
                        );
                      },
                      childCount: group.feedItems.length,
                    ),
                  ),
                ),

                // --- Leaderboard ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: ValenceSpacing.lg),
                    child: WeeklyLeaderboard(
                      scores: group.weeklyScores,
                      copy: group.copy,
                      period: group.leaderboardPeriod,
                      onPeriodChanged: group.setLeaderboardPeriod,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: ValenceSpacing.huge),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleNudge(
    BuildContext context,
    GroupProvider group,
    String memberId,
  ) async {
    if (!group.canNudge) {
      ValenceToast.show(
        context,
        message: group.copy.nudgeDisabledReason,
        type: ToastType.warning,
      );
      return;
    }

    if (group.hasNudgedToday(memberId)) {
      ValenceToast.show(
        context,
        message: group.copy.nudgeAlreadySent,
        type: ToastType.info,
      );
      return;
    }

    final member = group.members.firstWhere((m) => m.id == memberId);
    final confirmed = await NudgeSheet.show(
      context,
      receiverName: member.name,
      copy: group.copy,
    );

    if (confirmed == true && context.mounted) {
      group.sendNudge(memberId);
      ValenceToast.show(
        context,
        message: group.copy.nudgeSentToast(member.name),
        type: ToastType.success,
      );
    }
  }

  void _handleKudos(
    BuildContext context,
    GroupProvider group,
    String memberId,
  ) {
    group.sendKudos(memberId);
    final member = group.members.firstWhere((m) => m.id == memberId);
    ValenceToast.show(
      context,
      message: group.copy.personalityOn
          ? '${member.name} just got their flowers 💐'
          : 'Kudos sent to ${member.name}',
      type: ToastType.success,
    );
  }
}

// ---------------------------------------------------------------------------
// Action bar (streak freeze + invite)
// ---------------------------------------------------------------------------

class _ActionBar extends StatelessWidget {
  final GroupProvider group;

  const _ActionBar({required this.group});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Row(
      children: [
        // Streak freeze button
        Expanded(
          child: GestureDetector(
            onTap: () => _handleFreeze(context, group),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: ValenceSpacing.smMd,
                vertical: ValenceSpacing.smMd,
              ),
              decoration: BoxDecoration(
                color: colors.surfacePrimary,
                borderRadius: ValenceRadii.mediumAll,
                border: Border.all(color: colors.borderDefault),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PhosphorIcon(
                    PhosphorIcons.snowflake(),
                    size: 18,
                    color: group.freezeActiveToday
                        ? colors.accentSecondary
                        : colors.textPrimary,
                  ),
                  const SizedBox(width: ValenceSpacing.sm),
                  Text(
                    group.freezeActiveToday
                        ? 'Freeze Active ❄️'
                        : 'Streak Freeze (${group.consistencyPoints} pts)',
                    style: tokens.typography.caption.copyWith(
                      color: group.freezeActiveToday
                          ? colors.accentSecondary
                          : colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleFreeze(BuildContext context, GroupProvider group) async {
    if (group.freezeActiveToday) {
      ValenceToast.show(
        context,
        message: group.copy.personalityOn
            ? 'Already frozen today --- chill. ❄️'
            : 'Streak freeze already active today.',
        type: ToastType.info,
      );
      return;
    }

    final confirmed = await StreakFreezeSheet.show(
      context,
      consistencyPoints: group.consistencyPoints,
      cost: group.freezeCost,
      canAfford: group.canAffordFreeze,
      copy: group.copy,
    );

    if (confirmed == true && context.mounted) {
      group.useStreakFreeze();
      ValenceToast.show(
        context,
        message: group.copy.freezeActivatedToast,
        type: ToastType.success,
      );
    }
  }
}
```

- [ ] **Step 2: Verify the screen builds**

```bash
cd client && flutter analyze lib/screens/group/group_screen.dart
```

Expected: No analysis issues.

- [ ] **Step 3: Commit**

```bash
git add client/lib/screens/group/group_screen.dart
git commit -m "feat: assemble full Group Screen with header, member grid, feed, leaderboard, and solo empty state"
```

---

### Task 15: Add FeedItemType import to feed_item.dart barrel and register GroupProvider in MainShell

**Files:**
- Modify: `client/lib/screens/main_shell.dart` (no changes needed --- GroupScreen is already in the tab list)

- [ ] **Step 1: Verify MainShell already imports GroupScreen**

The existing `main_shell.dart` already has `import 'package:valence/screens/group/group_screen.dart';` and includes `GroupScreen()` in its `_tabs` list. No changes needed.

- [ ] **Step 2: Run full project analysis**

```bash
cd client && flutter analyze
```

Expected: No new issues. All imports resolve correctly.

- [ ] **Step 3: Commit (if any adjustments were needed)**

```bash
# Only if changes were made:
# git add client/lib/screens/main_shell.dart
# git commit -m "fix: ensure MainShell correctly renders the new GroupScreen"
```

---

### Task 16: Manual QA verification

- [ ] **Step 1: Run the app and verify Group tab**

```bash
cd client && flutter run
```

**Verify:**
1. Navigate to the Group tab (Tab 1) --- full screen loads without errors
2. Header shows "Build Squad" with Ember tier badge and "14 day streak"
3. Member grid scrolls horizontally, shows 5 members with colored rings + badge icons
4. Nitil (all done) shows green ring + checkmark + kudos button
5. Ava (partial) shows amber ring + "3/5" badge + nudge button
6. Ravi (not started) shows gray ring + "–" badge + nudge button
7. Zara (inactive) shows muted ring + "💤" badge
8. Tapping "Nudge" on Ravi opens the NudgeSheet bottom sheet
9. Sending a nudge adds a nudge feed item at the top and shows a toast
10. Tapping "Nudge" on Ravi again shows "already nudged" message
11. Feed shows 12+ items with personality-ON copy (witty, fun)
12. Tapping the "Fun/Clean" toggle switches all copy to neutral mode
13. Chain strip shows the 7-day chain
14. Streak Freeze button shows "(42 pts)" --- tapping opens confirmation
15. Confirming freeze deducts points and shows "Freeze Active" state
16. Leaderboard shows 5 members ranked by consistency %
17. Tapping a leaderboard row expands to show contribution breakdown
18. Week/Month toggle switches the period label
19. Verification badges appear on plugin-tracked completions (LeetCode)

- [ ] **Step 2: Test solo mode**

Temporarily change `GroupProvider()` to `GroupProvider(soloMode: true)` in `group_screen.dart`:

**Verify:**
1. Empty state shows with playful title and body
2. "Create a Group" and "Join with Invite Link" buttons visible
3. Social proof card shows at bottom
4. Toggling personality OFF shows neutral copy

- [ ] **Step 3: Restore group mode and commit final state**

```bash
cd client && flutter analyze
git add -A
git commit -m "feat: complete Phase 4 --- Group Screen with personality layer, feed, leaderboard, nudge/kudos/freeze flows"
```

---

## Dependency Graph

```
Task 1 (GroupMember model)  ──┐
Task 2 (FeedItem model)   ────┤
Task 3 (WeeklyScore model) ───┤
Task 4 (PersonalityCopy)  ────┼──→ Task 5 (GroupProvider) ──→ Task 14 (GroupScreen)
                               │
Task 6 (MemberAvatar) ────────┤
Task 7 (MemberGrid) ──────────┤ (depends on Task 6)
Task 8 (FeedItemCard) ────────┤ (depends on Task 4)
Task 9 (GroupHeader) ─────────┤
Task 10 (WeeklyLeaderboard) ──┤ (depends on Task 3)
Task 11 (NudgeSheet) ─────────┤ (depends on Task 4)
Task 12 (StreakFreezeSheet) ───┤ (depends on Task 4)
Task 13 (SoloEmptyState) ─────┘ (depends on Task 4)

Task 15 (Integration check) ──→ depends on Task 14
Task 16 (QA) ─────────────────→ depends on Task 15
```

**Parallelizable:** Tasks 1-4 can run in parallel. Tasks 6-13 can run in parallel after Tasks 1-4 complete. Task 5 depends on Tasks 1-4. Task 14 depends on all of 5-13.
```

---

### Critical Files for Implementation
- `D:/@home/deepan/Downloads/valence/client/lib/utils/personality_copy.dart` -- the soul of the Group screen; all personality-aware copy for all 8 feed types, toasts, empty states, and action sheets lives here
- `D:/@home/deepan/Downloads/valence/client/lib/providers/group_provider.dart` -- all state management for the screen: members, feed items, leaderboard data, nudge/kudos/freeze actions, personality toggle, mock data
- `D:/@home/deepan/Downloads/valence/client/lib/screens/group/group_screen.dart` -- the screen assembly that composes all widgets, wires up the GroupProvider via Consumer, and handles action flows (nudge sheet, freeze sheet, kudos toasts)
- `D:/@home/deepan/Downloads/valence/client/lib/widgets/group/feed_item_card.dart` -- the most complex widget, handling 8 feed item type variants with personality-aware message resolution
- `D:/@home/deepan/Downloads/valence/client/lib/widgets/group/weekly_leaderboard.dart` -- stateful widget with expandable contribution breakdown rows, period toggle, and percentage-colored bars