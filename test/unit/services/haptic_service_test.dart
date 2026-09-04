import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';

void main() {
  group('HapticService', () {
    final service = HapticService();

    test('standardDurationMs maps step 1 to 10ms and step 8 to 200ms', () {
      expect(service.standardDurationMs(intensity: 1), 10);
      expect(service.standardDurationMs(intensity: 8), 200);
      expect(service.standardDurationMs(intensity: 100), 200);
    });

    test('standardDurationMs scales linearly across 8 steps', () {
      // Midpoint step 4
      final duration4 = service.standardDurationMs(intensity: 4);
      expect(duration4, greaterThan(10));
      expect(duration4, lessThan(200));
      // Step 4: 10 + (3 * 190 ~/ 7) = 10 + 81 = 91 ms
      expect(duration4, 91);
    });

    test('checkpointDurationMs scales standardDurationMs', () {
      expect(service.checkpointDurationMs(intensity: 1), 30); // 10 * 3 = 30
      expect(service.checkpointDurationMs(intensity: 8), 600); // 200 * 3 = 600
    });
  });
}
