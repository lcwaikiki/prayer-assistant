import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';

Item item({
  String id = 'i1',
  String title = 'Subhanallah',
  String notes = '',
  int count = 33,
  int check = 11,
  int setCount = 0,
  int vibrationIntensity = 50,
  int currentProgress = 0,
  bool reminderEnabled = false,
  ReminderRecurrence reminderRecurrence = ReminderRecurrence.once,
  CalendarBasis reminderMonthlyBasis = CalendarBasis.gregorian,
  CalendarBasis reminderYearlyBasis = CalendarBasis.gregorian,
  DateTime? reminderAt,
  ItemReminderAnchor reminderAnchor = ItemReminderAnchor.clockTime,
  String? reminderPrayerName,
  int reminderOffsetMinutes = 0,
  DateTime? reminderAnchorDate,
  int? reminderRepeatCount,
  List<int> reminderWeekdays = const [],
  int? reminderDayOfMonth,
  DateTime? reminderYearlyDate,
}) {
  return Item(
    id: id,
    title: title,
    notes: notes,
    count: count,
    check: check,
    setCount: setCount,
    vibrationIntensity: vibrationIntensity,
    currentProgress: currentProgress,
    reminderEnabled: reminderEnabled,
    reminderRecurrence: reminderRecurrence,
    reminderMonthlyBasis: reminderMonthlyBasis,
    reminderYearlyBasis: reminderYearlyBasis,
    reminderAt: reminderAt,
    reminderAnchor: reminderAnchor,
    reminderPrayerName: reminderPrayerName,
    reminderOffsetMinutes: reminderOffsetMinutes,
    reminderAnchorDate: reminderAnchorDate,
    reminderRepeatCount: reminderRepeatCount,
    reminderWeekdays: reminderWeekdays,
    reminderDayOfMonth: reminderDayOfMonth,
    reminderYearlyDate: reminderYearlyDate,
  );
}

