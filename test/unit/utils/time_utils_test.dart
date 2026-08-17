import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/utils/time_utils.dart';

void main() {
  group('prayerOrder', () {
    test('lists all six prayers in display order', () {
      expect(prayerOrder, [
        'Imsak',
        'Gunes',
        'Ogle',
        'Ikindi',
        'Aksam',
        'Yatsi',
      ]);
    });
  });

  group('prayerMapForDay', () {
    test('maps every prayer key to its time', () {
      final map = prayerMapForDay(_day());

      expect(map['Imsak'], '05:10');
      expect(map['Gunes'], '06:42');
      expect(map['Ogle'], '12:35');
      expect(map['Ikindi'], '16:10');
      expect(map['Aksam'], '18:20');
      expect(map['Yatsi'], '19:45');
    });
  });

  group('parsePrayerTime', () {
    test('parses a valid HH:mm string onto the base date', () {
      final time = parsePrayerTime(DateTime(2026, 8, 17), '05:10');

      expect(time, DateTime(2026, 8, 17, 5, 10));
    });

    test('returns null for malformed input', () {
      expect(parsePrayerTime(DateTime(2026), ''), isNull);
      expect(parsePrayerTime(DateTime(2026), '05'), isNull);
      expect(parsePrayerTime(DateTime(2026), 'ab:cd'), isNull);
      expect(parsePrayerTime(DateTime(2026), '05:10:30'), isNull);
    });
  });

  group('formatRemaining', () {
    test('formats hours, minutes and seconds with padding', () {
      expect(formatRemaining(const Duration(hours: 2, minutes: 3, seconds: 4)),
          '02:03:04');
    });

    test('clamps negative durations to zero', () {
      expect(formatRemaining(const Duration(seconds: -5)), '00:00:00');
    });

    test('formats zero', () {
      expect(formatRemaining(Duration.zero), '00:00:00');
    });

    test('rolls over seconds into minutes', () {
      expect(formatRemaining(const Duration(seconds: 61)), '00:01:01');
    });
  });
}

PrayerDay _day() => PrayerDay(
      date: DateTime(2026, 8, 17),
      hijriDate: '',
      imsak: '05:10',
      gunes: '06:42',
      ogle: '12:35',
      ikindi: '16:10',
      aksam: '18:20',
      yatsi: '19:45',
    );