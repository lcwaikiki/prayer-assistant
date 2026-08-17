import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/ui/reminder_settings_screen.dart';

import '../helpers/test_harness.dart';

void main() {
  testWidgets('shows the prayer name in the title', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const ReminderSettingsScreen(prayerName: 'Imsak'),
    );

    expect(find.text('Fajr Reminder'), findsOneWidget);
    expect(find.text('On time'), findsOneWidget);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('Vibrate'), findsOneWidget);
    expect(find.text('Sound'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('After'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('toggling a chip updates the reminder setting', (tester) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.saveReminderSettings(any()),
    ).thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const ReminderSettingsScreen(prayerName: 'Imsak'),
    );

    await tester.tap(find.text('Before'));
    await tester.pump();

    expect(harness.controller.reminderFor('Imsak').notifyBefore, isTrue);
    verify(() => harness.database.saveReminderSettings(any())).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('minute chips appear once the before toggle is on',
      (tester) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.saveReminderSettings(any()),
    ).thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const ReminderSettingsScreen(prayerName: 'Imsak'),
    );

    // Chips are enabled only when the corresponding toggle is on.
    await tester.tap(find.text('Before'));
    await tester.pump();

    expect(find.text('10 min'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('selecting a minute chip persists the choice', (tester) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.saveReminderSettings(any()),
    ).thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const ReminderSettingsScreen(prayerName: 'Imsak'),
    );

    await tester.tap(find.text('Before'));
    await tester.pump();
    await tester.tap(find.text('15 min').first);
    await tester.pump();

    expect(harness.controller.reminderFor('Imsak').minutesBefore, 15);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('custom minutes field updates the setting as you type',
      (tester) async {
    final harness = TestHarness.create();
    when(
      () => harness.database.saveReminderSettings(any()),
    ).thenAnswer((_) async {});
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      const ReminderSettingsScreen(prayerName: 'Imsak'),
    );

    await tester.tap(find.text('Before'));
    await tester.pump();

    await tester.enterText(find.byType(TextField).first, '23');
    await tester.pump();

    expect(harness.controller.reminderFor('Imsak').customMinutesBefore, 23);

    await tester.pumpWidget(const SizedBox());
  });
}