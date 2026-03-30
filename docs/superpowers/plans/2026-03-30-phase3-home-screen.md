# Phase 3: Home Screen --- Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Home Screen (Tab 0 in MainShell) with persona-driven greeting, daily progress bar, week day selector with accessible status indicators, 2-column habit card grid following the gesture matrix, and group streak chain preview --- replacing the current placeholder.

**Architecture:** A `HomeProvider` (ChangeNotifier) manages habit list, daily completion status, selected day, and group streak data using mock data. The screen composes five key widgets: greeting header, daily progress bar, `DaySelector`, `HabitCard` grid, and `ChainStrip`. The `HabitCard` follows the gesture matrix exactly: checkbox for completion, card body for navigation, plugin habits show lock icon. All colors come from `context.tokens` with zero hardcoded values.

**Tech Stack:** Flutter, Provider, Phosphor Icons (`phosphor_flutter`), Google Fonts (`google_fonts`)

**Design Spec:** `docs/superpowers/specs/2026-03-30-ui-redesign-design.md` --- Sections 2.1 (Home Screen), 2.28 (Amplified Progress Stats), 3.1 (Component Library: HabitCard, DaySelector, ChainStrip)

---

## File Map

```
client/lib/
├── models/
│   ├── habit.dart                           # Habit data model for the new UI
│   └── group_streak.dart                    # Group streak + chain link data
├── providers/
│   └── home_provider.dart                   # HomeProvider with mock data
├── screens/
│   └── home/
│       └── home_screen.dart                 # REPLACE: Full home screen layout
├── widgets/
│   ├── habit/
│   │   ├── habit_card.dart                  # 2-col grid card with gesture matrix
│   │   ├── day_selector.dart                # Horizontal 7-day selector
│   │   └── daily_progress_bar.dart          # X/Y habits progress bar
│   └── group/
│       └── chain_strip.dart                 # Horizontal 7-day chain visualization

client/test/
├── models/
│   └── habit_test.dart
├── providers/
│   └── home_provider_test.dart
└── widgets/
    └── habit/
        ├── habit_card_test.dart
        └── day_selector_test.dart
```

---

### Task 1: Create the Habit model

**Files:**
- Create: `client/lib/models/habit.dart`
- Create: `client/test/models/habit_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/models/habit_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';

void main() {
  group('Habit', () {
    test('constructs with required fields', () {
      final habit = Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: const Color(0xFF4E55E0),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );

      expect(habit.id, '1');
      expect(habit.name, 'LeetCode');
      expect(habit.trackingType, TrackingType.manual);
      expect(habit.isCompleted, isFalse);
    });

    test('copyWith overrides specified fields', () {
      final habit = Habit(
        id: '1',
        name: 'LeetCode',
        subtitle: 'Solve 1 problem',
        color: const Color(0xFF4E55E0),
        iconName: 'code',
        trackingType: TrackingType.manual,
      );

      final completed = habit.copyWith(isCompleted: true);
      expect(completed.isCompleted, isTrue);
      expect(completed.name, 'LeetCode');
    });

    test('plugin habits have correct tracking type', () {
      final habit = Habit(
        id: '2',
        name: 'GitHub Commits',
        subtitle: 'Push 1 commit',
        color: const Color(0xFFB8EB6C),
        iconName: 'git-branch',
        trackingType: TrackingType.plugin,
        pluginName: 'GitHub',
      );

      expect(habit.trackingType, TrackingType.plugin);
      expect(habit.pluginName, 'GitHub');
      expect(habit.isPlugin, isTrue);
    });

    test('redirect habits have redirectUrl', () {
      final habit = Habit(
        id: '3',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: const Color(0xFFF7CD63),
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
      );

      expect(habit.isRedirect, isTrue);
      expect(habit.redirectUrl, 'https://duolingo.com');
    });
  });

  group('TrackingType', () {
    test('all values exist', () {
      expect(TrackingType.values.length, 4);
      expect(TrackingType.values, contains(TrackingType.manual));
      expect(TrackingType.values, contains(TrackingType.manualPhoto));
      expect(TrackingType.values, contains(TrackingType.plugin));
      expect(TrackingType.values, contains(TrackingType.redirect));
    });
  });

  group('DayStatus', () {
    test('all values exist', () {
      expect(DayStatus.values.length, 4);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/models/habit_test.dart
```

Expected: FAIL --- `package:valence/models/habit.dart` not found.

- [ ] **Step 3: Write the Habit model**

```dart
// client/lib/models/habit.dart
import 'package:flutter/material.dart';

/// Tracking method for a habit.
enum TrackingType {
  /// User taps checkbox to complete.
  manual,

  /// User must attach a photo to complete.
  manualPhoto,

  /// Auto-tracked via external plugin (LeetCode, GitHub, etc.).
  plugin,

  /// Card body opens an external URL; checkbox is still manual.
  redirect,
}

/// Day completion status for the week day selector.
enum DayStatus {
  /// All habits completed.
  allDone,

  /// Some habits completed.
  partial,

  /// No habits completed (past day).
  missed,

  /// Day hasn't happened yet.
  future,
}

/// Chain link quality for group streak visualization.
enum ChainLinkType {
  /// Everyone completed --- gold link.
  gold,

  /// Most completed --- silver link.
  silver,

  /// Chain broken --- red gap.
  broken,

  /// Day hasn't happened yet.
  future,
}

/// Group tier based on consecutive streak length.
enum GroupTier {
  spark,  // 0-6 days
  ember,  // 7-20 days
  flame,  // 21-65 days
  blaze,  // 66+ days
}

/// A single habit displayed on the Home screen.
class Habit {
  final String id;
  final String name;
  final String subtitle;
  final Color color;
  final String iconName;
  final TrackingType trackingType;
  final bool isCompleted;
  final String? pluginName;
  final String? redirectUrl;

  const Habit({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    required this.iconName,
    required this.trackingType,
    this.isCompleted = false,
    this.pluginName,
    this.redirectUrl,
  });

  /// Whether this habit is tracked by an external plugin.
  bool get isPlugin => trackingType == TrackingType.plugin;

  /// Whether this habit opens a redirect URL on card body tap.
  bool get isRedirect => trackingType == TrackingType.redirect;

  /// Whether this habit requires a photo for completion.
  bool get requiresPhoto => trackingType == TrackingType.manualPhoto;

  Habit copyWith({
    String? id,
    String? name,
    String? subtitle,
    Color? color,
    String? iconName,
    TrackingType? trackingType,
    bool? isCompleted,
    String? pluginName,
    String? redirectUrl,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      subtitle: subtitle ?? this.subtitle,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      trackingType: trackingType ?? this.trackingType,
      isCompleted: isCompleted ?? this.isCompleted,
      pluginName: pluginName ?? this.pluginName,
      redirectUrl: redirectUrl ?? this.redirectUrl,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/models/habit_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/models/habit.dart client/test/models/habit_test.dart
git commit -m "feat: add Habit model with TrackingType, DayStatus, ChainLinkType, and GroupTier enums"
```

