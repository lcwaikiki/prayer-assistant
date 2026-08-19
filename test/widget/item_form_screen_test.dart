import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/item_form_screen.dart';

import '../helpers/test_harness.dart';

Item _item() {
  return const Item(
    id: 'a',
    title: 'Tasbih',
    count: 33,
    check: 11,
    setCount: 11,
    vibrationIntensity: 50,
  );
}

Future<void> _pumpForm(
  WidgetTester tester,
  TestHarness harness, {
  Item? itemToEdit,
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
                builder: (_) => ItemFormScreen(itemToEdit: itemToEdit),
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

Future<void> _tapSave(WidgetTester tester) async {
  for (var i = 0; i < 8 && tester.any(find.text('Save')) == false; i++) {
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
  }
  // _scrollTo stops once the button is built in the cache extent, which can
  // still be below the fold; one more drag guarantees it is tappable.
  await tester.drag(find.byType(ListView), const Offset(0, -150));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FilledButton, 'Save'));
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 10 && tester.any(finder) == false; i++) {
    await tester.drag(find.byType(ListView), const Offset(0, -150));
    await tester.pumpAndSettle();
  }
}

Future<void> _enableReminder(WidgetTester tester) async {
  await _scrollTo(tester, find.byKey(const Key('reminder_enable_switch')));
  // _scrollTo stops once the switch is built in the cache extent, which can
  // still be below the fold; one more drag guarantees it is tappable.
  await tester.drag(find.byType(ListView), const Offset(0, -150));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('reminder_enable_switch')));
  await tester.pumpAndSettle();
}

Future<void> _fillBasicFields(WidgetTester tester) async {
  await tester.enterText(find.byKey(const Key('title_field')), 'Tasbih');
  await tester.enterText(find.byKey(const Key('count_field')), '33');
  await tester.enterText(find.byKey(const Key('check_field')), '11');
}

void main() {
  testWidgets('shows validation errors when required fields are empty',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _tapSave(tester);

    expect(find.text('Create Beads'), findsOneWidget);
    expect(harness.itemRepository.loadItems(), isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saving a valid form adds the item', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byKey(const Key('title_field')), 'Tasbih');
    await tester.enterText(find.byKey(const Key('count_field')), '33');
    await tester.enterText(find.byKey(const Key('check_field')), '11');
    await _tapSave(tester);

    final saved = harness.itemRepository.loadItems();
    expect(saved, hasLength(1));
    expect(saved.first.title, 'Tasbih');
    expect(saved.first.count, 33);
    expect(saved.first.check, 11);
    expect(saved.first.vibrationIntensity, 50);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('rejects a check larger than half of count', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    await tester.enterText(find.byKey(const Key('title_field')), 'Tasbih');
    await tester.enterText(find.byKey(const Key('count_field')), '33');
    await tester.enterText(find.byKey(const Key('check_field')), '20');
    await _tapSave(tester);

    expect(find.text('Create Beads'), findsOneWidget);
    expect(harness.itemRepository.loadItems(), isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('editing an item updates it', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item()]);
    await harness.initialize();

    await _pumpForm(tester, harness, itemToEdit: _item());

    expect(find.text('Edit Beads'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Tasbih'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('title_field')), 'Tesbih');
    for (var i = 0; i < 8 && tester.any(find.text('Update')) == false; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Update'));
    await tester.pumpAndSettle();

    final saved = harness.itemRepository.loadItems();
    expect(saved, hasLength(1));
    expect(saved.first.title, 'Tesbih');
    expect(saved.first.setCount, 11);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('enabling the reminder reveals recurrence options',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);

    expect(find.text('Once'), findsNothing);

    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byKey(const Key('reminder_enable_switch')));
    await tester.pumpAndSettle();
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
    }

    expect(find.text('Repeat'), findsWidgets);
    expect(find.text('Once'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('repeat count chip is hidden for the once recurrence',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _enableReminder(tester);

    expect(
      find.byKey(const Key('reminder_repeat_count_chip')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('reminder_repeat_count_field')),
      findsNothing,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('saving a daily reminder with a repeat count stores it',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _fillBasicFields(tester);
    await _enableReminder(tester);

    await _scrollTo(tester, find.text('Daily'));
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.tap(find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reminder_repeat_count_field')),
      '5',
    );
    await _scrollTo(tester, find.byKey(const Key('reminder_time_button')));
    await tester.tap(find.byKey(const Key('reminder_time_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    final saved = harness.itemRepository.loadItems();
    expect(saved, hasLength(1));
    expect(saved.first.reminderEnabled, isTrue);
    expect(saved.first.reminderRecurrence, ReminderRecurrence.daily);
    expect(saved.first.reminderRepeatCount, 5);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a repeat count below 2 shows an error and does not save',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _fillBasicFields(tester);
    await _enableReminder(tester);

    await _scrollTo(tester, find.text('Daily'));
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.tap(find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('reminder_repeat_count_field')),
      '1',
    );
    await _scrollTo(tester, find.byKey(const Key('reminder_time_button')));
    await tester.tap(find.byKey(const Key('reminder_time_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    await _scrollTo(
      tester,
      find.byKey(const Key('reminder_repeat_count_field')),
    );
    expect(find.text('Enter a number from 2 to 100'), findsOneWidget);
    expect(harness.itemRepository.loadItems(), isEmpty);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('turning the repeat count chip off again stores no count',
      (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await _pumpForm(tester, harness);
    await _fillBasicFields(tester);
    await _enableReminder(tester);

    await _scrollTo(tester, find.text('Daily'));
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    await _scrollTo(tester, find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.tap(find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reminder_repeat_count_chip')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('reminder_repeat_count_field')),
      findsNothing,
    );

    await _scrollTo(tester, find.byKey(const Key('reminder_time_button')));
    await tester.tap(find.byKey(const Key('reminder_time_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await _tapSave(tester);

    final saved = harness.itemRepository.loadItems();
    expect(saved, hasLength(1));
    expect(saved.first.reminderRecurrence, ReminderRecurrence.daily);
    expect(saved.first.reminderRepeatCount, isNull);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('editing a reminder prefills its repeat count',
      (tester) async {
    final harness = TestHarness.create();
    final existing = Item(
      id: 'a',
      title: 'Tasbih',
      count: 33,
      check: 11,
      setCount: 11,
      vibrationIntensity: 50,
      reminderEnabled: true,
      reminderRecurrence: ReminderRecurrence.daily,
      reminderAt: DateTime(2026, 8, 17, 12, 0),
      reminderRepeatCount: 7,
    );
    harness.itemRepository = ItemRepository.memory([existing]);
    await harness.initialize();

    await _pumpForm(tester, harness, itemToEdit: existing);

    await _scrollTo(
      tester,
      find.byKey(const Key('reminder_repeat_count_chip')),
    );
    final chip = tester.widget<FilterChip>(
      find.byKey(const Key('reminder_repeat_count_chip')),
    );
    expect(chip.selected, isTrue);
    final field = tester.widget<TextFormField>(
      find.byKey(const Key('reminder_repeat_count_field')),
    );
    expect(field.controller!.text, '7');

    for (var i = 0; i < 8 && tester.any(find.text('Update')) == false; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -150));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.widgetWithText(FilledButton, 'Update'));
    await tester.pumpAndSettle();

    final saved = harness.itemRepository.loadItems();
    expect(saved, hasLength(1));
    expect(saved.first.reminderRepeatCount, 7);

    await tester.pumpWidget(const SizedBox());
  });
}