void main() {
  group('Item constructor asserts', () {
    test('rejects non-positive count', () {
      expect(() => item(count: 0), throwsAssertionError);
    });

    test('rejects non-positive check', () {
      expect(() => item(check: 0), throwsAssertionError);
    });

    test('rejects check above half of count', () {
      expect(() => item(count: 10, check: 6), throwsAssertionError);
    });

    test('rejects negative setCount', () {
      expect(() => item(setCount: -1), throwsAssertionError);
    });

    test('rejects out-of-range vibration intensity', () {
      expect(() => item(vibrationIntensity: 0), throwsAssertionError);
      expect(() => item(vibrationIntensity: 101), throwsAssertionError);
    });

    test('rejects out-of-range currentProgress', () {
      expect(() => item(currentProgress: -1), throwsAssertionError);
      expect(() => item(count: 5, currentProgress: 6), throwsAssertionError);
    });
  });

  group('Item.copyWith', () {
    test('overrides only provided fields', () {
      final base = item(title: 'A', count: 33);
      final updated = base.copyWith(title: 'B', count: 66);

      expect(updated.title, 'B');
      expect(updated.count, 66);
      expect(updated.check, base.check);
      expect(updated.id, base.id);
    });
  });

  group('Item serialization', () {
    test('toMap/fromMap round-trips a full prayer-time item', () {
      final source = item(
        id: 'i9',
        title: 'Istigfar',
        notes: 'Morning',
        count: 100,
        check: 25,
        setCount: 2,
        vibrationIntensity: 80,
        currentProgress: 50,
        reminderEnabled: true,
        reminderRecurrence: ReminderRecurrence.weekly,
        reminderMonthlyBasis: CalendarBasis.hijri,
        reminderYearlyBasis: CalendarBasis.hijri,
        reminderAt: DateTime(2026, 8, 17, 5, 10),
        reminderAnchor: ItemReminderAnchor.prayerTime,
        reminderPrayerName: 'Imsak',
        reminderOffsetMinutes: -10,
        reminderAnchorDate: DateTime(2026, 8, 17),
        reminderRepeatCount: 7,
      );

      final restored = Item.fromMap(source.toMap());

      expect(restored.id, 'i9');
      expect(restored.title, 'Istigfar');
      expect(restored.notes, 'Morning');
      expect(restored.count, 100);
      expect(restored.check, 25);
      expect(restored.setCount, 2);
      expect(restored.vibrationIntensity, 80);
      expect(restored.currentProgress, 50);
      expect(restored.reminderEnabled, isTrue);
      expect(restored.reminderRecurrence, ReminderRecurrence.weekly);
      expect(restored.reminderMonthlyBasis, CalendarBasis.hijri);
      expect(restored.reminderYearlyBasis, CalendarBasis.hijri);
      expect(restored.reminderAt, source.reminderAt);
      expect(restored.reminderAnchor, ItemReminderAnchor.prayerTime);
      expect(restored.reminderPrayerName, 'Imsak');
      expect(restored.reminderOffsetMinutes, -10);
      expect(restored.reminderAnchorDate, DateTime(2026, 8, 17));
      expect(restored.reminderRepeatCount, 7);
    });

    test('fromMap tolerates a missing reminderRepeatCount', () {
      final source = item(reminderAt: DateTime(2026, 8, 17, 12, 0));
      final restored = Item.fromMap(source.toMap()..remove('reminderRepeatCount'));
      expect(restored.reminderRepeatCount, isNull);
    });

    test('copyWith preserves the repeat count', () {
      final base = item(reminderAt: DateTime(2026, 8, 17, 12, 0));
      expect(base.copyWith(reminderRepeatCount: 9).reminderRepeatCount, 9);
      expect(
        base
            .copyWith(reminderRepeatCount: 9)
            .copyWith(title: 'X')
            .reminderRepeatCount,
        9,
      );
    });

    test('fromMap handles legacy reminderRepeat fallback', () {
      final restored = Item.fromMap(const {
        'id': 'legacy',
        'title': 'T',
        'notes': '',
        'count': 33,
        'check': 11,
        'setCount': 0,
        'vibrationIntensity': 50,
        'currentProgress': 0,
        'reminderEnabled': true,
        'reminderRepeat': 'daily',
        'reminderMonthlyBasis': 'gregorian',
        'reminderYearlyBasis': 'gregorian',
        'reminderAnchor': 'clockTime',
        'reminderOffsetMinutes': 0,
        'reminderAt': '2026-08-17T12:00:00.000',
      });

      expect(restored.reminderRecurrence, ReminderRecurrence.daily);
    });

    test('toMap/fromMap round-trips the recurrence-day fields', () {
      final source = item(
        reminderAt: DateTime(2026, 8, 17, 12, 0),
        reminderWeekdays: [2, 4, 6],
        reminderDayOfMonth: 15,
        reminderYearlyDate: DateTime(2026, 5, 6),
      );

      final restored = Item.fromMap(source.toMap());

      expect(restored.reminderWeekdays, [2, 4, 6]);
      expect(restored.reminderDayOfMonth, 15);
      expect(restored.reminderYearlyDate, DateTime(2026, 5, 6));
    });

    test('fromMap tolerates missing recurrence-day keys', () {
      final source = item(reminderAt: DateTime(2026, 8, 17, 12, 0));
      final restored = Item.fromMap(source.toMap()
        ..remove('reminderWeekdays')
        ..remove('reminderDayOfMonth')
        ..remove('reminderYearlyDate'));

      expect(restored.reminderWeekdays, isEmpty);
      expect(restored.reminderDayOfMonth, isNull);
      expect(restored.reminderYearlyDate, isNull);
    });

    test('fromMap filters out-of-range reminder weekdays', () {
      final source = item(reminderAt: DateTime(2026, 8, 17, 12, 0));
      final restored = Item.fromMap(source.toMap()
        ..['reminderWeekdays'] = '1,9,0,7');

      expect(restored.reminderWeekdays, [1, 7]);
    });

    test('fromMap migrates legacy prayer-time items to daily', () {
      final restored = Item.fromMap(const {
        'id': 'legacy-prayer',
        'title': 'T',
        'notes': '',
        'count': 33,
        'check': 11,
        'setCount': 0,
        'vibrationIntensity': 50,
        'currentProgress': 0,
        'reminderEnabled': true,
        'reminderRecurrence': 'once',
        'reminderMonthlyBasis': 'gregorian',
        'reminderYearlyBasis': 'gregorian',
        'reminderAnchor': 'prayerTime',
        'reminderPrayerName': 'Imsak',
        'reminderOffsetMinutes': 0,
      });

      expect(restored.reminderRecurrence, ReminderRecurrence.daily);
      expect(restored.reminderAnchorDate, isNull);
    });

    test('fromMap preserves weekly recurrence for prayer-time items when reminderAnchorDate is null', () {
      final source = item(
        id: 'prayer-weekly',
        reminderEnabled: true,
        reminderRecurrence: ReminderRecurrence.weekly,
        reminderAnchor: ItemReminderAnchor.prayerTime,
        reminderPrayerName: 'Aksam',
        reminderWeekdays: [1, 3, 5],
        reminderAnchorDate: null,
      );

      final map = source.toMap();
      final restored = Item.fromMap(map);

      expect(restored.reminderRecurrence, ReminderRecurrence.weekly);
      expect(restored.reminderWeekdays, [1, 3, 5]);
      expect(restored.reminderAnchorDate, isNotNull);
    });

    test('fromMap preserves weekly recurrence for clock-time items across restart/serialization', () {
      final source = item(
        id: 'clock-weekly',
        reminderEnabled: true,
        reminderRecurrence: ReminderRecurrence.weekly,
        reminderAnchor: ItemReminderAnchor.clockTime,
        reminderAt: DateTime(2026, 9, 4, 8, 30),
        reminderWeekdays: [2, 4, 6],
      );

      final map = source.toMap();
      final restored = Item.fromMap(map);

      expect(restored.reminderRecurrence, ReminderRecurrence.weekly);
      expect(restored.reminderWeekdays, [2, 4, 6]);
      expect(restored.reminderAt, DateTime(2026, 9, 4, 8, 30));
    });

    test('fromMap preserves monthly and yearly recurrences without converting to daily', () {
      final monthly = Item.fromMap(item(
        reminderRecurrence: ReminderRecurrence.monthly,
        reminderDayOfMonth: 15,
      ).toMap());
      final yearly = Item.fromMap(item(
        reminderRecurrence: ReminderRecurrence.yearly,
        reminderYearlyDate: DateTime(2026, 10, 1),
      ).toMap());

      expect(monthly.reminderRecurrence, ReminderRecurrence.monthly);
      expect(monthly.reminderDayOfMonth, 15);
      expect(yearly.reminderRecurrence, ReminderRecurrence.yearly);
      expect(yearly.reminderYearlyDate, DateTime(2026, 10, 1));
    });

    test('fromMap defaults missing numeric fields', () {
      final restored = Item.fromMap(const {
        'id': 'x',
        'title': 'T',
        'notes': '',
        'count': 33,
        'check': 11,
      });

      expect(restored.setCount, 0);
      expect(restored.vibrationIntensity, 1);
      expect(restored.currentProgress, 0);
      expect(restored.reminderOffsetMinutes, 0);
      expect(restored.reminderAnchor, ItemReminderAnchor.clockTime);
    });
  });

  group('Item.validateCheckValue', () {
    test('null check is rejected', () {
      expect(
        Item.validateCheckValue(count: 10, check: null),
        'Check is required',
      );
    });

    test('non-positive check is rejected', () {
      expect(
        Item.validateCheckValue(count: 10, check: 0),
        'Check must be greater than 0',
      );
    });

    test('missing or invalid count is rejected first', () {
      expect(
        Item.validateCheckValue(count: null, check: 5),
        'Enter a valid count first',
      );
      expect(
        Item.validateCheckValue(count: 0, check: 5),
        'Enter a valid count first',
      );
    });

    test('check above half of count is rejected', () {
      expect(
        Item.validateCheckValue(count: 10, check: 6),
        'Check cannot be greater than half of count',
      );
    });

    test('valid check returns null', () {
      expect(Item.validateCheckValue(count: 10, check: 5), isNull);
    });
  });

  group('Item.isCheckpointProgress', () {
    test('returns true when progress is a multiple of check', () {
      expect(
        Item.isCheckpointProgress(currentProgress: 11, check: 11),
        isTrue,
      );
      expect(
        Item.isCheckpointProgress(currentProgress: 22, check: 11),
        isTrue,
      );
    });

    test('returns false for non-multiples', () {
      expect(
        Item.isCheckpointProgress(currentProgress: 5, check: 11),
        isFalse,
      );
    });

    test('returns false for zero or negative values', () {
      expect(
        Item.isCheckpointProgress(currentProgress: 0, check: 11),
        isFalse,
      );
      expect(
        Item.isCheckpointProgress(currentProgress: 11, check: 0),
        isFalse,
      );
    });
  });
}