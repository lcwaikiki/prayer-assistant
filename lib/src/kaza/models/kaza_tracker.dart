import 'dart:convert';

class KazaTracker {
  const KazaTracker({
    this.fajrTarget = 0,
    this.dhuhrTarget = 0,
    this.asrTarget = 0,
    this.maghribTarget = 0,
    this.ishaTarget = 0,
    this.witrTarget = 0,
    this.fajrCompleted = 0,
    this.dhuhrCompleted = 0,
    this.asrCompleted = 0,
    this.maghribCompleted = 0,
    this.ishaCompleted = 0,
    this.witrCompleted = 0,
    this.dailyPace = 6,
  });

  final int fajrTarget;
  final int dhuhrTarget;
  final int asrTarget;
  final int maghribTarget;
  final int ishaTarget;
  final int witrTarget;

  final int fajrCompleted;
  final int dhuhrCompleted;
  final int asrCompleted;
  final int maghribCompleted;
  final int ishaCompleted;
  final int witrCompleted;

  /// Target completed prayers per day (default 6 = 1 full day of prayers).
  final int dailyPace;

  int targetFor(String prayerKey) {
    return switch (prayerKey.toLowerCase()) {
      'fajr' || 'imsak' => fajrTarget,
      'dhuhr' || 'ogle' => dhuhrTarget,
      'asr' || 'ikindi' => asrTarget,
      'maghrib' || 'aksam' => maghribTarget,
      'isha' || 'yatsi' => ishaTarget,
      'witr' => witrTarget,
      _ => 0,
    };
  }

  int completedFor(String prayerKey) {
    return switch (prayerKey.toLowerCase()) {
      'fajr' || 'imsak' => fajrCompleted,
      'dhuhr' || 'ogle' => dhuhrCompleted,
      'asr' || 'ikindi' => asrCompleted,
      'maghrib' || 'aksam' => maghribCompleted,
      'isha' || 'yatsi' => ishaCompleted,
      'witr' => witrCompleted,
      _ => 0,
    };
  }

  int remainingFor(String prayerKey) {
    final target = targetFor(prayerKey);
    final done = completedFor(prayerKey);
    return (target - done).clamp(0, 999999);
  }

  int get totalTarget =>
      fajrTarget + dhuhrTarget + asrTarget + maghribTarget + ishaTarget + witrTarget;

  int get totalCompleted =>
      fajrCompleted +
      dhuhrCompleted +
      asrCompleted +
      maghribCompleted +
      ishaCompleted +
      witrCompleted;

  int get totalRemaining =>
      remainingFor('fajr') +
      remainingFor('dhuhr') +
      remainingFor('asr') +
      remainingFor('maghrib') +
      remainingFor('isha') +
      remainingFor('witr');

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
    int? fajrCompleted,
    int? dhuhrCompleted,
    int? asrCompleted,
    int? maghribCompleted,
    int? ishaCompleted,
    int? witrCompleted,
    int? dailyPace,
  }) {
    return KazaTracker(
      fajrTarget: fajrTarget ?? this.fajrTarget,
      dhuhrTarget: dhuhrTarget ?? this.dhuhrTarget,
      asrTarget: asrTarget ?? this.asrTarget,
      maghribTarget: maghribTarget ?? this.maghribTarget,
      ishaTarget: ishaTarget ?? this.ishaTarget,
      witrTarget: witrTarget ?? this.witrTarget,
      fajrCompleted: fajrCompleted ?? this.fajrCompleted,
      dhuhrCompleted: dhuhrCompleted ?? this.dhuhrCompleted,
      asrCompleted: asrCompleted ?? this.asrCompleted,
      maghribCompleted: maghribCompleted ?? this.maghribCompleted,
      ishaCompleted: ishaCompleted ?? this.ishaCompleted,
      witrCompleted: witrCompleted ?? this.witrCompleted,
      dailyPace: dailyPace ?? this.dailyPace,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fajrTarget': fajrTarget,
      'dhuhrTarget': dhuhrTarget,
      'asrTarget': asrTarget,
      'maghribTarget': maghribTarget,
      'ishaTarget': ishaTarget,
      'witrTarget': witrTarget,
      'fajrCompleted': fajrCompleted,
      'dhuhrCompleted': dhuhrCompleted,
      'asrCompleted': asrCompleted,
      'maghribCompleted': maghribCompleted,
      'ishaCompleted': ishaCompleted,
      'witrCompleted': witrCompleted,
      'dailyPace': dailyPace,
    };
  }

  factory KazaTracker.fromMap(Map<String, dynamic> map) {
    return KazaTracker(
      fajrTarget: (map['fajrTarget'] as num?)?.toInt() ?? 0,
      dhuhrTarget: (map['dhuhrTarget'] as num?)?.toInt() ?? 0,
      asrTarget: (map['asrTarget'] as num?)?.toInt() ?? 0,
      maghribTarget: (map['maghribTarget'] as num?)?.toInt() ?? 0,
      ishaTarget: (map['ishaTarget'] as num?)?.toInt() ?? 0,
      witrTarget: (map['witrTarget'] as num?)?.toInt() ?? 0,
      fajrCompleted: (map['fajrCompleted'] as num?)?.toInt() ?? 0,
      dhuhrCompleted: (map['dhuhrCompleted'] as num?)?.toInt() ?? 0,
      asrCompleted: (map['asrCompleted'] as num?)?.toInt() ?? 0,
      maghribCompleted: (map['maghribCompleted'] as num?)?.toInt() ?? 0,
      ishaCompleted: (map['ishaCompleted'] as num?)?.toInt() ?? 0,
      witrCompleted: (map['witrCompleted'] as num?)?.toInt() ?? 0,
      dailyPace: (map['dailyPace'] as num?)?.toInt() ?? 6,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory KazaTracker.fromJson(String source) =>
      KazaTracker.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
