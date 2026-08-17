import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';

CalendarReminder reminder({
  String id = 'r1',
  String title = 'Ramadan starts',
  String notes = '',
  DateTime? anchorAt,
  ReminderRecurrence recurrence = ReminderRecurrence.once,
  CalendarBasis monthlyBasis = CalendarBasis.gregorian,
  CalendarBasis yearlyBasis = CalendarBasis.gregorian,
  CalendarReminderAnchor anchor = CalendarReminderAnchor.clockTime,
  String? anchorPrayerName,
  int anchorOffsetMinutes = 0,
  DateTime? anchorDate,
  bool enabled = true,
}) {
  return CalendarReminder(
    id: id,
    title: title,
    notes: notes,
    anchorAt: anchorAt ?? DateTime(2026, 8, 17, 12, 0),
    recurrence: recurrence,
    monthlyBasis: monthlyBasis,
    yearlyBasis: yearlyBasis,
    anchor: anchor,
    anchorPrayerName: anchorPrayerName,
    anchorOffsetMinutes: anchorOffsetMinutes,
    anchorDate: anchorDate,
    enabled: enabled,
  );
}

void main() {
  group('CalendarReminder.occursOn', () {
    test('once reminder occurs only on its anchor day', () {
      final r = reminder(anchorAt: DateTime(2026, 8, 17, 12, 0));

      expect(r.occursOn(DateTime(2026, 8, 17)), isTrue);
      expect(r.occursOn(DateTime(2026, 8, 18)), isFalse);
    });

    test('occursOn returns false before the anchor day', () {
      final r = reminder(anchorAt: DateTime(2026, 8, 17, 12, 0));

      expect(r.occursOn(DateTime(2026, 8, 16)), isFalse);
    });

    test('daily reminder occurs on every day at or after anchor', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.daily,
      );

      expect(r.occursOn(DateTime(2026, 8, 17)), isTrue);
      expect(r.occursOn(DateTime(2026, 12, 31)), isTrue);
      expect(r.occursOn(DateTime(2026, 8, 16)), isFalse);
    });

    test('weekly reminder occurs on the anchor weekday', () {
      // 2026-08-17 is a Monday.
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.weekly,
      );

      expect(r.occursOn(DateTime(2026, 8, 24)), isTrue);
      expect(r.occursOn(DateTime(2026, 8, 25)), isFalse);
    });

    test('monthly Gregorian reminder occurs on the anchor day-of-month', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.monthly,
      );

      expect(r.occursOn(DateTime(2026, 9, 17)), isTrue);
      expect(r.occursOn(DateTime(2026, 9, 16)), isFalse);
    });

    test('yearly Gregorian reminder occurs on the anchor month/day', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.yearly,
      );

      expect(r.occursOn(DateTime(2027, 8, 17)), isTrue);
      expect(r.occursOn(DateTime(2027, 8, 18)), isFalse);
    });

    test('legacy prayer-time reminder (no anchorDate) occurs every day', () {
      final r = reminder(
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Imsak',
      );

      expect(r.occursOn(DateTime(2026, 8, 17)), isTrue);
      expect(r.occursOn(DateTime(2026, 12, 31)), isTrue);
    });

    test('prayer-time reminder with anchorDate honors recurrence', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.weekly,
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Imsak',
        anchorDate: DateTime(2026, 8, 17),
      );

      expect(r.occursOn(DateTime(2026, 8, 24)), isTrue);
      expect(r.occursOn(DateTime(2026, 8, 25)), isFalse);
    });
  });

  group('CalendarReminder.nextOccurrenceFrom', () {
    test('returns null when disabled', () {
      final r = reminder(enabled: false);

      expect(r.nextOccurrenceFrom(DateTime(2026, 1, 1)), isNull);
    });

    test('once reminder returns the anchor moment if upcoming', () {
      final r = reminder(anchorAt: DateTime(2026, 8, 17, 12, 0));

      final next = r.nextOccurrenceFrom(DateTime(2026, 8, 1));

      expect(next, DateTime(2026, 8, 17, 12, 0));
    });

    test('once reminder returns null when the moment has passed', () {
      final r = reminder(anchorAt: DateTime(2026, 8, 17, 12, 0));

      expect(r.nextOccurrenceFrom(DateTime(2026, 8, 17, 13, 0)), isNull);
    });

    test('daily reminder returns today if the time is still ahead', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.daily,
      );

      final next = r.nextOccurrenceFrom(DateTime(2026, 8, 17, 9, 0));

      expect(next, DateTime(2026, 8, 17, 12, 0));
    });

    test('daily reminder rolls to tomorrow when the time passed', () {
      final r = reminder(
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.daily,
      );

      final next = r.nextOccurrenceFrom(DateTime(2026, 8, 17, 15, 0));

      expect(next, DateTime(2026, 8, 18, 12, 0));
    });
  });

  group('CalendarReminder serialization', () {
    test('toMap/fromMap round-trips a full reminder', () {
      final r = reminder(
        id: 'r9',
        title: 'Eid',
        notes: 'Pray at the mosque',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        recurrence: ReminderRecurrence.yearly,
        yearlyBasis: CalendarBasis.hijri,
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Aksam',
        anchorOffsetMinutes: -15,
        anchorDate: DateTime(2026, 8, 17),
        enabled: false,
      );

      final restored = CalendarReminder.fromMap(r.toMap());

      expect(restored.id, 'r9');
      expect(restored.title, 'Eid');
      expect(restored.notes, 'Pray at the mosque');
      expect(restored.anchorAt, r.anchorAt);
      expect(restored.recurrence, ReminderRecurrence.yearly);
      expect(restored.yearlyBasis, CalendarBasis.hijri);
      expect(restored.anchor, CalendarReminderAnchor.prayerTime);
      expect(restored.anchorPrayerName, 'Aksam');
      expect(restored.anchorOffsetMinutes, -15);
      expect(restored.anchorDate, DateTime(2026, 8, 17));
      expect(restored.enabled, isFalse);
    });

    test('fromMap migrates legacy prayer-time recurrence to daily', () {
      final r = CalendarReminder.fromMap(const {
        'id': 'legacy',
        'title': 'Old reminder',
        'notes': '',
        'anchor_at': '2026-08-17T12:00:00.000',
        'recurrence': 'weekly',
        'monthly_basis': 'gregorian',
        'yearly_basis': 'gregorian',
        'anchor': 'prayerTime',
        'anchor_offset_minutes': 0,
        'enabled': 1,
      });

      expect(r.recurrence, ReminderRecurrence.daily);
      expect(r.anchorDate, isNull);
    });

    test('fromMap defaults missing enabled to on', () {
      final r = CalendarReminder.fromMap(const {
        'id': 'x',
        'title': 'T',
        'notes': '',
        'anchor_at': '2026-08-17T12:00:00.000',
        'recurrence': 'once',
        'monthly_basis': 'gregorian',
        'yearly_basis': 'gregorian',
        'anchor': 'clockTime',
        'anchor_offset_minutes': 0,
      });

      expect(r.enabled, isTrue);
    });

    test('copyWith keeps id and overrides only provided fields', () {
      final base = reminder(title: 'A');
      final updated = base.copyWith(title: 'B', enabled: false);

      expect(updated.id, base.id);
      expect(updated.title, 'B');
      expect(updated.enabled, isFalse);
      expect(updated.anchorAt, base.anchorAt);
      expect(updated.recurrence, base.recurrence);
    });
  });
}