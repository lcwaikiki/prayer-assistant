import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_models.dart';
import '../utils/time_utils.dart';
import 'notification_tap_handler.dart';
import 'timezone_setup.dart';

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
    await initializeLocalTimezone();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    // All notification producers share one platform channel, so every
    // initialize() must register the same shared tap router — otherwise
    // the last one to run would silently win and misroute the others'
    // taps. Prayer payloads are JSON and don't deep-link.
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        handleNotificationTap(response.payload);
      },
    );
    _useExactAlarms = await _requestPermissions();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.deleteNotificationChannel(channelId: 'prayer_reminders');
    _isInitialized = true;
  }

  static const int _maxScheduledReminders = 48;

  /// A repeating 0.5s-vibrate / 1s-pause pattern lasting about 10 seconds,
  /// in the [delay, vibrate, pause, vibrate, pause, ...] format Android
  /// notification channels expect.
  static Int64List _reminderVibrationPattern() {
    const vibrateMs = 500;
    const pauseMs = 1000;
    const totalMs = 10000;
    final pattern = <int>[0];
    var elapsed = 0;
    while (elapsed < totalMs) {
      pattern.add(vibrateMs);
      elapsed += vibrateMs;
      if (elapsed >= totalMs) {
        break;
      }
      pattern.add(pauseMs);
      elapsed += pauseMs;
    }
    return Int64List.fromList(pattern);
  }

  /// Android locks a notification channel's sound/vibration to whatever it
  /// was created with the *first* time that channel id is used — later calls
  /// with a different [AndroidNotificationDetails] on the same id are
  /// silently ignored by the OS. So each vibrate/sound combination needs its
  /// own permanent channel id rather than one shared, mutable-looking one.
  static NotificationDetails _reminderNotificationDetails({
    required bool vibrationEnabled,
    required bool soundEnabled,
  }) {
    final String channelId;
    final String channelName;
    if (vibrationEnabled && soundEnabled) {
      channelId = 'prayer_reminders_vibrate_sound';
      channelName = 'Prayer Reminders (vibrate + sound)';
    } else if (vibrationEnabled) {
      channelId = 'prayer_reminders_vibrate_only';
      channelName = 'Prayer Reminders (vibrate only)';
    } else if (soundEnabled) {
      channelId = 'prayer_reminders_sound_only';
      channelName = 'Prayer Reminders (sound only)';
    } else {
      channelId = 'prayer_reminders_silent';
      channelName = 'Prayer Reminders (silent)';
    }

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Prayer reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
        vibrationPattern: vibrationEnabled ? _reminderVibrationPattern() : null,
      ),
      iOS: DarwinNotificationDetails(presentSound: soundEnabled),
    );
  }

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
    required bool vibrationEnabled,
    required bool soundEnabled,
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
        if (!setting.notifyOnTime &&
            !setting.notifyBefore &&
            !setting.notifyAfter) {
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
        // The global toggle is a master switch: it must be on, and the
        // per-prayer toggle then decides that specific prayer's alert.
        final effectiveVibration = vibrationEnabled && setting.vibrationEnabled;
        final effectiveSound = soundEnabled && setting.soundEnabled;

        if (setting.notifyOnTime && prayerTime.isAfter(now)) {
          notifications.add(
            _ReminderNotification(
              fireAt: prayerTime,
              title: '$displayName time',
              body: '$locationName - It is time for $displayName prayer.',
              vibrationEnabled: effectiveVibration,
              soundEnabled: effectiveSound,
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
                vibrationEnabled: effectiveVibration,
                soundEnabled: effectiveSound,
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
                vibrationEnabled: effectiveVibration,
                soundEnabled: effectiveSound,
              ),
            );
          }
        }

        if (setting.notifyAfter) {
          final afterTime = prayerTime.add(
            Duration(minutes: setting.minutesAfter),
          );
          if (afterTime.isAfter(now)) {
            notifications.add(
              _ReminderNotification(
                fireAt: afterTime,
                title: '$displayName +${setting.minutesAfter} min',
                body:
                    '$locationName - It has been ${setting.minutesAfter} min since $displayName.',
                vibrationEnabled: effectiveVibration,
                soundEnabled: effectiveSound,
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
      final notificationDetails = _reminderNotificationDetails(
        vibrationEnabled: item.vibrationEnabled,
        soundEnabled: item.soundEnabled,
      );

      final payload = jsonEncode({
        'fireAt': item.fireAt.toIso8601String(),
        'title': item.title,
      });

      // Exact alarms keep prayer times precise, but on Android 12+ they
      // require the user to grant the exact-alarm permission (or the app to
      // fall back when the call is rejected). Prefer exact when granted,
      // otherwise schedule inexactly so reminders still fire at all.
      try {
        await _plugin.zonedSchedule(
          id: i + 1,
          title: item.title,
          body: item.body,
          scheduledDate: date,
          notificationDetails: notificationDetails,
          androidScheduleMode: _useExactAlarms
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      } catch (_) {
        // Permission state can change after initialization; never let a
        // rejected exact-alarm request silently drop the reminder.
        await _plugin.zonedSchedule(
          id: i + 1,
          title: item.title,
          body: item.body,
          scheduledDate: date,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
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
    required this.vibrationEnabled,
    required this.soundEnabled,
  });

  final DateTime fireAt;
  final String title;
  final String body;
  final bool vibrationEnabled;
  final bool soundEnabled;
}
