import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/execution_screen.dart';
import 'package:prayer_assistant/src/tesbihat/services/haptic_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/item_reminder_service.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';
import 'package:prayer_assistant/src/tesbihat/state/sound_library_notifier.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

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

  testWidgets('displays sound playback card when item has sound attached', (tester) async {
    final sound = SoundItem(
      id: 'snd_abc',
      title: 'SubhanAllah Recording',
      bytes: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime(2026, 1, 1),
    );

    final item = Item(
      id: 'bead_1',
      title: 'Tasbih with Sound',
      count: 33,
      check: 11,
      setCount: 0,
      vibrationIntensity: 50,
      currentProgress: 10,
      soundId: 'snd_abc',
      soundTitle: 'SubhanAllah Recording',
      autoCountWithSound: true,
    );

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

    final fakeAudioPlayer = FakeAudioPlayerService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider
              .overrideWithValue(ItemRepository.memory([item])),
          itemHistoryRepositoryProvider
              .overrideWithValue(ItemHistoryRepository.memory()),
          itemReminderServiceProvider
              .overrideWithValue(mockReminderService),
          soundLibraryRepositoryProvider
              .overrideWithValue(SoundLibraryRepository.memory([sound])),
          hapticServiceProvider.overrideWithValue(haptic),
        ],
        child: testLocalizedApp(
          child: ExecutionScreen(
            itemId: 'bead_1',
            audioPlayerService: fakeAudioPlayer,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify sound playback button and toggle button are visible
    expect(find.byKey(const Key('audio_playback_button')), findsOneWidget);
    expect(find.byKey(const Key('toggle_sound_controls_button')), findsOneWidget);
    expect(find.text('SubhanAllah Recording'), findsOneWidget);
    expect(find.byKey(const Key('speed_slider')), findsNothing);

    // Expand sound controls
    await tester.tap(find.byKey(const Key('toggle_sound_controls_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('speed_slider')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_1x')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_1.25x')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_1.5x')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_2x')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_3x')), findsOneWidget);
    expect(find.byKey(const Key('speed_preset_4x')), findsOneWidget);

    // Tap 1.5x preset
    await tester.tap(find.byKey(const Key('speed_preset_1.5x')));
    await tester.pump();
    expect(fakeAudioPlayer.playbackRate, 1.5);
    expect(find.text('1.50x'), findsOneWidget);

    // Tap +0.05 button
    await tester.tap(find.byKey(const Key('speed_increase_button')));
    await tester.pump();
    expect(fakeAudioPlayer.playbackRate, 1.55);
    expect(find.text('1.55x'), findsOneWidget);

    // Tap -0.05 button
    await tester.tap(find.byKey(const Key('speed_decrease_button')));
    await tester.pump();
    expect(fakeAudioPlayer.playbackRate, 1.5);
    expect(find.text('1.50x'), findsOneWidget);

    // Tap play button and verify state changes to playing
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.playing);

    // Tap play button again during playback - should pause, not stop
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.paused);

    // Tap play button again when paused - should resume playback
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.playing);

    // Long press play button - should stop playback
    await tester.longPress(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.stopped);

    // Tap play button again and let sound complete
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.playing);

    // Simulate completion
    fakeAudioPlayer.triggerComplete();
    await tester.pump();

    // Verify progress advanced from 10 to 11
    expect(find.text('11'), findsWidgets);

    // Collapse sound controls
    await tester.tap(find.byKey(const Key('toggle_sound_controls_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('speed_slider')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('initializes execution screen with persisted item soundSpeed', (tester) async {
    final sound = SoundItem(
      id: 'snd_2x',
      title: 'Dhikr 2x',
      bytes: Uint8List.fromList([1, 2, 3]),
      createdAt: DateTime(2026, 1, 1),
    );

    final item = Item(
      id: 'bead_fast',
      title: 'Fast Bead',
      count: 33,
      check: 0,
      setCount: 0,
      vibrationIntensity: 50,
      currentProgress: 5,
      soundId: 'snd_2x',
      soundTitle: 'Dhikr 2x',
      soundSpeed: 2.0,
    );

    final haptic = MockHapticService();
    when(() => haptic.standard(intensity: any(named: 'intensity')))
        .thenAnswer((_) async {});

    final mockReminderService = MockItemReminderService();
    when(() => mockReminderService.scheduleReminder(any()))
        .thenAnswer((_) async {});
    when(() => mockReminderService.cancelReminder(any()))
        .thenAnswer((_) async {});

    final fakeAudioPlayer = FakeAudioPlayerService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider
              .overrideWithValue(ItemRepository.memory([item])),
          itemHistoryRepositoryProvider
              .overrideWithValue(ItemHistoryRepository.memory()),
          itemReminderServiceProvider
              .overrideWithValue(mockReminderService),
          soundLibraryRepositoryProvider
              .overrideWithValue(SoundLibraryRepository.memory([sound])),
          hapticServiceProvider.overrideWithValue(haptic),
        ],
        child: testLocalizedApp(
          child: ExecutionScreen(
            itemId: 'bead_fast',
            audioPlayerService: fakeAudioPlayer,
          ),
        ),
      ),
    );
    await tester.pump();

    // Expand controls and verify speed badge initialized to 2.00x
    await tester.tap(find.byKey(const Key('toggle_sound_controls_button')));
    await tester.pumpAndSettle();
    expect(find.text('2.00x'), findsOneWidget);

    // Tap play and verify playBytes uses 2.0 speed
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.playbackRate, 2.0);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('entering bead with no sound attached works without error', (tester) async {
    final item = Item(
      id: 'bead_no_sound',
      title: 'No Sound Bead',
      count: 33,
      check: 11,
      setCount: 0,
      vibrationIntensity: 50,
      currentProgress: 0,
      soundId: null,
      soundTitle: null,
    );

    final haptic = MockHapticService();
    when(() => haptic.standard(intensity: any(named: 'intensity')))
        .thenAnswer((_) async {});
    when(() => haptic.checkpoint(intensity: any(named: 'intensity')))
        .thenAnswer((_) async {});
    final mockReminderService = MockItemReminderService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider
              .overrideWithValue(ItemRepository.memory([item])),
          itemHistoryRepositoryProvider
              .overrideWithValue(ItemHistoryRepository.memory()),
          itemReminderServiceProvider
              .overrideWithValue(mockReminderService),
          soundLibraryRepositoryProvider
              .overrideWithValue(SoundLibraryRepository.memory()),
          hapticServiceProvider.overrideWithValue(haptic),
        ],
        child: testLocalizedApp(
          child: const ExecutionScreen(
            itemId: 'bead_no_sound',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Sound Bead'), findsOneWidget);
    expect(find.byKey(const Key('audio_playback_button')), findsNothing);
    expect(find.byKey(const Key('big_tap_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('big_tap_button')));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });
}
