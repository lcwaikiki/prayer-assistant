class DailyItemStat {
  const DailyItemStat({
    required this.itemId,
    required this.dateKey,
    required this.count,
  });

  factory DailyItemStat.fromMap(Map<String, dynamic> map) {
    return DailyItemStat(
      itemId: (map['itemId'] ?? '').toString(),
      dateKey: (map['dateKey'] ?? '').toString(),
      count: (map['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'dateKey': dateKey,
      'count': count,
    };
  }

  /// The counted item, or null when the item has since been deleted.
  final String itemId;

  /// Day the taps happened, in 'yyyy-MM-dd' local format.
  final String dateKey;

  /// Total taps recorded that day for [itemId].
  final int count;
}
