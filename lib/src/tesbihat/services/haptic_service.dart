import 'package:vibration/vibration.dart';

class HapticService {
  int standardDurationMs({required int intensity}) {
    final safeIntensity = intensity.clamp(1, 100);
    return 5 + (((safeIntensity - 1) * 45) ~/ 99);
  }

  int checkpointDurationMs({required int intensity}) {
    final base = standardDurationMs(intensity: intensity);
    return (base * 3).clamp(120, 700);
  }

  Future<void> standard({required int intensity}) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(
      duration: standardDurationMs(intensity: intensity),
    );
  }

  Future<void> checkpoint({required int intensity}) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (!hasVibrator) return;

    await Vibration.vibrate(
      duration: checkpointDurationMs(intensity: intensity),
    );
  }
}
