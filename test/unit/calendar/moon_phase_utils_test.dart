import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/moon_phase_utils.dart';

void main() {
  group('MoonPhaseUtils', () {
    test('calculates valid moon phase values and illumination percentage', () {
      final date = DateTime(2026, 9, 4);
      final info = getMoonPhase(date);

      expect(info.phaseValue, greaterThanOrEqualTo(0.0));
      expect(info.phaseValue, lessThan(1.0));
      expect(info.illumination, greaterThanOrEqualTo(0.0));
      expect(info.illumination, lessThanOrEqualTo(100.0));
      expect(info.ageInDays, greaterThanOrEqualTo(0.0));
      expect(info.ageInDays, lessThanOrEqualTo(synodicMonthDays));
      expect(info.phaseNameKey, isNotEmpty);
    });

    test('correctly identifies White Days (13, 14, 15 Hijri)', () {
      // Find a date corresponding to Hijri day 14
      DateTime? whiteDayDate;
      for (int i = 0; i < 30; i++) {
        final d = DateTime(2026, 9, 1).add(Duration(days: i));
        final info = getMoonPhase(d);
        if (info.isWhiteDay) {
          whiteDayDate = d;
          expect(info.whiteDayNumber, isIn([13, 14, 15]));
          break;
        }
      }
      expect(whiteDayDate, isNotNull);
    });

    test('phase names map to valid localization keys', () {
      final keys = <String>{};
      for (int i = 0; i < 30; i++) {
        final d = DateTime(2026, 9, 1).add(Duration(days: i));
        final info = getMoonPhase(d);
        keys.add(info.phaseNameKey);
      }

      expect(keys, containsAll([
        'moonPhaseNewMoon',
        'moonPhaseFullMoon',
      ]));
    });
  });
}
