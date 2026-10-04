import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/item_repository.dart';
import 'items_notifier.dart';

final homeOrderNotifierProvider =
    NotifierProvider<HomeOrderNotifier, List<String>>(HomeOrderNotifier.new);

class HomeOrderNotifier extends Notifier<List<String>> {
  late ItemRepository _repository;

  @override
  List<String> build() {
    _repository = ref.watch(itemRepositoryProvider);
    return _repository.loadHomeOrder();
  }

  void updateOrder(List<String> newOrder) {
    state = List<String>.from(newOrder);
    _repository.saveHomeOrder(state);
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.length) return;
    if (newIndex < 0 || newIndex >= state.length) return;
    if (oldIndex == newIndex) return;

    final nextState = [...state];
    final moved = nextState.removeAt(oldIndex);
    nextState.insert(newIndex, moved);
    state = nextState;
    _repository.saveHomeOrder(state);
  }
}
