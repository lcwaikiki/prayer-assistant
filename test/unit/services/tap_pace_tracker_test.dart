import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/services/tap_pace_tracker.dart';

void main() {
  group('TapPaceTracker', () {
    late TapPaceTracker tracker;

    setUp(() {
      tracker = TapPaceTracker();
    });

    test('returns --:-- initially and after single tap', () {
      expect(tracker.formatRemaining(33), '--:--');
      expect(tracker.averageIntervalMs, isNull);

      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);

      expect(tracker.formatRemaining(33), '--:--');
      expect(tracker.averageIntervalMs, isNull);
    });

    test('calculates pace and formats remaining time for normal taps', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);

      // Tap 1: 1000ms later
      tracker.recordTap(t0.add(const Duration(milliseconds: 1000)));
      expect(tracker.averageIntervalMs, 1000);
      // Remaining 30 items at 1000ms = 30 seconds -> '00:30'
      expect(tracker.formatRemaining(30), '00:30');

      // Tap 2: 1000ms later
      tracker.recordTap(t0.add(const Duration(milliseconds: 2000)));
      expect(tracker.averageIntervalMs, 1000);
      // Remaining 60 items at 1000ms = 60 seconds -> '01:00'
      expect(tracker.formatRemaining(60), '01:00');
    });

    test('treats long waits as an exception and uses current average time', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);

      // Normal taps at 500ms intervals
      tracker.recordTap(t0.add(const Duration(milliseconds: 500)));
      tracker.recordTap(t0.add(const Duration(milliseconds: 1000)));
      tracker.recordTap(t0.add(const Duration(milliseconds: 1500)));
      expect(tracker.averageIntervalMs, 500);

      // Long wait of 30 seconds (break / interruption)
      tracker.recordTap(t0.add(const Duration(milliseconds: 31500)));

      // The 30s interval should be capped to the current average (500ms)
      expect(tracker.averageIntervalMs, 500);
      expect(tracker.intervalsMs.last, 500);

      // Remaining 20 taps at 500ms = 10 seconds -> '00:10'
      expect(tracker.formatRemaining(20), '00:10');
    });

    test('formats long durations in hours', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);
      tracker.recordTap(t0.add(const Duration(milliseconds: 2000)));

      // 2000 taps remaining at 2s per tap = 4000s = 1 hour, 6 minutes, 40 seconds
      expect(tracker.formatRemaining(2000), '1:06:40');
    });

    test('returns 00:00 when remaining is zero or negative', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);
      tracker.recordTap(t0.add(const Duration(milliseconds: 1000)));

      expect(tracker.formatRemaining(0), '00:00');
      expect(tracker.formatRemaining(-5), '00:00');
    });

    test('reset clears intervals and resets state to --:--', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);
      tracker.recordTap(t0.add(const Duration(milliseconds: 1000)));
      expect(tracker.intervalCount, 1);

      tracker.reset();
      expect(tracker.intervalCount, 0);
      expect(tracker.formatRemaining(33), '--:--');
    });
  });
}
