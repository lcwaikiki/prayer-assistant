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

    final fakeAudioPlayer = FakeAudioPlayerService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider
              .overrideWithValue(ItemRepository.memory([item])),
          itemHistoryRepositoryProvider
              .overrideWithValue(ItemHistoryRepository.memory()),
          itemReminderServiceProvider
              .overrideWithValue(MockItemReminderService()),
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

    // Verify sound playback widget is visible
    expect(find.byKey(const Key('audio_playback_button')), findsOneWidget);
    expect(find.text('SubhanAllah Recording'), findsOneWidget);

    // Tap play button and verify state changes
    await tester.tap(find.byKey(const Key('audio_playback_button')));
    await tester.pump();
    expect(fakeAudioPlayer.state, PlayerState.playing);

    // Simulate completion
    fakeAudioPlayer.triggerComplete();
    await tester.pump();

    // Verify progress advanced from 10 to 11
    expect(find.text('11'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });
}
