import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../calendar/models/calendar_reminder.dart';
import '../../navigation.dart';
import '../../services/local_database.dart';
import '../models/item.dart';
import '../screens/execution_screen.dart';
import 'prayer_anchor_resolver.dart';

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

    if (!item.reminderEnabled) {
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
      // Fire on the next occurrence matching the recurrence, resolved to
      // that occurrence's own prayer time (which shifts day to day). A
      // plain one-shot is scheduled and MidnightReminderScheduler re-runs
      // this daily to advance to the following occurrence.
      final fireAt = await _resolveNextPrayerFireTime(item);
      if (fireAt == null) {
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
      return;
    }

    final reminderAt = item.reminderAt;
    if (reminderAt == null) {
      return;
    }

    switch (item.reminderRecurrence) {
      case ReminderRecurrence.once:
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
      case ReminderRecurrence.daily:
        await _plugin.zonedSchedule(
          id: id,
          title: item.title,
          body: body,
          scheduledDate: _nextTimeOfDay(reminderAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: item.id,
        );
      case ReminderRecurrence.weekly:
        await _plugin.zonedSchedule(
          id: id,
          title: item.title,
          body: body,
          scheduledDate: _nextWeekday(reminderAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: item.id,
        );
      case ReminderRecurrence.monthly:
        if (item.reminderMonthlyBasis == CalendarBasis.gregorian) {
          final next = _nextDayOfMonth(reminderAt);
          if (next == null) {
            return;
          }
          await _plugin.zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: next,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
            payload: item.id,
          );
        } else {
          final next = _nextHijriMonthlyOccurrence(reminderAt);
          await _plugin.zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: item.id,
          );
        }
      case ReminderRecurrence.yearly:
        if (item.reminderYearlyBasis == CalendarBasis.gregorian) {
          await _plugin.zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: _nextDayOfYear(reminderAt),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
            payload: item.id,
          );
        } else {
          final next = _nextHijriAnniversary(reminderAt);
          await _plugin.zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: item.id,
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

  /// Next Gregorian occurrence of the anchor's Hijri day-of-month, at or
  /// after now, trying the current Hijri month and then subsequent ones
  /// (skipping months shorter than the anchor's day-of-month, e.g. the
  /// 30th in a 29-day Hijri month).
  DateTime _nextHijriMonthlyOccurrence(DateTime anchor) {
    final anchorHijri = HijriCalendar.fromDate(anchor);
    final now = DateTime.now();
    final nowHijri = HijriCalendar.fromDate(now);
    final calendar = HijriCalendar();
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final totalMonths =
          (nowHijri.hYear * 12 + (nowHijri.hMonth - 1)) + monthOffset;
      final hYear = totalMonths ~/ 12;
      final hMonth = (totalMonths % 12) + 1;
      if (anchorHijri.hDay > calendar.getDaysInMonth(hYear, hMonth)) {
        continue;
      }
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        hMonth,
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
    // future date within a year.
    return anchor;
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

  /// Resolves the next concrete fire time for a prayer-anchored reminder,
  /// honoring [Item.reminderRecurrence]. Scans occurrence dates forward
  /// from today, resolving each candidate date's own prayer time, and picks
  /// the first one that is still upcoming (or, like the old logic, within
  /// the catch-up window). Returns null when no upcoming occurrence exists
  /// or the prayer data for a candidate date isn't cached yet.
  Future<DateTime?> _resolveNextPrayerFireTime(Item item) async {
    final database = LocalDatabase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final anchor = item.reminderAnchorDate ?? item.reminderAt ?? now;
    final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);

    var from = today;
    for (var i = 0; i < 400; i++) {
      final occurrence = _nextPrayerOccurrenceDate(item, anchorDate, from);
      if (occurrence == null) {
        return null;
      }
      final resolved = await resolvePrayerAnchoredTime(
        database,
        prayerName: item.reminderPrayerName,
        offsetMinutes: item.reminderOffsetMinutes,
        date: occurrence,
      );
      if (resolved == null) {
        return null;
      }
      if (resolved.isAfter(now)) {
        return resolved;
      }
      if (now.difference(resolved) <= _catchUpWindow) {
        return now.add(const Duration(seconds: 5));
      }
      if (item.reminderRecurrence == ReminderRecurrence.once) {
        return null;
      }
      from = occurrence.add(const Duration(days: 1));
    }
    return null;
  }

  /// The next occurrence date (>= [from]) matching the item's recurrence
  /// and anchored to [anchor]'s date part, or null when there is none.
  DateTime? _nextPrayerOccurrenceDate(
    Item item,
    DateTime anchor,
    DateTime from,
  ) {
    switch (item.reminderRecurrence) {
      case ReminderRecurrence.once:
        return anchor.isBefore(from) ? null : anchor;
      case ReminderRecurrence.daily:
        return from;
      case ReminderRecurrence.weekly:
        var candidate = from;
        while (candidate.weekday != anchor.weekday) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;
      case ReminderRecurrence.monthly:
        if (item.reminderMonthlyBasis == CalendarBasis.gregorian) {
          return _nextGregorianDayOfMonth(anchor, from);
        }
        return _nextHijriDayOfMonth(anchor, from);
      case ReminderRecurrence.yearly:
        if (item.reminderYearlyBasis == CalendarBasis.gregorian) {
          return _nextGregorianMonthDay(anchor, from);
        }
        return _nextHijriMonthDay(anchor, from);
    }
  }

  /// Next date (>= [from]) with the anchor's day-of-month, skipping months
  /// where that day doesn't exist (e.g. the 31st).
  DateTime? _nextGregorianDayOfMonth(DateTime anchor, DateTime from) {
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final year = from.year + ((from.month - 1 + monthOffset) ~/ 12);
      final month = ((from.month - 1 + monthOffset) % 12) + 1;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (anchor.day > daysInMonth) {
        continue;
      }
      final candidate = DateTime(year, month, anchor.day);
      if (!candidate.isBefore(from)) {
        return candidate;
      }
    }
    return null;
  }

  /// Next date (>= [from]) with the anchor's Gregorian month/day.
  DateTime? _nextGregorianMonthDay(DateTime anchor, DateTime from) {
    final candidate = DateTime(from.year, anchor.month, anchor.day);
    if (!candidate.isBefore(from)) {
      return candidate;
    }
    return DateTime(from.year + 1, anchor.month, anchor.day);
  }

  /// Next date (>= [from]) whose Hijri day-of-month equals the anchor's,
  /// skipping months shorter than that day.
  DateTime? _nextHijriDayOfMonth(DateTime anchor, DateTime from) {
    final calendar = HijriCalendar();
    final anchorHijri = HijriCalendar.fromDate(anchor);
    final fromHijri = HijriCalendar.fromDate(from);
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final totalMonths =
          (fromHijri.hYear * 12 + (fromHijri.hMonth - 1)) + monthOffset;
      final hYear = totalMonths ~/ 12;
      final hMonth = (totalMonths % 12) + 1;
      if (anchorHijri.hDay > calendar.getDaysInMonth(hYear, hMonth)) {
        continue;
      }
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        hMonth,
        anchorHijri.hDay,
      );
      final candidate = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
      );
      if (!candidate.isBefore(from)) {
        return candidate;
      }
    }
    return null;
  }

  /// Next date (>= [from]) whose Hijri month/day equals the anchor's,
  /// trying the current Hijri year and then the next one.
  DateTime? _nextHijriMonthDay(DateTime anchor, DateTime from) {
    final calendar = HijriCalendar();
    final anchorHijri = HijriCalendar.fromDate(anchor);
    final fromHijri = HijriCalendar.fromDate(from);
    for (final hYear in [fromHijri.hYear, fromHijri.hYear + 1]) {
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        anchorHijri.hMonth,
        anchorHijri.hDay,
      );
      final candidate = DateTime(
        candidateDate.year,
        candidateDate.month,
        candidateDate.day,
      );
      if (!candidate.isBefore(from)) {
        return candidate;
      }
    }
    return null;
  }
}
