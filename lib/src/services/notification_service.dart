import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_models.dart';
import '../utils/time_utils.dart';

class NotificationService {
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initSettings);
    await _requestPermissions();
    _isInitialized = true;
  }

  Future<void> cancelAllPrayerNotifications() async {
    await _plugin.cancelAll();
  }

  Future<void> reschedulePrayerNotifications({
    required List<PrayerDay> days,
    required Map<String, ReminderSetting> reminderSettings,
    required String locationName,
  }) async {
    await cancelAllPrayerNotifications();

    final now = DateTime.now();
    final notifications = <_ReminderNotification>[];

    for (final day in days) {
      final prayerTimes = prayerMapForDay(day);
      for (final prayerName in prayerOrder) {
        final setting =
            reminderSettings[prayerName] ?? ReminderSetting.defaults();
        if (!setting.notifyOnTime && !setting.notifyBefore) {
          continue;
        }
        final prayerTime = parsePrayerTime(
          day.date,
          prayerTimes[prayerName] ?? '',
        );
        if (prayerTime == null) {
          continue;
        }

        if (setting.notifyOnTime && prayerTime.isAfter(now)) {
          notifications.add(
            _ReminderNotification(
              fireAt: prayerTime,
              title: '$prayerName time',
              body: '$locationName - It is time for $prayerName prayer.',
            ),
          );
        }

        if (setting.notifyBefore) {
          final beforeTime = prayerTime.subtract(
            Duration(minutes: setting.minutesBefore),
          );
          if (beforeTime.isAfter(now)) {
            notifications.add(
              _ReminderNotification(
                fireAt: beforeTime,
                title: '$prayerName in ${setting.minutesBefore} min',
                body:
                    '$locationName - $prayerName is at ${prayerTimes[prayerName]}.',
              ),
            );
          }
        }
      }
    }

    notifications.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    final limited = notifications.take(60).toList(growable: false);

    for (var i = 0; i < limited.length; i++) {
      final item = limited[i];
      await _plugin.zonedSchedule(
        id: i + 1,
        title: item.title,
        body: item.body,
        scheduledDate: tz.TZDateTime.from(item.fireAt, tz.local),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminders',
            'Prayer Reminders',
            channelDescription: 'Prayer reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> _requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    final canExact = await android?.canScheduleExactNotifications();
    if (canExact == false) {
      await android?.requestExactAlarmsPermission();
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }
}

class _ReminderNotification {
  _ReminderNotification({
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final DateTime fireAt;
  final String title;
  final String body;
}
