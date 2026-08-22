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
        fajrCompleted: 40,
        dhuhrTarget: 100,
        dhuhrCompleted: 100,
      );

      expect(tracker.targetFor('fajr'), 100);
      expect(tracker.completedFor('fajr'), 40);
      expect(tracker.remainingFor('fajr'), 60);

      expect(tracker.targetFor('dhuhr'), 100);
      expect(tracker.completedFor('dhuhr'), 100);
      expect(tracker.remainingFor('dhuhr'), 0);
    });

    test('estimated completion date calculation', () {
      final now = DateTime(2026, 8, 22);
      // 60 remaining prayers at 6/day = 10 days
      const tracker = KazaTracker(
        fajrTarget: 60,
        fajrCompleted: 0,
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
        fajrCompleted: 50,
        dhuhrCompleted: 50,
        dailyPace: 12,
      );

      final jsonStr = original.toJson();
      final restored = KazaTracker.fromJson(jsonStr);

      expect(restored.fajrTarget, 365);
      expect(restored.fajrCompleted, 50);
      expect(restored.dhuhrCompleted, 50);
      expect(restored.dailyPace, 12);
      expect(restored.totalTarget, 2190);
    });
  });
}
