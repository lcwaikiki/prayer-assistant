import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('PrayerAppController Widget Settings', () {
    test('default widget theme and calendar display match expected defaults', () {
      final harness = TestHarness.create();
      final controller = harness.controller;

      expect(controller.widgetTheme, equals(WidgetTheme.system));
      expect(controller.widgetCalendarDisplay, equals(WidgetCalendarDisplay.hijri));
    });

    test('updates widgetTheme and persists to database and widget bridge', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      await harness.controller.updateWidgetTheme(WidgetTheme.transparent);

      expect(harness.controller.widgetTheme, equals(WidgetTheme.transparent));
      verify(() => harness.database.saveWidgetTheme('transparent')).called(1);
      verify(() => harness.widgetBridge.updateWidgetTheme('transparent')).called(1);
    });

    test('updates widgetCalendarDisplay and persists to database and widget bridge', () async {
      final harness = TestHarness.create();
      await harness.initialize();

      await harness.controller.updateWidgetCalendarDisplay(WidgetCalendarDisplay.gregorian);

      expect(harness.controller.widgetCalendarDisplay, equals(WidgetCalendarDisplay.gregorian));
      verify(() => harness.database.saveWidgetCalendarDisplay('gregorian')).called(1);
      verify(() => harness.widgetBridge.updateWidgetCalendarDisplay('gregorian', true)).called(1);
    });
  });
}
