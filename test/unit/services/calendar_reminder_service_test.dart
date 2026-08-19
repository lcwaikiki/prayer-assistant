import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/services/calendar_reminder_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_flutter_local_notifications_platform.dart';

/// Mirrors CalendarReminderService's private _notificationId.
int _notificationId(String id) {
  var hash = 0;
  for (final codeUnit in id.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
  }
  return 700000 + (hash % 100000);
}

CalendarReminder _reminder({
  required DateTime anchorAt,
  ReminderRecurrence recurrence = ReminderRecurrence.daily,
  int? repeatCount,
  List<int> weekdays = const [],
  int? dayOfMonth,
  DateTime? yearlyDate,
}) {
  return CalendarReminder(
    id: 'calendar-1',
    title: 'T',
    notes: '',
    anchorAt: anchorAt,
    recurrence: recurrence,
    repeatCount: repeatCount,
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
    yearlyDate: yearlyDate,
  );
}

/// The first occurrence day for a clock-anchored reminder, starting today.
/// Mirrors the service: naive (machine-local) DateTimes throughout.
DateTime _firstDay(DateTime anchorTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final todayAt = DateTime(
      today.year, today.month, today.day, anchorTime.hour, anchorTime.minute);
  return todayAt.isAfter(now) ? today : today.add(const Duration(days: 1));
}

/// Next date (>= [from]) whose Gregorian day-of-month is the 31st.
DateTime? _next31(DateTime from) {
  for (var offset = 0; offset < 12; offset++) {
    final year = from.year + ((from.month - 1 + offset) ~/ 12);
    final month = ((from.month - 1 + offset) % 12) + 1;
    if (31 > DateTime(year, month + 1, 0).day) {
      continue;
    }
    final candidate = DateTime(year, month, 31);
    if (!candidate.isBefore(from)) {
      return candidate;
    }
  }
  return null;
}

