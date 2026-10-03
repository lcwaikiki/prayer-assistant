import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_reminder_form_screen.dart';
import 'package:prayer_assistant/src/controller/prayer_app_controller.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/item_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/services/audio_player_service.dart';
import 'package:prayer_assistant/src/tesbihat/services/shared_audio_handler.dart';
import 'package:prayer_assistant/src/tesbihat/state/sound_library_notifier.dart';
import 'package:provider/provider.dart' as provider;

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';
import '../helpers/test_harness.dart';

Future<void> _pumpForm(
  WidgetTester tester, {
  CalendarReminder? reminder,
  SoundLibraryRepository? soundRepo,
  FakeAudioPlayerService? audioPlayer,
}) async {
  final player = audioPlayer ?? FakeAudioPlayerService();
  final repo = soundRepo ?? SoundLibraryRepository.memory();
  final mockDb = MockLocalDatabase();
  final controller = PrayerAppController(
    api: MockImsakiyemApi(),
    database: mockDb,
    locationResolver: MockLocationResolver(),
    notificationService: MockNotificationService(),
    widgetBridgeService: MockWidgetBridgeService(),
    calendarReminderService: MockCalendarReminderService(),
  );

  await tester.pumpWidget(
    provider.ChangeNotifierProvider<PrayerAppController>.value(
      value: controller,
      child: ProviderScope(
        overrides: [
          soundLibraryRepositoryProvider.overrideWithValue(repo),
          audioPlayerServiceProvider.overrideWithValue(player),
        ],
        child: testLocalizedApp(
          child: CalendarReminderFormScreen(
            reminder: reminder,
            audioPlayerService: player,
            database: mockDb,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('renders sound attach button when no sound is attached',
      (tester) async {
    await _pumpForm(tester);

    expect(find.byKey(const Key('reminder_pick_sound_button')), findsOneWidget);
    expect(find.byKey(const Key('reminder_sound_preview_button')), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('renders sound card and title when reminder has attached sound',
      (tester) async {
    final reminderWithSound = CalendarReminder(
      id: 'r_sound',
      title: 'Morning Reminder',
      anchorAt: DateTime(2026, 8, 17, 9, 0),
      soundId: 'sound_123',
      soundTitle: 'Adhan Makkah',
    );

    await _pumpForm(tester, reminder: reminderWithSound);

    expect(find.text('Adhan Makkah'), findsOneWidget);
    expect(find.byKey(const Key('reminder_sound_preview_button')), findsOneWidget);
    expect(find.byKey(const Key('reminder_sound_swap_button')), findsOneWidget);
    expect(find.byKey(const Key('reminder_sound_remove_button')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('removing sound clears sound card and reveals attach button',
      (tester) async {
    final reminderWithSound = CalendarReminder(
      id: 'r_sound',
      title: 'Morning Reminder',
      anchorAt: DateTime(2026, 8, 17, 9, 0),
      soundId: 'sound_123',
      soundTitle: 'Adhan Makkah',
    );

    await _pumpForm(tester, reminder: reminderWithSound);

    expect(find.text('Adhan Makkah'), findsOneWidget);

    await tester.tap(find.byKey(const Key('reminder_sound_remove_button')));
    await tester.pump();

    expect(find.text('Adhan Makkah'), findsNothing);
    expect(find.byKey(const Key('reminder_pick_sound_button')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('preview sound plays sound bytes from sound library',
      (tester) async {
    final soundItem = SoundItem(
      id: 'sound_123',
      title: 'Adhan Makkah',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      mimeType: 'audio/mp3',
      createdAt: DateTime.now(),
    );
    final soundRepo = SoundLibraryRepository.memory([soundItem]);
    final player = FakeAudioPlayerService();

    final reminderWithSound = CalendarReminder(
      id: 'r_sound',
      title: 'Morning Reminder',
      anchorAt: DateTime(2026, 8, 17, 9, 0),
      soundId: 'sound_123',
      soundTitle: 'Adhan Makkah',
    );

    await _pumpForm(
      tester,
      reminder: reminderWithSound,
      soundRepo: soundRepo,
      audioPlayer: player,
    );

    await tester.tap(find.byKey(const Key('reminder_sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.playing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'pure reminder read-only screen allows audio player to be played',
      (tester) async {
    final soundItem = SoundItem(
      id: 'sound_123',
      title: 'Adhan Makkah',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      mimeType: 'audio/mp3',
      createdAt: DateTime.now(),
    );
    final soundRepo = SoundLibraryRepository.memory([soundItem]);
    final player = FakeAudioPlayerService();

    final reminderWithSound = CalendarReminder(
      id: 'r_sound',
      title: 'Morning Reminder',
      anchorAt: DateTime(2026, 8, 17, 9, 0),
      soundId: 'sound_123',
      soundTitle: 'Adhan Makkah',
    );

    final mockDb = MockLocalDatabase();
    final controller = PrayerAppController(
      api: MockImsakiyemApi(),
      database: mockDb,
      locationResolver: MockLocationResolver(),
      notificationService: MockNotificationService(),
      widgetBridgeService: MockWidgetBridgeService(),
      calendarReminderService: MockCalendarReminderService(),
    );

    await tester.pumpWidget(
      provider.ChangeNotifierProvider<PrayerAppController>.value(
        value: controller,
        child: ProviderScope(
          overrides: [
            soundLibraryRepositoryProvider.overrideWithValue(soundRepo),
            audioPlayerServiceProvider.overrideWithValue(player),
          ],
          child: testLocalizedApp(
            child: CalendarReminderFormScreen(
              reminder: reminderWithSound,
              readOnly: true,
              audioPlayerService: player,
              database: mockDb,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Adhan Makkah'), findsOneWidget);
    // Swap and remove buttons should not appear in read-only
    expect(find.byKey(const Key('reminder_sound_swap_button')), findsNothing);
    expect(find.byKey(const Key('reminder_sound_remove_button')), findsNothing);

    // Audio preview button MUST still be playable in read-only
    await tester.tap(find.byKey(const Key('reminder_sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.playing);

    // Tapping again pauses
    await tester.tap(find.byKey(const Key('reminder_sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.paused);

    // Tapping again resumes
    await tester.tap(find.byKey(const Key('reminder_sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.playing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'bead read-only screen allows audio player to be played, paused, and resumed',
      (tester) async {
    final harness = TestHarness.create();
    final soundItem = SoundItem(
      id: 'sound_bead',
      title: 'SubhanAllah Audio',
      bytes: Uint8List.fromList([1, 2, 3, 4]),
      mimeType: 'audio/mp3',
      createdAt: DateTime.now(),
    );
    final soundRepo = SoundLibraryRepository.memory([soundItem]);
    final player = FakeAudioPlayerService();

    final itemWithSound = Item(
      id: 'bead_1',
      title: 'Tasbih',
      count: 33,
      check: 11,
      setCount: 11,
      vibrationIntensity: 4,
      soundId: 'sound_bead',
      soundTitle: 'SubhanAllah Audio',
    );

    await pumpWithHarness(
      tester,
      harness,
      ItemFormScreen(
        itemToEdit: itemWithSound,
        readOnly: true,
        audioPlayerService: player,
      ),
      extraOverrides: [
        soundLibraryRepositoryProvider.overrideWithValue(soundRepo),
        audioPlayerServiceProvider.overrideWithValue(player),
      ],
    );
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pump();

    expect(find.text('SubhanAllah Audio'), findsOneWidget);
    // Swap and remove buttons should not appear in read-only
    expect(find.byIcon(Icons.swap_horiz), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);

    // Audio preview button MUST still be playable in read-only
    await tester.tap(find.byKey(const Key('sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.playing);

    // Tapping again pauses
    await tester.tap(find.byKey(const Key('sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.paused);

    // Tapping again resumes
    await tester.tap(find.byKey(const Key('sound_preview_button')));
    await tester.pump();

    expect(player.state, PlayerState.playing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'shared audio dialog shows option to attach to active reminder and updates reminder',
      (tester) async {
    final harness = TestHarness.create();
    final soundRepo = SoundLibraryRepository.memory();
    final reminder = CalendarReminder(
      id: 'cal_active',
      title: 'Dua Reminder',
      anchorAt: DateTime(2026, 8, 17, 10, 0),
      enabled: true,
    );
    await harness.controller.addCalendarReminder(reminder);

    final container = ProviderContainer(
      overrides: [
        soundLibraryRepositoryProvider.overrideWithValue(soundRepo),
      ],
    );

    await pumpWithHarness(
      tester,
      harness,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                SharedAudioHandler.showAttachOrSaveDialog(
                  context,
                  Uint8List.fromList([1, 2, 3, 4]),
                  'Shared Audio Test',
                  container,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify option to attach to active reminder is present
    expect(find.text('Attach to Active Reminder'), findsOneWidget);

    // Tap attach to active reminder
    await tester.tap(find.text('Attach to Active Reminder'));
    await tester.pumpAndSettle();

    // Dialog should show the active reminder
    expect(find.text('Dua Reminder'), findsOneWidget);

    // Tap on the reminder
    await tester.tap(find.text('Dua Reminder'));
    await tester.pumpAndSettle();

    // Verify reminder was updated with sound
    final updated = harness.controller.calendarReminders.firstWhere((r) => r.id == 'cal_active');
    expect(updated.soundId, isNotNull);
    expect(updated.soundTitle, 'Shared Audio Test');

    container.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}

