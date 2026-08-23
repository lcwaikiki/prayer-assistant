import 'package:flutter/material.dart';


/// Representation of streak metrics calculated from prayer completion history.
@immutable
class PrayerStreakResult {
  const PrayerStreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeCurrentStreak,
    required this.activeLongestStreak,
  });

  /// Consecutive days leading up to today/yesterday with all 5 daily prayers completed.
  final int currentStreak;

  /// Maximum consecutive days ever achieved with all 5 daily prayers completed.
  final int longestStreak;

  /// Consecutive days leading up to today/yesterday with at least 1 prayer completed.
  final int activeCurrentStreak;

  /// Maximum consecutive days ever achieved with at least 1 prayer completed.
  final int activeLongestStreak;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerStreakResult &&
          runtimeType == other.runtimeType &&
          currentStreak == other.currentStreak &&
          longestStreak == other.longestStreak &&
          activeCurrentStreak == other.activeCurrentStreak &&
          activeLongestStreak == other.activeLongestStreak;

  @override
  int get hashCode =>
      currentStreak.hashCode ^
      longestStreak.hashCode ^
      activeCurrentStreak.hashCode ^
      activeLongestStreak.hashCode;
}

/// Statistics for an individual prayer (Fajr, Dhuhr, Asr, Maghrib, Isha).
@immutable
class PrayerStat {
  const PrayerStat({
    required this.prayerKey,
    required this.completedCount,
    required this.totalDays,
  });

  final String prayerKey;
  final int completedCount;
  final int totalDays;

  double get percentage =>
      totalDays == 0 ? 0.0 : (completedCount / totalDays * 100).clamp(0, 100);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerStat &&
          runtimeType == other.runtimeType &&
          prayerKey == other.prayerKey &&
          completedCount == other.completedCount &&
          totalDays == other.totalDays;

  @override
  int get hashCode =>
      prayerKey.hashCode ^ completedCount.hashCode ^ totalDays.hashCode;
}

/// Daily heatmap cell info.
@immutable
class DailyHeatmapCell {
  const DailyHeatmapCell({
    required this.date,
    required this.completedCount,
    required this.totalPrayers,
  });

  final DateTime date;
  final int completedCount;
  final int totalPrayers;

  double get ratio =>
      totalPrayers == 0 ? 0.0 : (completedCount / totalPrayers).clamp(0.0, 1.0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyHeatmapCell &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          completedCount == other.completedCount &&
          totalPrayers == other.totalPrayers;

  @override
  int get hashCode =>
      date.hashCode ^ completedCount.hashCode ^ totalPrayers.hashCode;
}

/// Service providing calculations for prayer analytics, streaks, heatmaps, and completion rates.
class PrayerAnalyticsService {
  const PrayerAnalyticsService();

  static const List<String> corePrayers = [
    'imsak', // Fajr / Imsak
    'ogle',  // Dhuhr / Ogle
    'ikindi',// Asr / Ikindi
    'aksam', // Maghrib / Aksam
    'yatsi', // Isha / Yatsi
  ];

  /// Standardizes a DateTime to yyyy-MM-dd date key.
  static String dateToKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }

  /// Checks if a date has all 5 core daily prayers completed.
  bool isDayFullyCompleted(
    Map<String, List<String>> completions,
    DateTime date,
  ) {
    final key = dateToKey(date);
    final list = completions[key];
    if (list == null) return false;
    final lowerList = list.map((e) => e.toLowerCase()).toSet();
    return corePrayers.every(lowerList.contains);
  }

  /// Gets total completed core prayers count for a specific date (0 to 5).
  int completedCountForDay(
    Map<String, List<String>> completions,
    DateTime date,
  ) {
    final key = dateToKey(date);
    final list = completions[key];
    if (list == null) return 0;
    final lowerList = list.map((e) => e.toLowerCase()).toSet();
    return corePrayers.where(lowerList.contains).length;
  }

  /// Calculates current and longest streaks.
  PrayerStreakResult calculateStreaks(
    Map<String, List<String>> completions, {
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final safeToday = DateTime(now.year, now.month, now.day);

    if (completions.isEmpty) {
      return const PrayerStreakResult(
        currentStreak: 0,
        longestStreak: 0,
        activeCurrentStreak: 0,
        activeLongestStreak: 0,
      );
    }

    // Parse all dates in sorted order
    final dates = completions.keys
        .map((k) {
          final parts = k.split('-');
          if (parts.length != 3) return null;
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2]);
          if (y == null || m == null || d == null) return null;
          return DateTime(y, m, d);
        })
        .whereType<DateTime>()
        .toList()
      ..sort();

    if (dates.isEmpty) {
      return const PrayerStreakResult(
        currentStreak: 0,
        longestStreak: 0,
        activeCurrentStreak: 0,
        activeLongestStreak: 0,
      );
    }

    // 1. Calculate Full Streaks (All 5 prayers completed)
    int longestFull = 0;
    int currentFullRun = 0;