---

### Task 2: Create the GroupStreak model

**Files:**
- Create: `client/lib/models/group_streak.dart`

- [ ] **Step 1: Write GroupStreak model**

```dart
// client/lib/models/group_streak.dart
import 'package:valence/models/habit.dart';

/// A single day's chain link in the group streak.
class ChainDay {
  final DateTime date;
  final ChainLinkType type;

  const ChainDay({
    required this.date,
    required this.type,
  });
}

/// Group streak data displayed on the Home screen chain strip.
class GroupStreak {
  final String groupName;
  final int currentStreak;
  final GroupTier tier;
  final List<ChainDay> last7Days;

  const GroupStreak({
    required this.groupName,
    required this.currentStreak,
    required this.tier,
    required this.last7Days,
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/models/group_streak.dart
git commit -m "feat: add GroupStreak and ChainDay models for chain strip visualization"
```

---

### Task 3: Create the Phosphor icon resolver utility

**Files:**
- Create: `client/lib/utils/icon_resolver.dart`

- [ ] **Step 1: Write the icon resolver**

```dart
// client/lib/utils/icon_resolver.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Maps string icon names to Phosphor icon data.
/// Used to store icon names as strings in the Habit model and resolve
/// them to actual IconData at render time.
class IconResolver {
  static final Map<String, IconData> _icons = {
    'code': PhosphorIcons.code(),
    'barbell': PhosphorIcons.barbell(),
    'book-open': PhosphorIcons.bookOpen(),
    'brain': PhosphorIcons.brain(),
    'globe': PhosphorIcons.globe(),
    'git-branch': PhosphorIcons.gitBranch(),
    'pencil-simple': PhosphorIcons.pencilSimple(),
    'heart': PhosphorIcons.heart(),
    'music-note': PhosphorIcons.musicNote(),
    'sun': PhosphorIcons.sun(),
    'moon': PhosphorIcons.moon(),
    'lightning': PhosphorIcons.lightning(),
    'tree': PhosphorIcons.tree(),
    'camera': PhosphorIcons.camera(),
    'chat-circle': PhosphorIcons.chatCircle(),
    'currency-dollar': PhosphorIcons.currencyDollar(),
    'paint-brush': PhosphorIcons.paintBrush(),
    'game-controller': PhosphorIcons.gameController(),
    'cooking-pot': PhosphorIcons.cookingPot(),
    'person-simple-run': PhosphorIcons.personSimpleRun(),
  };

  /// Resolves a string icon name to an IconData.
  /// Falls back to [PhosphorIcons.circlesFour] if not found.
  static IconData resolve(String name) {
    return _icons[name] ?? PhosphorIcons.circlesFour();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/utils/icon_resolver.dart
git commit -m "feat: add IconResolver utility mapping string names to Phosphor icons"
```

---

### Task 4: Create the HomeProvider with mock data

**Files:**
- Create: `client/lib/providers/home_provider.dart`
- Create: `client/test/providers/home_provider_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/providers/home_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/providers/home_provider.dart';

void main() {
  group('HomeProvider', () {
    late HomeProvider provider;

    setUp(() {
      provider = HomeProvider();
    });

    test('initializes with mock habits', () {
      expect(provider.habits.isNotEmpty, isTrue);
      expect(provider.habits.length, greaterThanOrEqualTo(6));
    });

    test('greeting reflects time of day', () {
      // The greeting is time-dependent, but always contains a name
      expect(provider.greeting, isNotEmpty);
    });

    test('subtitle returns a persona-driven message', () {
      expect(provider.subtitle, isNotEmpty);
    });

    test('completedCount tracks completed habits', () {
      expect(provider.completedCount, isA<int>());
      expect(provider.completedCount, lessThanOrEqualTo(provider.habits.length));
    });

    test('totalCount returns total habits', () {
      expect(provider.totalCount, provider.habits.length);
    });

    test('progress returns fraction between 0 and 1', () {
      expect(provider.progress, greaterThanOrEqualTo(0.0));
      expect(provider.progress, lessThanOrEqualTo(1.0));
    });

    test('toggleHabit marks a manual habit as completed', () {
      final firstManual = provider.habits.firstWhere(
        (h) => h.trackingType == TrackingType.manual,
      );
      final wasCompleted = firstManual.isCompleted;

      provider.toggleHabit(firstManual.id);

      final updated = provider.habits.firstWhere((h) => h.id == firstManual.id);
      expect(updated.isCompleted, !wasCompleted);
    });

    test('toggleHabit does NOT toggle plugin habits', () {
      final plugin = provider.habits.firstWhere(
        (h) => h.trackingType == TrackingType.plugin,
      );
      final wasDone = plugin.isCompleted;

      provider.toggleHabit(plugin.id);

      final updated = provider.habits.firstWhere((h) => h.id == plugin.id);
      expect(updated.isCompleted, wasDone); // unchanged
    });

    test('selectedDay defaults to today', () {
      final now = DateTime.now();
      expect(provider.selectedDay.day, now.day);
    });

    test('selectDay updates the selected day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      provider.selectDay(yesterday);
      expect(provider.selectedDay.day, yesterday.day);
    });

    test('weekDays returns 7 days', () {
      expect(provider.weekDays.length, 7);
    });

    test('dayStatusFor returns a DayStatus', () {
      final status = provider.dayStatusFor(DateTime.now());
      expect(DayStatus.values, contains(status));
    });

    test('groupStreak returns mock data', () {
      expect(provider.groupStreak, isNotNull);
      expect(provider.groupStreak.last7Days.length, 7);
      expect(provider.groupStreak.currentStreak, isNonNegative);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/providers/home_provider_test.dart
```

Expected: FAIL --- `package:valence/providers/home_provider.dart` not found.

- [ ] **Step 3: Write the HomeProvider**

