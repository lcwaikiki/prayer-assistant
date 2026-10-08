import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';

void main() {
  group('KazaTracker Model Tests', () {
    test('default constructor creates zero targets and 6 daily pace', () {
      const tracker = KazaTracker();
      expect(tracker.fajrTarget, 0);
      expect(tracker.totalTarget, 0);
      expect(tracker.totalCompleted, 0);
      expect(tracker.totalRemaining, 0);
      expect(tracker.completionRatio, 0.0);
      expect(tracker.dailyPace, 6);
      expect(tracker.estimatedCompletionDate(), null);
    });

    test('target, completed, remaining calculation per prayer', () {
      const tracker = KazaTracker(
        fajrTarget: 100,
        dhuhrTarget: 100,
        baseline: {'fajr': 40, 'dhuhr': 100},
      );

      expect(tracker.targetFor('fajr'), 100);
      expect(tracker.completedFor('fajr'), 40);
      expect(tracker.remainingFor('fajr'), 60);

      expect(tracker.targetFor('dhuhr'), 100);
      expect(tracker.completedFor('dhuhr'), 100);
      expect(tracker.remainingFor('dhuhr'), 0);
    });

    test('completed is baseline plus all daily logs', () {
      const tracker = KazaTracker(
        baseline: {'fajr': 10},
        dailyLogs: {
          '2026-10-07': {'fajr': 2, 'isha': 1},
          '2026-10-08': {'fajr': 3},
        },
      );

      expect(tracker.loggedFor('fajr'), 5);
      expect(tracker.completedFor('fajr'), 15);
      expect(tracker.completedFor('imsak'), 15);
      expect(tracker.completedFor('isha'), 1);
      expect(tracker.totalCompleted, 16);
    });

    test('legacy completed totals become baseline minus logged', () {
      final tracker = KazaTracker.fromMap(
        {'fajrCompleted': 26, 'ishaCompleted': 1, 'fajrTarget': 100},
        {
          '2026-10-08': {'fajr': 12, 'isha': 3},
        },
      );

      expect(tracker.baseline['fajr'], 14);
      expect(tracker.baseline['isha'], 0);
      expect(tracker.completedFor('fajr'), 26);
      expect(tracker.completedFor('isha'), 3);
    });

    test('estimated completion date calculation', () {
      final now = DateTime(2026, 8, 22);
      // 60 remaining prayers at 6/day = 10 days
      const tracker = KazaTracker(
        fajrTarget: 60,
        dailyPace: 6,
      );

      final est = tracker.estimatedCompletionDate(now);
      expect(est, DateTime(2026, 9, 1));
    });

    test('serialization roundtrip (toMap / fromMap / toJson / fromJson)', () {
      const original = KazaTracker(
        fajrTarget: 365,
        dhuhrTarget: 365,
        asrTarget: 365,
        maghribTarget: 365,
        ishaTarget: 365,
        witrTarget: 365,
        baseline: {'fajr': 50, 'dhuhr': 50},
        dailyPace: 12,
      );

      final jsonStr = original.toJson();
      final restored = KazaTracker.fromJson(jsonStr);

      expect(restored.fajrTarget, 365);
      expect(restored.completedFor('fajr'), 50);
      expect(restored.completedFor('dhuhr'), 50);
      expect(restored.dailyPace, 12);
      expect(restored.totalTarget, 2190);
    });
  });
}
