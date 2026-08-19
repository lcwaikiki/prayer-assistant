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

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 8 && tester.any(finder) == false; i++) {
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
  }
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

    await _scrollTo(tester, find.text('Gregorian'));
    expect(find.text('Monthly basis'), findsOneWidget);
    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);

    for (var i = 0; i < 8 && tester.any(find.text('Yearly')) == false; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, 150));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Yearly'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Gregorian'));

    expect(find.text('Yearly basis'), findsOneWidget);
    expect(find.text('Gregorian'), findsOneWidget);
    expect(find.text('Hijri'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('repeat count chip is hidden for the once recurrence',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    expect(find.byKey(const Key('repeat_count_chip')), findsNothing);
    expect(find.byKey(const Key('repeat_count_field')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('repeat count chip appears for repeating recurrences and '
      'reveals the value field', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('repeat_count_chip')));

    expect(find.byKey(const Key('repeat_count_chip')), findsOneWidget);
    expect(find.byKey(const Key('repeat_count_field')), findsNothing);

    await tester.tap(find.byKey(const Key('repeat_count_chip')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('repeat_count_field')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saving a daily reminder with a repeat count stores it',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byType(TextField).first, 'Test Reminder');
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('repeat_count_chip')));
    await tester.tap(find.byKey(const Key('repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('repeat_count_field')),
      '5',
    );
    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.recurrence, ReminderRecurrence.daily);
    expect(reminders.first.repeatCount, 5);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a repeat count below 2 shows an error and does not save',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byType(TextField).first, 'Test Reminder');
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('repeat_count_chip')));
    await tester.tap(find.byKey(const Key('repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('repeat_count_field')),
      '1',
    );
    await _scrollToSave(tester);

    await _scrollTo(tester, find.byKey(const Key('repeat_count_field')));
    expect(find.text('Enter a number from 2 to 100'), findsOneWidget);
    expect(harness.controller.calendarReminders, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('turning the repeat count chip off again stores no count',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byType(TextField).first, 'Test Reminder');
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.byKey(const Key('repeat_count_chip')));
    await tester.tap(find.byKey(const Key('repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('repeat_count_chip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('repeat_count_field')), findsNothing);

    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.recurrence, ReminderRecurrence.daily);
    expect(reminders.first.repeatCount, isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('editing a daily reminder prefills its repeat count',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    harness.controller.addCalendarReminder(
      CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 7,
      ),
    );

    await _pumpForm(
      tester,
      harness,
      reminder: CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 7,
      ),
    );

    await _scrollTo(tester, find.byKey(const Key('repeat_count_chip')));
    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('repeat_count_chip')),
    );
    expect(chip.selected, isTrue);
    final field = tester.widget<TextField>(
      find.byKey(const Key('repeat_count_field')),
    );
    expect(field.controller!.text, '7');

    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.repeatCount, 7);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('switching back to once drops the saved repeat count',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();
    harness.controller.addCalendarReminder(
      CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 7,
      ),
    );

    await _pumpForm(
      tester,
      harness,
      reminder: CalendarReminder(
        id: 'r1',
        title: 'Old Title',
        anchorAt: DateTime(2026, 8, 17, 9, 0),
        recurrence: ReminderRecurrence.daily,
        repeatCount: 7,
      ),
    );

    await _scrollTo(tester, find.text('Once'));
    await tester.tap(find.text('Once'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('repeat_count_chip')), findsNothing);

    await _scrollToSave(tester);

    final reminders = harness.controller.calendarReminders;
    expect(reminders, hasLength(1));
    expect(reminders.first.recurrence, ReminderRecurrence.once);
    expect(reminders.first.repeatCount, isNull);

    await tester.pumpWidget(const SizedBox());
  });
}