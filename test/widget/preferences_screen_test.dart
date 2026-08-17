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

    await tester.tap(find.text('Reminders on/off'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(Switch).first);
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

    await tester.tap(find.text('Widget text size'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();

    expect(harness.controller.widgetTextSize, WidgetTextSize.large);
    verify(() => harness.widgetBridge.updateWidgetTextSize('large')).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('vibration switch persists the reminder vibration preference',
      (tester) async {
    final harness = TestHarness.create();
    when(() => harness.database.saveReminderVibrationEnabled(any()))
        .thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(tester, harness, const PreferencesScreen());

    await tester.tap(find.text('Reminders on/off'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();

    expect(harness.controller.reminderVibrationEnabled, isFalse);

    await tester.pumpWidget(const SizedBox());
  });
}