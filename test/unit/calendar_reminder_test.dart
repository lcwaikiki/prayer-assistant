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
  List<int> weekdays = const [],
  int? dayOfMonth,
  DateTime? yearlyDate,
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
    weekdays: weekdays,
    dayOfMonth: dayOfMonth,
    yearlyDate: yearlyDate,
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

  group('weekly selected weekdays', () {
    // Anchor is Tuesday 2099-01-06 (weekday 2), which itself is NOT a
    // selected weekday.
    CalendarReminder weekly(List<int> weekdays, {int? repeatCount}) =>
        _reminder(
          anchorAt: DateTime(2099, 1, 6, 9, 0),
          recurrence: ReminderRecurrence.weekly,
          weekdays: weekdays,
          repeatCount: repeatCount,
        );

    test('occursOn matches only the selected weekdays', () {
      final reminder = weekly([1, 3, 5]); // Mon, Wed, Fri.
      expect(reminder.occursOn(_day(2099, 1, 7)), isTrue); // Wed.
      expect(reminder.occursOn(_day(2099, 1, 9)), isTrue); // Fri.
      expect(reminder.occursOn(_day(2099, 1, 12)), isTrue); // Mon.
      expect(reminder.occursOn(_day(2099, 1, 6)), isFalse); // Tue anchor.
      expect(reminder.occursOn(_day(2099, 1, 4)), isFalse); // Sun.
      expect(reminder.occursOn(_day(2099, 1, 8)), isFalse); // Thu.
      expect(reminder.occursOn(_day(2099, 1, 5)), isFalse); // Before anchor.
    });

    test('occursOn with a repeat count counts only matching days', () {
      final reminder = weekly([1, 3, 5], repeatCount: 2);
      expect(reminder.occursOn(_day(2099, 1, 7)), isTrue); // First match.
      expect(reminder.occursOn(_day(2099, 1, 9)), isTrue); // Second match.
      expect(reminder.occursOn(_day(2099, 1, 12)), isFalse); // Third.
      expect(reminder.occursOn(_day(2099, 1, 5)), isFalse); // Before anchor.
    });

    test('nextOccurrenceFrom skips non-matching anchor day', () {
      final reminder = weekly([1, 3, 5]);
      // Tuesday Jan 6 is not a match; the first match is Wed Jan 7.
      expect(
        reminder.nextOccurrenceFrom(DateTime(2099, 1, 6, 8, 0)),
        DateTime(2099, 1, 7, 9, 0),
      );
      // Fri Jan 9 comes after Wed Jan 7.
      expect(
        reminder.nextOccurrenceFrom(DateTime(2099, 1, 7, 10, 0)),
        DateTime(2099, 1, 9, 9, 0),
      );
    });

    test('nextOccurrenceFrom respects a repeat count', () {
      final reminder = weekly([1, 3, 5], repeatCount: 2);
      final first = reminder.nextOccurrenceFrom(DateTime(2099, 1, 6, 8, 0));
      expect(first, DateTime(2099, 1, 7, 9, 0));
      final second = reminder.nextOccurrenceFrom(
        first!.add(const Duration(minutes: 1)),
      );
      expect(second, DateTime(2099, 1, 9, 9, 0));
      expect(
        reminder.nextOccurrenceFrom(second!.add(const Duration(minutes: 1))),
        isNull,
      );
    });

    test('empty weekdays falls back to the anchor weekday', () {
      final reminder = weekly(const []);
      expect(reminder.occursOn(_day(2099, 1, 6)), isTrue); // Tue anchor.
      expect(reminder.occursOn(_day(2099, 1, 13)), isTrue); // Tue.
      expect(reminder.occursOn(_day(2099, 1, 9)), isFalse); // Fri.
    });
  });

  group('monthly explicit day of month', () {
    test('occursOn honors the explicit day', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.monthly,
        dayOfMonth: 5,
      );
      expect(reminder.occursOn(_day(2099, 1, 5)), isTrue);
      expect(reminder.occursOn(_day(2099, 2, 5)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 4)), isFalse);
    });

    test('skips short months for the 31st', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.monthly,
        dayOfMonth: 31,
      );
      expect(reminder.occursOn(_day(2100, 1, 31)), isTrue);
      expect(reminder.occursOn(_day(2100, 2, 28)), isFalse);
      expect(reminder.occursOn(_day(2100, 3, 31)), isTrue);
    });

    test('nextOccurrenceFrom with a repeat count counts real occurrences',
        () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 12, 31, 9, 0),
        recurrence: ReminderRecurrence.monthly,
        dayOfMonth: 31,
        repeatCount: 2,
      );
      // Dec 31 2099 is the anchor day and a match.
      final first = reminder.nextOccurrenceFrom(DateTime(2099, 12, 31, 8, 0));
      expect(first, DateTime(2099, 12, 31, 9, 0));
      final second = reminder.nextOccurrenceFrom(
        first!.add(const Duration(minutes: 1)),
      );
      // Jan 31 2100; Feb is skipped because it has no 31st.
      expect(second, DateTime(2100, 1, 31, 9, 0));
      expect(
        reminder.nextOccurrenceFrom(second!.add(const Duration(minutes: 1))),
        isNull,
      );
    });

    test('null dayOfMonth falls back to the anchor day', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 15, 9, 0),
        recurrence: ReminderRecurrence.monthly,
      );
      expect(reminder.occursOn(_day(2099, 2, 15)), isTrue);
      expect(reminder.occursOn(_day(2099, 2, 16)), isFalse);
    });
  });

  group('yearly explicit month and day', () {
    test('occursOn uses only the month and day of yearlyDate', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.yearly,
        yearlyDate: DateTime(2098, 3, 10),
      );
      expect(reminder.occursOn(_day(2099, 3, 10)), isTrue);
      expect(reminder.occursOn(_day(2100, 3, 10)), isTrue);
      expect(reminder.occursOn(_day(2099, 1, 1)), isFalse);
    });

    test('nextOccurrenceFrom with a repeat count stops after two years',
        () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 7, 15, 9, 0),
        recurrence: ReminderRecurrence.yearly,
        yearlyDate: DateTime(2099, 7, 15),
        repeatCount: 2,
      );
      expect(reminder.occursOn(_day(2099, 7, 15)), isTrue);
      expect(reminder.occursOn(_day(2100, 7, 15)), isTrue);
      expect(reminder.occursOn(_day(2101, 7, 15)), isFalse);
    });

    test('null yearlyDate falls back to the anchor month and day', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 4, 22, 9, 0),
        recurrence: ReminderRecurrence.yearly,
      );
      expect(reminder.occursOn(_day(2099, 4, 22)), isTrue);
      expect(reminder.occursOn(_day(2100, 4, 22)), isTrue);
      expect(reminder.occursOn(_day(2099, 4, 21)), isFalse);
    });
  });

  group('recurrence day serialization', () {
    test('toMap/fromMap round-trips weekdays, dayOfMonth and yearlyDate', () {
      final reminder = _reminder(
        anchorAt: DateTime(2099, 1, 1, 9, 0),
        recurrence: ReminderRecurrence.weekly,
        weekdays: [2, 4, 6],
        dayOfMonth: 15,
        yearlyDate: DateTime(2099, 5, 6),
      );
      final restored = CalendarReminder.fromMap(reminder.toMap());
      expect(restored.weekdays, [2, 4, 6]);
      expect(restored.dayOfMonth, 15);
      expect(restored.yearlyDate, DateTime(2099, 5, 6));
    });

    test('fromMap tolerates missing recurrence-day columns', () {
      final map = _reminder(anchorAt: DateTime(2099, 1, 1, 9, 0)).toMap()
        ..remove('weekdays')
        ..remove('day_of_month')
        ..remove('yearly_date');
      final restored = CalendarReminder.fromMap(map);
      expect(restored.weekdays, isEmpty);
      expect(restored.dayOfMonth, isNull);
      expect(restored.yearlyDate, isNull);
    });

    test('fromMap filters out-of-range weekdays', () {
      final map = _reminder(anchorAt: DateTime(2099, 1, 1, 9, 0)).toMap()
        ..['weekdays'] = '1,9,0,3';
      final restored = CalendarReminder.fromMap(map);
      expect(restored.weekdays, [1, 3]);
    });
  });
}
