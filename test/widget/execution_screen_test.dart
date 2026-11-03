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
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:wakelock_plus_platform_interface/wakelock_plus_platform_interface.dart';

import 'package:provider/provider.dart' as provider;
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/controller/prayer_app_controller.dart';
import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

Item _item({
  String id = 'a',
  String title = 'Tasbih',
  int count = 33,
  int progress = 0,
  int check = 11,
  int setCount = 11,
  String notes = '',
  List<String> groupIds = const [],
  List<int> paceIntervals = const [],
  bool isTask = false,
  bool reminderEnabled = false,
  ReminderRecurrence reminderRecurrence = ReminderRecurrence.daily,
}) {
  return Item(
    id: id,
    title: title,
    notes: notes,
    count: count,
    check: check,
    setCount: setCount,
    vibrationIntensity: 50,
    currentProgress: progress,
    groupIds: groupIds,
    paceIntervals: paceIntervals,
    isTask: isTask,
    reminderEnabled: reminderEnabled,
    reminderRecurrence: reminderRecurrence,
  );
}

Future<MockHapticService> _pumpExecution(
  WidgetTester tester, {
  Item? item,
  List<Item>? items,
  List<ItemGroup>? groups,
  String? groupId,
  String? targetItemId,
  MockLocalDatabase? database,
  AudioPlayerService? audioPlayer,
  FakeAudioPlayerService? chimePlayer,
  MockItemReminderService? reminderService,
  PrayerAppController? controller,
}) async {
  final haptic = MockHapticService();
  when(() => haptic.standard(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});
  when(() => haptic.checkpoint(intensity: any(named: 'intensity')))
      .thenAnswer((_) async {});

  final mockReminderService = reminderService ?? MockItemReminderService();
  if (reminderService == null) {
    when(() => mockReminderService.scheduleReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelActiveNotification(any()))
        .thenAnswer((_) async {});
  }

  final db = database ?? MockLocalDatabase();
  when(() => db.loadBeadsMinimizeOnExit()).thenAnswer((_) async => true);
  when(() => db.saveBeadsMinimizeOnExit(any())).thenAnswer((_) async {});
  if (database == null) {
    when(() => db.loadTaskCompletions())
        .thenAnswer((_) async => <String, List<String>>{});
    when(() => db.saveTaskCompletions(any())).thenAnswer((_) async {});
  }

  final itemList = items ?? (item != null ? [item] : <Item>[]);
  final executionScreen = ExecutionScreen(
    itemId: targetItemId ?? item?.id ?? (itemList.isNotEmpty ? itemList.first.id : 'a'),
    groupId: groupId,
    audioPlayerService: audioPlayer ?? FakeAudioPlayerService(),
    chimePlayerService: chimePlayer ?? FakeAudioPlayerService(),
    reminderService: mockReminderService,
  );

  final Widget appWidget = controller != null
      ? provider.ChangeNotifierProvider<PrayerAppController>.value(
          value: controller,
          child: testLocalizedApp(child: executionScreen),
        )
      : testLocalizedApp(child: executionScreen);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(ItemRepository.memory(itemList, groups ?? const [])),
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
      child: appWidget,
    ),
  );
  await tester.pump();
  return haptic;
}

class FakeItem extends Fake implements Item {}

class FakeWakelockPlusPlatform extends WakelockPlusPlatformInterface {
  final calls = <bool>[];

  @override
  Future<void> toggle({required bool enable}) async {
    calls.add(enable);
  }

