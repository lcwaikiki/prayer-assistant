import 'dart:convert';

/// Qadaa (missed prayer) progress. Completed counts are derived from an
/// opening [baseline] (prayers made up before daily logging) plus the
/// per-day [dailyLogs].
class KazaTracker {
  const KazaTracker({
    this.fajrTarget = 0,
    this.dhuhrTarget = 0,
    this.asrTarget = 0,
    this.maghribTarget = 0,
    this.ishaTarget = 0,
    this.witrTarget = 0,
    this.baseline = const {},
    this.dailyLogs = const {},
    this.dailyPace = 6,
  });

  static const prayerKeys = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha', 'witr'];

  /// Obligatory raka'at made up per qadaa prayer (witr is wajib).
  static const rakatPerPrayer = {
    'fajr': 2,
    'dhuhr': 4,
    'asr': 4,
    'maghrib': 3,
    'isha': 4,
    'witr': 3,
  };

  final int fajrTarget;
  final int dhuhrTarget;
  final int asrTarget;
  final int maghribTarget;
  final int ishaTarget;
  final int witrTarget;

  /// Prayers made up before daily logging: prayerKey -> count.
  final Map<String, int> baseline;

  /// Prayers made up per day: dateKey (yyyy-MM-dd) -> prayerKey -> count.
  final Map<String, Map<String, int>> dailyLogs;

  /// Target completed prayers per day (default 6 = 1 full day of prayers).
  final int dailyPace;

  /// Maps Turkish prayer names to their canonical qadaa key.
  static String canonicalKey(String prayerKey) =>
      switch (prayerKey.toLowerCase()) {
        'imsak' => 'fajr',
        'ogle' => 'dhuhr',
        'ikindi' => 'asr',
        'aksam' => 'maghrib',
        'yatsi' => 'isha',
        final key => key,
      };

  int targetFor(String prayerKey) {
    return switch (canonicalKey(prayerKey)) {
      'fajr' => fajrTarget,
      'dhuhr' => dhuhrTarget,
      'asr' => asrTarget,
      'maghrib' => maghribTarget,
      'isha' => ishaTarget,
      'witr' => witrTarget,
      _ => 0,
    };
  }

  /// Total logged across all days for [prayerKey].
  int loggedFor(String prayerKey) {
    final key = canonicalKey(prayerKey);
    return dailyLogs.values.fold(0, (sum, day) => sum + (day[key] ?? 0));
  }

  int completedFor(String prayerKey) =>
      (baseline[canonicalKey(prayerKey)] ?? 0) + loggedFor(prayerKey);

  int remainingFor(String prayerKey) {
    final target = targetFor(prayerKey);
    final done = completedFor(prayerKey);
    return (target - done).clamp(0, 999999);
  }

  int get totalTarget =>
      fajrTarget + dhuhrTarget + asrTarget + maghribTarget + ishaTarget + witrTarget;

  int get totalCompleted =>
      prayerKeys.fold(0, (sum, key) => sum + completedFor(key));

  int get totalRemaining =>
      prayerKeys.fold(0, (sum, key) => sum + remainingFor(key));

  double get completionRatio {
    if (totalTarget == 0) return 0.0;
    return (totalCompleted / totalTarget).clamp(0.0, 1.0);
  }

  /// Calculates estimated completion date based on [dailyPace].
  DateTime? estimatedCompletionDate([DateTime? fromDate]) {
    if (totalRemaining <= 0) return null;
    final pace = dailyPace <= 0 ? 6 : dailyPace;
    final daysNeeded = (totalRemaining / pace).ceil();
    final start = fromDate ?? DateTime.now();
    return start.add(Duration(days: daysNeeded));
  }

  KazaTracker copyWith({
    int? fajrTarget,
    int? dhuhrTarget,
    int? asrTarget,
    int? maghribTarget,
    int? ishaTarget,
    int? witrTarget,
    Map<String, int>? baseline,
    Map<String, Map<String, int>>? dailyLogs,
    int? dailyPace,
  }) {
    return KazaTracker(
      fajrTarget: fajrTarget ?? this.fajrTarget,
      dhuhrTarget: dhuhrTarget ?? this.dhuhrTarget,
      asrTarget: asrTarget ?? this.asrTarget,
      maghribTarget: maghribTarget ?? this.maghribTarget,
      ishaTarget: ishaTarget ?? this.ishaTarget,
      witrTarget: witrTarget ?? this.witrTarget,
      baseline: baseline ?? this.baseline,
      dailyLogs: dailyLogs ?? this.dailyLogs,
      dailyPace: dailyPace ?? this.dailyPace,
    );
  }

  /// Serializes targets, pace and baseline. [dailyLogs] are stored separately.
  Map<String, dynamic> toMap() {
    return {
      'fajrTarget': fajrTarget,
      'dhuhrTarget': dhuhrTarget,
      'asrTarget': asrTarget,
      'maghribTarget': maghribTarget,
      'ishaTarget': ishaTarget,
      'witrTarget': witrTarget,
      'baseline': baseline,
      'dailyPace': dailyPace,
    };
  }

  /// Builds a tracker from [map] and its [dailyLogs].
  ///
  /// Legacy maps store `<prayer>Completed` totals instead of a baseline;
  /// those totals already include the logged prayers, so the baseline is
  /// the total minus what was logged.
  factory KazaTracker.fromMap(
    Map<String, dynamic> map, [
    Map<String, Map<String, int>> dailyLogs = const {},
  ]) {
    final tracker = KazaTracker(
      fajrTarget: (map['fajrTarget'] as num?)?.toInt() ?? 0,
      dhuhrTarget: (map['dhuhrTarget'] as num?)?.toInt() ?? 0,
      asrTarget: (map['asrTarget'] as num?)?.toInt() ?? 0,
      maghribTarget: (map['maghribTarget'] as num?)?.toInt() ?? 0,
      ishaTarget: (map['ishaTarget'] as num?)?.toInt() ?? 0,
      witrTarget: (map['witrTarget'] as num?)?.toInt() ?? 0,
      dailyLogs: dailyLogs,
      dailyPace: (map['dailyPace'] as num?)?.toInt() ?? 6,
    );
    final baseline = map['baseline'] as Map<String, dynamic>?;
    if (baseline != null) {
      return tracker.copyWith(
        baseline: baseline.map((k, v) => MapEntry(k, (v as num).toInt())),
      );
    }
    return tracker.copyWith(
      baseline: {
        for (final key in prayerKeys)
          key: (((map['${key}Completed'] as num?)?.toInt() ?? 0) -
                  tracker.loggedFor(key))
              .clamp(0, 999999),
      },
    );
  }

  String toJson() => jsonEncode(toMap());

  factory KazaTracker.fromJson(
    String source, [
    Map<String, Map<String, int>> dailyLogs = const {},
  ]) =>
      KazaTracker.fromMap(jsonDecode(source) as Map<String, dynamic>, dailyLogs);
}

/// Parses a raw daily qadaa log map (dateKey -> {prayerKey: count}).
Map<String, Map<String, int>> kazaDailyLogsFromMap(Map<String, dynamic> raw) {
  return raw.map(
    (dateKey, counts) => MapEntry(
      dateKey,
      (counts as Map<String, dynamic>).map(
        (prayerKey, count) => MapEntry(prayerKey, (count as num).toInt()),
      ),
    ),
  );
}
