import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/utils/time_utils.dart';

void main() {
  test('parsePrayerTime parses HH:mm values', () {
    final date = DateTime(2026, 1, 1);
    final parsed = parsePrayerTime(date, '05:37');
    expect(parsed, isNotNull);
    expect(parsed!.hour, 5);
    expect(parsed.minute, 37);
    expect(parsed.year, 2026);
  });

  test('formatRemaining uses hh:mm:ss', () {
    expect(
      formatRemaining(const Duration(hours: 2, minutes: 4, seconds: 9)),
      '02:04:09',
    );
  });

  test('prayerMapForDay creates all prayer labels', () {
    final day = PrayerDay(
      date: DateTime(2026, 1, 1),
      hijriDate: '12 Rajab 1447',
      imsak: '06:00',
      gunes: '07:30',
      ogle: '12:15',
      ikindi: '15:45',
      aksam: '18:20',
      yatsi: '19:45',
    );
    final map = prayerMapForDay(day);
    expect(map['Imsak'], '06:00');
    expect(map['Yatsi'], '19:45');
    expect(map.keys.length, 6);
  });
}
