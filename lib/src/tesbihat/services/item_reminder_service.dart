import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../../services/notification_tap_handler.dart';
import '../../services/timezone_setup.dart';
import '../models/item.dart';
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

  /// Largest allowed [Item.reminderRepeatCount]; also the size of the
  /// notification-id window reserved per item (ids base..base+99), so a
  /// reduced count or a switch back to infinite repetition can cancel the
  /// leftover per-occurrence notifications.
  static const _maxOccurrences = 100;

  Future<void> initialize() async {
    // The midnight refresh callback runs this in its own background
    // isolate, where timezone state doesn't exist until initialized.
    await initializeLocalTimezone();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        handleNotificationTap(response.payload);
      },
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
    final base = _notificationId(itemId);
    return Future.wait([
      for (var i = 0; i < _maxOccurrences; i++) _plugin.cancel(id: base + i),
    ]);
  }

  /// Schedules with an exact alarm when the OS allows it, falling back to
  /// an inexact alarm when the exact-alarm permission is denied (Android
  /// 12+ rejects exact scheduling with a platform exception), so the
  /// reminder still fires instead of the call throwing. Returns false when
  /// even the inexact attempt failed (e.g. Android's scheduled-notification
  /// cap reached), so the caller can stop scheduling further occurrences.
  Future<bool> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required String payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: matchDateTimeComponents,
      );
      return true;
    } catch (_) {
      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
          matchDateTimeComponents: matchDateTimeComponents,
        );
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  Future<void> scheduleReminder(Item item) async {
    final id = _notificationId(item.id);
    // Clear the full per-occurrence id window: a finite count schedules
    // several one-shots (id..id+count-1), and switching to/from a finite
    // count would otherwise leave stale notifications behind.
    for (var i = 0; i < _maxOccurrences; i++) {
      await _plugin.cancel(id: id + i);
    }

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

    final repeatCount = item.reminderRepeatCount;
    if (repeatCount != null) {
      await _scheduleOccurrences(item, id, repeatCount, details, body);
      return;
    }

    if (item.reminderAnchor == ItemReminderAnchor.prayerTime) {
      // Fire on the next occurrence matching the recurrence, resolved to
      // that occurrence's own prayer time (which shifts day to day). A
      // plain one-shot is scheduled and MidnightReminderScheduler re-runs
      // this daily to advance to the following occurrence.
      final fireAt = await _resolveNextPrayerFireTime(item);
      if (fireAt == null) {
        return;
      }
      await _zonedSchedule(
        id: id,
        title: item.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: details,
        payload: '$tesbihItemPayloadPrefix${item.id}',
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
        await _zonedSchedule(
          id: id,
          title: item.title,
          body: body,
          scheduledDate: tz.TZDateTime.from(reminderAt, tz.local),
          notificationDetails: details,
          payload: '$tesbihItemPayloadPrefix${item.id}',
        );
      case ReminderRecurrence.daily:
        await _zonedSchedule(
          id: id,
          title: item.title,
          body: body,
          scheduledDate: _nextTimeOfDay(reminderAt),
          notificationDetails: details,
          payload: '$tesbihItemPayloadPrefix${item.id}',
          matchDateTimeComponents: DateTimeComponents.time,
        );
      case ReminderRecurrence.weekly:
        if (item.reminderWeekdays.isEmpty) {
          await _zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: _nextWeekday(reminderAt),
            notificationDetails: details,
            payload: '$tesbihItemPayloadPrefix${item.id}',
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        } else {
          // One OS-level weekly repeat per selected weekday.
          var index = 0;
          for (final weekday in item.reminderWeekdays) {
            final scheduled = await _zonedSchedule(
              id: id + index,
              title: item.title,
              body: body,
              scheduledDate: _nextWeekday(reminderAt, weekday),
              notificationDetails: details,
              payload: '$tesbihItemPayloadPrefix${item.id}',
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
            if (!scheduled) {
              break;
            }
            index++;
          }
        }
      case ReminderRecurrence.monthly:
        if (item.reminderMonthlyBasis == CalendarBasis.gregorian) {
          final next = _nextDayOfMonth(
            reminderAt,
            day: item.reminderDayOfMonth,
          );
          if (next == null) {
            return;
          }
          await _zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: next,
            notificationDetails: details,
            payload: '$tesbihItemPayloadPrefix${item.id}',
            matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
          );
        } else {
          final next = _nextHijriMonthlyOccurrence(
            reminderAt,
            day: item.reminderDayOfMonth,
          );
          await _zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: details,
            payload: '$tesbihItemPayloadPrefix${item.id}',
          );
        }
      case ReminderRecurrence.yearly:
        if (item.reminderYearlyBasis == CalendarBasis.gregorian) {
          await _zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: _nextDayOfYear(
              reminderAt,
              month: item.reminderYearlyDate?.month,
              day: item.reminderYearlyDate?.day,
            ),
            notificationDetails: details,
            payload: '$tesbihItemPayloadPrefix${item.id}',
            matchDateTimeComponents: DateTimeComponents.dateAndTime,
          );
        } else {
          final next = _nextHijriAnniversary(
            reminderAt,
            yearlyDate: item.reminderYearlyDate,
          );
          await _zonedSchedule(
            id: id,
            title: item.title,
            body: body,
            scheduledDate: tz.TZDateTime.from(next, tz.local),
            notificationDetails: details,
            payload: '$tesbihItemPayloadPrefix${item.id}',
          );
        }
    }
  }

  /// Schedules the item's first [count] concrete fire times as separate
  /// one-shot notifications (ids base..base+count-1). Used instead of an
  /// OS-level repeat so the reminder stops after [count] occurrences. The
  /// prayer-anchored path is re-resolved nightly by MidnightReminderScheduler,
  /// which naturally drops already-fired occurrences and keeps the total
  /// at [count].
  Future<void> _scheduleOccurrences(
    Item item,
    int baseId,
    int count,
    NotificationDetails details,
    String body,
  ) async {
    final occurrences = item.reminderAnchor == ItemReminderAnchor.prayerTime
        ? await _resolveNextPrayerFireTimes(item, count)
        : _nextClockTimeOccurrences(item, count);
    final payload = '$tesbihItemPayloadPrefix${item.id}';
    var index = 0;
    for (final fireAt in occurrences) {
      final scheduled = await _zonedSchedule(
        id: baseId + index,
        title: item.title,
        body: body,
        scheduledDate: tz.TZDateTime.from(fireAt, tz.local),
        notificationDetails: details,
        payload: payload,
      );
      if (!scheduled) {
        // Android caps scheduled notifications; stop instead of throwing.
        break;
      }
      index++;
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

  tz.TZDateTime _nextWeekday(DateTime anchor, [int? weekday]) {
    var scheduled = _nextTimeOfDay(anchor);
    while (scheduled.weekday != (weekday ?? anchor.weekday)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  /// Null when the anchor's day-of-month doesn't exist in the coming months
  /// (e.g. 31st) for a very long stretch — practically never happens since
  /// every day-of-month from 1-28 exists every month.
  tz.TZDateTime? _nextDayOfMonth(DateTime anchor, {int? day}) {
    final targetDay = day ?? anchor.day;
    final now = tz.TZDateTime.now(tz.local);
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final year = now.year + ((now.month - 1 + monthOffset) ~/ 12);
      final month = ((now.month - 1 + monthOffset) % 12) + 1;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (targetDay > daysInMonth) {
        continue;
      }
      final candidate = tz.TZDateTime(
        tz.local,
        year,
        month,
        targetDay,
        anchor.hour,
        anchor.minute,
      );
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }
    return null;
  }

  tz.TZDateTime _nextDayOfYear(DateTime anchor, {int? month, int? day}) {
    final targetMonth = month ?? anchor.month;
    final targetDay = day ?? anchor.day;
    final now = tz.TZDateTime.now(tz.local);
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      targetMonth,
      targetDay,
      anchor.hour,
      anchor.minute,
    );
    if (!candidate.isAfter(now)) {
      candidate = tz.TZDateTime(
        tz.local,
        now.year + 1,
        targetMonth,
        targetDay,
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
  DateTime _nextHijriMonthlyOccurrence(DateTime anchor, {int? day}) {
    final targetDay = day ?? HijriCalendar.fromDate(anchor).hDay;
    final now = DateTime.now();
    final nowHijri = HijriCalendar.fromDate(now);
    final calendar = HijriCalendar();
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final totalMonths =
          (nowHijri.hYear * 12 + (nowHijri.hMonth - 1)) + monthOffset;
      final hYear = totalMonths ~/ 12;
      final hMonth = (totalMonths % 12) + 1;
      if (targetDay > calendar.getDaysInMonth(hYear, hMonth)) {
        continue;
      }
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        hMonth,
        targetDay,
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
  DateTime _nextHijriAnniversary(DateTime anchor, {DateTime? yearlyDate}) {
    final anchorHijri = HijriCalendar.fromDate(yearlyDate ?? anchor);
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
  /// honoring [Item.reminderRecurrence] and [Item.reminderRepeatCount].
  Future<DateTime?> _resolveNextPrayerFireTime(Item item) async {
    final times = await _resolveNextPrayerFireTimes(item, 1);
    return times.isEmpty ? null : times.first;
  }

  /// Resolves up to [count] upcoming concrete fire times for a
  /// prayer-anchored reminder, honoring its recurrence (and, through it,
  /// the repeat count). Each occurrence date's own prayer time is resolved;
  /// occurrences already past by more than the catch-up window are skipped.
  /// An empty list means nothing is left to schedule.
  Future<List<DateTime>> _resolveNextPrayerFireTimes(Item item, int count) async {
    final database = LocalDatabase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final anchor = item.reminderAnchorDate ?? item.reminderAt ?? now;
    final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);

    var from = today;
    final times = <DateTime>[];
    for (var attempts = 0; attempts < 400 && times.length < count; attempts++) {
      final occurrence = _nextPrayerOccurrenceDate(item, anchorDate, from);
      if (occurrence == null) {
        break;
      }
      final resolved = await resolvePrayerAnchoredTime(
        database,
        prayerName: item.reminderPrayerName,
        offsetMinutes: item.reminderOffsetMinutes,
        date: occurrence,
      );
      if (resolved == null) {
        break;
      }
      if (resolved.isAfter(now)) {
        times.add(resolved);
      } else if (now.difference(resolved) <= _catchUpWindow) {
        times.add(now.add(const Duration(seconds: 5)));
      } else if (item.reminderRecurrence == ReminderRecurrence.once) {
        break;
      }
      from = occurrence.add(const Duration(days: 1));
    }
    return times;
  }

  /// The first [count] clock-anchored occurrence moments strictly after
  /// now, at [Item.reminderAt]'s time-of-day. Occurrences already past
  /// (e.g. today's time already gone) are skipped so only remaining fires
  /// are scheduled.
  List<DateTime> _nextClockTimeOccurrences(Item item, int count) {
    final reminderAt = item.reminderAt;
    if (reminderAt == null) {
      return const [];
    }
    final now = DateTime.now();
    final anchor = DateTime(
      reminderAt.year,
      reminderAt.month,
      reminderAt.day,
    );
    var from = DateTime(now.year, now.month, now.day);
    final occurrences = <DateTime>[];
    for (var i = 0; i < count; i++) {
      final date = _nextPrayerOccurrenceDate(item, anchor, from);
      if (date == null) {
        break;
      }
      final at = DateTime(
        date.year,
        date.month,
        date.day,
        reminderAt.hour,
        reminderAt.minute,
      );
      if (at.isAfter(now)) {
        occurrences.add(at);
      }
      from = date.add(const Duration(days: 1));
    }
    return occurrences;
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
        if (item.reminderWeekdays.isNotEmpty) {
          for (var offset = 0; offset < 7; offset++) {
            final candidate = from.add(Duration(days: offset));
            if (item.reminderWeekdays.contains(candidate.weekday)) {
              return candidate;
            }
          }
          return null;
        }
        var candidate = from;
        while (candidate.weekday != anchor.weekday) {
          candidate = candidate.add(const Duration(days: 1));
        }
        return candidate;
      case ReminderRecurrence.monthly:
        if (item.reminderMonthlyBasis == CalendarBasis.gregorian) {
          return _nextGregorianDayOfMonth(
            anchor,
            from,
            day: item.reminderDayOfMonth,
          );
        }
        return _nextHijriDayOfMonth(anchor, from, day: item.reminderDayOfMonth);
      case ReminderRecurrence.yearly:
        if (item.reminderYearlyBasis == CalendarBasis.gregorian) {
          return _nextGregorianMonthDay(
            anchor,
            from,
            month: item.reminderYearlyDate?.month,
            day: item.reminderYearlyDate?.day,
          );
        }
        return _nextHijriMonthDay(
          anchor,
          from,
          yearlyDate: item.reminderYearlyDate,
        );
    }
  }

  /// Next date (>= [from]) with the anchor's day-of-month, skipping months
  /// where that day doesn't exist (e.g. the 31st).
  DateTime? _nextGregorianDayOfMonth(DateTime anchor, DateTime from, {int? day}) {
    final targetDay = day ?? anchor.day;
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final year = from.year + ((from.month - 1 + monthOffset) ~/ 12);
      final month = ((from.month - 1 + monthOffset) % 12) + 1;
      final daysInMonth = DateTime(year, month + 1, 0).day;
      if (targetDay > daysInMonth) {
        continue;
      }
      final candidate = DateTime(year, month, targetDay);
      if (!candidate.isBefore(from)) {
        return candidate;
      }
    }
    return null;
  }

  /// Next date (>= [from]) with the anchor's Gregorian month/day.
  DateTime? _nextGregorianMonthDay(
    DateTime anchor,
    DateTime from, {
    int? month,
    int? day,
  }) {
    final targetMonth = month ?? anchor.month;
    final targetDay = day ?? anchor.day;
    final candidate = DateTime(from.year, targetMonth, targetDay);
    if (!candidate.isBefore(from)) {
      return candidate;
    }
    return DateTime(from.year + 1, targetMonth, targetDay);
  }

  /// Next date (>= [from]) whose Hijri day-of-month equals the anchor's,
  /// skipping months shorter than that day.
  DateTime? _nextHijriDayOfMonth(DateTime anchor, DateTime from, {int? day}) {
    final calendar = HijriCalendar();
    final targetDay = day ?? HijriCalendar.fromDate(anchor).hDay;
    final fromHijri = HijriCalendar.fromDate(from);
    for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
      final totalMonths =
          (fromHijri.hYear * 12 + (fromHijri.hMonth - 1)) + monthOffset;
      final hYear = totalMonths ~/ 12;
      final hMonth = (totalMonths % 12) + 1;
      if (targetDay > calendar.getDaysInMonth(hYear, hMonth)) {
        continue;
      }
      final candidateDate = calendar.hijriToGregorian(
        hYear,
        hMonth,
        targetDay,
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
  DateTime? _nextHijriMonthDay(
    DateTime anchor,
    DateTime from, {
    DateTime? yearlyDate,
  }) {
    final calendar = HijriCalendar();
    final anchorHijri = HijriCalendar.fromDate(yearlyDate ?? anchor);
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
