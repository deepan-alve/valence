// client/lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Notification channel IDs matching design spec 2.11.
enum NotificationChannel {
  morning('morning_activation', 'Morning Activation',
      'Daily morning habit reminder'),
  evening('evening_reflection', 'Evening Reflection',
      'Daily evening reflection prompt'),
  nudge('friend_nudge', 'Friend Nudges', 'Nudges from your group'),
  recovery('recovery_nudge', 'Recovery Nudge', 'Post-miss encouragement'),
  chain('chain_update', 'Chain Updates', 'Group streak milestones');

  final String id;
  final String name;
  final String description;
  const NotificationChannel(this.id, this.name, this.description);
}

/// Wraps flutter_local_notifications for all client-side notification scheduling.
///
/// FCM push notifications (friend nudge, chain updates) are sent server-side
/// via Firebase Cloud Messaging. This service handles LOCAL notifications only:
/// - Morning activation (daily, 8:00 local time)
/// - Evening reflection (daily, 21:00 local time)
/// - Recovery nudge (next morning after a miss)
///
/// Call [initialize] once at app startup (in NotificationProvider).
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Named constructor for subclassing in tests.
  NotificationService.forTesting();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    for (final channel in NotificationChannel.values) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              channel.id,
              channel.name,
              description: channel.description,
              importance: Importance.high,
            ),
          );
    }

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final result = await ios.requestPermissions(
          alert: true, badge: true, sound: true);
      return result ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  Future<void> scheduleMorningActivation({
    required String title,
    required String body,
    int hourOfDay = 8,
  }) async {
    await cancelByChannel(NotificationChannel.morning);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hourOfDay, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: NotificationChannel.morning.hashCode,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannel.morning.id,
          NotificationChannel.morning.name,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleEveningReflection({
    required String title,
    required String body,
    int hourOfDay = 21,
  }) async {
    await cancelByChannel(NotificationChannel.evening);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hourOfDay, 0);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id: NotificationChannel.evening.hashCode,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannel.evening.id,
          NotificationChannel.evening.name,
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleRecoveryNudge({
    required String habitName,
    required String body,
  }) async {
    await cancelByChannel(NotificationChannel.recovery);

    final now = tz.TZDateTime.now(tz.local);
    final tomorrow = tz.TZDateTime(
        tz.local, now.year, now.month, now.day + 1, 8, 0);

    await _plugin.zonedSchedule(
      id: NotificationChannel.recovery.hashCode,
      title: 'Ready to get back on track?',
      body: body,
      scheduledDate: tomorrow,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannel.recovery.id,
          NotificationChannel.recovery.name,
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelByChannel(NotificationChannel channel) async {
    await _plugin.cancel(id: channel.hashCode);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
