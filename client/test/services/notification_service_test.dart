// client/test/services/notification_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:valence/services/notification_service.dart';

void main() {
  group('NotificationService', () {
    test('NotificationChannel enum has all 5 channels', () {
      expect(NotificationChannel.values.length, 5);
      expect(NotificationChannel.values, contains(NotificationChannel.morning));
      expect(NotificationChannel.values, contains(NotificationChannel.evening));
      expect(NotificationChannel.values, contains(NotificationChannel.nudge));
      expect(NotificationChannel.values, contains(NotificationChannel.recovery));
      expect(NotificationChannel.values, contains(NotificationChannel.chain));
    });

    test('NotificationService constructs without error', () {
      expect(() => NotificationService(), returnsNormally);
    });
  });
}
