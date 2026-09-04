import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/services/item_reminder_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../helpers/fake_flutter_local_notifications_platform.dart';

/// Mirrors ItemReminderService's private _notificationId.
int _notificationId(String id) {
  var hash = 0;
  for (final codeUnit in id.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
  }
  return 800000 + (hash % 100000);
}

Item _item({
  required DateTime reminderAt,
  ReminderRecurrence recurrence = ReminderRecurrence.daily,
  int? reminderRepeatCount,
}) {
  return Item(
    id: 'item-1',
    title: 'Subhanallah',
    count: 33,
    check: 11,
    setCount: 0,
    vibrationIntensity: 50,
    reminderEnabled: true,
    reminderRecurrence: recurrence,
    reminderAt: reminderAt,
    reminderRepeatCount: reminderRepeatCount,
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
  late ItemReminderService service;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    platform = FakeFlutterLocalNotificationsPlatform();
    FlutterLocalNotificationsPlatform.instance = platform;
    service = ItemReminderService();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('finite repeat count', () {
    test('daily x3 schedules three one-shots with consecutive ids', () async {
      final anchor = DateTime(2099, 12, 31, 12, 0);
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(reminderAt: anchor, reminderRepeatCount: 3),
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
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(reminderAt: DateTime(2099, 12, 31, 12, 0), reminderRepeatCount: 3),
      );

      final cancelled = [...platform.cancelledIds]..sort();
      expect(cancelled, [for (var i = 0; i < 100; i++) base + i]);
    });

    test('once x5 still schedules a single occurrence', () async {
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(
          reminderAt: DateTime(2099, 12, 31, 12, 0),
          recurrence: ReminderRecurrence.once,
          reminderRepeatCount: 5,
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
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(
          reminderAt: anchor,
          recurrence: ReminderRecurrence.weekly,
          reminderRepeatCount: 2,
        ),
      );

      final now = DateTime.now();
      final expected = <DateTime>[];
      var from = DateTime(now.year, now.month, now.day);
      for (var i = 0; i < 2; i++) {
        var day = from;
        while (day.weekday != anchor.weekday) {
          day = day.add(const Duration(days: 1));
        }
        final at = DateTime(day.year, day.month, day.day, 12, 0);
        if (at.isAfter(now)) {
          expected.add(at);
        }
        from = day.add(const Duration(days: 1));
      }
      expect(platform.scheduledIds, [
        for (var i = 0; i < expected.length; i++) base + i,
      ]);
      expect(
        platform.scheduledDates.map((d) => d.microsecondsSinceEpoch).toList(),
        expected.map((d) => d.microsecondsSinceEpoch).toList(),
      );
      expect(
        platform.scheduledMatches,
        [for (var i = 0; i < expected.length; i++) null],
      );
    });

    test('monthly gregorian x2 skips months without the 31st', () async {
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(
          reminderAt: DateTime(2099, 12, 31, 12, 0),
          recurrence: ReminderRecurrence.monthly,
          reminderRepeatCount: 2,
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
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(
          reminderAt: DateTime(2099, 7, 15, 12, 0),
          recurrence: ReminderRecurrence.yearly,
          reminderRepeatCount: 2,
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
        _item(reminderAt: DateTime(2099, 12, 31, 12, 0), reminderRepeatCount: 3),
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
        _item(reminderAt: DateTime(2099, 12, 31, 12, 0), reminderRepeatCount: 3),
      );

      expect(platform.scheduledIds, isEmpty);
    });
  });
  group('infinite repeat count', () {
    test('null count daily uses the OS-level daily repeat', () async {
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        _item(reminderAt: DateTime(2099, 12, 31, 12, 0)),
      );

      expect(platform.scheduledIds, [base]);
      expect(platform.scheduledMatches.single, DateTimeComponents.time);
    });

    test('null count weekly uses the OS-level weekly repeat', () async {
      await service.scheduleReminder(
        _item(
          reminderAt: DateTime(2099, 1, 2, 12, 0),
          recurrence: ReminderRecurrence.weekly,
        ),
      );

      expect(
        platform.scheduledMatches.single,
        DateTimeComponents.dayOfWeekAndTime,
      );
    });
  });

  group('disabled and cancel', () {
    test('disabled item only clears the id window', () async {
      final base = _notificationId('item-1');
      await service.scheduleReminder(
        Item(
          id: 'item-1',
          title: 'Subhanallah',
          count: 33,
          check: 11,
          setCount: 0,
          vibrationIntensity: 50,
          reminderEnabled: false,
          reminderRecurrence: ReminderRecurrence.daily,
          reminderAt: DateTime(2099, 12, 31, 12, 0),
          reminderRepeatCount: 3,
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
      final base = _notificationId('item-1');
      await service.cancelReminder('item-1');

      expect(platform.cancelledIds.length, 100);
      expect(
        platform.cancelledIds.toSet(),
        {for (var i = 0; i < 100; i++) base + i},
      );
    });
  });

  group('notification message localization', () {
    test('schedules notification with Turkish message when locale is tr', () async {
      final anchor = DateTime(2099, 12, 31, 12, 0);
      await service.scheduleReminder(
        _item(reminderAt: anchor),
        locale: const Locale('tr'),
      );

      expect(platform.scheduledBodies, isNotEmpty);
      expect(platform.scheduledBodies.first, 'Subhanallah zikri vakti geldi.');
    });

    test('schedules notification with Arabic message when locale is ar', () async {
      final anchor = DateTime(2099, 12, 31, 12, 0);
      await service.scheduleReminder(
        _item(reminderAt: anchor),
        locale: const Locale('ar'),
      );

      expect(platform.scheduledBodies, isNotEmpty);
      expect(platform.scheduledBodies.first, 'حان وقت ذكر Subhanallah.');
    });

    test('schedules notification with English message when locale is en', () async {
      final anchor = DateTime(2099, 12, 31, 12, 0);
      await service.scheduleReminder(
        _item(reminderAt: anchor),
        locale: const Locale('en'),
      );

      expect(platform.scheduledBodies, isNotEmpty);
      expect(platform.scheduledBodies.first, 'Time for your Subhanallah dhikr.');
    });
  });
}