  @override
  Future<bool> get enabled => Future.value(calls.isNotEmpty && calls.last);
}

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

  tearDown(() {
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

  testWidgets('reaching max count triggers checkpoint buzz as well', (tester) async {
    final haptic = await _pumpExecution(
      tester,
      item: _item(count: 33, check: 0, progress: 32),
    );

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pump();

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

  testWidgets(
    'toggles notes expansion upward',
    (tester) async {
      await _pumpExecution(tester, item: _item(notes: 'Sample note content'));

      final toggleButton = find.byKey(const Key('toggle_notes_expansion_button'));
      expect(toggleButton, findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

      final containerBefore = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.byKey(const Key('notes_bottom_text')),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(containerBefore.constraints?.maxHeight ?? 60.0, 60.0);

      // Expand notes
      await tester.tap(toggleButton);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
      final containerAfter = tester.widget<AnimatedContainer>(
        find.ancestor(
          of: find.byKey(const Key('notes_bottom_text')),
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(containerAfter.constraints?.maxHeight ?? 200.0, 200.0);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'shows next bead button for group members on completion and transitions to next bead',
    (tester) async {
      final bead1 = _item(
        id: 'b1',
        title: 'Bead 1',
        count: 10,
        check: 5,
        setCount: 0,
        progress: 9,
        groupIds: const ['g1'],
      );
      final bead2 = _item(
        id: 'b2',
        title: 'Bead 2',
        count: 10,
        check: 5,
        setCount: 0,
        progress: 0,
        groupIds: const ['g1'],
      );

      await _pumpExecution(
        tester,
        items: [bead1, bead2],
        targetItemId: 'b1',
        groupId: 'g1',
      );

      expect(find.byType(ExecutionScreen), findsOneWidget);
      expect(find.text('Bead 1'), findsOneWidget);

      // Tap once to reach progress 10 (target count)
      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pumpAndSettle();

      final nextButton = find.byKey(const Key('next_group_bead_button'));
      expect(nextButton, findsOneWidget);

      // Tap next button to transition to Bead 2
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      expect(find.text('Bead 2'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'keeps wakelock enabled across group bead transitions and disables on exit',
    (tester) async {
      final fakeWakelock = FakeWakelockPlusPlatform();
      final originalWakelock = wakelockPlusPlatformInstance;
      wakelockPlusPlatformInstance = fakeWakelock;
      addTearDown(() => wakelockPlusPlatformInstance = originalWakelock);

      final bead1 = _item(
        id: 'b1',
        title: 'Bead 1',
        count: 10,
        check: 5,
        progress: 9,
        groupIds: const ['g1'],
      );
      final bead2 = _item(
        id: 'b2',
        title: 'Bead 2',
        count: 10,
        check: 5,
        progress: 0,
        groupIds: const ['g1'],
      );

      await _pumpExecution(
        tester,
        items: [bead1, bead2],
        targetItemId: 'b1',
        groupId: 'g1',
      );

      expect(fakeWakelock.calls.isNotEmpty, isTrue);
      expect(fakeWakelock.calls.last, isTrue);

      // Tap once to reach 10 and show next button
      await tester.tap(find.byKey(const Key('big_tap_button')));
      await tester.pumpAndSettle();

      fakeWakelock.calls.clear();

      // Tap next button to pushReplacement to Bead 2
      await tester.tap(find.byKey(const Key('next_group_bead_button')));
      await tester.pumpAndSettle();

      expect(find.text('Bead 2'), findsOneWidget);
      // Wakelock must NOT have been turned off by Bead 1's disposal
      expect(fakeWakelock.calls.last, isTrue);
      expect(fakeWakelock.calls.contains(false), isFalse);

      fakeWakelock.calls.clear();

      // Exit ExecutionScreen
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();

      expect(fakeWakelock.calls.contains(false), isTrue);
    },
  );

  testWidgets(
    're-enables wakelock when app resumes from paused state',
    (tester) async {
      final fakeWakelock = FakeWakelockPlusPlatform();
      final originalWakelock = wakelockPlusPlatformInstance;
      wakelockPlusPlatformInstance = fakeWakelock;
      addTearDown(() => wakelockPlusPlatformInstance = originalWakelock);

      final bead = _item(
        id: 'b1',
        title: 'Bead 1',
        count: 10,
        check: 0,
        progress: 0,
      );

      await _pumpExecution(tester, items: [bead], targetItemId: 'b1');
      expect(fakeWakelock.calls.last, isTrue);

      fakeWakelock.calls.clear();

      // Simulate app backgrounding then resuming
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(fakeWakelock.calls.contains(true), isTrue);

      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
      'does not show mark as done button for non-task completed bead',
      (tester) async {
    final item = _item(count: 33, progress: 33, isTask: false);
    await _pumpExecution(tester, item: item);

    expect(find.byKey(const Key('reset_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_button')), findsNothing);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsNothing);
  });

  testWidgets('does not show mark as done button for incomplete task bead',
      (tester) async {
    final item = _item(count: 33, progress: 10, isTask: true);
    await _pumpExecution(tester, item: item);

    expect(find.byKey(const Key('reset_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_button')), findsNothing);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsNothing);
  });

  testWidgets(
      'shows mark as done button when task bead is completed and removes notification on tap',
      (tester) async {
    final item = _item(
      id: 'task_bead_1',
      title: 'Daily Dhikr',
      count: 33,
      progress: 32,
      check: 11,
      isTask: true,
      reminderEnabled: true,
    );
    final mockReminderService = MockItemReminderService();
    when(() => mockReminderService.scheduleReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelActiveNotification(any()))
        .thenAnswer((_) async {});

    final mockDb = MockLocalDatabase();
    when(() => mockDb.loadBeadsMinimizeOnExit()).thenAnswer((_) async => true);
    when(() => mockDb.saveBeadsMinimizeOnExit(any())).thenAnswer((_) async {});
    when(() => mockDb.loadTaskCompletions())
        .thenAnswer((_) async => <String, List<String>>{});
    when(() => mockDb.saveTaskCompletions(any())).thenAnswer((_) async {});

    await _pumpExecution(
      tester,
      item: item,
      database: mockDb,
      reminderService: mockReminderService,
    );
    await tester.pumpAndSettle();

    // Tap to reach max progress (2 -> 3)
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mark_as_done_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsOneWidget);

    // Tap mark as done
    await tester.tap(find.byKey(const Key('mark_as_done_button')));
    await tester.pumpAndSettle();

    // Verify notification/activation was removed
    verify(() => mockReminderService.cancelActiveNotification('task_bead_1'))
        .called(2);

    // Verify task completion was recorded in database
    verify(() => mockDb.saveTaskCompletions(any())).called(1);

    // Screen exits directly upon completion
    expect(find.byType(ExecutionScreen), findsNothing);
  });

  testWidgets(
      'reaching max progress on task bead shows mark as done button and cancels notification',
      (tester) async {
    final item = _item(
      id: 'task_bead_2',
      title: 'Evening Dhikr',
      count: 3,
      check: 1,
      progress: 2,
      isTask: true,
      reminderEnabled: true,
    );
    final mockReminderService = MockItemReminderService();
    when(() => mockReminderService.scheduleReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelActiveNotification(any()))
        .thenAnswer((_) async {});

    await _pumpExecution(
      tester,
      item: item,
      reminderService: mockReminderService,
    );

    // Before reaching max
    expect(find.byKey(const Key('mark_as_done_button')), findsNothing);

    // Tap to reach max progress (2 -> 3)
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    // After reaching max, mark as done button appears
    expect(find.byKey(const Key('mark_as_done_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsOneWidget);

    // Automatically cancelled active notification on reaching max
    verify(() => mockReminderService.cancelActiveNotification('task_bead_2'))
        .called(1);
  });

  testWidgets(
      'tapping mark as done when already done completes and exits',
      (tester) async {
    final item = _item(
      id: 'task_bead_3',
      title: 'Morning Dhikr',
      count: 33,
      progress: 32,
      check: 11,
      isTask: true,
    );

    final today = DateTime.now();
    final todayKey =
        '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final mockDb = MockLocalDatabase();
    when(() => mockDb.loadBeadsMinimizeOnExit()).thenAnswer((_) async => true);
    when(() => mockDb.saveBeadsMinimizeOnExit(any())).thenAnswer((_) async {});
    when(() => mockDb.loadTaskCompletions()).thenAnswer(
      (_) async => <String, List<String>>{
        todayKey: ['bead_task_bead_3'],
      },
    );
    when(() => mockDb.saveTaskCompletions(any())).thenAnswer((_) async {});

    await _pumpExecution(tester, item: item, database: mockDb);
    await tester.pumpAndSettle();

    // Tap to complete the bead
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    // Done state
    expect(find.byKey(const Key('mark_as_done_button')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsWidgets);

    // Tapping it completes and exits directly without confirmation dialog
    await tester.tap(find.byKey(const Key('mark_as_done_button')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(ExecutionScreen), findsNothing);
  });

  testWidgets(
      'for a group task, mark as done only appears on the last bead',
      (tester) async {
    const group = ItemGroup(
      id: 'task_group_1',
      title: 'Daily Group Dhikr',
      isTask: true,
      reminderEnabled: true,
      reminderRecurrence: ReminderRecurrence.daily,
    );

    final bead1 = _item(
      id: 'g_bead_1',
      title: 'Bead 1',
      count: 2,
      check: 1,
      progress: 1,
      groupIds: ['task_group_1'],
    );
    final bead2 = _item(
      id: 'g_bead_2',
      title: 'Bead 2 (Last)',
      count: 2,
      check: 1,
      progress: 0,
      groupIds: ['task_group_1'],
    );

    final mockReminderService = MockItemReminderService();
    when(() => mockReminderService.scheduleReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelActiveNotification(any()))
        .thenAnswer((_) async {});

    final mockDb = MockLocalDatabase();
    when(() => mockDb.loadBeadsMinimizeOnExit()).thenAnswer((_) async => true);
    when(() => mockDb.saveBeadsMinimizeOnExit(any())).thenAnswer((_) async {});
    when(() => mockDb.loadTaskCompletions())
        .thenAnswer((_) async => <String, List<String>>{});
    when(() => mockDb.saveTaskCompletions(any())).thenAnswer((_) async {});

    // Open first bead
    await _pumpExecution(
      tester,
      items: [bead1, bead2],
      groups: [group],
      groupId: 'task_group_1',
      targetItemId: 'g_bead_1',
      reminderService: mockReminderService,
      database: mockDb,
    );
    await tester.pumpAndSettle();

    // Tap to complete first bead (1 -> 2)
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    // On intermediate bead: Next button exists, but mark as done MUST NOT appear
    expect(find.byKey(const Key('next_group_bead_action_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_button')), findsNothing);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsNothing);

    // Tap Next to move to the last bead
    await tester.tap(find.byKey(const Key('next_group_bead_action_button')));
    await tester.pumpAndSettle();

    // Now on last bead: initially incomplete (progress 0 of 2), so mark as done still absent
    expect(find.text('Bead 2 (Last)'), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_button')), findsNothing);

    // Complete the last bead by tapping to 2
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    // On the last bead, once completed: mark as done button appears!
    expect(find.byKey(const Key('mark_as_done_button')), findsOneWidget);
    expect(find.byKey(const Key('mark_as_done_appbar_button')), findsOneWidget);

    // Tap mark as done on the last bead
    await tester.tap(find.byKey(const Key('mark_as_done_button')));
    await tester.pumpAndSettle();

    // Group task completion recorded and group notification cancelled
    verify(() => mockReminderService.cancelActiveNotification('task_group_1'))
        .called(1);
    verify(() => mockDb.saveTaskCompletions(any())).called(1);
    expect(find.byType(ExecutionScreen), findsNothing);
  });

  testWidgets(
      'automatically resets progress to zero on opening when bead is at max number',
      (tester) async {
    final item = _item(
      id: 'max_bead',
      title: 'Completed Bead',
      count: 33,
      progress: 33,
      isTask: true,
    );

    await _pumpExecution(tester, item: item);
    await tester.pumpAndSettle();

    // Progress counter displays 0 of 33 and big tap button is enabled
    expect(find.text('0'), findsWidgets);
    final tapButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('big_tap_button')),
    );
    expect(tapButton.onPressed, isNotNull);
  });
}
