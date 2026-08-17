import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';

import '../../helpers/mocks.dart';

Item item(
  String id, {
  String title = 'Subhanallah',
  int count = 33,
  int check = 11,
  int setCount = 0,
  int currentProgress = 0,
}) {
  return Item(
    id: id,
    title: title,
    count: count,
    check: check,
    setCount: setCount,
    vibrationIntensity: 50,
    currentProgress: currentProgress,
  );
}

ProviderContainer containerWith(
  ItemRepository repository,
  MockItemReminderService reminderService,
) {
  final container = ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWithValue(repository),
      itemReminderServiceProvider.overrideWithValue(reminderService),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockItemReminderService reminderService;

  setUpAll(() {
    registerFallbackValue(item('fallback'));
  });

  setUp(() {
    reminderService = MockItemReminderService();
    when(
      () => reminderService.scheduleReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => reminderService.cancelReminder(any()),
    ).thenAnswer((_) async {});
  });

  group('ItemsNotifier.build', () {
    test('loads items from the repository', () {
      final container = containerWith(
        ItemRepository.memory([item('a'), item('b')]),
        reminderService,
      );

      final items = container.read(itemsNotifierProvider);

      expect(items.map((i) => i.id), ['a', 'b']);
    });

    test('exposes an empty list for an empty repository', () {
      final container = containerWith(
        ItemRepository.memory(),
        reminderService,
      );

      expect(container.read(itemsNotifierProvider), isEmpty);
    });
  });

  group('ItemsNotifier.addItem', () {
    test('appends the item, persists and schedules a reminder', () {
      final repository = ItemRepository.memory();
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).addItem(
        title: 'Istigfar',
        notes: 'Morning',
        count: 100,
        check: 25,
        vibrationIntensity: 80,
        reminderEnabled: true,
        reminderAnchor: ItemReminderAnchor.prayerTime,
        reminderPrayerName: 'Imsak',
      );

      final items = container.read(itemsNotifierProvider);
      expect(items, hasLength(1));
      expect(items.single.title, 'Istigfar');
      expect(items.single.notes, 'Morning');
      expect(items.single.reminderAnchor, ItemReminderAnchor.prayerTime);

      final persisted = repository.loadItems();
      expect(persisted.single.title, 'Istigfar');
      verify(() => reminderService.scheduleReminder(any())).called(1);
    });
  });

  group('ItemsNotifier.updateItem', () {
    test('replaces the matching item and reschedules its reminder', () {
      final repository = ItemRepository.memory([item('a', title: 'Old')]);
      final container = containerWith(repository, reminderService);
      final updated = item('a', title: 'New', count: 99);

      container
          .read(itemsNotifierProvider.notifier)
          .updateItem(updated);

      final items = container.read(itemsNotifierProvider);
      expect(items, hasLength(1));
      expect(items.single.title, 'New');
      expect(items.single.count, 99);
      expect(repository.loadItems().single.title, 'New');
      verify(() => reminderService.scheduleReminder(any())).called(1);
    });

    test('leaves other items untouched', () {
      final repository = ItemRepository.memory([
        item('a', title: 'A'),
        item('b', title: 'B'),
      ]);
      final container = containerWith(repository, reminderService);

      container
          .read(itemsNotifierProvider.notifier)
          .updateItem(item('b', title: 'B2'));

      final titles = container
          .read(itemsNotifierProvider)
          .map((i) => i.title)
          .toList();
      expect(titles, ['A', 'B2']);
    });
  });

  group('ItemsNotifier.deleteItem', () {
    test('removes the item, persists and cancels its reminder', () {
      final repository = ItemRepository.memory([
        item('a'),
        item('b'),
      ]);
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).deleteItem('a');

      expect(
        container.read(itemsNotifierProvider).map((i) => i.id),
        ['b'],
      );
      expect(repository.loadItems().map((i) => i.id), ['b']);
      verify(() => reminderService.cancelReminder('a')).called(1);
    });
  });

  group('ItemsNotifier.restoreItem', () {
    test('inserts the item at the requested index and reschedules', () {
      final repository = ItemRepository.memory([
        item('a'),
        item('b'),
      ]);
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).restoreItem(
        item('x', title: 'X'),
        index: 1,
      );

      expect(
        container.read(itemsNotifierProvider).map((i) => i.id),
        ['a', 'x', 'b'],
      );
      verify(() => reminderService.scheduleReminder(any())).called(1);
    });

    test('skips items whose id already exists', () {
      final repository = ItemRepository.memory([item('a')]);
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).restoreItem(
        item('a', title: 'Duplicate'),
        index: 0,
      );

      expect(container.read(itemsNotifierProvider), hasLength(1));
      verifyNever(() => reminderService.scheduleReminder(any()));
    });

    test('clamps out-of-range indexes', () {
      final repository = ItemRepository.memory([item('a')]);
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).restoreItem(
        item('x'),
        index: 99,
      );

      expect(
        container.read(itemsNotifierProvider).map((i) => i.id),
        ['a', 'x'],
      );
    });
  });

  group('ItemsNotifier.reorderItems', () {
    test('moves an item down', () {
      final repository = ItemRepository.memory([
        item('a'),
        item('b'),
        item('c'),
      ]);
      final container = containerWith(repository, reminderService);

      // ReorderableListView semantics: newIndex is the drop position in the
      // list that still includes the dragged item.
      container
          .read(itemsNotifierProvider.notifier)
          .reorderItems(0, 3);

      expect(
        container.read(itemsNotifierProvider).map((i) => i.id),
        ['b', 'c', 'a'],
      );
      expect(repository.loadItems().map((i) => i.id), ['b', 'c', 'a']);
    });

    test('moves an item up', () {
      final repository = ItemRepository.memory([
        item('a'),
        item('b'),
        item('c'),
      ]);
      final container = containerWith(repository, reminderService);

      container
          .read(itemsNotifierProvider.notifier)
          .reorderItems(2, 0);

      expect(
        container.read(itemsNotifierProvider).map((i) => i.id),
        ['c', 'a', 'b'],
      );
    });

    test('ignores out-of-range indexes', () {
      final repository = ItemRepository.memory([item('a')]);
      final container = containerWith(repository, reminderService);

      container.read(itemsNotifierProvider.notifier).reorderItems(5, 0);

      expect(container.read(itemsNotifierProvider), hasLength(1));
      verifyNever(() => reminderService.scheduleReminder(any()));
    });
  });

  group('ItemsNotifier.incrementProgress', () {
    test('returns none for an unknown id', () {
      final container = containerWith(
        ItemRepository.memory([item('a')]),
        reminderService,
      );

      expect(
        container.read(itemsNotifierProvider.notifier).incrementProgress('nope'),
        TapFeedback.none,
      );
    });

    test('returns none at max progress', () {
      final container = containerWith(
        ItemRepository.memory([item('a', count: 33, currentProgress: 33)]),
        reminderService,
      );

      expect(
        container.read(itemsNotifierProvider.notifier).incrementProgress('a'),
        TapFeedback.none,
      );
    });

    test('returns standard feedback for a normal tap', () {
      final container = containerWith(
        ItemRepository.memory([item('a', count: 33, currentProgress: 5)]),
        reminderService,
      );

      expect(
        container.read(itemsNotifierProvider.notifier).incrementProgress('a'),
        TapFeedback.standard,
      );
      expect(
        container.read(itemsNotifierProvider).single.currentProgress,
        6,
      );
    });

    test('returns checkpoint feedback at check boundaries', () {
      final container = containerWith(
        ItemRepository.memory([item('a', count: 33, currentProgress: 10)]),
        reminderService,
      );

      expect(
        container.read(itemsNotifierProvider.notifier).incrementProgress('a'),
        TapFeedback.checkpoint,
      );
    });

    test('increments setCount when the full count is reached', () {
      final container = containerWith(
        ItemRepository.memory([
          item('a', count: 33, currentProgress: 32, setCount: 2),
        ]),
        reminderService,
      );

      container.read(itemsNotifierProvider.notifier).incrementProgress('a');

      final current = container.read(itemsNotifierProvider).single;
      expect(current.currentProgress, 33);
      expect(current.setCount, 3);
    });
  });

  group('ItemsNotifier.resetProgress', () {
    test('zeroes progress but keeps setCount', () {
      final container = containerWith(
        ItemRepository.memory([
          item('a', currentProgress: 20, setCount: 1),
        ]),
        reminderService,
      );

      container.read(itemsNotifierProvider.notifier).resetProgress('a');

      final current = container.read(itemsNotifierProvider).single;
      expect(current.currentProgress, 0);
      expect(current.setCount, 1);
    });

    test('is a no-op for unknown ids', () {
      final container = containerWith(
        ItemRepository.memory([item('a', currentProgress: 5)]),
        reminderService,
      );

      container.read(itemsNotifierProvider.notifier).resetProgress('nope');

      expect(
        container.read(itemsNotifierProvider).single.currentProgress,
        5,
      );
    });
  });

  group('ItemsNotifier.setProgress', () {
    test('clamps progress into the item range', () {
      final container = containerWith(
        ItemRepository.memory([item('a', count: 10, check: 5)]),
        reminderService,
      );

      final notifier = container.read(itemsNotifierProvider.notifier);
      notifier.setProgress('a', -5);
      expect(container.read(itemsNotifierProvider).single.currentProgress, 0);

      notifier.setProgress('a', 99);
      expect(container.read(itemsNotifierProvider).single.currentProgress, 10);

      notifier.setProgress('a', 4);
      expect(container.read(itemsNotifierProvider).single.currentProgress, 4);
    });
  });

  group('ItemsNotifier.updateProgressAndSetCount', () {
    test('returns an error for an unknown id', () {
      final container = containerWith(
        ItemRepository.memory([item('a')]),
        reminderService,
      );

      final error = container
          .read(itemsNotifierProvider.notifier)
          .updateProgressAndSetCount(id: 'nope', progress: 0, setCount: 0);

      expect(error, 'Item not found');
    });

    test('rejects out-of-range progress', () {
      final container = containerWith(
        ItemRepository.memory([item('a', count: 10, check: 5)]),
        reminderService,
      );

      final error = container
          .read(itemsNotifierProvider.notifier)
          .updateProgressAndSetCount(id: 'a', progress: 11, setCount: 0);

      expect(error, contains('between'));
    });

    test('rejects negative set count', () {
      final container = containerWith(
        ItemRepository.memory([item('a')]),
        reminderService,
      );

      final error = container
          .read(itemsNotifierProvider.notifier)
          .updateProgressAndSetCount(id: 'a', progress: 0, setCount: -1);

      expect(error, 'Set count cannot be negative');
    });

    test('applies valid values and returns null', () {
      final container = containerWith(
        ItemRepository.memory([item('a')]),
        reminderService,
      );

      final error = container
          .read(itemsNotifierProvider.notifier)
          .updateProgressAndSetCount(id: 'a', progress: 7, setCount: 3);

      expect(error, isNull);
      final current = container.read(itemsNotifierProvider).single;
      expect(current.currentProgress, 7);
      expect(current.setCount, 3);
    });
  });
}