// client/lib/providers/onboarding_provider.dart
import 'package:flutter/foundation.dart';

enum GroupChoice { create, join, solo }

/// Tracks state for the 7-screen onboarding flow.
class OnboardingProvider extends ChangeNotifier {
  int _currentPage = 0;
  String? _selectedThemeId;
  final List<String> _selectedHabits = [];
  GroupChoice? _groupChoice;

  int get currentPage => _currentPage;
  String? get selectedThemeId => _selectedThemeId;
  List<String> get selectedHabits => List.unmodifiable(_selectedHabits);
  GroupChoice? get groupChoice => _groupChoice;

  void nextPage() {
    _currentPage++;
    notifyListeners();
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }

  void goToPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setTheme(String themeId) {
    _selectedThemeId = themeId;
    notifyListeners();
  }

  void addHabit(String habitId) {
    if (!_selectedHabits.contains(habitId)) {
      _selectedHabits.add(habitId);
      notifyListeners();
    }
  }

  void removeHabit(String habitId) {
    if (_selectedHabits.remove(habitId)) {
      notifyListeners();
    }
  }

  void setGroupChoice(GroupChoice choice) {
    _groupChoice = choice;
    notifyListeners();
  }

  void reset() {
    _currentPage = 0;
    _selectedThemeId = null;
    _selectedHabits.clear();
    _groupChoice = null;
    notifyListeners();
  }
}
