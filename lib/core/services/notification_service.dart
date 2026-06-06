import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  // Only supported on Android & iOS
  static bool get _supported => Platform.isAndroid || Platform.isIOS;

  Future<void> init() async {
    if (!_supported) return;

    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (details) {
        pendingFollowupId = details.payload;
      },
    );

    // Request Android 13+ permission
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  /// Followup ID of the last tapped notification — read this in the app
  /// on resume to open the correct QuickActionsSheet.
  static String? pendingFollowupId;

  Future<void> scheduleFollowup({
    required int id,
    required String customerName,
    required String followupId,
    required DateTime scheduledAt,
  }) async {
    if (!_supported) return;

    final scheduled = tz.TZDateTime.from(scheduledAt, tz.local);

    // Don't schedule in the past
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    const androidDetails = AndroidNotificationDetails(
      'followups_channel',
      'Follow-up Reminders',
      channelDescription: 'Route request follow-up alerts',
      importance: Importance.max,
      priority: Priority.high,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      'Follow-up: $customerName',
      'Tap to update the status of this route request.',
      scheduled,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: followupId,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    if (!_supported) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    await _plugin.cancelAll();
  }
}
