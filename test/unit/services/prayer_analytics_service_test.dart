import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/services/prayer_analytics_service.dart';

void main() {
  const service = PrayerAnalyticsService();

  group('PrayerAnalyticsService - Streaks', () {
    test('returns zero streaks when completions map is empty', () {
      final streaks = service.calculateStreaks({});
      expect(streaks.currentStreak, 0);
      expect(streaks.longestStreak, 0);
      expect(streaks.activeCurrentStreak, 0);
      expect(streaks.activeLongestStreak, 0);
    });

    test('calculates current and longest streaks correctly', () {
      final today = DateTime(2026, 8, 23);
      final completions = <String, List<String>>{
        // 3-day streak past
        '2026-08-10': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-11': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-12': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        // Gap
        '2026-08-14': ['imsak', 'ogle'], // partial
        // 2-day current streak (yesterday and today)
        '2026-08-22': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-23': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
      };

      final result = service.calculateStreaks(completions, today: today);
      expect(result.currentStreak, 2);
      expect(result.longestStreak, 3);
      expect(result.activeCurrentStreak, 2);
      expect(result.activeLongestStreak, 3);
    });

    test('retains current streak from yesterday if today is not completed yet', () {
      final today = DateTime(2026, 8, 23);
      final completions = <String, List<String>>{
        '2026-08-21': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-22': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        // 2026-08-23 has 0 prayers checked yet
      };

      final result = service.calculateStreaks(completions, today: today);
      expect(result.currentStreak, 2);
    });

    test('handles capitalized prayer keys (Imsak, Ogle, Ikindi, Aksam, Yatsi)', () {
      final today = DateTime(2026, 8, 23);
      final completions = <String, List<String>>{
        '2026-08-22': ['Imsak', 'Ogle', 'Ikindi', 'Aksam', 'Yatsi'],
        '2026-08-23': ['Imsak', 'Ogle', 'Ikindi', 'Aksam', 'Yatsi'],
      };

      final result = service.calculateStreaks(completions, today: today);
      expect(result.currentStreak, 2);
      expect(result.longestStreak, 2);
      expect(service.calculateTotalPrayersLogged(completions), 10);
    });
  });


  group('PrayerAnalyticsService - Monthly Heatmap', () {
    test('generates correct number of days for a month', () {
      final completions = <String, List<String>>{
        '2026-08-01': ['imsak', 'ogle'],
        '2026-08-15': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
      };

      final cells = service.generateMonthlyHeatmap(completions, 2026, 8);
      expect(cells.length, 31);
      expect(cells[0].completedCount, 2);
      expect(cells[0].ratio, 0.4);
      expect(cells[14].completedCount, 5);
      expect(cells[14].ratio, 1.0);
      expect(cells[1].completedCount, 0);
      expect(cells[1].ratio, 0.0);
    });
  });

  group('PrayerAnalyticsService - Prayer Breakdown & Totals', () {
    test('calculates per-prayer completion percentages for last 30 days', () {
      final today = DateTime(2026, 8, 23);
      final completions = <String, List<String>>{
        '2026-08-23': ['imsak', 'ogle', 'ikindi', 'aksam', 'yatsi'],
        '2026-08-22': ['imsak', 'ogle', 'aksam'],
      };

      final stats = service.calculatePrayerBreakdown(
        completions,
        referenceToday: today,
      );

      expect(stats.length, 5);
      final imsak = stats.firstWhere((s) => s.prayerKey == 'imsak');
      expect(imsak.completedCount, 2);
      expect(imsak.totalDays, 30);
      expect(imsak.percentage, closeTo(6.66, 0.1));

      final ikindi = stats.firstWhere((s) => s.prayerKey == 'ikindi');
      expect(ikindi.completedCount, 1);

      final overall = service.calculateOverallRate(
        completions,
        referenceToday: today,
      );
      expect(overall, closeTo(5.33, 0.1));

      final totalLogged = service.calculateTotalPrayersLogged(completions);
      expect(totalLogged, 8);
    });
  });
}
