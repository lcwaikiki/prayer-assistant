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

    test('calculates pace for fast beads (0.5s - 0.8s)', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);

      // Fast taps at 600ms and 700ms
      tracker.recordTap(t0.add(const Duration(milliseconds: 600)));
      tracker.recordTap(t0.add(const Duration(milliseconds: 1300)));
      expect(tracker.averageIntervalMs, 650);

      // 30 remaining at 650ms avg = 19.5s -> '00:20'
      expect(tracker.formatRemaining(30), '00:20');

      // 5-second pause (outlier for 650ms pace) is excluded
      tracker.recordTap(t0.add(const Duration(milliseconds: 6300)));
      expect(tracker.averageIntervalMs, 650);

      // Next active tap 600ms later
      tracker.recordTap(t0.add(const Duration(milliseconds: 6900)));
      expect(tracker.intervalCount, 3);
      expect(tracker.averageIntervalMs, closeTo(633, 1));
    });

    test('calculates pace for long beads (10s - 20s+)', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);

      // Long bead taps at 15s and 17s
      tracker.recordTap(t0.add(const Duration(seconds: 15)));
      tracker.recordTap(t0.add(const Duration(seconds: 32)));
      expect(tracker.averageIntervalMs, 16000);

      // 10 remaining at 16s = 160s = 2 min 40s -> '02:40'
      expect(tracker.formatRemaining(10), '02:40');

      // 2-minute break is excluded
      tracker.recordTap(t0.add(const Duration(seconds: 152)));
      expect(tracker.averageIntervalMs, 16000);
      expect(tracker.formatRemaining(9), '02:24');

      // Next active tap 16s later is accepted
      tracker.recordTap(t0.add(const Duration(seconds: 168)));
      expect(tracker.intervalCount, 3);
      expect(tracker.averageIntervalMs, 16000);
    });

    test('pauseSession excludes elapsed time when leaving app or bead', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);
      tracker.recordTap(t0.add(const Duration(milliseconds: 800)));
      expect(tracker.averageIntervalMs, 800);

      // User leaves app or navigates away
      tracker.pauseSession();

      // User returns 10 minutes later and taps
      final tReturn = t0.add(const Duration(minutes: 10));
      tracker.recordTap(tReturn);

      // Pace is preserved without adding 10 minutes
      expect(tracker.averageIntervalMs, 800);
      expect(tracker.formatRemaining(20), '00:16');

      // Subsequent tap continues at 800ms
      tracker.recordTap(tReturn.add(const Duration(milliseconds: 800)));
      expect(tracker.intervalCount, 2);
      expect(tracker.averageIntervalMs, 800);
    });

    test('formats long durations in hours', () {
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      tracker.recordTap(t0);
      tracker.recordTap(t0.add(const Duration(seconds: 20)));

      // 200 taps remaining at 20s per tap = 4000s = 1 hour, 6 minutes, 40 seconds
      expect(tracker.formatRemaining(200), '1:06:40');
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
