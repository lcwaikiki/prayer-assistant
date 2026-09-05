import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/ui/preferences_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('expanding the theme section and picking dark updates preference',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveThemePreference(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.tap(find.text('Theme mode'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(harness.controller.themePreference, AppThemePreference.dark);
    verify(() => harness.database.saveThemePreference('dark')).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('language section lists the system default option',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.text('System default'), findsNWidgets(2));
    expect(find.text('Türkçe'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reminders on/off switch flips the silenced flag',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveRemindersSilenced(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.scrollUntilVisible(
      find.text('Reminders on/off'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reminders on/off'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(harness.controller.remindersSilenced, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('widget text size section changes the widget bridge call',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveWidgetTextSize(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.tap(find.text('Widget Settings'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Slider).first);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider).first, const Offset(100, 0));
    await tester.pumpAndSettle();

    expect(harness.controller.widgetTextSizeValue, greaterThanOrEqualTo(14));
    verify(() => harness.database.saveWidgetTextSize(any())).called(greaterThanOrEqualTo(1));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('widget calendar display selection and secondary calendar toggle update settings',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveWidgetCalendarDisplay(any()))
        .thenAnswer((_) async {});
    when(() => harness.database.saveShowSecondaryCalendarDate(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.scrollUntilVisible(
      find.text('Widget Settings'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Widget Settings'));
    await tester.pumpAndSettle();

    final gregorianFinder = find.byWidgetPredicate(
      (widget) => widget is RadioListTile<WidgetCalendarDisplay> && widget.value == WidgetCalendarDisplay.gregorian,
    );
    await tester.scrollUntilVisible(
      gregorianFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(gregorianFinder);
    await tester.pumpAndSettle();

    expect(harness.controller.widgetCalendarDisplay, WidgetCalendarDisplay.gregorian);
    verify(() => harness.database.saveWidgetCalendarDisplay('gregorian')).called(1);

    final switchFinder = find.byKey(const Key('show_secondary_calendar_date_switch'));
    await tester.scrollUntilVisible(
      switchFinder,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(harness.controller.showSecondaryCalendarDate, isFalse);
    verify(() => harness.database.saveShowSecondaryCalendarDate(false)).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('vibration switch persists the reminder vibration preference',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveReminderVibrationEnabled(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.scrollUntilVisible(
      find.text('Reminders on/off'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Reminders on/off'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(harness.controller.reminderVibrationEnabled, isFalse);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows Backup & Export section and lists export options',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.scrollUntilVisible(
      find.text('Backup & Export'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Backup & Export'));
    await tester.pumpAndSettle();

    expect(find.text('Export Backup Data (JSON)'), findsOneWidget);
    expect(find.text('Restore Data from Backup'), findsOneWidget);
    expect(find.text('Export Islamic Holidays (.ics)'), findsOneWidget);


    await tester.pumpWidget(const SizedBox());
  });
}