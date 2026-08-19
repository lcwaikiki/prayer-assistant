import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/state/groups_notifier.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';

import '../../helpers/mocks.dart';

ProviderContainer containerWith(
  ItemRepository repository,
  MockItemReminderService reminderService,
) {
  final container = ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWithValue(repository),
      itemHistoryRepositoryProvider.overrideWithValue(
        ItemHistoryRepository.memory(),
      ),
      itemReminderServiceProvider.overrideWithValue(reminderService),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  late MockItemReminderService reminderService;

  setUpAll(() {
    registerFallbackValue(const ItemGroup(id: 'fallback', title: 'fallback'));
    registerFallbackValue(
      Item(
        id: 'fallback',
        title: 'fallback',
        count: 4,
        check: 2,
        setCount: 0,
        vibrationIntensity: 50,
      ),
    );
  });

  setUp(() {
    reminderService = MockItemReminderService();
    when(
      () => reminderService.scheduleGroupReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => reminderService.scheduleReminder(any()),
    ).thenAnswer((_) async {});
    when(() => reminderService.cancelReminder(any())).thenAnswer((_) async {});
  });

  group('GroupsNotifier.build', () {
    test('loads groups from the repository', () {
      final repository = ItemRepository.memory();
      repository.saveGroups([
        const ItemGroup(id: 'g1', title: 'Morning'),
        const ItemGroup(id: 'g2', title: 'Night'),
      ]);
      final container = containerWith(repository, reminderService);

      expect(
        container.read(groupsNotifierProvider).map((g) => g.id),
        ['g1', 'g2'],
      );
    });

    test('exposes an empty list for an empty repository', () {
      final container = containerWith(ItemRepository.memory(), reminderService);

      expect(container.read(groupsNotifierProvider), isEmpty);
    });
  });

  group('GroupsNotifier.addGroup', () {
    test('appends the group and persists it', () {
      final repository = ItemRepository.memory();
      final container = containerWith(repository, reminderService);

      container
          .read(groupsNotifierProvider.notifier)
          .addGroup(title: 'Morning Adhkar');

      final state = container.read(groupsNotifierProvider);
      expect(state, hasLength(1));
      expect(state.single.title, 'Morning Adhkar');
      expect(repository.loadGroups().single.title, 'Morning Adhkar');
    });

    test('schedules the group reminder when one is configured', () {
      final container = containerWith(ItemRepository.memory(), reminderService);

      container.read(groupsNotifierProvider.notifier).addGroup(
        title: 'Morning Adhkar',
        reminderEnabled: true,
      );

      verify(() => reminderService.scheduleGroupReminder(any())).called(1);
    });
  });

  group('GroupsNotifier.updateGroup', () {
    test('replaces the matching group and persists it', () {
      final repository = ItemRepository.memory();
      repository.saveGroups([
        const ItemGroup(id: 'g1', title: 'Morning'),
        const ItemGroup(id: 'g2', title: 'Night'),
      ]);
      final container = containerWith(repository, reminderService);

      container.read(groupsNotifierProvider.notifier).updateGroup(
            const ItemGroup(id: 'g1', title: 'Renamed'),
          );

      final state = container.read(groupsNotifierProvider);
      expect(state.map((g) => g.title), ['Renamed', 'Night']);
      expect(repository.loadGroups().map((g) => g.title), ['Renamed', 'Night']);
    });
  });

  group('GroupsNotifier.deleteGroup', () {
    test('removes the group, persists, and cancels its reminder', () {
      final repository = ItemRepository.memory();
      repository.saveGroups([
        const ItemGroup(id: 'g1', title: 'Morning'),
        const ItemGroup(id: 'g2', title: 'Night'),
      ]);
      final container = containerWith(repository, reminderService);

      container.read(groupsNotifierProvider.notifier).deleteGroup('g1');

      expect(
        container.read(groupsNotifierProvider).map((g) => g.id),
        ['g2'],
      );
      expect(repository.loadGroups().map((g) => g.id), ['g2']);
      verify(() => reminderService.cancelReminder('g1')).called(1);
    });
  });

  group('GroupsNotifier.restoreGroup', () {
    test('re-inserts the group at the given index and reschedules it', () {
      final repository = ItemRepository.memory();
      repository.saveGroups([const ItemGroup(id: 'g1', title: 'Morning')]);
      final container = containerWith(repository, reminderService);
      final removed = container.read(groupsNotifierProvider).single;
      container.read(groupsNotifierProvider.notifier).deleteGroup('g1');

      container
          .read(groupsNotifierProvider.notifier)
          .restoreGroup(removed, index: 0);

      expect(container.read(groupsNotifierProvider).single.id, 'g1');
      expect(repository.loadGroups().single.id, 'g1');
      verify(() => reminderService.scheduleGroupReminder(any())).called(1);
    });

    test('does nothing when a group with the same id already exists', () {
      final repository = ItemRepository.memory();
      repository.saveGroups([const ItemGroup(id: 'g1', title: 'Morning')]);
      final container = containerWith(repository, reminderService);

      container
          .read(groupsNotifierProvider.notifier)
          .restoreGroup(const ItemGroup(id: 'g1', title: 'Other'), index: 0);

      expect(container.read(groupsNotifierProvider).single.title, 'Morning');
    });
  });
}