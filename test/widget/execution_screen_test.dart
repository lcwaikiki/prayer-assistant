import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';

import '../helpers/mocks.dart';
import '../helpers/test_harness.dart';

Item _item({
  int progress = 0,
  int check = 11,
  String notes = '',
  List<int> paceIntervals = const [],
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
    paceIntervals: paceIntervals,
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
    ExecutionScreen(
      itemId: 'a',
      audioPlayerService: FakeAudioPlayerService(),
    ),
    settle: false,
    extraOverrides: [hapticServiceProvider.overrideWithValue(haptic)],
  );
  await tester.pump();
  return haptic;
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (call) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/wakelock'),
      (call) async => true,
    );
  });

  testWidgets('shows item not found for an unknown id', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(
      tester,
      harness,
      ExecutionScreen(
        itemId: 'x',
        audioPlayerService: FakeAudioPlayerService(),
      ),
      settle: false,
    );
    await tester.pump();

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

  testWidgets('shows an outlined tap button while the counter is empty', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item());

    expect(find.widgetWithText(OutlinedButton, 'TAP'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TAP'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('keeps the outlined tap button once progress has started', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item(progress: 5));

    expect(find.widgetWithText(OutlinedButton, 'TAP'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TAP'), findsNothing);

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

  testWidgets('AppBar edit button opens ItemFormScreen', (tester) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item());

    expect(find.byKey(const Key('edit_item_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('edit_item_button')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('displays time left stat card initialized to --:--', (
    tester,
  ) async {
    final harness = TestHarness.create();
    await _pumpExecution(tester, harness, item: _item(progress: 0));

    expect(find.text('Time Left'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const Key('time_left_value_text')))
          .data,
      '--:--',
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'shows estimated time to complete when executed count is 0 or equals count number, otherwise shows time left',
    (tester) async {
      final harness = TestHarness.create();
      // Item with paceIntervals of 1000ms (1 sec per tap) and progress = 0
      final initialItem = _item(
        progress: 0,
        paceIntervals: const [1000, 1000, 1000],
      );
      await _pumpExecution(tester, harness, item: initialItem);

      // Executed count is 0: shows estimated time to complete full count (33 sec -> 00:33)
      expect(
        tester
            .widget<Text>(find.byKey(const Key('time_left_value_text')))
            .data,
        '00:33',
      );

      // Tap button once (executed becomes 1, remaining is 32)
      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pump();

      // Executed count is 1 (in between): shows time left for remaining (32 sec -> 00:32)
      expect(
        tester
            .widget<Text>(find.byKey(const Key('time_left_value_text')))
            .data,
        '00:32',
      );

      await tester.pumpWidget(const SizedBox());

      // When executed equals count number (completed 33/33)
      final completedHarness = TestHarness.create();
      final completedItem = _item(
        progress: 33,
        paceIntervals: const [1000, 1000, 1000],
      );
      await _pumpExecution(tester, completedHarness, item: completedItem);

      // Executed count equals count number: shows estimated time to complete (33 sec -> 00:33)
      expect(
        tester
            .widget<Text>(find.byKey(const Key('time_left_value_text')))
            .data,
        '00:33',
      );

      await tester.pumpWidget(const SizedBox());
    },
  );
}