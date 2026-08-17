class DailyItemStat {
  const DailyItemStat({
    required this.itemId,
    required this.dateKey,
    required this.count,
  });

  /// The counted item, or null when the item has since been deleted.
  final String itemId;

  /// Day the taps happened, in 'yyyy-MM-dd' local format.
  final String dateKey;

  /// Total taps recorded that day for [itemId].
  final int count;
}