/// Next moment at [hour]:[minute] on [weekday] (DateTime.weekday), strictly
/// after now, in tz.local. Mirrors CalendarReminderService._nextWeekday.
tz.TZDateTime _nextWeekdayAt(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var scheduled =
      tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
  if (!scheduled.isAfter(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  while (scheduled.weekday != weekday) {
    scheduled = scheduled.add(const Duration(days: 1));
  }
  return scheduled;
}

/// Next moment at [hour]:[minute] on the [day]th of a month, strictly after
/// now in tz.local, skipping months without that day. Mirrors
/// CalendarReminderService._nextDayOfMonth.
tz.TZDateTime? _nextDayOfMonthAt(int day, int hour, int minute) {
  final times = _nextDayOfMonthTimes(day, hour, minute, 1);
  return times.isEmpty ? null : times.first;
}

/// The first [count] moments at [hour]:[minute] on the [day]th of a month,
/// strictly after now in tz.local, skipping months without that day.
List<tz.TZDateTime> _nextDayOfMonthTimes(
    int day, int hour, int minute, int count) {
  final now = tz.TZDateTime.now(tz.local);
  final times = <tz.TZDateTime>[];
  for (var monthOffset = 0;
      monthOffset < 24 && times.length < count;
      monthOffset++) {
    final year = now.year + ((now.month - 1 + monthOffset) ~/ 12);
    final month = ((now.month - 1 + monthOffset) % 12) + 1;
    if (day > DateTime(year, month + 1, 0).day) {
      continue;
    }
    final candidate = tz.TZDateTime(tz.local, year, month, day, hour, minute);
    if (candidate.isAfter(now)) {
      times.add(candidate);
    }
  }
  return times;
}

/// Next moment at [hour]:[minute] on [month]/[day], strictly after now in
/// tz.local. Mirrors CalendarReminderService._nextDayOfYear.
tz.TZDateTime _nextMonthDayAt(int month, int day, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  var candidate = tz.TZDateTime(tz.local, now.year, month, day, hour, minute);
  if (!candidate.isAfter(now)) {
    candidate = tz.TZDateTime(
      tz.local,
      now.year + 1,
      month,
      day,
      hour,
      minute,
    );
  }
  return candidate;
}

/// Next moment at [hour]:[minute] on [month]/[day], strictly after now,
/// in machine-local time (mirrors the finite-count path, whose naive
/// DateTimes are interpreted as local by TZDateTime.from).
DateTime _nextMonthDayAtLocal(int month, int day, int hour, int minute) {
  final now = DateTime.now();
  var candidate = DateTime(now.year, month, day, hour, minute);
  if (!candidate.isAfter(now)) {
    candidate = DateTime(now.year + 1, month, day, hour, minute);
  }
  return candidate;
}

/// Next date (>= [from]) whose day-of-month is [day] (short months
/// skipped). Mirrors CalendarReminderService._nextGregorianDayOfMonth.
DateTime _nextDayOfMonthFrom(DateTime from, int day) {
  for (var monthOffset = 0; monthOffset < 12; monthOffset++) {
    final year = from.year + ((from.month - 1 + monthOffset) ~/ 12);
    final month = ((from.month - 1 + monthOffset) % 12) + 1;
    if (day > DateTime(year, month + 1, 0).day) {
      continue;
    }
    final candidate = DateTime(year, month, day);
    if (!candidate.isBefore(from)) {
      return candidate;
    }
  }
  throw StateError('unreachable');
}

/// Next date (>= [from]) whose weekday is in [weekdays].
DateTime _nextMatchingWeekday(DateTime from, List<int> weekdays) {
  for (var offset = 0; offset < 7; offset++) {
    final candidate = from.add(Duration(days: offset));
    if (weekdays.contains(candidate.weekday)) {
      return candidate;
    }
  }
  throw StateError('unreachable');
}

void main() {
  late FakeFlutterLocalNotificationsPlatform platform;
  late CalendarReminderService service;

setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    platform = FakeFlutterLocalNotificationsPlatform();
    FlutterLocalNotificationsPlatform.instance = platform;
    service = CalendarReminderService();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('finite repeat count', () {
    test('daily x3 schedules three one-shots with consecutive ids', () async {
      final anchor = DateTime(2099, 12, 31, 12, 0);
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(anchorAt: anchor, repeatCount: 3),
      );

      // Mirrors the service: today's 12:00 is dropped when already past, so
      // fewer than three occurrences may remain.
      final now = DateTime.now();
      final expectedDates = <DateTime>[];
      var from = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < 3; i++) {
        final at = DateTime(from.year, from.month, from.day, 12, 0);
        if (at.isAfter(now)) {
          expectedDates.add(at);
        }
        from = from.add(const Duration(days: 1));
      }
      expect(platform.scheduledIds, [
        for (var i = 0; i < expectedDates.length; i++) base + i,
      ]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expectedDates.map((d) => d.microsecondsSinceEpoch).toList(),
      );
      expect(
        platform.scheduledMatches,
        [for (var i = 0; i < expectedDates.length; i++) null],
      );
    });

    test('daily x3 clears the full id window first', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          repeatCount: 3,
        ),
      );

      final cancelled = [...platform.cancelledIds]..sort();
      expect(cancelled, [for (var i = 0; i < 100; i++) base + i]);
    });

    test('once x5 still schedules a single occurrence', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          recurrence: ReminderRecurrence.once,
          repeatCount: 5,
        ),
      );

expect(platform.scheduledIds, [base]);
      expect(
        platform.scheduledDates.single.microsecondsSinceEpoch,
        DateTime(2099, 12, 31, 12, 0).microsecondsSinceEpoch,
      );
      expect(platform.scheduledMatches.single, isNull);
    });

    test('weekly x2 schedules the next two matching weekdays', () async {
      final anchor = DateTime(2099, 1, 2, 12, 0);
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: anchor,
          recurrence: ReminderRecurrence.weekly,
          repeatCount: 2,
        ),
      );

      var day = _firstDay(anchor);
      while (day.weekday != anchor.weekday) {
        day = day.add(const Duration(days: 1));
      }
