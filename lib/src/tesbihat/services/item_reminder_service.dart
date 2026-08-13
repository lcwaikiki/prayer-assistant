import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../navigation.dart';
import '../models/item.dart';
import '../screens/execution_screen.dart';

class ItemReminderService {
  ItemReminderService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'tesbih_reminders';
  static const _channelName = 'Tasbih Reminders';

  /// How far in the past a resolved prayer-anchored fire time can be and
  /// still be worth a catch-up notification, rather than silently waiting
  /// for the next scheduling pass.
  static const _catchUpWindow = Duration(minutes: 120);

  Future<void> initialize() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        _openItem(response.payload);
      },
    );
  }

  /// Call once after the widget tree (and [rootNavigatorKey]'s Navigator)
  /// exists, to handle the case where tapping the reminder notification is
  /// what launched the app from fully killed rather than just bringing an
  /// already-running app to the foreground.
  Future<void> handleAppLaunchFromNotification() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      _openItem(details!.notificationResponse?.payload);
    }
  }

  void _openItem(String? itemId) {
    if (itemId == null || itemId.isEmpty) {
      return;
    }
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(builder: (_) => ExecutionScreen(itemId: itemId)),
    );
  }

  /// Derives a stable notification id from an item's string id, in a
  /// dedicated range that doesn't collide with prayer reminder ids.
  int _notificationId(String itemId) {
    var hash = 0;
    for (final codeUnit in itemId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return 800000 + (hash % 100000);
  }

  Future<void> cancelReminder(String itemId) {
    return _plugin.cancel(id: _notificationId(itemId));
  }

  Future<void> scheduleReminder(Item item) async {
    final id = _notificationId(item.id);
    await _plugin.cancel(id: id);

    final reminderAt = item.reminderAt;
    if (!item.reminderEnabled || reminderAt == null) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminders for tasbih/dhikr items',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    final body = 'Time for your ${item.title} dhikr.';

    if (item.reminderAnchor == ItemReminderAnchor.prayerTime) {
      // Always a plain one-shot for today's already-resolved time: the
      // daily repeat is handled by MidnightReminderScheduler re-resolving
      // and re-scheduling this every midnight, since the underlying prayer
      // time itself shifts from day to day (a fixed matchDateTimeComponents
      // repeat would freeze it to today's clock time forever).
      final now = DateTime.now();
      DateTime fireAt;
      if (reminderAt.isAfter(now)) {
        fireAt = reminderAt;
      } else if (now.difference(reminderAt) <= _catchUpWindow) {
        // The resolved moment (e.g. "20 min before Asr") already passed by
        // the time this got (re)scheduled — likely because the prayer was
        // close when the reminder was set up, or the app was briefly closed
        // right around the fire time. Firing shortly after is still useful;
        // silently waiting for tomorrow's midnight refresh is not.
        fireAt = now.add(const Duration(seconds: 5));
      } else {
        return;
      }
      await _plugin.zonedSchedule(
        id: id,
        title: item.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: item.id,
      );
    } else if (item.reminderRepeat == ItemReminderRepeat.daily) {
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminderAt.hour,
        reminderAt.minute,
      );
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: id,
        title: item.title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: item.id,
      );
    } else {
      if (!reminderAt.isAfter(DateTime.now())) {
        return;
      }
      await _plugin.zonedSchedule(
        id: id,
        title: item.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: item.id,
      );
    }
  }
}
