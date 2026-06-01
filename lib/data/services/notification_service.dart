import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_environment.dart';
import '../../core/utils/date_time_utils.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _notifications.initialize(const InitializationSettings(android: android, iOS: ios));

    if (AppEnvironment.enableFirebase) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showForegroundNotification(message);
      });
      await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);
    }

    _initialized = true;
  }

  Future<void> setLocalNotificationPermission(bool enabled) async {
    if (!enabled) {
      await cancelAll();
    }
  }

  Future<void> scheduleOutageReminder({
    required int id,
    required DateTime outageStartsAt,
    required DateTime outageEndsAt,
    required String areaName,
  }) async {
    final reminderAt = outageStartsAt.subtract(AppConstants.defaultOutageReminderOffset);
    if (reminderAt.isAfter(DateTime.now())) {
      await _notifications.zonedSchedule(
        id,
        'PowerAlert Pakistan',
        'Load shedding starts in 15 minutes for $areaName.',
        tz.TZDateTime.from(reminderAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'outage-reminders',
            'Outage reminders',
            channelDescription: 'Outage reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    await _notifications.zonedSchedule(
      id + 100000,
      'PowerAlert Pakistan',
      'Power restored for $areaName.',
      tz.TZDateTime.from(outageEndsAt, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'power-restored',
          'Power restored',
          channelDescription: 'Power restoration notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showSnackLikeNotification(String title, String body) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general',
          'General',
          channelDescription: 'General app notifications',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> cancelAll() => _notifications.cancelAll();

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      message.notification?.title ?? 'PowerAlert Pakistan',
      message.notification?.body ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm',
          'Firebase Cloud Messages',
          channelDescription: 'Firebase push notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  String formatReminderBody(DateTime startTime) {
    final formatted = DateTimeUtils.formatTime(startTime);
    return 'Next outage begins at $formatted.';
  }

  @visibleForTesting
  FlutterLocalNotificationsPlugin get plugin => _notifications;
}
