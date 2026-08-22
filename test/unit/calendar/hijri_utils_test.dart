import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/hijri_utils.dart';

void main() {
  test('arabic locale returns native hijri month names', () {
    // 2026-08-17 is 4 Rabi' Al-Awwal 1448.
    final month = HijriMonth.fromDate(DateTime(2026, 8, 17));
    expect(month.month, 3);
    expect(month.longMonthName('ar'), 'ربيع الاول');
  });

  test('non-arabic locales return transliterated names', () {
    final month = HijriMonth.fromDate(DateTime(2026, 8, 17));
    expect(month.longMonthName('en'), "Rabi' Al-Awwal");
    expect(month.longMonthName('tr'), "REBİÜLEVVEL");
  });


  test('switching languages back and forth stays consistent', () {
    final month = HijriMonth.fromDate(DateTime(2026, 8, 17));
    expect(month.longMonthName('ar'), 'ربيع الاول');
    expect(month.longMonthName('en'), "Rabi' Al-Awwal");
    expect(month.longMonthName('ar'), 'ربيع الاول');
  });
}
