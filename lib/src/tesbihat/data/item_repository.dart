import 'package:hive/hive.dart';

import '../models/item.dart';
import '../models/item_group.dart';

class ItemRepository {
  ItemRepository.hive(Box<dynamic> box)
      : _box = box,
        _memoryItems = null,
        _memoryGroups = null,
        _memoryHomeOrder = null;

  ItemRepository.memory([
    List<Item>? initialItems,
    List<ItemGroup>? initialGroups,
    List<String>? initialHomeOrder,
  ])  : _box = null,
        _memoryItems = List<Item>.from(initialItems ?? const []),
        _memoryGroups = List<ItemGroup>.from(initialGroups ?? const []),
        _memoryHomeOrder = List<String>.from(initialHomeOrder ?? const []);

  final Box<dynamic>? _box;
  List<Item>? _memoryItems;
  List<ItemGroup>? _memoryGroups;
  List<String>? _memoryHomeOrder;
  static const _itemsKey = 'items';
  static const _groupsKey = 'groups';
  static const _homeOrderKey = 'home_order';

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

  List<ItemGroup> loadGroups() {
    if (_memoryGroups != null) {
      return List<ItemGroup>.from(_memoryGroups!);
    }

    final raw =
        _box?.get(_groupsKey, defaultValue: <dynamic>[]) as List<dynamic>;
    return raw
        .whereType<Map>()
        .map((map) => ItemGroup.fromMap(map))
        .toList(growable: false);
  }

  void saveGroups(List<ItemGroup> groups) {
    if (_memoryGroups != null) {
      _memoryGroups = List<ItemGroup>.from(groups);
      return;
    }

    final data = groups.map((group) => group.toMap()).toList(growable: false);
    _box?.put(_groupsKey, data);
  }

  List<String> loadHomeOrder() {
    if (_memoryHomeOrder != null) {
      return List<String>.from(_memoryHomeOrder!);
    }

    final raw =
        _box?.get(_homeOrderKey, defaultValue: <dynamic>[]) as List<dynamic>?;
    return raw?.whereType<String>().toList(growable: false) ?? const [];
  }

  void saveHomeOrder(List<String> order) {
    if (_memoryHomeOrder != null) {
      _memoryHomeOrder = List<String>.from(order);
      return;
    }

    _box?.put(_homeOrderKey, List<String>.from(order));
  }
}