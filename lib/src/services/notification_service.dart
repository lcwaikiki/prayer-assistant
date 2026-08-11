import 'dart:convert';

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
  bool _useExactAlarms = false;

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
    _useExactAlarms = await _requestPermissions();
    _isInitialized = true;
  }

  static const int _maxScheduledReminders = 48;

  Future<void> cancelAllPrayerNotifications() async {
    for (var id = 1; id <= _maxScheduledReminders; id++) {
      await _plugin.cancel(id: id);
    }
  }

  Future<List<ScheduledReminderEntry>> getPendingScheduledReminders() async {
    final requests = await _plugin.pendingNotificationRequests();
    final entries = requests
        .map((request) {
          DateTime? scheduledAt;
          final payload = request.payload;
          if (payload != null && payload.isNotEmpty) {
            try {
              final map = jsonDecode(payload) as Map<String, dynamic>;
              final rawDate = map['fireAt']?.toString();

              if (rawDate != null && rawDate.isNotEmpty) {
                scheduledAt = DateTime.tryParse(rawDate);
              }
            } catch (_) {
              scheduledAt = null;
            }
          }
          return ScheduledReminderEntry(
            id: request.id,
            title: request.title ?? 'Reminder',
            body: request.body ?? '',
            scheduledAt: scheduledAt,
          );
        })
        .toList(growable: false);

    entries.sort((a, b) {
      final at = a.scheduledAt;
      final bt = b.scheduledAt;
      if (at == null && bt == null) {
        return a.id.compareTo(b.id);
      }
      if (at == null) {
        return 1;
      }
      if (bt == null) {
        return -1;
      }
      return at.compareTo(bt);
    });
    return entries;
  }

  Future<void> showTestNotificationNow() async {
    await _plugin.show(
      id: 900001,
      title: 'Prayer Assistant test',
      body: 'Notification pipeline is working on this device.',
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
    );
  }

  Future<void> reschedulePrayerNotifications({
    required List<PrayerDay> days,
    required Map<String, ReminderSetting> reminderSettings,
    required String locationName,
    required String Function(String prayerKey) prayerNameLabel,
  }) async {
    await cancelAllPrayerNotifications();

    final now = DateTime.now();
    final startDay = DateTime(now.year, now.month, now.day);
    final endDay = startDay.add(const Duration(days: 1));
    final notifications = <_ReminderNotification>[];

    for (final day in days) {
      final safeDay = DateTime(day.date.year, day.date.month, day.date.day);
      final isTodayDay =
          safeDay.year == startDay.year &&
          safeDay.month == startDay.month &&
          safeDay.day == startDay.day;
      if (safeDay.isBefore(startDay) || safeDay.isAfter(endDay)) {
        continue;
      }
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

        final displayName = prayerNameLabel(prayerName);

        if (setting.notifyOnTime && prayerTime.isAfter(now)) {
          notifications.add(
            _ReminderNotification(
              fireAt: prayerTime,
              title: '$displayName time',
              body: '$locationName - It is time for $displayName prayer.',
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
                title: '$displayName in ${setting.minutesBefore} min',
                body:
                    '$locationName - $displayName is at ${prayerTimes[prayerName]}.',
              ),
            );
          } else if (isTodayDay && prayerTime.isAfter(now)) {
            // Catch-up reminder when user enables "before" inside the active
            // pre-prayer window (beforeTime already passed).
            notifications.add(
              _ReminderNotification(
                fireAt: now.add(const Duration(seconds: 5)),
                title: '$displayName soon',
                body:
                    '$locationName - $displayName is at ${prayerTimes[prayerName]}.',
              ),
            );
          }
        }
      }
    }

    notifications.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    final limited = notifications.take(48).toList(growable: false);

    for (var i = 0; i < limited.length; i++) {
      final item = limited[i];
      final date = tz.TZDateTime.from(item.fireAt, tz.local);

      try {
        final payload = jsonEncode({
          'fireAt': item.fireAt.toIso8601String(),
          'title': item.title,
        });
        await _plugin.zonedSchedule(
          id: i + 1,
          title: item.title,
          body: item.body,
          scheduledDate: date,
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
          androidScheduleMode : AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        final payload = jsonEncode({
          'fireAt': item.fireAt.toIso8601String(),
          'title': item.title,
        });

        await _plugin.zonedSchedule(
          id: i + 1,
          title: item.title,
          body: item.body,
          scheduledDate: date,
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
          payload: payload,
        );
      }
    }
  }

  Future<bool> _requestPermissions() async {
    var canUseExactAlarms = false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();
    final canExact = await android?.canScheduleExactNotifications();
    if (canExact == true) {
      canUseExactAlarms = true;
    } else if (canExact == false) {
      final requested = await android?.requestExactAlarmsPermission();
      canUseExactAlarms = requested == true;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return canUseExactAlarms;
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
