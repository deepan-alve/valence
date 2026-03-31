// client/lib/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:valence/models/user_profile.dart';
import 'package:valence/services/user_service.dart';

/// Light data class used by ProfileScreen's habit list.
class ProfileHabit {
  final String id;
  final String name;
  final String iconName;
  final int streakDays;
  final bool isArchived;

  const ProfileHabit({
    required this.id,
    required this.name,
    required this.iconName,
    required this.streakDays,
    this.isArchived = false,
  });
}

/// Summary statistics shown on the profile screen.
class ProfileStats {
  final int totalHabits;
  final int totalDaysCompleted;
  final int longestStreak;
  final int perfectDays;
  final int habitsGraduated;

  const ProfileStats({
    required this.totalHabits,
    required this.totalDaysCompleted,
    required this.longestStreak,
    required this.perfectDays,
    required this.habitsGraduated,
  });
}

/// Manages profile screen state: user info, habits list, stats, plugins, settings.
/// Loads real data from UserService; falls back to mock on error.
class ProfileProvider extends ChangeNotifier {
  final UserService _userService;

  UserProfile _profile = _mockProfile();
  ProfileStats _stats = _mockStats();
  List<ProfileHabit> _habits = _mockHabits();
  List<PluginConnection> _plugins = _mockPlugins();
  NotificationPreferences _notificationPrefs = const NotificationPreferences();

  bool _personalityOn = true;
  bool _loading = false;
  String? _error;

  ProfileProvider({UserService? userService})
      : _userService = userService ?? UserService() {
    _loadProfile();
  }

  // --- Getters ---
  UserProfile get profile => _profile;
  ProfileStats get stats => _stats;
  List<ProfileHabit> get activeHabits => _habits.where((h) => !h.isArchived).toList();
  List<ProfileHabit> get archivedHabits => _habits.where((h) => h.isArchived).toList();
  List<PluginConnection> get plugins => List.unmodifiable(_plugins);
  NotificationPreferences get notificationPrefs => _notificationPrefs;
  bool get personalityOn => _personalityOn;
  bool get isLoading => _loading;
  String? get error => _error;

  // --- Actions ---

  void setPersonaType(PersonaType type) {
    if (_profile.personaType == type) return;
    _profile = _profile.copyWith(personaType: type);
    notifyListeners();
    () async {
      try {
        await _userService.updateMe(personaType: type.name);
      } catch (_) {}
    }();
  }

  void archiveHabit(String habitId) {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    final h = _habits[idx];
    _habits[idx] = ProfileHabit(
      id: h.id,
      name: h.name,
      iconName: h.iconName,
      streakDays: h.streakDays,
      isArchived: true,
    );
    notifyListeners();
  }

  void unarchiveHabit(String habitId) {
    final idx = _habits.indexWhere((h) => h.id == habitId);
    if (idx == -1) return;
    final h = _habits[idx];
    _habits[idx] = ProfileHabit(
      id: h.id,
      name: h.name,
      iconName: h.iconName,
      streakDays: h.streakDays,
      isArchived: false,
    );
    notifyListeners();
  }

  void togglePersonality() {
    _personalityOn = !_personalityOn;
    notifyListeners();
  }

  void toggleNotification(String key) {
    _notificationPrefs = switch (key) {
      'morning' => _notificationPrefs.copyWith(morning: !_notificationPrefs.morning),
      'nudges' => _notificationPrefs.copyWith(nudges: !_notificationPrefs.nudges),
      'memes' => _notificationPrefs.copyWith(memes: !_notificationPrefs.memes),
      'reflection' => _notificationPrefs.copyWith(reflection: !_notificationPrefs.reflection),
      _ => _notificationPrefs,
    };
    notifyListeners();
  }

  // --- API ---

  Future<void> _loadProfile() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _userService.fetchMe();
      _profile = _profileFromApi(data);
      final statsData = await _userService.fetchStats();
      _stats = _statsFromApi(statsData);
      _loading = false;
      notifyListeners();
    } catch (_) {
      _loading = false;
      // Keep mock data as fallback
      notifyListeners();
    }
  }

  UserProfile _profileFromApi(Map<String, dynamic> d) {
    final personaStr = d['persona_type'] as String? ?? 'general';
    final persona = PersonaType.values.firstWhere(
      (p) => p.name == personaStr,
      orElse: () => PersonaType.general,
    );
    return UserProfile(
      id: d['id'] as String? ?? '',
      name: d['name'] as String? ?? 'You',
      email: d['email'] as String? ?? '',
      avatarUrl: d['avatar_url'] as String?,
      xp: (d['xp'] as num?)?.toInt() ?? 0,
      sparks: (d['sparks'] as num?)?.toInt() ?? 0,
      personaType: persona,
      equipped: const EquippedCustomizations(),
      memberSince: DateTime.tryParse(d['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ProfileStats _statsFromApi(Map<String, dynamic> d) {
    return ProfileStats(
      totalHabits: (d['total_habits'] as num?)?.toInt() ?? 0,
      totalDaysCompleted: (d['total_days_completed'] as num?)?.toInt() ?? 0,
      longestStreak: (d['longest_streak'] as num?)?.toInt() ?? 0,
      perfectDays: (d['perfect_days'] as num?)?.toInt() ?? 0,
      habitsGraduated: (d['habits_graduated'] as num?)?.toInt() ?? 0,
    );
  }

  // --- Mock data ---

  static UserProfile _mockProfile() {
    return UserProfile(
      id: 'u1',
      name: 'Diana',
      email: 'diana@example.com',
      xp: 1240,
      sparks: 340,
      personaType: PersonaType.general,
      equipped: const EquippedCustomizations(),
      memberSince: DateTime(2024, 10, 1),
    );
  }

  static ProfileStats _mockStats() {
    return const ProfileStats(
      totalHabits: 6,
      totalDaysCompleted: 58,
      longestStreak: 21,
      perfectDays: 14,
      habitsGraduated: 2,
    );
  }

  static List<ProfileHabit> _mockHabits() {
    return const [
      ProfileHabit(id: '1', name: 'LeetCode', iconName: 'code', streakDays: 12),
      ProfileHabit(id: '2', name: 'Exercise', iconName: 'barbell', streakDays: 5),
      ProfileHabit(id: '3', name: 'Read', iconName: 'book-open', streakDays: 8),
      ProfileHabit(id: '4', name: 'Meditate', iconName: 'brain', streakDays: 3),
      ProfileHabit(id: '5', name: 'Duolingo', iconName: 'globe', streakDays: 21),
      ProfileHabit(id: '6', name: 'Journal', iconName: 'pencil-simple', streakDays: 1),
    ];
  }

  static List<PluginConnection> _mockPlugins() {
    return const [
      PluginConnection(
        id: 'leetcode',
        name: 'LeetCode',
        iconName: 'code',
        isConnected: true,
      ),
      PluginConnection(
        id: 'duolingo',
        name: 'Duolingo',
        iconName: 'globe',
        isConnected: false,
      ),
    ];
  }
}
