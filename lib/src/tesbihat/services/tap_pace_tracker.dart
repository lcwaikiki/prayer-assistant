class TapPaceTracker {
  DateTime? _lastTapTime;
  final List<int> _intervalsMs = [];

  List<int> get intervalsMs => List.unmodifiable(_intervalsMs);
  int get intervalCount => _intervalsMs.length;

  double? get averageIntervalMs {
    if (_intervalsMs.isEmpty) return null;
    return _intervalsMs.reduce((a, b) => a + b) / _intervalsMs.length;
  }

  void reset() {
    _lastTapTime = null;
    _intervalsMs.clear();
  }

  void recordTap([DateTime? timestamp]) {
    final now = timestamp ?? DateTime.now();
    if (_lastTapTime != null) {
      final rawIntervalMs = now.difference(_lastTapTime!).inMilliseconds;
      if (rawIntervalMs > 0) {
        if (_intervalsMs.isEmpty) {
          // If first interval is an unusually long pause (> 3s), cap it to 2000ms.
          _intervalsMs.add(rawIntervalMs > 3000 ? 2000 : rawIntervalMs);
        } else {
          final currentAvg =
              _intervalsMs.reduce((a, b) => a + b) / _intervalsMs.length;
          // Long waits compared to the calculated average are treated as an exception
          // and calculated as tapped in average time.
          if (rawIntervalMs > currentAvg * 2.5 && rawIntervalMs > 2000) {
            _intervalsMs.add(currentAvg.round());
          } else {
            _intervalsMs.add(rawIntervalMs);
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
}
