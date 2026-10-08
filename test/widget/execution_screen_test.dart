import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/services/audio_player_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';
import 'package:prayer_assistant/src/tesbihat/state/minimize_on_exit_notifier.dart';
import 'package:prayer_assistant/src/tesbihat/state/sound_library_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

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
  WidgetTester tester, {
  Item? item,
  String? targetItemId,
  MockLocalDatabase? database,
  AudioPlayerService? audioPlayer,
  FakeAudioPlayerService? chimePlayer,
}) async {
  final haptic = MockHapticService();
  when(() => haptic.standard(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});
  when(() => haptic.checkpoint(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});

  final mockReminderService = MockItemReminderService();
  when(() => mockReminderService.scheduleReminder(any()))
      .thenAnswer((_) async {});
  when(() => mockReminderService.cancelReminder(any()))
      .thenAnswer((_) async {});

  final db = database ?? MockLocalDatabase();
  when(() => db.loadBeadsMinimizeOnExit()).thenAnswer((_) async => true);
  when(() => db.saveBeadsMinimizeOnExit(any())).thenAnswer((_) async {});

  final items = item != null ? [item] : <Item>[];
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(ItemRepository.memory(items)),
        itemHistoryRepositoryProvider.overrideWithValue(
          ItemHistoryRepository.memory(),
        ),
        itemReminderServiceProvider.overrideWithValue(mockReminderService),
        soundLibraryRepositoryProvider.overrideWithValue(
          SoundLibraryRepository.memory(),
        ),
        hapticServiceProvider.overrideWithValue(haptic),
        localDatabaseProvider.overrideWithValue(db),
      ],
      child: testLocalizedApp(
        child: ExecutionScreen(
          itemId: targetItemId ?? item?.id ?? 'a',
          audioPlayerService: audioPlayer ?? FakeAudioPlayerService(),
          chimePlayerService: chimePlayer ?? FakeAudioPlayerService(),
        ),
      ),
    ),
  );
  await tester.pump();
  return haptic;
}

class FakeItem extends Fake implements Item {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeItem());
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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows item not found for an unknown id', (tester) async {
    await _pumpExecution(tester, targetItemId: 'x');

    expect(find.text('Item not found'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders the stats, progress and notes', (tester) async {
    await _pumpExecution(tester, item: _item(notes: 'Keep going'));

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
    await _pumpExecution(tester, item: _item());

    expect(find.text('No notes added.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows an outlined tap button while the counter is empty', (
    tester,
  ) async {
    await _pumpExecution(tester, item: _item());

    expect(find.widgetWithText(OutlinedButton, 'TAP'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TAP'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('keeps the outlined tap button once progress has started', (
    tester,
  ) async {
    await _pumpExecution(tester, item: _item(progress: 5));

    expect(find.widgetWithText(OutlinedButton, 'TAP'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'TAP'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping TAP increments progress and triggers a standard buzz',
      (tester) async {
    final haptic = await _pumpExecution(tester, item: _item());

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pump();

    expect(find.text('1'), findsWidgets);
    verify(() => haptic.standard(intensity: 50)).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a checkpoint tap triggers the checkpoint buzz', (tester) async {
    final haptic = await _pumpExecution(tester, item: _item(progress: 10));

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pump();

    expect(find.text('11'), findsWidgets);
    verify(() => haptic.checkpoint(intensity: 50)).called(1);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('reset asks for confirmation and resets progress',
      (tester) async {
    await _pumpExecution(tester, item: _item(progress: 30));

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
    await _pumpExecution(tester, item: _item());

    expect(find.byKey(const Key('edit_item_button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('edit_item_button')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('displays time left stat card initialized to --:--', (
    tester,
  ) async {
    await _pumpExecution(tester, item: _item(progress: 0));

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
    'resets time left when tapping the first bead from progress 0',
    (tester) async {
      final initialItem = _item(
        progress: 0,
        paceIntervals: const [1000, 1000, 1000],
      );
      await _pumpExecution(tester, item: initialItem);

      expect(
        tester
            .widget<Text>(find.byKey(const Key('time_left_value_text')))
            .data,
        '00:33',
      );

      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pump();

      expect(
        tester
            .widget<Text>(find.byKey(const Key('time_left_value_text')))
            .data,
        '--:--',
      );

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'renders minimize on exit button in AppBar actions and allows toggling',
    (tester) async {
      final db = MockLocalDatabase();
      await _pumpExecution(tester, item: _item(progress: 0), database: db);

      final buttonFinder =
          find.byKey(const Key('toggle_minimize_on_exit_button'));
      expect(buttonFinder, findsOneWidget);
      expect(find.byIcon(Icons.picture_in_picture_alt), findsOneWidget);

      // Tap to toggle off
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(
        find.byIcon(Icons.picture_in_picture_alt_outlined),
        findsOneWidget,
      );
      verify(() => db.saveBeadsMinimizeOnExit(false)).called(1);

      // Tap again to toggle on
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.byIcon(Icons.picture_in_picture_alt), findsOneWidget);
      verify(() => db.saveBeadsMinimizeOnExit(true)).called(1);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'renders bell icon in AppBar, defaults to off, and allows toggling',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final db = MockLocalDatabase();
      await _pumpExecution(tester, item: _item(progress: 0), database: db);

      final buttonFinder =
          find.byKey(const Key('toggle_interval_chime_button'));
      expect(buttonFinder, findsOneWidget);
      // Default is off
      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);

      // Tap to toggle on
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.byIcon(Icons.notifications_active), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('beads_interval_sound'), isTrue);

      // Tap again to toggle off
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
      expect(prefs.getBool('beads_interval_sound'), isFalse);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'plays chime together with vibration at every interval when enabled',
    (tester) async {
      final chimePlayer = FakeAudioPlayerService();
      final haptic = await _pumpExecution(
        tester,
        item: _item(progress: 10, check: 11),
        chimePlayer: chimePlayer,
      );

      // Toggle chime ON
      await tester.tap(find.byKey(const Key('toggle_interval_chime_button')));
      await tester.pump();

      // Tap to reach progress 11 (checkpoint)
      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pump();

      expect(find.text('11'), findsWidgets);
      verify(() => haptic.checkpoint(intensity: 50)).called(1);
      expect(chimePlayer.playAssetCallCount, 1);
      expect(chimePlayer.lastPlayedAsset, 'audio/interval_chime.mp3');

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'does not play chime at interval when disabled (default off)',
    (tester) async {
      final chimePlayer = FakeAudioPlayerService();
      final haptic = await _pumpExecution(
        tester,
        item: _item(progress: 10, check: 11),
        chimePlayer: chimePlayer,
      );

      // Tap to reach progress 11 (checkpoint) without toggling on
      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pump();

      expect(find.text('11'), findsWidgets);
      verify(() => haptic.checkpoint(intensity: 50)).called(1);
      expect(chimePlayer.playAssetCallCount, 0);

      await tester.pumpWidget(const SizedBox());
    },
  );
}