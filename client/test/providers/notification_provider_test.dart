// client/test/providers/notification_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/providers/notification_provider.dart';
import 'package:valence/services/notification_service.dart';

/// A stub NotificationService that does nothing, for unit tests.
class _StubNotificationService extends NotificationService {
  _StubNotificationService() : super.forTesting();

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> scheduleMorningActivation({
    required String title,
    required String body,
    int hourOfDay = 8,
  }) async {}

  @override
  Future<void> scheduleEveningReflection({
    required String title,
    required String body,
    int hourOfDay = 21,
  }) async {}

  @override
  Future<void> scheduleRecoveryNudge({
    required String habitName,
    required String body,
  }) async {}

  @override
  Future<void> cancelByChannel(NotificationChannel channel) async {}

  @override
  Future<void> cancelAll() async {}
}

void main() {
  group('NotificationProvider', () {
    late NotificationProvider provider;

    setUp(() {
      provider = NotificationProvider(service: _StubNotificationService());
    });

    test('initializes with default state', () {
      expect(provider.permissionGranted, isFalse);
      expect(provider.morningEnabled, isTrue);
      expect(provider.eveningEnabled, isTrue);
      expect(provider.isInitialized, isFalse);
    });

    test('toggleMorning flips morningEnabled', () {
      expect(provider.morningEnabled, isTrue);
      provider.toggleMorning();
      expect(provider.morningEnabled, isFalse);
      provider.toggleMorning();
      expect(provider.morningEnabled, isTrue);
    });

    test('toggleEvening flips eveningEnabled', () {
      expect(provider.eveningEnabled, isTrue);
      provider.toggleEvening();
      expect(provider.eveningEnabled, isFalse);
    });

    test('setPermissionGranted updates state', () {
      provider.setPermissionGranted(true);
      expect(provider.permissionGranted, isTrue);
    });
  });
}
