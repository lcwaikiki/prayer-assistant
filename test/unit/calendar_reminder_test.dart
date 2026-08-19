import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';

CalendarReminder _reminder({
  DateTime? anchorAt,
  ReminderRecurrence recurrence = ReminderRecurrence.daily,
  CalendarBasis monthlyBasis = CalendarBasis.gregorian,
  CalendarBasis yearlyBasis = CalendarBasis.gregorian,
  int? repeatCount,
  CalendarReminderAnchor anchor = CalendarReminderAnchor.clockTime,
  DateTime? anchorDate,
}) {
  return CalendarReminder(
    id: 'r',
    title: 'T',
    anchorAt: anchorAt ?? DateTime(2099, 12, 31, 12, 0),
    recurrence: recurrence,
    monthlyBasis: monthlyBasis,
    yearlyBasis: yearlyBasis,
    repeatCount: repeatCount,
    anchor: anchor,
    anchorDate: anchorDate,
  );
}

DateTime _day(int year, int month, int day) => DateTime(year, month, day);

void main() {
  group('occursOn with repeatCount', () {
    test('daily x3 marks exactly the first three days', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        repeatCount: 3,
      );
      expect(reminder.occursOn(_day(2099, 1, 1)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 2)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 3)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 4)), isFalse);
      expect(reminder.occursOn(_day(2099, 1, 30)), isFalse);
      expect(reminder.occursOn(_day(2098, 12, 31)), isFalse);
    });

    test('daily with null count repeats forever', () {
      final reminder = _reminder(anchorAt: DateTime(2099, 1, 1, 9, 0));
      expect(reminder.occursOn(_day(2099, 1, 1)), isTrue);
      expect(reminder.occursOn(_day(2099, 2, 1)), isTrue);
      expect(reminder.occursOn(_day(2100, 12, 31)), isTrue);
    });

    test('weekly x2 marks the two matching weekdays only', () {
      final anchor = DateTime(2099, 1, 5, 9, 0);
      final reminder = _reminder(
        anchorAt: anchor,
        recurrence: ReminderRecurrence.weekly,
        repeatCount: 2,
      );
      expect(reminder.occursOn(_day(2099, 1, 5)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 12)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 19)), isFalse);
      expect(reminder.occursOn(_day(2099, 1, 6)), isFalse);
      expect(reminder.occursOn(_day(2098, 12, 29)), isFalse);
    });

    test('monthly x3 skips short months and stops after three occurrences', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 12, 31, 9, 0),
        recurrence: ReminderRecurrence.monthly,
        repeatCount: 3,
      );
      // Occurrences are Dec 31 2099, Jan 31 2100 and Mar 31 2100
      // (Feb 2100 has no 31st).
      expect(reminder.occursOn(_day(2099, 12, 31)), isTrue);
      expect(reminder.occursOn(_day(2100, 1, 31)), isTrue);
      expect(reminder.occursOn(_day(2100, 2, 28)), isFalse);
      expect(reminder.occursOn(_day(2100, 3, 31)), isTrue);
      expect(reminder.occursOn(_day(2100, 5, 31)), isFalse);
    });

    test('yearly x2 gregorian covers the two anniversaries only', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 7, 15, 9, 0),
        recurrence: ReminderRecurrence.yearly,
        repeatCount: 2,
      );
      expect(reminder.occursOn(_day(2099, 7, 15)), isTrue);
      expect(reminder.occursOn(_day(2100, 7, 15)), isTrue);
      expect(reminder.occursOn(_day(2101, 7, 15)), isFalse);
    });

    test('hijri monthly x2 counts only real occurrences', () {
      // HijriCalendar only supports 1937-2077 CE; stay within range.
      final reminder = _reminder(
        anchorAt: DateTime(2076, 12, 31, 9, 0),
        recurrence: ReminderRecurrence.monthly,
        monthlyBasis: CalendarBasis.hijri,
        repeatCount: 2,
      );
      final second = reminder.nextOccurrenceFrom(
        DateTime(2076, 12, 31, 10, 0),
      );
      expect(second, isNotNull);
      expect(second!.isAfter(DateTime(2076, 12, 31)), isTrue);
      expect(reminder.occursOn(second), isTrue);
      final third = reminder.nextOccurrenceFrom(second.add(const Duration(minutes: 1)));
      expect(third, isNull);
    });
  });

  group('nextOccurrenceFrom with repeatCount', () {
    test('returns the remaining occurrences in order, then null', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 3,
      );
      // Occurrences are Jan 1, Jan 2 and Jan 3 at 09:00.
      expect(
        reminder.nextOccurrenceFrom(DateTime(2099, 1, 1, 8, 0)),
        DateTime(2099, 1, 1, 9, 0),
      );
      // The moment check: the day's midnight is past, the 09:00 time is not.
      final first = reminder.nextOccurrenceFrom(DateTime(2099, 1, 2, 8, 0));
      expect(first, DateTime(2099, 1, 2, 9, 0));
      final second = reminder.nextOccurrenceFrom(
        first!.add(const Duration(seconds: 1)),
      );
      expect(second, DateTime(2099, 1, 3, 9, 0));
      expect(
        reminder.nextOccurrenceFrom(second!.add(const Duration(seconds: 1))),
        isNull,
      );
    });

    test('once with a repeatCount still yields a single occurrence', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 6, 1, 9, 0),
        recurrence: ReminderRecurrence.once,
        repeatCount: 5,
      );
      expect(reminder.occursOn(_day(2099, 6, 1)), isTrue);
      expect(reminder.occursOn(_day(2099, 6, 2)), isFalse);
      expect(
        reminder.nextOccurrenceFrom(DateTime(2099, 5, 31)),
        DateTime(2099, 6, 1, 9, 0),
      );
      expect(
        reminder.nextOccurrenceFrom(DateTime(2099, 6, 1, 10, 0)),
        isNull,
      );
    });

    test('disabled reminders yield nothing', () {
      final reminder = CalendarReminder(
        id: 'r',
        title: 'T',
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.daily,
        enabled: false,
        repeatCount: 3,
      );
      expect(reminder.nextOccurrenceFrom(DateTime(2098, 12, 31)), isNull);
    });

    test('legacy prayer-time reminder with count behaves as daily', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 2,
        anchor: CalendarReminderAnchor.prayerTime,
      );
      expect(reminder.occursOn(_day(2099, 1, 1)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 2)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 3)), isFalse);
    });
  });

  group('serialization', () {
    test('toMap/fromMap round-trips the repeat count', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        repeatCount: 7,
      );
      final restored = CalendarReminder.fromMap(reminder.toMap());
      expect(restored.repeatCount, 7);
      expect(restored.anchorAt, DateTime(2099, 1, 1, 9, 0));
    });

    test('fromMap tolerates a missing repeat_count column', () {
      final map = _reminder(anchorAt: DateTime(2099, 1, 1, 9, 0)).toMap()
        ..remove('repeat_count');
      expect(CalendarReminder.fromMap(map).repeatCount, isNull);
    });

    test('copyWith preserves the repeat count', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        repeatCount: 5,
      );
      expect(reminder.copyWith(title: 'X').repeatCount, 5);
      expect(reminder.copyWith(repeatCount: 9).repeatCount, 9);
    });
  });
}
