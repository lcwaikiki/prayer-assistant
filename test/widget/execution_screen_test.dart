import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';

import '../helpers/mocks.dart';
import '../helpers/test_harness.dart';

Item _item({
  int progress = 0,
  int check = 11,
  String notes = '',
}) {
  return Item(
    id: 'a',
    title: 'Tasbih',
    notes: notes,
    count: 33,
    check: check,
    setCount: 11,
    vibrationIntensity: 50,
    currentProgress: progress,
  );
}

Future<MockHapticService> _pumpExecution(
  WidgetTester tester,
  TestHarness harness, {
  Item? item,
}) async {
  final haptic = MockHapticService();
  when(() => haptic.standard(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});
  when(() => haptic.checkpoint(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});
  harness.itemRepository = ItemRepository.memory([?item]);
  await harness.initialize();

  await pumpWithHarness(
    tester,
    harness,
    ExecutionScreen(itemId: 'a'),
    extraOverrides: [hapticServiceProvider.overrideWithValue(haptic)],
  );
  return haptic;
}

void main() {
  testWidgets('shows item not found for an unknown id', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const ExecutionScreen(itemId: 'x'));

    expect(find.text('Item not found'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the stats, progress and notes', (tester) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item(notes: 'Keep going'));

    expect(find.text('Tasbih'), findsOneWidget);
    expect(find.text('Count'), findsOneWidget);
    expect(find.text('33'), findsWidgets);
    expect(find.text('Left Count'), findsOneWidget);
    expect(find.text('11'), findsWidgets);
    expect(find.text('0'), findsWidgets);
    expect(find.text('TAP'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the no-notes placeholder', (tester) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item());

    expect(find.text('No notes added.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping TAP increments progress and triggers a standard buzz',
      (tester) async {
    final harness = TestHarness.create();
    final haptic = await _pumpExecution(tester, harness, item: _item());

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pump();

    expect(find.text('1'), findsWidgets);
    verify(() => haptic.standard(intensity: 50)).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a checkpoint tap triggers the checkpoint buzz', (tester) async {
    final harness = TestHarness.create();
    final haptic = await _pumpExecution(tester, harness, item: _item(progress: 10));

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pump();

    expect(find.text('11'), findsWidgets);
    verify(() => haptic.checkpoint(intensity: 50)).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reset asks for confirmation and resets progress',
      (tester) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item(progress: 30));

    await tester.tap(find.byKey(const Key('reset_button')));
    await tester.pumpAndSettle();

    expect(find.text('Reset progress?'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('progress_text')), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('progress_text')))
          .data,
      '0',
    );

    await tester.pumpWidget(const SizedBox());
  });
}