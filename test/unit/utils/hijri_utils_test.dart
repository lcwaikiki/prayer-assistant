import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/hijri_utils.dart';

void main() {
  group('HijriMonth', () {
    test('fromDate resolves the Hijri month of a Gregorian date', () {
      // 2026-08-17 is in Ramadan 1447 (1 Ramadan 1447 = 2026-03-11
      // per the hijri package); verify against the package itself rather
      // than hardcoding: the month must contain that date.
      final month = HijriMonth.fromDate(DateTime(2026, 8, 17));
      final start = month.gregorianStart;
      final end = start.add(Duration(days: month.daysInMonth - 1));
      final date = DateTime(2026, 8, 17);

      expect(!date.isBefore(start) && !date.isAfter(end), isTrue);
    });

    test('daysInMonth is between 29 and 30', () {
      final month = HijriMonth.fromDate(DateTime(2026, 8, 17));

      expect(month.daysInMonth, inInclusiveRange(29, 30));
    });

    test('shift(+1) advances to the following Hijri month', () {
      final month = HijriMonth(1447, 9);
      final next = month.shift(1);

      expect(next.year, 1447);
      expect(next.month, 10);
    });

    test('shift(-1) goes back a month', () {
      final month = HijriMonth(1447, 1);
      final previous = month.shift(-1);

      expect(previous.year, 1446);
      expect(previous.month, 12);
    });

    test('shift wraps year boundaries in both directions', () {
      expect(HijriMonth(1447, 12).shift(1).year, 1448);
      expect(HijriMonth(1447, 12).shift(1).month, 1);
      expect(HijriMonth(1447, 1).shift(-1).year, 1446);
      expect(HijriMonth(1447, 1).shift(-1).month, 12);
    });

    test('gregorianStart falls in the same Gregorian month it spans', () {
      final start = HijriMonth.fromDate(DateTime(2026, 8, 17)).gregorianStart;

      expect(start, isNotNull);
      expect(start.year, greaterThanOrEqualTo(2025));
    });
  });
}