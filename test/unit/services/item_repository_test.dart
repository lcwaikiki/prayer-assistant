import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';

void main() {
  group('ItemRepository.memory', () {
    test('loadItems returns the initial items', () {
      final repository = ItemRepository.memory([_item('a'), _item('b')]);

      final items = repository.loadItems();

      expect(items.map((i) => i.id), ['a', 'b']);
    });

    test('loadItems returns an empty list when nothing was seeded', () {
      final repository = ItemRepository.memory();

      expect(repository.loadItems(), isEmpty);
    });

    test('saveItems replaces the in-memory list and is readable back', () {
      final repository = ItemRepository.memory([_item('a')]);

      repository.saveItems([_item('b'), _item('c')]);

      expect(repository.loadItems().map((i) => i.id), ['b', 'c']);
    });

    test('loadItems returns copies so callers cannot mutate storage', () {
      final repository = ItemRepository.memory([_item('a')]);

      repository.loadItems().clear();

      expect(repository.loadItems(), hasLength(1));
    });

    test('round-trips reminder metadata through the memory store', () {
      final original = Item(
        id: 'a',
        title: 'T',
        notes: 'N',
        count: 33,
        check: 11,
        setCount: 1,
        vibrationIntensity: 70,
        currentProgress: 11,
        reminderEnabled: true,
        reminderAnchor: ItemReminderAnchor.prayerTime,
        reminderRecurrence: ReminderRecurrence.weekly,
        reminderMonthlyBasis: CalendarBasis.hijri,
        reminderYearlyBasis: CalendarBasis.hijri,
        reminderAt: DateTime(2026, 8, 17, 12, 0),
        reminderPrayerName: 'Imsak',
        reminderOffsetMinutes: -5,
        reminderAnchorDate: DateTime(2026, 8, 17),
      );
      final repository = ItemRepository.memory();
      repository.saveItems([original]);

      final restored = repository.loadItems().single;

      expect(restored.title, 'T');
      expect(restored.reminderAnchor, ItemReminderAnchor.prayerTime);
      expect(restored.reminderRecurrence, ReminderRecurrence.weekly);
      expect(restored.reminderMonthlyBasis, CalendarBasis.hijri);
      expect(restored.reminderPrayerName, 'Imsak');
      expect(restored.reminderOffsetMinutes, -5);
      expect(restored.reminderAnchorDate, DateTime(2026, 8, 17));
    });
  });
}

Item _item(String id) {
  return Item(
    id: id,
    title: 'Title $id',
    count: 33,
    check: 11,
    setCount: 0,
    vibrationIntensity: 50,
  );
}