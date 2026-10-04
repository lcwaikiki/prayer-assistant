import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/state/home_order_notifier.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';

import '../../helpers/mocks.dart';

ProviderContainer _containerWith(ItemRepository repository) {
  final container = ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWithValue(repository),
      itemHistoryRepositoryProvider.overrideWithValue(
        ItemHistoryRepository.memory(),
      ),
      itemReminderServiceProvider.overrideWithValue(MockItemReminderService()),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('HomeOrderNotifier', () {
    test('loads home order from repository on build', () {
      final repository = ItemRepository.memory(
        null,
        null,
        ['group:g1', 'item:i1'],
      );
      final container = _containerWith(repository);

      final order = container.read(homeOrderNotifierProvider);

      expect(order, ['group:g1', 'item:i1']);
    });

    test('updateOrder replaces order and persists to repository', () {
      final repository = ItemRepository.memory();
      final container = _containerWith(repository);

      container
          .read(homeOrderNotifierProvider.notifier)
          .updateOrder(['item:i2', 'group:g1', 'item:i1']);

      expect(container.read(homeOrderNotifierProvider), [
        'item:i2',
        'group:g1',
        'item:i1',
      ]);
      expect(repository.loadHomeOrder(), ['item:i2', 'group:g1', 'item:i1']);
    });

    test('reorder moves item to new position and persists', () {
      final repository = ItemRepository.memory(
        null,
        null,
        ['group:g1', 'item:i1', 'item:i2'],
      );
      final container = _containerWith(repository);

      container.read(homeOrderNotifierProvider.notifier).reorder(2, 0);

      expect(container.read(homeOrderNotifierProvider), [
        'item:i2',
        'group:g1',
        'item:i1',
      ]);
      expect(repository.loadHomeOrder(), ['item:i2', 'group:g1', 'item:i1']);
    });

    test('reorder ignores out of bounds indexes and no-ops', () {
      final repository = ItemRepository.memory(
        null,
        null,
        ['group:g1', 'item:i1'],
      );
      final container = _containerWith(repository);

      container.read(homeOrderNotifierProvider.notifier).reorder(-1, 0);
      container.read(homeOrderNotifierProvider.notifier).reorder(0, 5);
      container.read(homeOrderNotifierProvider.notifier).reorder(1, 1);

      expect(container.read(homeOrderNotifierProvider), ['group:g1', 'item:i1']);
    });
  });
}
