import 'package:hive/hive.dart';

import '../models/daily_item_stat.dart';

/// Persists per-day tap counts for tesbih items. Keeps a small in-memory
/// cache so the frequent increment path never re-reads the whole box.
class ItemHistoryRepository {
  ItemHistoryRepository.hive(Box<dynamic> box)
    : _box = box,
      _memoryStats = null {
    _cache = _readFromBox();
  }

  ItemHistoryRepository.memory([List<DailyItemStat>? initialStats])
    : _box = null,
      _memoryStats = List<DailyItemStat>.from(initialStats ?? const []),
      _cache = List<DailyItemStat>.from(initialStats ?? const []);

  final Box<dynamic>? _box;
  List<DailyItemStat>? _memoryStats;
  static const _statsKey = 'daily_stats';
  late List<DailyItemStat> _cache;

  List<DailyItemStat> _readFromBox() {
    final raw =
        _box?.get(_statsKey, defaultValue: <dynamic>[]) as List<dynamic>?;
    return raw
            ?.whereType<Map>()
            .map(
              (map) => DailyItemStat(
                itemId: (map['itemId'] ?? '').toString(),
                dateKey: (map['dateKey'] ?? '').toString(),
                count: (map['count'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList(growable: false) ??
        const <DailyItemStat>[];
  }

  List<DailyItemStat> loadStats() => List<DailyItemStat>.from(_cache);

  void addCount(String itemId, String dateKey, int increment) {
    final index = _cache.indexWhere(
      (stat) => stat.itemId == itemId && stat.dateKey == dateKey,
    );
    if (index >= 0) {
      final existing = _cache[index];
      _cache = [..._cache]
        ..[index] = DailyItemStat(
          itemId: itemId,
          dateKey: dateKey,
          count: existing.count + increment,
        );
    } else {
      _cache = [
        ..._cache,
        DailyItemStat(itemId: itemId, dateKey: dateKey, count: increment),
      ];
    }
    _persist();
  }

  void _persist() {
    if (_memoryStats != null) {
      _memoryStats = List<DailyItemStat>.from(_cache);
      return;
    }
    final data = _cache
        .map(
          (stat) => <String, Object>{
            'itemId': stat.itemId,
            'dateKey': stat.dateKey,
            'count': stat.count,
          },
        )
        .toList(growable: false);
    _box?.put(_statsKey, data);
  }
}
