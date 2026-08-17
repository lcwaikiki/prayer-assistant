import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_reminder_form_screen.dart';

import '../helpers/test_harness.dart';

Future<void> _pumpForm(
  WidgetTester tester,
  TestHarness harness, {
  CalendarReminder? reminder,
}) async {
  await pumpWithHarness(
    tester,
    harness,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    CalendarReminderFormScreen(reminder: reminder),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _scrollToSave(WidgetTester tester) async {
  for (var i = 0; i < 6 && tester.any(find.text('Save')) == false; i++) {
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('saving without a title shows an error', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _scrollToSave(tester);

    expect(find.text('Enter a title'), findsOneWidget);
    expect(harness.controller.calendarReminders, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saving a titled reminder adds it to the controller',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byType(TextField).first, 'Test Reminder');
    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.title, 'Test Reminder');
    expect(reminders.first.anchor, CalendarReminderAnchor.clockTime);
    expect(reminders.first.recurrence, ReminderRecurrence.once);
    expect(reminders.first.enabled, isTrue);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('editing an existing reminder prefills and updates it',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    harness.controller.addCalendarReminder(
      CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
      ),
    );

    await _pumpForm(
      tester,
      harness,
      reminder: CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
      ),
    );

    expect(find.text('Edit reminder'), findsOneWidget);
    expect(find.text('Old Title'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Updated');
    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.id, 'r1');
    expect(reminders.first.title, 'Updated');

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the prayer time anchor reveals prayer and offset fields',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.tap(find.text('Prayer time'));
    await tester.pumpAndSettle();

    expect(find.text('Select prayer'), findsOneWidget);
    expect(find.text('On time'), findsOneWidget);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('selecting monthly and yearly recurrence reveals basis chips',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.tap(find.text('Monthly'));
    await tester.pumpAndSettle();

    expect(find.text('Monthly basis'), findsOneWidget);
    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);

    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();

    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}