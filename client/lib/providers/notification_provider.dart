// client/lib/providers/notification_provider.dart
import 'package:flutter/foundation.dart';
import 'package:valence/services/llm_nudge_service.dart';
import 'package:valence/services/notification_service.dart';

/// Manages notification permission state and scheduled notification toggling.
class NotificationProvider extends ChangeNotifier {
  final NotificationService _service;
  final LlmNudgeService _llmService;

  bool _permissionGranted = false;
  bool _morningEnabled = true;
  bool _eveningEnabled = true;
  bool _isInitialized = false;

  NotificationProvider({
    NotificationService? service,
    LlmNudgeService? llmService,
  })  : _service = service ?? NotificationService(),
        _llmService = llmService ?? LlmNudgeService();

  bool get permissionGranted => _permissionGranted;
  bool get morningEnabled => _morningEnabled;
  bool get eveningEnabled => _eveningEnabled;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _service.initialize();
    _isInitialized = true;

    if (_morningEnabled && _permissionGranted) {
      await _scheduleMorning();
    }
    if (_eveningEnabled && _permissionGranted) {
      await _scheduleEvening();
    }

    notifyListeners();
  }

  Future<void> requestPermission() async {
    if (!_isInitialized) await initialize();
    final granted = await _service.requestPermission();
    _permissionGranted = granted;
    if (granted) {
      if (_morningEnabled) await _scheduleMorning();
      if (_eveningEnabled) await _scheduleEvening();
    }
    notifyListeners();
  }

  void setPermissionGranted(bool value) {
    _permissionGranted = value;
    notifyListeners();
  }

  void toggleMorning() {
    _morningEnabled = !_morningEnabled;
    if (_morningEnabled && _permissionGranted) {
      _scheduleMorning();
    } else {
      _service.cancelByChannel(NotificationChannel.morning);
    }
    notifyListeners();
  }

  void toggleEvening() {
    _eveningEnabled = !_eveningEnabled;
    if (_eveningEnabled && _permissionGranted) {
      _scheduleEvening();
    } else {
      _service.cancelByChannel(NotificationChannel.evening);
    }
    notifyListeners();
  }

  Future<void> scheduleRecoveryNudge(String habitName) async {
    if (!_permissionGranted) return;
    final body = await _llmService.generateMorningActivation(
      userName: 'you',
      friendsCompleted: 0,
    );
    await _service.scheduleRecoveryNudge(habitName: habitName, body: body);
  }

  Future<void> _scheduleMorning() async {
    final body = await _llmService.generateMorningActivation(
      userName: 'you',
      friendsCompleted: 2,
    );
    await _service.scheduleMorningActivation(
      title: 'Time to build something great',
      body: body,
    );
  }

  Future<void> _scheduleEvening() async {
    await _service.scheduleEveningReflection(
      title: 'Quick reflection on today?',
      body: 'It only takes 15 seconds. How did your habits go today?',
    );
  }
}