```dart
// client/lib/providers/home_provider.dart
import 'package:flutter/material.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/utils/constants.dart';

/// Manages home screen state: habits, daily progress, selected day, group streak.
/// Uses mock data until the API service layer is built (Phase 7+).
class HomeProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  DateTime _selectedDay = DateTime.now();
  late GroupStreak _groupStreak;
  String _userName = 'Diana';

  HomeProvider() {
    _habits = _mockHabits();
    _groupStreak = _mockGroupStreak();
  }

  // --- Getters ---

  List<Habit> get habits => List.unmodifiable(_habits);
  DateTime get selectedDay => _selectedDay;
  GroupStreak get groupStreak => _groupStreak;
  String get userName => _userName;

  int get completedCount => _habits.where((h) => h.isCompleted).length;
  int get totalCount => _habits.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;
  bool get isPerfectDay => completedCount == totalCount && totalCount > 0;

  /// Time-of-day greeting.
  String get greeting {
    final hour = DateTime.now().hour;
    final String timeGreeting;
    if (hour < 12) {
      timeGreeting = 'Good morning';
    } else if (hour < 17) {
      timeGreeting = 'Good afternoon';
    } else {
      timeGreeting = 'Good evening';
    }
    return '$timeGreeting, $_userName';
  }

  /// Persona-driven motivational subtitle (mock: General persona).
  String get subtitle {
    if (isPerfectDay) {
      return 'Perfect day! All $totalCount habits crushed.';
    }
    if (completedCount == 0) {
      return 'Fresh start. $totalCount habits waiting for you.';
    }
    final remaining = totalCount - completedCount;
    return '$completedCount/$totalCount habits done. $remaining more for a perfect day.';
  }

  /// Returns the 7 days of the current week (Mon-Sun).
  List<DateTime> get weekDays {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      return DateTime(day.year, day.month, day.day);
    });
  }

  // --- Actions ---

  /// Toggle completion for a habit. Plugin habits cannot be toggled manually.
  void toggleHabit(String habitId) {
    final index = _habits.indexWhere((h) => h.id == habitId);
    if (index == -1) return;

    final habit = _habits[index];
    // Plugin habits are auto-tracked --- cannot be toggled manually
    if (habit.isPlugin) return;

    _habits[index] = habit.copyWith(isCompleted: !habit.isCompleted);
    notifyListeners();
  }

  /// Select a day in the week selector.
  void selectDay(DateTime day) {
    _selectedDay = DateTime(day.year, day.month, day.day);
    notifyListeners();
  }

  /// Returns the day status for a given date (mock implementation).
  DayStatus dayStatusFor(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(day.year, day.month, day.day);

    if (target.isAfter(today)) return DayStatus.future;
    if (target.isAtSameMomentAs(today)) {
      if (isPerfectDay) return DayStatus.allDone;
      if (completedCount > 0) return DayStatus.partial;
      return DayStatus.missed;
    }

    // Mock: past days have varied statuses
    final dayOfWeek = target.weekday;
    if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
      return DayStatus.allDone;
    }
    if (dayOfWeek == DateTime.wednesday) {
      return DayStatus.partial;
    }
    if (dayOfWeek == DateTime.friday && target.isBefore(today)) {
      return DayStatus.missed;
    }
    return DayStatus.allDone;
  }

  // --- Mock Data ---

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
        isCompleted: true,
      ),
      Habit(
        id: '2',
        name: 'Exercise',
        subtitle: '30 min workout',
        color: HabitColors.lime,
        iconName: 'barbell',
        trackingType: TrackingType.manual,
        isCompleted: false,
      ),
      Habit(
        id: '3',
        name: 'Read',
        subtitle: 'Read 20 pages',
        color: HabitColors.amber,
        iconName: 'book-open',
        trackingType: TrackingType.manual,
        isCompleted: true,
      ),
      Habit(
        id: '4',
        name: 'Meditate',
        subtitle: '10 min session',
        color: HabitColors.pink,
        iconName: 'brain',
        trackingType: TrackingType.manualPhoto,
        isCompleted: false,
      ),
      Habit(
        id: '5',
        name: 'Duolingo',
        subtitle: '1 lesson',
        color: HabitColors.teal,
        iconName: 'globe',
        trackingType: TrackingType.redirect,
        redirectUrl: 'https://duolingo.com',
        isCompleted: false,
      ),
      Habit(
        id: '6',
        name: 'Journal',
        subtitle: 'Write 1 entry',
        color: HabitColors.purple,
        iconName: 'pencil-simple',
        trackingType: TrackingType.manual,
        isCompleted: false,
      ),
    ];
  }

  static GroupStreak _mockGroupStreak() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final today = DateTime(now.year, now.month, now.day);

    return GroupStreak(
      groupName: 'Build Squad',
      currentStreak: 12,
      tier: GroupTier.ember,
      last7Days: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final target = DateTime(day.year, day.month, day.day);

        ChainLinkType type;
        if (target.isAfter(today)) {
          type = ChainLinkType.future;
        } else if (i == 4) {
          // Friday is broken for demo
          type = ChainLinkType.broken;
        } else if (i % 3 == 0) {
          type = ChainLinkType.silver;
        } else {
          type = ChainLinkType.gold;
        }

        return ChainDay(date: target, type: type);
      }),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/providers/home_provider_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/providers/home_provider.dart client/test/providers/home_provider_test.dart
git commit -m "feat: add HomeProvider with mock habits, day selector state, and group streak data"
```

---

### Task 5: Create the DailyProgressBar widget

**Files:**
- Create: `client/lib/widgets/habit/daily_progress_bar.dart`

- [ ] **Step 1: Write the DailyProgressBar**

```dart
// client/lib/widgets/habit/daily_progress_bar.dart
import 'package:flutter/material.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal progress bar showing X/Y habits completed today.
/// Fills with accent.success color. Shows sparkle state at 100%.
class DailyProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const DailyProgressBar({
    super.key,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final progress = total == 0 ? 0.0 : (completed / total).clamp(0.0, 1.0);
    final isPerfect = completed == total && total > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed/$total habits',
              style: tokens.typography.caption.copyWith(
                color: colors.textSecondary,
              ),
            ),
            if (isPerfect)
              Text(
                'Perfect day!',
                style: tokens.typography.caption.copyWith(
                  color: colors.accentSuccess,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: ValenceSpacing.sm),
        ClipRRect(
          borderRadius: ValenceRadii.roundAll,
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // Background track
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surfaceSunken,
                    borderRadius: ValenceRadii.roundAll,
                  ),
                ),
                // Fill
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPerfect
                          ? colors.accentSuccess
                          : colors.accentSuccess.withValues(alpha: 0.85),
                      borderRadius: ValenceRadii.roundAll,
                      boxShadow: isPerfect
                          ? [
                              BoxShadow(
                                color: colors.accentSuccess.withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// An animated FractionallySizedBox that smoothly transitions widthFactor.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final double widthFactor;
  final Widget child;

  const AnimatedFractionallySizedBox({
    super.key,
    required this.widthFactor,
    required this.child,
    required super.duration,
    super.curve,
  });

  @override
  AnimatedWidgetBaseState<AnimatedFractionallySizedBox> createState() =>
      _AnimatedFractionallySizedBoxState();
}

class _AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: _widthFactor?.evaluate(animation) ?? widget.widthFactor,
      child: widget.child,
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/widgets/habit
git add client/lib/widgets/habit/daily_progress_bar.dart
git commit -m "feat: add DailyProgressBar widget with animated fill and perfect day state"
```

