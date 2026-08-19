import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';

void main() {
  group('ItemGroup', () {
    test('round-trips all reminder fields through toMap/fromMap', () {
      final original = ItemGroup(
        id: 'g1',
        title: 'Morning Adhkar',
        reminderEnabled: true,
        reminderAnchor: ItemReminderAnchor.prayerTime,
        reminderRecurrence: ReminderRecurrence.daily,
        reminderMonthlyBasis: CalendarBasis.hijri,
        reminderYearlyBasis: CalendarBasis.hijri,
        reminderAt: DateTime(2026, 8, 19, 7, 30),
        reminderPrayerName: 'Fajr',
        reminderOffsetMinutes: 10,
        reminderAnchorDate: DateTime(2026, 8, 19),
        reminderRepeatCount: 3,
        reminderWeekdays: const [1, 3, 5],
        reminderDayOfMonth: 15,
        reminderYearlyDate: DateTime(2026, 9, 1),
      );

      final restored = ItemGroup.fromMap(original.toMap());

      expect(restored.id, 'g1');
      expect(restored.title, 'Morning Adhkar');
      expect(restored.reminderEnabled, isTrue);
      expect(restored.reminderAnchor, ItemReminderAnchor.prayerTime);
      expect(restored.reminderRecurrence, ReminderRecurrence.daily);
      expect(restored.reminderMonthlyBasis, CalendarBasis.hijri);
      expect(restored.reminderYearlyBasis, CalendarBasis.hijri);
      expect(restored.reminderAt, DateTime(2026, 8, 19, 7, 30));
      expect(restored.reminderPrayerName, 'Fajr');
      expect(restored.reminderOffsetMinutes, 10);
      expect(restored.reminderAnchorDate, DateTime(2026, 8, 19));
      expect(restored.reminderRepeatCount, 3);
      expect(restored.reminderWeekdays, [1, 3, 5]);
      expect(restored.reminderDayOfMonth, 15);
      expect(restored.reminderYearlyDate, DateTime(2026, 9, 1));
    });

    test('fromMap fills defaults for a bare group', () {
      final restored = ItemGroup.fromMap({
        'id': 'g2',
        'title': 'Night Adhkar',
        'reminderWeekdays': '2,9',
      });

      expect(restored.id, 'g2');
      expect(restored.title, 'Night Adhkar');
      expect(restored.reminderEnabled, isFalse);
      expect(restored.reminderAnchor, ItemReminderAnchor.clockTime);
      expect(restored.reminderRecurrence, ReminderRecurrence.once);
      expect(restored.reminderWeekdays, [2]);
    });

    test('copyWith overrides only the provided fields', () {
      const group = ItemGroup(id: 'g', title: 'Original');

      final updated = group.copyWith(title: 'Renamed', reminderEnabled: true);

      expect(updated.id, 'g');
      expect(updated.title, 'Renamed');
      expect(updated.reminderEnabled, isTrue);
      expect(updated.reminderRecurrence, ReminderRecurrence.once);
    });
  });
}