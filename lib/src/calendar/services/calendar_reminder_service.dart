import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../navigation.dart';
import '../models/calendar_reminder.dart';
import '../screens/hijri_calendar_screen.dart';

class CalendarReminderService {
  CalendarReminderService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'calendar_reminders';
  static const _channelName = 'Calendar Reminders';

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
        _openReminderDate(response.payload);
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
      _openReminderDate(details!.notificationResponse?.payload);
    }
  }

  void _openReminderDate(String? reminderId) {
    if (reminderId == null || reminderId.isEmpty) {
      return;
    }
    rootNavigatorKey.currentState?.push(
      MaterialPageRoute<void>(
        builder: (_) => HijriCalendarScreen(
          initialDate: DateTime.now(),
          openDetailOnLaunch: true,
        ),
      ),
    );
  }

  /// Derives a stable notification id from a reminder's string id, in a
  /// dedicated range that doesn't collide with prayer (1-48) or tesbih
  /// (800000-899999) notification ids.
  int _notificationId(String reminderId) {
    var hash = 0;
    for (final codeUnit in reminderId.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    return 700000 + (hash % 100000);
  }

  Future<void> cancelReminder(String reminderId) {
    return _plugin.cancel(id: _notificationId(reminderId));
  }

  Future<void> scheduleReminder(CalendarReminder reminder) async {
    final id = _notificationId(reminder.id);
    await _plugin.cancel(id: id);

    if (!reminder.enabled) {
      return;
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Reminders scheduled from the calendar',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    final body = reminder.notes.isEmpty ? reminder.title : reminder.notes;

    if (reminder.anchor == CalendarReminderAnchor.prayerTime) {
      // Always a plain one-shot for today's already-resolved time: the
      // daily repeat is handled by CalendarMidnightScheduler re-resolving
      // and re-scheduling this every midnight, since the underlying prayer
      // time itself shifts from day to day.
      final now = DateTime.now();
      DateTime fireAt;
      if (reminder.anchorAt.isAfter(now)) {
        fireAt = reminder.anchorAt;
      } else if (now.difference(reminder.anchorAt) <= _catchUpWindow) {
        fireAt = now.add(const Duration(seconds: 5));
      } else {
        return;
      }
      await _plugin.zonedSchedule(
        id: id,
        title: reminder.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: reminder.id,
      );
      return;
    }

    switch (reminder.recurrence) {
      case ReminderRecurrence.once:
        if (!reminder.anchorAt.isAfter(DateTime.now())) {
          return;
        }
        await _plugin.zonedSchedule(
          id: id,
          title: reminder.title,
          body: body,
          scheduledDate: tz.TZDateTime.from(reminder.anchorAt, tz.local),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: reminder.id,
        );
      case ReminderRecurrence.daily:
        await _plugin.zonedSchedule(
          id: id,
          title: reminder.title,
          body: body,
          scheduledDate: _nextTimeOfDay(reminder.anchorAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: reminder.id,
        );
      case ReminderRecurrence.weekly:
        await _plugin.zonedSchedule(
          id: id,
          title: reminder.title,
          body: body,
          scheduledDate: _nextWeekday(reminder.anchorAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: reminder.id,
        );
      case ReminderRecurrence.monthly:
        final next = _nextDayOfMonth(reminder.anchorAt);
        if (next == null) {
          return;
        }
        await _plugin.zonedSchedule(
          id: id,
          title: reminder.title,
          body: body,
          scheduledDate: next,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          payload: reminder.id,
        );
      case ReminderRecurrence.yearly:
        if (reminder.yearlyBasis == YearlyCalendarBasis.gregorian) {
          await _plugin.zonedSchedule(
            id: id,
            title: reminder.title,
            body: body,
            scheduledDate: _nextDayOfYear(reminder.anchorAt),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: reminder.id,
          );
        } else {
          final next = _nextHijriAnniversary(reminder.anchorAt);
          await _plugin.zonedSchedule(
            id: id,
            title: reminder.title,
            body: body,
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: reminder.id,
          );
        }
    }
  }

  tz.TZDateTime _nextTimeOfDay(DateTime anchor) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      anchor.hour,
      anchor.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextWeekday(DateTime anchor) {
    var scheduled = _nextTimeOfDay(anchor);
    while (scheduled.weekday != anchor.weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Null when the anchor's day-of-month doesn't exist in the coming months
  /// (e.g. 31st) for a very long stretch — practically never happens since
  /// every day-of-month from 1-28 exists every month.
  tz.TZDateTime? _nextDayOfMonth(DateTime anchor) {
    final now = tz.TZDateTime.now(tz.local);
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final year = now.year + ((now.month - 1 + monthOffset) ~/ 12);
      final month = ((now.month - 1 + monthOffset) % 12) + 1;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (anchor.day > daysInMonth) {
        continue;
      }
      final candidate = tz.TZDateTime(
        tz.local,
        year,
        month,
        anchor.day,
        anchor.hour,
        anchor.minute,
      );
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }
    return null;
  }

  tz.TZDateTime _nextDayOfYear(DateTime anchor) {
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      anchor.month,
      anchor.day,
      anchor.hour,
      anchor.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        anchor.month,
        anchor.day,
        anchor.hour,
        anchor.minute,
      );
    }
    return candidate;
  }

  /// Next Gregorian occurrence of the anchor's Hijri month/day, at or after
  /// now, trying the current Hijri year and then the next one.
  DateTime _nextHijriAnniversary(DateTime anchor) {
    final anchorHijri = HijriCalendar.fromDate(anchor);
    final now = DateTime.now();
    final nowHijri = HijriCalendar.fromDate(now);
    final calendar = HijriCalendar();
    for (final hYear in [nowHijri.hYear, nowHijri.hYear + 1]) {
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        anchorHijri.hMonth,
        anchorHijri.hDay,
      );
      final candidate = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
        anchor.hour,
        anchor.minute,
      );
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }
    // Fallback: should be unreachable given the loop above always finds a
    // future date within one Hijri year.
    return anchor;
  }
}
