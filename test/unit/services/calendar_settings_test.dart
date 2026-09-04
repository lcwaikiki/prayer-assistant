import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('PrayerAppController Calendar Settings', () {
    test('default values match expected initial defaults', () {
      final harness = TestHarness.create();
      final controller = harness.controller;

      expect(controller.hijriDateOffset, equals(0));
      expect(controller.showIslamicHolidays, isTrue);
      expect(controller.showFastingBadges, isTrue);
      expect(controller.defaultCalendarDisplay, equals(CalendarPrimaryDisplay.hijri));
      expect(controller.showCalendarReminderDots, isTrue);
    });

    test('updates hijriDateOffset and persists to database', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      harness.controller.updateHijriDateOffset(1);

      expect(harness.controller.hijriDateOffset, equals(1));
      verify(() => harness.database.saveHijriDateOffset(1)).called(1);
    });

    test('updates showIslamicHolidays and persists to database', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      harness.controller.updateShowIslamicHolidays(false);

      expect(harness.controller.showIslamicHolidays, isFalse);
      verify(() => harness.database.saveShowIslamicHolidays(false)).called(1);
    });

    test('updates showFastingBadges and persists to database', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      harness.controller.updateShowFastingBadges(false);

      expect(harness.controller.showFastingBadges, isFalse);
      verify(() => harness.database.saveShowFastingBadges(false)).called(1);
    });

    test('updates defaultCalendarDisplay and persists to database', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      harness.controller.updateDefaultCalendarDisplay(CalendarPrimaryDisplay.gregorian);

      expect(harness.controller.defaultCalendarDisplay, equals(CalendarPrimaryDisplay.gregorian));
      verify(() => harness.database.saveDefaultCalendarDisplay(CalendarPrimaryDisplay.gregorian)).called(1);
    });

    test('updates showCalendarReminderDots and persists to database', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      harness.controller.updateShowCalendarReminderDots(false);

      expect(harness.controller.showCalendarReminderDots, isFalse);
      verify(() => harness.database.saveShowCalendarReminderDots(false)).called(1);
    });
  });
}