    // First scan all dates up to safeToday for longest full streak
    DateTime? prevDate;
    for (final d in dates) {
      if (isDayFullyCompleted(completions, d)) {
        if (prevDate != null && d.difference(prevDate).inDays == 1) {
          currentFullRun++;
        } else {
          currentFullRun = 1;
        }
        if (currentFullRun > longestFull) {
          longestFull = currentFullRun;
        }
        prevDate = d;
      } else {
        currentFullRun = 0;
        prevDate = null;
      }
    }

    // Calculate current full streak walking back from today or yesterday
    int currentFull = 0;
    var checkDate = safeToday;
    if (!isDayFullyCompleted(completions, checkDate)) {
      // If today is not completed yet, check if yesterday was completed
      checkDate = safeToday.subtract(const Duration(days: 1));
    }
    while (isDayFullyCompleted(completions, checkDate)) {
      currentFull++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // 2. Calculate Active Streaks (At least 1 prayer completed)
    int longestActive = 0;
    int currentActiveRun = 0;
    prevDate = null;
    for (final d in dates) {
      if (completedCountForDay(completions, d) > 0) {
        if (prevDate != null && d.difference(prevDate).inDays == 1) {
          currentActiveRun++;
        } else {
          currentActiveRun = 1;
        }
        if (currentActiveRun > longestActive) {
          longestActive = currentActiveRun;
        }
        prevDate = d;
      } else {
        currentActiveRun = 0;
        prevDate = null;
      }
    }

    int currentActive = 0;
    checkDate = safeToday;
    if (completedCountForDay(completions, checkDate) == 0) {
      checkDate = safeToday.subtract(const Duration(days: 1));
    }
    while (completedCountForDay(completions, checkDate) > 0) {
      currentActive++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return PrayerStreakResult(
      currentStreak: currentFull,
      longestStreak: longestFull,
      activeCurrentStreak: currentActive,
      activeLongestStreak: longestActive,
    );
  }

  /// Generates a list of daily heatmap cells for a given month and year.
  List<DailyHeatmapCell> generateMonthlyHeatmap(
    Map<String, List<String>> completions,
    int year,
    int month,
  ) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final cells = <DailyHeatmapCell>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final count = completedCountForDay(completions, date);
      cells.add(
        DailyHeatmapCell(
          date: date,
          completedCount: count,
          totalPrayers: 5,
        ),
      );
    }

    return cells;
  }

  /// Calculates individual prayer statistics for a given date range (or default last 30 days).
  List<PrayerStat> calculatePrayerBreakdown(
    Map<String, List<String>> completions, {
    DateTimeRange? range,
    DateTime? referenceToday,
  }) {
    final today = referenceToday ?? DateTime.now();
    final safeToday = DateTime(today.year, today.month, today.day);

    final start =
        range?.start ?? safeToday.subtract(const Duration(days: 29));
    final end = range?.end ?? safeToday;

    final totalDays = end.difference(start).inDays + 1;
    if (totalDays <= 0) {
      return corePrayers
          .map(
            (p) => PrayerStat(
              prayerKey: p,
              completedCount: 0,
              totalDays: 0,
            ),
          )
          .toList();
    }

    final counts = <String, int>{for (final p in corePrayers) p: 0};

    var current = start;
    while (!current.isAfter(end)) {
      final key = dateToKey(current);
      final list = (completions[key] ?? []).map((e) => e.toLowerCase()).toSet();
      for (final p in corePrayers) {
        if (list.contains(p)) {
          counts[p] = (counts[p] ?? 0) + 1;
        }
      }
      current = current.add(const Duration(days: 1));
    }

    return corePrayers
        .map(
          (p) => PrayerStat(
            prayerKey: p,
            completedCount: counts[p] ?? 0,
            totalDays: totalDays,
          ),
        )
        .toList();
  }

  /// Calculates overall completion percentage across a date range.
  double calculateOverallRate(
    Map<String, List<String>> completions, {
    DateTimeRange? range,
    DateTime? referenceToday,
  }) {
    final stats = calculatePrayerBreakdown(
      completions,
      range: range,
      referenceToday: referenceToday,
    );
    if (stats.isEmpty) return 0.0;
    final totalCompleted = stats.fold<int>(0, (sum, s) => sum + s.completedCount);
    final totalPossible = stats.fold<int>(0, (sum, s) => sum + s.totalDays);
    if (totalPossible == 0) return 0.0;
    return (totalCompleted / totalPossible * 100).clamp(0.0, 100.0);
  }

  /// Calculates total count of all logged completed prayers across history.
  int calculateTotalPrayersLogged(Map<String, List<String>> completions) {
    int total = 0;
    for (final list in completions.values) {
      final lowerSet = list.map((e) => e.toLowerCase()).toSet();
      total += corePrayers.where(lowerSet.contains).length;
    }
    return total;
  }

}
