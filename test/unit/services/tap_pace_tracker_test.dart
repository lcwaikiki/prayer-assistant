import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/services/tap_pace_tracker.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';

import '../../helpers/mocks.dart';

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

    test('restores calculation data and continues long running beads after app restart', () {
      // Re-instantiate tracker with persisted intervals
      final restoredTracker = TapPaceTracker(
        initialIntervals: [15000, 16000, 14000],
      );

      // Immediately calculates time left from persisted pace without needing new taps
      expect(restoredTracker.averageIntervalMs, 15000);
      expect(restoredTracker.formatRemaining(100), '25:00');

      // First tap after restart resumes smoothly without counting restart delay
      final tNow = DateTime(2026, 1, 5, 10, 0, 0);
      restoredTracker.recordTap(tNow);
      expect(restoredTracker.averageIntervalMs, 15000);
      expect(restoredTracker.formatRemaining(99), '24:45');

      // Next tap 15 seconds later refines pace
      restoredTracker.recordTap(tNow.add(const Duration(seconds: 15)));
      expect(restoredTracker.intervalCount, 4);
      expect(restoredTracker.averageIntervalMs, 15000);
    });

    test('serializes to and from map', () {
      final original = TapPaceTracker(initialIntervals: [500, 600, 550]);
      final map = original.toMap();
      final restored = TapPaceTracker.fromMap(map);

      expect(restored.intervalsMs, [500, 600, 550]);
      expect(restored.averageIntervalMs, 550);
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

  group('BeadPaceNotifier with ItemRepository', () {
    test('persists and restores pace directly via Item.paceIntervals across container / app restarts', () {
      const initialItem = Item(
        id: 'item_1',
        title: 'Subhanallah',
        count: 33,
        check: 0,
        setCount: 0,
        vibrationIntensity: 50,
      );
      final repository = ItemRepository.memory([initialItem]);
      final reminderService = MockItemReminderService();
      final historyRepository = ItemHistoryRepository.memory();

      final container1 = ProviderContainer(
        overrides: [
          itemRepositoryProvider.overrideWithValue(repository),
          itemHistoryRepositoryProvider.overrideWithValue(historyRepository),
          itemReminderServiceProvider.overrideWithValue(reminderService),
        ],
      );

      final notifier1 = container1.read(beadPaceTrackerProvider.notifier);
      final t0 = DateTime(2026, 1, 1, 12, 0, 0);
      notifier1.recordTap('item_1', t0);
      notifier1.recordTap('item_1', t0.add(const Duration(seconds: 15)));
      notifier1.recordTap('item_1', t0.add(const Duration(seconds: 30)));

      final tracker1 = container1.read(beadPaceTrackerProvider)['item_1'];
      expect(tracker1?.averageIntervalMs, 15000);
      expect(tracker1?.formatRemaining(10), '02:30');

      // Verify it was persisted directly into the Item in repository
      final savedItems = repository.loadItems();
      expect(savedItems.first.paceIntervals, [15000, 15000]);

      // Simulate app restart: fresh container created with same persisted repository
      final container2 = ProviderContainer(
        overrides: [
          itemRepositoryProvider.overrideWithValue(repository),
          itemHistoryRepositoryProvider.overrideWithValue(historyRepository),
          itemReminderServiceProvider.overrideWithValue(reminderService),
        ],
      );

      final restoredTrackers = container2.read(beadPaceTrackerProvider);
      final restoredItem1 = restoredTrackers['item_1'];
      expect(restoredItem1, isNotNull);
      expect(restoredItem1!.averageIntervalMs, 15000);
      expect(restoredItem1.formatRemaining(10), '02:30');

      container1.dispose();
      container2.dispose();
    });
  });
}

