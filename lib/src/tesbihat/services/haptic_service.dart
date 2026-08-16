import 'dart:math' as math;

import 'package:vibration/vibration.dart';

class HapticService {
  bool? _hasAmplitudeControl;

  /// Maps a 1..100 intensity to a 0..1 factor with a square-root curve, so
  /// slider moves near the low end change the amplitude by a perceptible
  /// amount instead of everything feeling identical until the top of the
  /// range.
  double _curve(int intensity) {
    final safe = intensity.clamp(1, 100);
    return math.sqrt((safe - 1) / 99.0);
  }

  int standardDurationMs({required int intensity}) {
    final safe = intensity.clamp(1, 99);
    return 50 + (((safe - 1) * 950) ~/ 98);
  }

  int checkpointDurationMs({required int intensity}) {
    final base = standardDurationMs(intensity: intensity);
    return (base * 3).clamp(200, 1500);
  }

  int _amplitudeFor(int intensity) {
    // 1..255; the 30 floor keeps even a low setting a present-but-weak buzz
    // rather than a below-perception threshold quiver.
    return 30 + (225 * _curve(intensity)).round();
  }

  Future<void> standard({required int intensity}) async {
    await _vibrate(
      duration: standardDurationMs(intensity: intensity),
      intensity: intensity,
    );
  }

  Future<void> checkpoint({required int intensity}) async {
    await _vibrate(
      duration: checkpointDurationMs(intensity: intensity),
      intensity: intensity,
    );
  }

  Future<void> _vibrate({
    required int duration,
    required int intensity,
  }) async {
    if (!await Vibration.hasVibrator()) {
      return;
    }
    _hasAmplitudeControl ??= await Vibration.hasAmplitudeControl();
    if (_hasAmplitudeControl == true) {
      await Vibration.vibrate(
        duration: duration,
        amplitude: _amplitudeFor(intensity),
      );
    } else {
      await Vibration.vibrate(duration: duration);
    }
  }
}
