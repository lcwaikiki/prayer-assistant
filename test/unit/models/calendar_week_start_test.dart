import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/models/calendar_week_start.dart';

void main() {
  group('CalendarWeekStart', () {
    test('fromName returns correct enum value', () {
      expect(CalendarWeekStart.fromName('sunday'), CalendarWeekStart.sunday);
      expect(CalendarWeekStart.fromName('monday'), CalendarWeekStart.monday);
      expect(CalendarWeekStart.fromName('invalid'), CalendarWeekStart.monday);
      expect(CalendarWeekStart.fromName(null), CalendarWeekStart.monday);
    });

    test('leadingBlanks calculates correct offset for Sunday start', () {
      // 2026-09-01 is a Tuesday (weekday 2)
      final date = DateTime(2026, 9, 1);
      // Tuesday under Sunday start: Sun (0), Mon (1) -> 2 leading blanks
      expect(CalendarWeekStart.sunday.leadingBlanks(date), 2);
    });

    test('leadingBlanks calculates correct offset for Monday start', () {
      // 2026-09-01 is a Tuesday (weekday 2)
      final date = DateTime(2026, 9, 1);
      // Tuesday under Monday start: Mon (0) -> 1 leading blank
      expect(CalendarWeekStart.monday.leadingBlanks(date), 1);
    });

    test('weekdayOrder returns correct weekday sequence', () {
      expect(
        CalendarWeekStart.sunday.weekdayOrder,
        const [7, 1, 2, 3, 4, 5, 6],
      );
      expect(
        CalendarWeekStart.monday.weekdayOrder,
        const [1, 2, 3, 4, 5, 6, 7],
      );
    });
  });
}
