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
}) {
  return CalendarReminder(
    id: 'calendar-1',
    title: 'T',
    notes: '',
    anchorAt: anchorAt,
    recurrence: recurrence,
    repeatCount: repeatCount,
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

expect(platform.scheduledIds, [base, base + 1, base + 2]);
      final first = _firstDay(anchor);
      final expectedDates = [
        for (var i = 0; i < 3; i++)
          DateTime(
            first.add(Duration(days: i)).year,
            first.add(Duration(days: i)).month,
            first.add(Duration(days: i)).day,
            anchor.hour,
            anchor.minute,
          ),
      ];
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expectedDates.map((d) => d.microsecondsSinceEpoch).toList(),
      );
expect(platform.scheduledMatches, [null, null, null]);
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

    test('inexact-alarm fallback still schedules every occurrence', () async {
      platform.failFirstAttempt = true;
      await service.scheduleReminder(
        _reminder(
          anchorAt: DateTime(2099, 12, 31, 12, 0),
          repeatCount: 3,
        ),
      );

      expect(platform.scheduledIds.length, 3);
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

