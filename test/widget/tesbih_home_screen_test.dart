import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/tesbih_home_screen.dart';

import '../helpers/test_harness.dart';

Item _item({
  String id = 'a',
  String title = 'Tasbih',
  int count = 33,
  int check = 11,
  int setCount = 11,
  int progress = 0,
  int intensity = 50,
  String notes = '',
}) {
  return Item(
    id: id,
    title: title,
    notes: notes,
    count: count,
    check: check,
    setCount: setCount,
    vibrationIntensity: intensity,
    currentProgress: progress,
  );
}

void main() {
  testWidgets('shows the empty state when there are no items', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('No beads yet. Tap + to add one.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('lists seeded items with their stats', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(),
      _item(id: 'b', title: 'Salavat', count: 100, check: 25),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('Tasbih'), findsOneWidget);
    expect(find.text('Salavat'), findsOneWidget);
    expect(find.textContaining('Progress: 0 / 33'), findsOneWidget);
    expect(find.textContaining('Count: 100'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the add button opens the create form', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Create Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping an item opens the execution screen', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item()]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();

    expect(find.text('TAP'), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('deleting an item offers undo', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(),
      _item(id: 'b', title: 'Salavat'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Tasbih'), findsNothing);
    expect(find.text('"Tasbih" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Tasbih'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the menu edit action opens the edit form', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item()]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Beads'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Tasbih'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}