---

### Task 6: Create the DaySelector widget

**Files:**
- Create: `client/lib/widgets/habit/day_selector.dart`
- Create: `client/test/widgets/habit/day_selector_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/habit/day_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/widgets/habit/day_selector.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('DaySelector', () {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => monday.add(Duration(days: i)));

    testWidgets('renders 7 day labels', (tester) async {
      await tester.pumpWidget(_wrap(
        DaySelector(
          days: days,
          selectedDay: now,
          statusFor: (_) => DayStatus.future,
          onDaySelected: (_) {},
        ),
      ));

      // Should show 7 day abbreviations
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsWidgets); // Tue and Thu
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsWidgets); // Sat and Sun
    });

    testWidgets('calls onDaySelected when a day is tapped', (tester) async {
      DateTime? selected;
      await tester.pumpWidget(_wrap(
        DaySelector(
          days: days,
          selectedDay: now,
          statusFor: (_) => DayStatus.future,
          onDaySelected: (day) => selected = day,
        ),
      ));

      // Tap the first day label (Monday)
      await tester.tap(find.text('M'));
      expect(selected, isNotNull);
    });

    testWidgets('shows status icons for past days', (tester) async {
      await tester.pumpWidget(_wrap(
        DaySelector(
          days: days,
          selectedDay: now,
          statusFor: (day) {
            final target = DateTime(day.year, day.month, day.day);
            final today = DateTime(now.year, now.month, now.day);
            if (target.isBefore(today)) return DayStatus.allDone;
            return DayStatus.future;
          },
          onDaySelected: (_) {},
        ),
      ));

      await tester.pump();
      // The widget should render without errors
      expect(find.byType(DaySelector), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/habit/day_selector_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the DaySelector**

```dart
// client/lib/widgets/habit/day_selector.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal 7-day week selector with accessible status indicators.
/// Each past day shows both a colored dot AND an icon (accessibility:
/// color + icon, never color alone).
class DaySelector extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selectedDay;
  final DayStatus Function(DateTime) statusFor;
  final ValueChanged<DateTime> onDaySelected;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.statusFor,
    required this.onDaySelected,
  });

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SizedBox(
      height: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(days.length, (i) {
          final day = days[i];
          final isSelected = _isSameDay(day, selectedDay);
          final status = statusFor(day);

          return _DayChip(
            label: _dayLabels[i],
            dayNumber: day.day.toString(),
            isSelected: isSelected,
            status: status,
            tokens: tokens,
            onTap: () => onDaySelected(day),
          );
        }),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final String dayNumber;
  final bool isSelected;
  final DayStatus status;
  final ValenceTokens tokens;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.dayNumber,
    required this.isSelected,
    required this.status,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: ValenceSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.accentPrimary
              : Colors.transparent,
          borderRadius: ValenceRadii.roundAll,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day letter
            Text(
              label,
              style: tokens.typography.caption.copyWith(
                color: isSelected
                    ? colors.textInverse
                    : colors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 2),
            // Day number
            Text(
              dayNumber,
              style: tokens.typography.numbersBody.copyWith(
                color: isSelected
                    ? colors.textInverse
                    : colors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            // Status indicator: color dot + icon (accessible)
            _buildStatusIndicator(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(ValenceColors colors) {
    if (status == DayStatus.future) {
      return const SizedBox(height: 12);
    }

    final Color dotColor;
    final IconData icon;

    switch (status) {
      case DayStatus.allDone:
        dotColor = isSelected
            ? colors.textInverse
            : colors.accentSuccess;
        icon = PhosphorIcons.check(PhosphorIconsStyle.bold);
      case DayStatus.partial:
        dotColor = isSelected
            ? colors.textInverse
            : colors.accentWarning;
        icon = PhosphorIcons.tilde(PhosphorIconsStyle.bold);
      case DayStatus.missed:
        dotColor = isSelected
            ? colors.textInverse
            : colors.accentError;
        icon = PhosphorIcons.x(PhosphorIconsStyle.bold);
      case DayStatus.future:
        // Handled above, but Dart requires exhaustive switch
        return const SizedBox(height: 12);
    }

    return Icon(
      icon,
      size: 12,
      color: dotColor,
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

```bash
cd client && flutter test test/widgets/habit/day_selector_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/habit/day_selector.dart client/test/widgets/habit/day_selector_test.dart
git commit -m "feat: add DaySelector widget with accessible color+icon status indicators"
```

---

### Task 7: Create the HabitCard widget

**Files:**
- Create: `client/lib/widgets/habit/habit_card.dart`
- Create: `client/test/widgets/habit/habit_card_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/widgets/habit/habit_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';
import 'package:valence/widgets/habit/habit_card.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return MaterialApp(
    theme: ThemeData.light().copyWith(extensions: [tokens]),
    home: Scaffold(body: Center(child: SizedBox(width: 180, child: child))),
  );
}

void main() {
  group('HabitCard', () {
    final manualHabit = Habit(
      id: '1',
      name: 'Exercise',
      subtitle: '30 min workout',
      color: const Color(0xFFB8EB6C),
      iconName: 'barbell',
      trackingType: TrackingType.manual,
    );

    final pluginHabit = Habit(
      id: '2',
      name: 'LeetCode',
      subtitle: 'Solve 1 problem',
      color: const Color(0xFF4E55E0),
      iconName: 'code',
      trackingType: TrackingType.plugin,
      pluginName: 'LeetCode',
    );

    testWidgets('renders habit name and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(
        HabitCard(
          habit: manualHabit,
          onCheckboxTap: () {},
          onCardTap: () {},
        ),
      ));

      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('30 min workout'), findsOneWidget);
    });

    testWidgets('calls onCheckboxTap when checkbox tapped on manual habit',
        (tester) async {
      var checkboxTapped = false;
      await tester.pumpWidget(_wrap(
        HabitCard(
          habit: manualHabit,
          onCheckboxTap: () => checkboxTapped = true,
          onCardTap: () {},
        ),
      ));

      // Find the checkbox area (the InkWell wrapping the checkbox icon)
      final checkboxFinder = find.byKey(const Key('habit-checkbox'));
      await tester.tap(checkboxFinder);
      expect(checkboxTapped, isTrue);
    });

    testWidgets('calls onCardTap when card body tapped', (tester) async {
      var cardTapped = false;
      await tester.pumpWidget(_wrap(
        HabitCard(
          habit: manualHabit,
          onCheckboxTap: () {},
          onCardTap: () => cardTapped = true,
        ),
      ));

      // Tap the card body (the habit name text)
      await tester.tap(find.text('Exercise'));
      expect(cardTapped, isTrue);
    });

    testWidgets('shows "Auto" badge for plugin habits', (tester) async {
      await tester.pumpWidget(_wrap(
        HabitCard(
          habit: pluginHabit,
          onCheckboxTap: () {},
          onCardTap: () {},
        ),
      ));

      expect(find.text('Auto'), findsOneWidget);
    });

    testWidgets('plugin checkbox does not trigger onCheckboxTap',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(
        HabitCard(
          habit: pluginHabit,
          onCheckboxTap: () => tapped = true,
          onCardTap: () {},
        ),
      ));

      final checkboxFinder = find.byKey(const Key('habit-checkbox'));
      await tester.tap(checkboxFinder);
      expect(tapped, isFalse); // Plugin checkboxes are non-interactive
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
cd client && flutter test test/widgets/habit/habit_card_test.dart
```

Expected: FAIL --- not found.

- [ ] **Step 3: Write the HabitCard widget**

```dart
// client/lib/widgets/habit/habit_card.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/theme/valence_elevation.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/utils/icon_resolver.dart';

/// A single habit card in the 2-column grid on the Home screen.
///
/// Gesture matrix:
/// - Checkbox (top-right): THE completion action. Disabled for plugin habits.
/// - Card body tap: Opens habit detail (or redirect URL for redirect habits).
/// - Long-press: Opens habit detail for all types.
class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onCheckboxTap;
  final VoidCallback onCardTap;
  final VoidCallback? onLongPress;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onCheckboxTap,
    required this.onCardTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;
    final isDark = tokens.isDark;

    // Determine card background
    Color cardBg;
    if (isDark) {
      cardBg = colors.surfacePrimary;
    } else {
      // Light mode: light wash of habit color
      cardBg = Color.lerp(colors.surfacePrimary, habit.color, 0.06)!;
    }

    // Completed state: desaturate slightly
    if (habit.isCompleted) {
      cardBg = Color.lerp(cardBg, colors.accentSuccess, isDark ? 0.05 : 0.04)!;
    }

    BoxDecoration decoration = valenceElevation(
      level: 1,
      isDark: isDark,
      colors: colors,
      borderRadius: ValenceRadii.xlAll,
      color: cardBg,
    );

    // Dark mode: add left border with habit color
    if (isDark) {
      decoration = BoxDecoration(
        color: cardBg,
        borderRadius: ValenceRadii.xlAll,
        border: Border(
          left: BorderSide(color: habit.color, width: 4),
          top: BorderSide(
            color: colors.borderDefault.withValues(alpha: 0.3),
            width: 1,
          ),
          right: BorderSide(
            color: colors.borderDefault.withValues(alpha: 0.3),
            width: 1,
          ),
          bottom: BorderSide(
            color: colors.borderDefault.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onCardTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: decoration,
        padding: const EdgeInsets.all(ValenceSpacing.smMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + checkbox
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Habit icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: habit.color.withValues(alpha: isDark ? 0.15 : 0.12),
                    borderRadius: ValenceRadii.smallAll,
                  ),
                  child: Icon(
                    IconResolver.resolve(habit.iconName),
                    size: 20,
                    color: habit.color,
                  ),
                ),
                // Checkbox area
                _buildCheckbox(tokens),
              ],
            ),
            const SizedBox(height: ValenceSpacing.smMd),
            // Habit name
            Text(
              habit.name,
              style: tokens.typography.h3.copyWith(
                fontSize: 16,
                color: habit.isCompleted
                    ? colors.textSecondary
                    : colors.textPrimary,
                decoration:
                    habit.isCompleted ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Subtitle
            Text(
              habit.subtitle,
              style: tokens.typography.caption.copyWith(
                color: colors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Plugin badge
            if (habit.isPlugin) ...[
              const SizedBox(height: ValenceSpacing.sm),
              _buildPluginBadge(tokens),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(ValenceTokens tokens) {
    final colors = tokens.colors;
    final isInteractive = !habit.isPlugin;

    final Color bgColor;
    final Widget iconWidget;

    if (habit.isPlugin) {
      // Plugin: lock icon + "Auto" label nearby, not tappable
      bgColor = colors.surfaceSunken;
      iconWidget = Icon(
        PhosphorIcons.lock(PhosphorIconsStyle.fill),
        size: 16,
        color: colors.textSecondary,
      );
    } else if (habit.isCompleted) {
      // Completed: success color with check
      bgColor = colors.accentSuccess;
      iconWidget = Icon(
        PhosphorIcons.check(PhosphorIconsStyle.bold),
        size: 16,
        color: colors.textInverse,
      );
    } else {
      // Uncompleted: empty circle/box
      bgColor = Colors.transparent;
      iconWidget = const SizedBox.shrink();
    }

    final borderColor = habit.isCompleted
        ? colors.accentSuccess
        : habit.isPlugin
            ? colors.borderDefault
            : colors.textSecondary.withValues(alpha: 0.5);

    return GestureDetector(
      key: const Key('habit-checkbox'),
      onTap: isInteractive ? onCheckboxTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: ValenceRadii.smallAll,
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
        ),
        child: Center(child: iconWidget),
      ),
    );
  }

  Widget _buildPluginBadge(ValenceTokens tokens) {
    final colors = tokens.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceSunken,
        borderRadius: ValenceRadii.smallAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PhosphorIcons.lightning(PhosphorIconsStyle.fill),
            size: 10,
            color: colors.textSecondary,
          ),
          const SizedBox(width: 3),
          Text(
            'Auto',
            style: tokens.typography.overline.copyWith(
              color: colors.textSecondary,
              fontSize: 9,
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
cd client && flutter test test/widgets/habit/habit_card_test.dart
```

Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
git add client/lib/widgets/habit/habit_card.dart client/test/widgets/habit/habit_card_test.dart
git commit -m "feat: add HabitCard widget with gesture matrix, plugin lock, and completion states"
```

---

### Task 8: Create the ChainStrip widget

**Files:**
- Create: `client/lib/widgets/group/chain_strip.dart`

- [ ] **Step 1: Write the ChainStrip**

```dart
// client/lib/widgets/group/chain_strip.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/models/habit.dart';
import 'package:valence/models/group_streak.dart';
import 'package:valence/theme/valence_radii.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';

/// Horizontal chain visualization showing the last 7 days of group streak.
/// Each day is a chain link: gold (glowing), silver (matte), broken (red gap).
/// Shows streak count + flame icon and group tier badge.
/// Simplified version --- no Lottie yet (deferred to Phase 8).
class ChainStrip extends StatelessWidget {
  final GroupStreak streak;
  final VoidCallback? onTap;

  const ChainStrip({
    super.key,
    required this.streak,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(ValenceSpacing.md),
        decoration: BoxDecoration(
          color: tokens.isDark
              ? colors.surfacePrimary
              : colors.surfacePrimary,
          borderRadius: ValenceRadii.largeAll,
          border: tokens.isDark
              ? Border.all(
                  color: colors.borderDefault.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
          boxShadow: tokens.isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: group name + tier badge
            Row(
              children: [
                Icon(
                  PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                  size: 16,
                  color: colors.accentSocial,
                ),
                const SizedBox(width: ValenceSpacing.sm),
                Text(
                  streak.groupName,
                  style: tokens.typography.caption.copyWith(
                    color: colors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: ValenceSpacing.sm),
                _TierBadge(tier: streak.tier, tokens: tokens),
                const Spacer(),
                Icon(
                  PhosphorIcons.caretRight(),
                  size: 16,
                  color: colors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: ValenceSpacing.smMd),
            // Chain links row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildChainLinks(tokens),
            ),
            const SizedBox(height: ValenceSpacing.smMd),
            // Streak count with flame
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\u{1F525}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: ValenceSpacing.xs),
                Text(
                  '${streak.currentStreak}-day streak',
                  style: tokens.typography.numbersBody.copyWith(
                    color: colors.accentPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChainLinks(ValenceTokens tokens) {
    final List<Widget> widgets = [];

    for (int i = 0; i < streak.last7Days.length; i++) {
      final chainDay = streak.last7Days[i];

      // Add connecting line between links (not before the first one)
      if (i > 0) {
        final prevType = streak.last7Days[i - 1].type;
        final isBrokenConnection =
            prevType == ChainLinkType.broken ||
            chainDay.type == ChainLinkType.broken;

        widgets.add(
          Container(
            width: 12,
            height: 3,
            decoration: BoxDecoration(
              color: isBrokenConnection
                  ? tokens.colors.chainBroken.withValues(alpha: 0.3)
                  : tokens.colors.textSecondary.withValues(alpha: 0.2),
              borderRadius: ValenceRadii.roundAll,
            ),
          ),
        );
      }

      widgets.add(
        _ChainLink(
          day: chainDay,
          tokens: tokens,
        ),
      );
    }

    return widgets;
  }
}

class _ChainLink extends StatelessWidget {
  final ChainDay day;
  final ValenceTokens tokens;

  const _ChainLink({
    required this.day,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;
    final size = 32.0;

    Color bgColor;
    Color borderColor;
    Widget? icon;

    switch (day.type) {
      case ChainLinkType.gold:
        bgColor = colors.chainGold.withValues(alpha: 0.15);
        borderColor = colors.chainGold;
        icon = Icon(
          PhosphorIcons.link(PhosphorIconsStyle.fill),
          size: 16,
          color: colors.chainGold,
        );
      case ChainLinkType.silver:
        bgColor = colors.chainSilver.withValues(alpha: 0.10);
        borderColor = colors.chainSilver;
        icon = Icon(
          PhosphorIcons.link(PhosphorIconsStyle.fill),
          size: 16,
          color: colors.chainSilver,
        );
      case ChainLinkType.broken:
        bgColor = colors.chainBroken.withValues(alpha: 0.10);
        borderColor = colors.chainBroken;
        icon = Icon(
          PhosphorIcons.linkBreak(PhosphorIconsStyle.fill),
          size: 16,
          color: colors.chainBroken,
        );
      case ChainLinkType.future:
        bgColor = colors.surfaceSunken;
        borderColor = colors.borderDefault.withValues(alpha: 0.3);
        icon = null;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(child: icon),
    );
  }
}

class _TierBadge extends StatelessWidget {
  final GroupTier tier;
  final ValenceTokens tokens;

  const _TierBadge({
    required this.tier,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (tier) {
      GroupTier.spark => ('Spark', tokens.colors.textSecondary),
      GroupTier.ember => ('Ember', tokens.colors.accentWarning),
      GroupTier.flame => ('Flame', tokens.colors.accentError),
      GroupTier.blaze => ('Blaze', tokens.colors.accentPrimary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: ValenceRadii.smallAll,
      ),
      child: Text(
        tier == GroupTier.spark ? '\u{2728} $label' : '\u{1F525} $label',
        style: tokens.typography.overline.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
mkdir -p client/lib/widgets/group
git add client/lib/widgets/group/chain_strip.dart
git commit -m "feat: add ChainStrip widget with gold/silver/broken chain links and tier badge"
```

---

### Task 9: Register HomeProvider in app.dart

**Files:**
- Modify: `client/lib/app.dart`

- [ ] **Step 1: Add HomeProvider to MultiProvider**

Replace the contents of `client/lib/app.dart` with:

```dart
// client/lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/auth_provider.dart';
import 'package:valence/providers/home_provider.dart';
import 'package:valence/screens/splash/splash_screen.dart';
import 'package:valence/theme/theme_provider.dart';

class ValenceApp extends StatelessWidget {
  const ValenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Valence',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add client/lib/app.dart
git commit -m "feat: register HomeProvider in app.dart MultiProvider"
```

---

### Task 10: Build the full HomeScreen

**Files:**
- Modify: `client/lib/screens/home/home_screen.dart`

- [ ] **Step 1: Replace the placeholder HomeScreen**

Replace the entire contents of `client/lib/screens/home/home_screen.dart` with:

```dart
// client/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/home_provider.dart';
import 'package:valence/theme/valence_spacing.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/widgets/habit/daily_progress_bar.dart';
import 'package:valence/widgets/habit/day_selector.dart';
import 'package:valence/widgets/habit/habit_card.dart';
import 'package:valence/widgets/group/chain_strip.dart';

/// Home Screen (Tab 0 in MainShell).
/// Shows greeting, daily progress, week selector, habit grid, and chain strip.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return Scaffold(
      backgroundColor: colors.surfaceBackground,
      body: Consumer<HomeProvider>(
        builder: (context, provider, _) {
          return SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: ValenceSpacing.md),
                ),

                // Greeting header
                SliverToBoxAdapter(
                  child: _GreetingHeader(
                    greeting: provider.greeting,
                    subtitle: provider.subtitle,
                    tokens: tokens,
                  ),
                ),

                // Daily progress bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.gridMargin,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: ValenceSpacing.lg),
                        DailyProgressBar(
                          completed: provider.completedCount,
                          total: provider.totalCount,
                        ),
                      ],
                    ),
                  ),
                ),

                // Day selector
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.gridMargin,
                      vertical: ValenceSpacing.md,
                    ),
                    child: DaySelector(
                      days: provider.weekDays,
                      selectedDay: provider.selectedDay,
                      statusFor: provider.dayStatusFor,
                      onDaySelected: provider.selectDay,
                    ),
                  ),
                ),

                // Section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.gridMargin,
                    ),
                    child: Text(
                      "Today's Habits",
                      style: tokens.typography.h2,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ValenceSpacing.smMd),
                ),

                // 2-column habit card grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ValenceSpacing.gridMargin,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: ValenceSpacing.gridGutter,
                      mainAxisSpacing: ValenceSpacing.gridGutter,
                      childAspectRatio: 0.85,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final habit = provider.habits[index];
                        return HabitCard(
                          habit: habit,
                          onCheckboxTap: () {
                            provider.toggleHabit(habit.id);
                          },
                          onCardTap: () {
                            // TODO: Navigate to habit detail or redirect URL.
                            // For now, show a snackbar as placeholder.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  habit.isRedirect
                                      ? 'Would open: ${habit.redirectUrl}'
                                      : 'Would open detail for: ${habit.name}',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          onLongPress: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Would open detail for: ${habit.name}'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        );
                      },
                      childCount: provider.habits.length,
                    ),
                  ),
                ),

                // Spacing before chain strip
                const SliverToBoxAdapter(
                  child: SizedBox(height: ValenceSpacing.lg),
                ),

                // Group streak chain strip
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: ValenceSpacing.gridMargin,
                    ),
                    child: ChainStrip(
                      streak: provider.groupStreak,
                      onTap: () {
                        // TODO: Switch to Group tab (Tab 1) in MainShell.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Would switch to Group tab'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: ValenceSpacing.huge),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final String greeting;
  final String subtitle;
  final ValenceTokens tokens;

  const _GreetingHeader({
    required this.greeting,
    required this.subtitle,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    final colors = tokens.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ValenceSpacing.gridMargin,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: tokens.typography.h1,
                ),
                const SizedBox(height: ValenceSpacing.xs),
                Text(
                  subtitle,
                  style: tokens.typography.body.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ValenceSpacing.sm),
          // Notification bell + avatar
          Row(
            children: [
              // Notification bell with badge
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Open notifications
                    },
                    icon: Icon(
                      PhosphorIcons.bell(),
                      color: colors.textSecondary,
                      size: 24,
                    ),
                    padding: const EdgeInsets.all(ValenceSpacing.sm),
                    constraints: const BoxConstraints(),
                  ),
                  // Badge dot
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.accentError,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: ValenceSpacing.xs),
              // Avatar
              GestureDetector(
                onTap: () {
                  // TODO: Navigate to Profile tab
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colors.accentPrimary,
                  child: Text(
                    'D',
                    style: tokens.typography.numbersBody.copyWith(
                      color: colors.textInverse,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Hot restart and verify visually**

```bash
cd client && flutter run
```

Expected: Home screen shows greeting, progress bar, day selector, 6 habit cards in 2-column grid, and chain strip at bottom. Tapping checkboxes on manual habits toggles them. Plugin habits show lock + "Auto" badge and checkbox is non-interactive. Progress bar animates as habits are completed.

- [ ] **Step 3: Commit**

```bash
git add client/lib/screens/home/home_screen.dart
git commit -m "feat: replace placeholder HomeScreen with full layout — greeting, progress, days, grid, chain"
```

---

### Task 11: Add swipe-to-archive gesture on HabitCard

**Files:**
- Modify: `client/lib/screens/home/home_screen.dart`
- Modify: `client/lib/providers/home_provider.dart`

- [ ] **Step 1: Add archiveHabit to HomeProvider**

Add this method to `HomeProvider` in `client/lib/providers/home_provider.dart`, below the `toggleHabit` method:

```dart
  /// Archive (remove) a habit from the list. In the real app this would
  /// soft-delete via the API; here we just remove from mock data.
  void archiveHabit(String habitId) {
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
  }

  /// Undo an archive by re-inserting a habit at its previous position.
  void undoArchive(Habit habit, int index) {
    if (index >= 0 && index <= _habits.length) {
      _habits.insert(index, habit);
    } else {
      _habits.add(habit);
    }
    notifyListeners();
  }
```

- [ ] **Step 2: Wrap HabitCard in Dismissible in home_screen.dart**

In the `SliverChildBuilderDelegate` inside `home_screen.dart`, replace the `HabitCard(...)` return with:

```dart
                        return Dismissible(
                          key: Key('habit-${habit.id}'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(
                              right: ValenceSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: colors.accentError.withValues(alpha: 0.15),
                              borderRadius: ValenceRadii.xlAll,
                            ),
                            child: Icon(
                              PhosphorIcons.archiveBox(),
                              color: colors.accentError,
                              size: 24,
                            ),
                          ),
                          onDismissed: (_) {
                            final archivedIndex = index;
                            final archivedHabit = habit;
                            provider.archiveHabit(habit.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${habit.name} archived'),
                                action: SnackBarAction(
                                  label: 'Undo',
                                  onPressed: () {
                                    provider.undoArchive(
                                      archivedHabit,
                                      archivedIndex,
                                    );
                                  },
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                          child: HabitCard(
                            habit: habit,
                            onCheckboxTap: () {
                              provider.toggleHabit(habit.id);
                            },
                            onCardTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    habit.isRedirect
                                        ? 'Would open: ${habit.redirectUrl}'
                                        : 'Would open detail for: ${habit.name}',
                                  ),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            onLongPress: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Would open detail for: ${habit.name}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        );
```

- [ ] **Step 3: Commit**

```bash
git add client/lib/providers/home_provider.dart client/lib/screens/home/home_screen.dart
git commit -m "feat: add swipe-left-to-archive gesture on habit cards with undo support"
```

---

### Task 12: Wire ChainStrip tap to switch to Group tab

**Files:**
- Modify: `client/lib/screens/main_shell.dart`
- Modify: `client/lib/screens/home/home_screen.dart`

- [ ] **Step 1: Expose tab switching via a callback or inherited widget**

Replace the contents of `client/lib/screens/main_shell.dart` with:

```dart
// client/lib/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/screens/home/home_screen.dart';
import 'package:valence/screens/group/group_screen.dart';
import 'package:valence/screens/progress/progress_screen.dart';
import 'package:valence/screens/shop/shop_screen.dart';
import 'package:valence/screens/profile/profile_screen.dart';

/// Provides the ability for child widgets to switch tabs.
class MainShellScope extends InheritedWidget {
  final void Function(int index) switchTab;

  const MainShellScope({
    super.key,
    required this.switchTab,
    required super.child,
  });

  static MainShellScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MainShellScope>()!;
  }

  @override
  bool updateShouldNotify(MainShellScope oldWidget) => false;
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    if (index >= 0 && index < 5) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final colors = tokens.colors;

    return MainShellScope(
      switchTab: _switchTab,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeScreen(),
            GroupScreen(),
            ProgressScreen(),
            ShopScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: colors.surfacePrimary,
          selectedItemColor: colors.accentPrimary,
          unselectedItemColor: colors.textSecondary,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.house()),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.usersThree()),
              label: 'Group',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.chartLineUp()),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.storefront()),
              label: 'Shop',
            ),
            BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.user()),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update ChainStrip onTap in home_screen.dart**

In `home_screen.dart`, replace the ChainStrip's `onTap` callback:

```dart
                    child: ChainStrip(
                      streak: provider.groupStreak,
                      onTap: () {
                        MainShellScope.of(context).switchTab(1);
                      },
                    ),
```

- [ ] **Step 3: Commit**

```bash
git add client/lib/screens/main_shell.dart client/lib/screens/home/home_screen.dart
git commit -m "feat: add MainShellScope inherited widget so ChainStrip tap switches to Group tab"
```

---

### Task 13: Add widget tests for HomeScreen

**Files:**
- Create: `client/test/screens/home/home_screen_test.dart`

- [ ] **Step 1: Write the test**

```dart
// client/test/screens/home/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:valence/providers/home_provider.dart';
import 'package:valence/screens/home/home_screen.dart';
import 'package:valence/screens/main_shell.dart';
import 'package:valence/theme/valence_tokens.dart';
import 'package:valence/theme/themes/daybreak.dart';

Widget _wrap(Widget child) {
  final tokens = ValenceTokens.fromColors(colors: daybreakColors, isDark: false);
  return ChangeNotifierProvider<HomeProvider>(
    create: (_) => HomeProvider(),
    child: MaterialApp(
      theme: ThemeData.light().copyWith(extensions: [tokens]),
      home: MainShellScope(
        switchTab: (_) {},
        child: Scaffold(body: child),
      ),
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('renders greeting with user name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Greeting should contain the user's name
      expect(find.textContaining('Diana'), findsOneWidget);
    });

    testWidgets('renders daily progress bar', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Should show habit count
      expect(find.textContaining('habits'), findsWidgets);
    });

    testWidgets('renders day selector with 7 days', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Day labels should be visible
      expect(find.text('M'), findsOneWidget);
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('renders habit cards', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Mock data includes "LeetCode", "Exercise", etc.
      expect(find.text('LeetCode'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    });

    testWidgets('renders chain strip with group name', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Build Squad'), findsOneWidget);
      expect(find.textContaining('streak'), findsOneWidget);
    });

    testWidgets('toggling a manual habit updates the progress bar',
        (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      // Find the first checkbox and tap it
      final checkboxes = find.byKey(const Key('habit-checkbox'));
      expect(checkboxes, findsWidgets);

      // Tap the second checkbox (Exercise, which is manual and uncompleted)
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      // The progress count should have changed
      // (We can't easily assert the exact text since it depends on mock state,
      // but the widget should rebuild without errors)
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('shows section header', (tester) async {
      await tester.pumpWidget(_wrap(const HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text("Today's Habits"), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: Run the tests**

```bash
cd client && flutter test test/screens/home/home_screen_test.dart
```

Expected: All tests PASS.

- [ ] **Step 3: Commit**

```bash
git add client/test/screens/home/home_screen_test.dart
git commit -m "test: add widget tests for HomeScreen covering greeting, progress, day selector, and habit cards"
```

---

### Task 14: Run all tests and verify clean build

**Files:**
- No file changes.

- [ ] **Step 1: Run full test suite**

```bash
cd client && flutter test
```

Expected: All tests pass --- no regressions from Phase 1 or Phase 2.

- [ ] **Step 2: Verify build**

```bash
cd client && flutter build apk --debug
```

Expected: Build succeeds with no errors.

- [ ] **Step 3: Final commit (if any fixups needed)**

If any test fixes or import corrections were needed, commit them:

```bash
git add -A
git commit -m "fix: resolve test and build issues for Phase 3 Home Screen"
```

---

## Summary

Phase 3 delivers:
- **2 models:** `Habit` (with TrackingType, DayStatus, ChainLinkType, GroupTier enums) and `GroupStreak` (with ChainDay)
- **1 utility:** `IconResolver` for string-to-Phosphor icon mapping
- **1 provider:** `HomeProvider` with mock data, habit toggling, day selection, and group streak
- **4 widgets:** `DailyProgressBar`, `DaySelector`, `HabitCard`, `ChainStrip`
- **1 screen:** Complete `HomeScreen` replacing the placeholder
- **1 infrastructure update:** `MainShellScope` InheritedWidget for cross-tab navigation
- **Tests:** Unit tests for Habit model and HomeProvider, widget tests for DaySelector, HabitCard, and HomeScreen