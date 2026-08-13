import 'package:hive/hive.dart';

import '../models/item.dart';

class ItemRepository {
  ItemRepository.hive(Box<dynamic> box) : _box = box, _memoryItems = null;

  ItemRepository.memory([List<Item>? initialItems])
    : _box = null,
      _memoryItems = List<Item>.from(initialItems ?? const []);

  final Box<dynamic>? _box;
  List<Item>? _memoryItems;
  static const _itemsKey = 'items';

  List<Item> loadItems() {
    if (_memoryItems != null) {
      return List<Item>.from(_memoryItems!);
    }

    final raw =
        _box?.get(_itemsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .whereType<Map>()
        .map((map) => Item.fromMap(map))
        .toList(growable: false);
  }

  void saveItems(List<Item> items) {
    if (_memoryItems != null) {
      _memoryItems = List<Item>.from(items);
      return;
    }

    final data = items.map((item) => item.toMap()).toList(growable: false);
    _box?.put(_itemsKey, data);
  }
}
