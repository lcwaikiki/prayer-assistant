import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_reminder_detail_screen.dart';
import 'package:prayer_assistant/src/calendar/screens/calendar_reminder_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';
import 'package:prayer_assistant/src/tesbihat/screens/bead_detail_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_detail_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/item_form_screen.dart';
import 'package:prayer_assistant/src/widgets/read_only_detail_section.dart';

import '../helpers/test_harness.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'),
      (call) async => 'UTC',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('wakelock_plus'),
      (call) async => true,
    );
  });

  group('BeadDetailScreen', () {
    testWidgets('renders circular progress, zoomable notes, and bottom actions', (tester) async {
      final harness = TestHarness.create();
      const item = Item(
        id: 'bead-subhanallah',
        title: 'SubhanAllah',
        notes: 'Glory be to Allah alone',
        count: 33,
        check: 11,
        setCount: 2,
        vibrationIntensity: 80,
        currentProgress: 27,
        reminderEnabled: true,
        reminderOffsetMinutes: 15,
        reminderPrayerName: 'Fajr',
      );
      harness.itemRepository.saveItems([item]);
      await harness.initialize();

      await pumpWithHarness(
        tester,
        harness,
        const BeadDetailScreen(item: item),
      );

      // Verify header & titles
      expect(find.text('Milestone Details'), findsOneWidget);
      expect(find.text('SubhanAllah'), findsWidgets);
      expect(find.text('Glory be to Allah alone'), findsWidgets);

      // Verify circular progress card
      expect(find.byType(ReadOnlyCircularProgressCard), findsOneWidget);
      expect(find.text('27 / 33'), findsOneWidget);
      expect(find.text('81%'), findsOneWidget);
      expect(find.text('Target'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
      expect(find.text('Vibration'), findsOneWidget);

      // Verify zoomable notes card
      expect(find.byType(ReadOnlyZoomableNotesCard), findsOneWidget);
      expect(find.textContaining('Pinch'), findsOneWidget);

      // Scroll to reveal timing and bottom action bar
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pumpAndSettle();
      expect(find.byType(ReadOnlyTimingHeroCard), findsOneWidget);
      expect(find.text('Reminder Schedule'), findsOneWidget);

      // Verify bottom action bar
      expect(find.byType(ReadOnlyBottomActionBar), findsOneWidget);
      expect(find.byKey(const Key('start_counting_button')), findsOneWidget);
      expect(find.byKey(const Key('edit_bead_bottom_button')), findsOneWidget);

      // Tap Edit Bead bottom button opens ItemFormScreen in edit mode
      await tester.tap(find.byKey(const Key('edit_bead_bottom_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ItemFormScreen), findsOneWidget);
      final form = tester.widget<ItemFormScreen>(find.byType(ItemFormScreen));
      expect(form.readOnly, isFalse);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('changing audio speed persists soundSpeed on bead item', (tester) async {
      final harness = TestHarness.create();
      await harness.initialize();

      final sound = SoundItem(
        id: 'sound-custom',
        title: 'Custom Azan',
        path: 'azans/custom.mp3',
        durationMs: 45000,
        createdAt: DateTime(2026, 1, 1),
      );
      harness.soundLibraryRepository.saveSounds([sound]);
      final item = Item(
        id: 'bead-with-audio',
        title: 'Tahmid',
        count: 33,
        check: 11,
        setCount: 0,
        vibrationIntensity: 100,
        soundId: sound.id,
        soundTitle: sound.title,
        soundSpeed: 1.0,
      );
      harness.itemRepository.saveItems([item]);

      await pumpWithHarness(
        tester,
        harness,
        BeadDetailScreen(item: item),
      );

      await tester.scrollUntilVisible(find.byType(ReadOnlySoundPlayerCard), 200);
      expect(find.byType(ReadOnlySoundPlayerCard), findsOneWidget);

      // Expand speed controls
      await tester.tap(find.byKey(const Key('toggle_sound_controls_button')));
      await tester.pumpAndSettle();
      expect(find.text('1x'), findsOneWidget);

      // Tap speed 1.5x button
      await tester.tap(find.text('1.5x'));
      await tester.pumpAndSettle();

      final updated = harness.itemRepository.loadItems().firstWhere((it) => it.id == item.id);
      expect(updated.soundSpeed, 1.5);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('GroupDetailScreen', () {
    testWidgets('renders group members, zoomable notes, and bottom actions', (tester) async {
      final harness = TestHarness.create();
      const group = ItemGroup(
        id: 'group-post-prayer',
        title: 'Post-Prayer Adhkar',
        notes: 'Say each tasbih 33 times after prayer',
        reminderEnabled: true,
        reminderOffsetMinutes: 10,
        reminderPrayerName: 'Dhuhr',
      );
      const member1 = Item(
        id: 'm1',
        title: 'SubhanAllah',
        count: 33,
        check: 11,
        setCount: 0,
        vibrationIntensity: 100,
        currentProgress: 33,
        groupIds: ['group-post-prayer'],
      );
      const member2 = Item(
        id: 'm2',
        title: 'Alhamdulillah',
        count: 33,
        check: 11,
        setCount: 0,
        vibrationIntensity: 100,
        currentProgress: 15,
        groupIds: ['group-post-prayer'],
      );
      harness.itemRepository.saveGroups([group]);
      harness.itemRepository.saveItems([member1, member2]);
      await harness.initialize();

      await pumpWithHarness(
        tester,
        harness,
        const GroupDetailScreen(group: group),
      );

      // Verify header
      expect(find.text('Group Details'), findsOneWidget);
      expect(find.text('Post-Prayer Adhkar'), findsWidgets);
      expect(find.text('Say each tasbih 33 times after prayer'), findsWidgets);

      // Verify group sequence card
      expect(find.byType(ReadOnlyGroupSequenceCard), findsOneWidget);
      expect(find.text('SubhanAllah'), findsOneWidget);
      expect(find.text('Alhamdulillah'), findsOneWidget);

      // Verify zoomable notes card
      expect(find.byType(ReadOnlyZoomableNotesCard), findsOneWidget);
      expect(find.textContaining('Pinch'), findsOneWidget);

      // Verify timing card
      expect(find.byType(ReadOnlyTimingHeroCard), findsOneWidget);

      // Verify bottom action bar
      expect(find.byType(ReadOnlyBottomActionBar), findsOneWidget);
      expect(find.byKey(const Key('start_group_session_button')), findsOneWidget);
      expect(find.byKey(const Key('edit_group_bottom_button')), findsOneWidget);

      // Tap Edit Group button opens GroupFormScreen in edit mode
      await tester.tap(find.byKey(const Key('edit_group_bottom_button')));
      await tester.pumpAndSettle();
      expect(find.byType(GroupFormScreen), findsOneWidget);
      final form = tester.widget<GroupFormScreen>(find.byType(GroupFormScreen));
      expect(form.readOnly, isFalse);

      await tester.pumpWidget(const SizedBox());
    });
  });

  group('CalendarReminderDetailScreen', () {
    testWidgets('renders timing hero, zoomable notes, snooze preview, and toggle button', (tester) async {
      final harness = TestHarness.create();
      final reminder = CalendarReminder(
        id: 'cal-morning-adhkar',
        title: 'Morning Adhkar',
        notes: 'We have reached the morning and unto Allah belongs all praise',
        anchorAt: DateTime(2026, 8, 20, 6, 15),
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Gunes',
        anchorOffsetMinutes: 15,
        recurrence: ReminderRecurrence.daily,
        enabled: true,
        isTask: true,
      );
      harness.controller.addCalendarReminder(reminder);
      await harness.initialize();

      await pumpWithHarness(
        tester,
        harness,
        CalendarReminderDetailScreen(reminder: reminder),
      );

      // Verify header & titles
      expect(find.text('Reminder Details'), findsOneWidget);
      expect(find.text('Morning Adhkar'), findsWidgets);
      expect(find.text('We have reached the morning and unto Allah belongs all praise'), findsWidgets);

      // Verify timing card
      expect(find.byType(ReadOnlyTimingHeroCard), findsOneWidget);
      expect(find.text('Reminder Schedule'), findsOneWidget);

      // Verify zoomable notes card
      expect(find.byType(ReadOnlyZoomableNotesCard), findsOneWidget);
      expect(find.textContaining('Pinch'), findsOneWidget);

      // Verify snooze preview card
      expect(find.byType(ReadOnlySnoozePreviewCard), findsOneWidget);
      expect(find.text('+5 min'), findsOneWidget);
      expect(find.text('+10 min'), findsOneWidget);
      expect(find.text('+15 min'), findsOneWidget);

      // Verify bottom action bar
      expect(find.byType(ReadOnlyBottomActionBar), findsOneWidget);
      expect(find.byKey(const Key('toggle_done_reminder_button')), findsOneWidget);
      expect(find.byKey(const Key('edit_reminder_bottom_button')), findsOneWidget);

      // Tap Edit Reminder bottom button opens CalendarReminderFormScreen in edit mode
      await tester.tap(find.byKey(const Key('edit_reminder_bottom_button')));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarReminderFormScreen), findsOneWidget);
      final form = tester.widget<CalendarReminderFormScreen>(find.byType(CalendarReminderFormScreen));
      expect(form.readOnly, isFalse);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders localized strings in Turkish locale', (tester) async {
      final harness = TestHarness.create();
      final reminder = CalendarReminder(
        id: 'cal-tr-test',
        title: 'Sabah Duasi',
        notes: 'Allahim sana siginirim',
        anchorAt: DateTime(2026, 8, 20, 6, 15),
        anchor: CalendarReminderAnchor.prayerTime,
        anchorPrayerName: 'Gunes',
        anchorOffsetMinutes: 15,
        recurrence: ReminderRecurrence.daily,
        enabled: true,
        isTask: true,
      );
      harness.controller.addCalendarReminder(reminder);
      await harness.initialize();

      await pumpWithHarness(
        tester,
        harness,
        CalendarReminderDetailScreen(reminder: reminder),
        locale: const Locale('tr'),
      );

      // Verify Turkish localized labels
      expect(find.text('Hatırlatıcı Detayları'), findsOneWidget);
      expect(find.text('Hatırlatıcı Takvimi'), findsOneWidget);
      expect(find.text('Dua Notları'), findsOneWidget);
      expect(find.text('Bildirim Erteleme Seçenekleri'), findsOneWidget);
      expect(find.text('+5 dk'), findsOneWidget);
      expect(find.text('Yapıldı Olarak İşaretle'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mark as done marks task completed and closes screen', (tester) async {
      final harness = TestHarness.create();
      await harness.initialize();

      final reminder = CalendarReminder(
        id: 'cal-task-toggle',
        title: 'Daily Task',
        anchorAt: DateTime.now(),
        isTask: true,
        enabled: true,
      );
      await harness.controller.addCalendarReminder(reminder);

      await pumpWithHarness(
        tester,
        harness,
        CalendarReminderDetailScreen(reminder: reminder),
      );

      final today = DateTime.now();
      expect(harness.controller.isTaskCompleted('cal_${reminder.id}', today), isFalse);
      expect(find.text('Mark as Done'), findsOneWidget);

      // Tap Mark as Done
      await tester.tap(find.byKey(const Key('toggle_done_reminder_button')));
      await tester.pumpAndSettle();

      expect(harness.controller.isTaskCompleted('cal_${reminder.id}', today), isTrue);
      // Screen is popped/closed
      expect(find.byType(CalendarReminderDetailScreen), findsNothing);
    });

    testWidgets('non-task reminder hides disable/enable button and shows edit button', (tester) async {
      final harness = TestHarness.create();
      await harness.initialize();

      final reminder = CalendarReminder(
        id: 'cal-non-task',
        title: 'General Reminder',
        anchorAt: DateTime.now(),
        isTask: false,
        enabled: true,
      );
      await harness.controller.addCalendarReminder(reminder);

      await pumpWithHarness(
        tester,
        harness,
        CalendarReminderDetailScreen(reminder: reminder),
      );

      expect(find.byKey(const Key('toggle_done_reminder_button')), findsNothing);
      expect(find.text('Disable Reminder'), findsNothing);
      expect(find.text('Enable Reminder'), findsNothing);
      expect(find.byKey(const Key('edit_reminder_bottom_button')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('changing audio speed persists soundSpeed on calendar reminder', (tester) async {
      final harness = TestHarness.create();
      await harness.initialize();

      final sound = SoundItem(
        id: 'sound-dua',
        title: 'Dua Audio',
        path: 'duas/custom.mp3',
        durationMs: 30000,
        createdAt: DateTime(2026, 1, 1),
      );
      harness.soundLibraryRepository.saveSounds([sound]);
      final reminder = CalendarReminder(
        id: 'cal-audio-test',
        title: 'Adhkar with Audio',
        anchorAt: DateTime.now(),
        soundId: sound.id,
        soundTitle: sound.title,
        soundSpeed: 1.0,
      );
      await harness.controller.addCalendarReminder(reminder);

      await pumpWithHarness(
        tester,
        harness,
        CalendarReminderDetailScreen(reminder: reminder),
      );

      await tester.scrollUntilVisible(find.byType(ReadOnlySoundPlayerCard), 200);
      expect(find.byType(ReadOnlySoundPlayerCard), findsOneWidget);

      // Expand speed controls
      await tester.tap(find.byKey(const Key('toggle_sound_controls_button')));
      await tester.pumpAndSettle();
      expect(find.text('1x'), findsOneWidget);

      // Tap speed 1.5x button
      await tester.tap(find.text('1.5x'));
      await tester.pumpAndSettle();

      final updated = harness.controller.calendarReminders.firstWhere((r) => r.id == reminder.id);
      expect(updated.soundSpeed, 1.5);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
