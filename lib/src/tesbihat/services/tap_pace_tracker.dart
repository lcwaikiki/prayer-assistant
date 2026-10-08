import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/items_notifier.dart';

final beadPaceTrackerProvider =
    NotifierProvider<BeadPaceNotifier, Map<String, TapPaceTracker>>(
  BeadPaceNotifier.new,
);

class BeadPaceNotifier extends Notifier<Map<String, TapPaceTracker>> {
  @override
  Map<String, TapPaceTracker> build() {
    final items = ref.watch(itemsNotifierProvider);
    final previous = stateOrNull ?? const {};
    final result = <String, TapPaceTracker>{};
    for (final item in items) {
      final existing = previous[item.id];
      if (existing != null) {
        if (item.paceIntervals.isEmpty && existing.intervalCount > 0) {
          existing.reset();
        }
        result[item.id] = existing;
      } else {
        result[item.id] = TapPaceTracker(initialIntervals: item.paceIntervals);
      }
    }
    return result;
  }

  TapPaceTracker trackerFor(String itemId) {
    return state[itemId] ??= TapPaceTracker();
  }

  void recordTap(String itemId, [DateTime? timestamp]) {
    final tracker = state[itemId] ?? TapPaceTracker();
    tracker.recordTap(timestamp);
    state = {...state, itemId: tracker};
    ref.read(itemsNotifierProvider.notifier).updatePaceIntervals(
      itemId,
      tracker.intervalsMs,
    );
  }

  void reset(String itemId) {
    final tracker = state[itemId];
    if (tracker != null) {
      tracker.reset();
      state = {...state, itemId: tracker};
    }
    ref.read(itemsNotifierProvider.notifier).updatePaceIntervals(
      itemId,
      const [],
    );
  }

  void pauseSession(String itemId) {
    final tracker = state[itemId];
    if (tracker != null) {
      tracker.pauseSession();
      state = {...state, itemId: tracker};
    }
  }
}

class TapPaceTracker {
  TapPaceTracker({List<int>? initialIntervals}) {
    if (initialIntervals != null && initialIntervals.isNotEmpty) {
      _intervalsMs.addAll(initialIntervals);
    }
  }

  DateTime? _lastTapTime;
  final List<int> _intervalsMs = [];
  static const int _maxHistory = 30;
  static const int _maxInitialIntervalMs = 300000; // 5 minutes

  List<int> get intervalsMs => List.unmodifiable(_intervalsMs);
  int get intervalCount => _intervalsMs.length;

  double? get averageIntervalMs {
    if (_intervalsMs.isEmpty) return null;
    return _intervalsMs.reduce((a, b) => a + b) / _intervalsMs.length;
  }

  Map<String, dynamic> toMap() => {
    'intervalsMs': _intervalsMs,
  };

  factory TapPaceTracker.fromMap(Map<String, dynamic> map) {
    final list = (map['intervalsMs'] as List<dynamic>?)
        ?.map((e) => (e as num).toInt())
        .toList();
    return TapPaceTracker(initialIntervals: list);
  }

  void reset() {
    _lastTapTime = null;
    _intervalsMs.clear();
  }

  /// Pauses the active interval timing so time spent away from the app or bead
  /// is completely excluded from the pace calculation.
  void pauseSession() {
    _lastTapTime = null;
  }

  void recordTap([DateTime? timestamp]) {
    final now = timestamp ?? DateTime.now();
    if (_lastTapTime != null) {
      final rawIntervalMs = now.difference(_lastTapTime!).inMilliseconds;
      if (rawIntervalMs > 0) {
        if (_intervalsMs.isEmpty) {
          // Supports both fast beads (0.5s-0.8s) and long beads (10s-20s+).
          // Only discard if the first gap was an abandoned session (> 5 min).
          if (rawIntervalMs <= _maxInitialIntervalMs) {
            _intervalsMs.add(rawIntervalMs);
          }
        } else {
          final currentAvg =
              _intervalsMs.reduce((a, b) => a + b) / _intervalsMs.length;
          // Any interval exceeding 2.5x of average pace (with a minimum 5s threshold)
          // is considered a pause/interruption and excluded from pace calculation.
          final thresholdMs = (currentAvg * 2.5).clamp(5000.0, double.infinity);
          final isLongWait = rawIntervalMs >= thresholdMs;
          if (!isLongWait) {
            _intervalsMs.add(rawIntervalMs);
            if (_intervalsMs.length > _maxHistory) {
              _intervalsMs.removeAt(0);
            }
          }
        }
      }
    }
    _lastTapTime = now;
  }

  String formatRemaining(int remainingCount) {
    if (_intervalsMs.isEmpty) {
      return '--:--';
    }
    if (remainingCount <= 0) {
      return '00:00';
    }
    final avg = averageIntervalMs ?? 0;
    if (avg <= 0) {
      return '--:--';
    }
    final remainingMs = (remainingCount * avg).round();
    final totalSeconds = (remainingMs / 1000).round();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String formatPace() {
    if (_intervalsMs.isEmpty) {
      return '--:--';
    }
    final avg = averageIntervalMs ?? 0;
    if (avg <= 0) {
      return '--:--';
    }
    if (avg < 60000) {
      return '${(avg / 1000).toStringAsFixed(1)}s';
    }
    return formatRemaining(1);
  }
}