final expected = [
        DateTime(day.year, day.month, day.day, 12, 0),
        DateTime(
          day.add(const Duration(days: 7)).year,
          day.add(const Duration(days: 7)).month,
          day.add(const Duration(days: 7)).day,
          12,
          0,
        ),
      ];
      expect(platform.scheduledIds, [base, base + 1]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
      expect(platform.scheduledMatches, [null, null]);
    });

    test('monthly gregorian x2 skips months without the 31st', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          recurrence: ReminderRecurrence.monthly,
          repeatCount: 2,
        ),
      );

final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      var first = _next31(today)!;
      if (!DateTime(first.year, first.month, first.day, 12, 0)
          .isAfter(DateTime.now())) {
        first = _next31(first.add(const Duration(days: 1)))!;
      }
      final second = _next31(first.add(const Duration(days: 1)))!;
      final expected = [
        DateTime(first.year, first.month, first.day, 12, 0),
        DateTime(second.year, second.month, second.day, 12, 0),
      ];
      expect(platform.scheduledIds, [base, base + 1]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('yearly x2 schedules the two anniversaries', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 7, 15, 12, 0),
          recurrence: ReminderRecurrence.yearly,
          repeatCount: 2,
        ),
      );

final now = DateTime.now();
      var year = now.year;
      if (!DateTime(year, 7, 15, 12, 0).isAfter(now)) {
        year++;
      }
      final expected = [
        DateTime(year, 7, 15, 12, 0),
        DateTime(year + 1, 7, 15, 12, 0),
      ];
      expect(platform.scheduledIds, [base, base + 1]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('weekly x2 on selected weekdays schedules the next two matching '
        'weekdays', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 2, 12, 0),
          recurrence: ReminderRecurrence.weekly,
          weekdays: [1, 3, 5],
          repeatCount: 2,
        ),
      );

      // Mirrors the service loop: a matching day whose 12:00 is already past
      // consumes an iteration without scheduling.
      final now = DateTime.now();
      final matches = <DateTime>[];
      var from = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < 2; i++) {
        final date = _nextMatchingWeekday(from, [1, 3, 5]);
        final at = DateTime(date.year, date.month, date.day, 12, 0);
        if (at.isAfter(now)) {
          matches.add(at);
        }
        from = date.add(const Duration(days: 1));
      }
      expect(platform.scheduledIds, [
        for (var i = 0; i < matches.length; i++) base + i,
      ]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        matches.map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('monthly x2 with an explicit day schedules the next two month days',
        () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 1, 9, 0),
          recurrence: ReminderRecurrence.monthly,
          dayOfMonth: 15,
          repeatCount: 2,
        ),
      );

      // Mirrors the service loop: a matching day whose 09:00 is already past
      // consumes an iteration without scheduling.
      final now = DateTime.now();
      final expected = <DateTime>[];
      var from = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < 2; i++) {
        final date = _nextDayOfMonthFrom(from, 15);
        final at = DateTime(date.year, date.month, date.day, 9, 0);
        if (at.isAfter(now)) {
          expected.add(at);
        }
        from = date.add(const Duration(days: 1));
      }
      expect(platform.scheduledIds, [
        for (var i = 0; i < expected.length; i++) base + i,
      ]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('yearly x2 with an explicit month and day schedules the two '
        'anniversaries', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 1, 9, 0),
          recurrence: ReminderRecurrence.yearly,
          yearlyDate: DateTime(2098, 3, 10),
          repeatCount: 2,
        ),
      );

      final first = _nextMonthDayAtLocal(3, 10, 9, 0);
      final second = DateTime(first.year + 1, 3, 10, 9, 0);
      expect(platform.scheduledIds, [base, base + 1]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        [first, second].map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('inexact-alarm fallback still schedules every occurrence', () async {
      platform.failFirstAttempt = true;
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          repeatCount: 3,
        ),
      );

      // Today's 12:00 is dropped when already past, like the service does.
      final now = DateTime.now();
      final todayAt = DateTime(now.year, now.month, now.day, 12, 0);
      final expected = todayAt.isAfter(now) ? 3 : 2;
      expect(platform.scheduledIds.length, expected);
    });

    test('stops scheduling when even inexact scheduling fails', () async {
      platform.failSchedules = true;
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          repeatCount: 3,
        ),
      );

      expect(platform.scheduledIds, isEmpty);
    });
  });
  group('infinite repeat count', () {
    test('null count daily uses the OS-level daily repeat', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(anchorAt: DateTime(2099, 12, 31, 12, 0)),
      );

      expect(platform.scheduledIds, [base]);
      expect(
        platform.scheduledMatches.single,
        DateTimeComponents.time,
      );
    });

    test('null count weekly uses the OS-level weekly repeat', () async {
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 2, 12, 0),
          recurrence: ReminderRecurrence.weekly,
        ),
      );

      expect(platform.scheduledMatches.single, DateTimeComponents.dayOfWeekAndTime);
    });

    test('weekly on selected weekdays schedules one OS repeat per weekday',
        () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 2, 12, 0),
          recurrence: ReminderRecurrence.weekly,
          weekdays: [1, 3, 5],
        ),
      );

      expect(platform.scheduledIds, [base, base + 1, base + 2]);
      expect(
        platform.scheduledMatches,
        [
          DateTimeComponents.dayOfWeekAndTime,
          DateTimeComponents.dayOfWeekAndTime,
          DateTimeComponents.dayOfWeekAndTime,
        ],
      );
      final expected = [
        _nextWeekdayAt(1, 12, 0),
        _nextWeekdayAt(3, 12, 0),
        _nextWeekdayAt(5, 12, 0),
      ];
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
    });

    test('monthly with an explicit day uses dayOfMonthAndTime', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 1, 9, 0),
          recurrence: ReminderRecurrence.monthly,
          dayOfMonth: 15,
        ),
      );

      expect(platform.scheduledIds, [base]);
      expect(
        platform.scheduledMatches.single,
        DateTimeComponents.dayOfMonthAndTime,
      );
      expect(
        platform.scheduledDates.single.microsecondsSinceEpoch,
        _nextDayOfMonthAt(15, 9, 0)!.microsecondsSinceEpoch,
      );
    });

    test('monthly day 31 skips months without the 31st', () async {
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 1, 9, 0),
          recurrence: ReminderRecurrence.monthly,
          dayOfMonth: 31,
        ),
      );

      final date = platform.scheduledDates.single;
      expect(date.day, 31);
      expect(
        date.microsecondsSinceEpoch,
        _nextDayOfMonthAt(31, 9, 0)!.microsecondsSinceEpoch,
      );
    });

    test('yearly with an explicit month and day uses dateAndTime', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 1, 1, 9, 0),
          recurrence: ReminderRecurrence.yearly,
          yearlyDate: DateTime(2098, 3, 10),
        ),
      );

      expect(platform.scheduledIds, [base]);
      expect(
        platform.scheduledMatches.single,
        DateTimeComponents.dateAndTime,
      );
      expect(
        platform.scheduledDates.single.microsecondsSinceEpoch,
        _nextMonthDayAt(3, 10, 9, 0).microsecondsSinceEpoch,
      );
    });
  });

  group('disabled and cancel', () {
    test('disabled reminder only clears the id window', () async {
      final base = _notificationId('calendar-1');
      await service.scheduleReminder(
        CalendarReminder(
          id: 'calendar-1',
          title: 'T',
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          recurrence: ReminderRecurrence.daily,
          repeatCount: 3,
          enabled: false,
        ),
      );

      expect(platform.scheduledIds, isEmpty);
      expect(platform.cancelledIds.length, 100);
      expect(
        platform.cancelledIds.toSet(),
        {for (var i = 0; i < 100; i++) base + i},
      );
    });

    test('cancelReminder clears the full id window', () async {
      final base = _notificationId('calendar-1');
      await service.cancelReminder('calendar-1');

      expect(platform.cancelledIds.length, 100);
      expect(
        platform.cancelledIds.toSet(),
        {for (var i = 0; i < 100; i++) base + i},
      );
    });
  });
}

