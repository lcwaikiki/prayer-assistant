import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_form_screen.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';

import '../helpers/mocks.dart';
import '../helpers/test_app.dart';

void main() {
  late ItemRepository repository;
  late MockItemReminderService reminderService;

  setUpAll(() {
    registerFallbackValue(const ItemGroup(id: 'fallback', title: 'fallback'));
  });

  setUp(() {
    repository = ItemRepository.memory([], []);
    reminderService = MockItemReminderService();
    when(() => reminderService.scheduleGroupReminder(any()))
        .thenAnswer((_) async {});
    when(() => reminderService.cancelReminder(any())).thenAnswer((_) async {});
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    ItemGroup? groupToEdit,
    bool readOnly = false,
  }) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          itemRepositoryProvider.overrideWithValue(repository),
          itemHistoryRepositoryProvider.overrideWithValue(
            ItemHistoryRepository.memory(),
          ),
          itemReminderServiceProvider.overrideWithValue(reminderService),
        ],
        child: testLocalizedApp(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => GroupFormScreen(
                        groupToEdit: groupToEdit,
                        readOnly: readOnly,
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('persists isTask when saving a new group', (tester) async {
    await pumpForm(tester);

    // Enter title
    await tester.enterText(
        find.byKey(const Key('group_title_field')), 'Task Group');
    await tester.pumpAndSettle();

    // Enable reminder
    await tester.tap(find.byKey(const Key('reminder_enable_switch')));
    await tester.pumpAndSettle();

    // Select daily
    await tester.ensureVisible(find.text('Daily'));
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();

    // Pick time to satisfy clockTime validation
    await tester.ensureVisible(find.byKey(const Key('reminder_time_button')));
    await tester.tap(find.byKey(const Key('reminder_time_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    // Enable mark as task
    await tester.ensureVisible(find.byKey(const Key('reminder_is_task_switch')));
    await tester.tap(find.byKey(const Key('reminder_is_task_switch')));
    await tester.pumpAndSettle();

    // Save
    await tester.ensureVisible(find.byKey(const Key('save_group_button')));
    await tester.tap(find.byKey(const Key('save_group_button')));
    await tester.pumpAndSettle();

    final groups = repository.loadGroups();
    expect(groups, hasLength(1));
    expect(groups.first.title, 'Task Group');
    expect(groups.first.isTask, isTrue);
    expect(groups.first.reminderEnabled, isTrue);
  });

  testWidgets('persists updated isTask when editing an existing group',
      (tester) async {
    final existingGroup = ItemGroup(
      id: 'g1',
      title: 'Existing Group',
      reminderEnabled: true,
      isTask: false,
      reminderAnchor: ItemReminderAnchor.clockTime,
      reminderRecurrence: ReminderRecurrence.daily,
      reminderAt: DateTime(2026, 8, 17, 10, 0),
    );
    repository.saveGroups([existingGroup]);

    await pumpForm(tester, groupToEdit: existingGroup);

    // Toggle mark as task switch to true
    await tester.tap(find.byKey(const Key('reminder_is_task_switch')));
    await tester.pumpAndSettle();

    // Save
    await tester.tap(find.byKey(const Key('save_group_button')));
    await tester.pumpAndSettle();

    final groups = repository.loadGroups();
    expect(groups, hasLength(1));
    expect(groups.first.isTask, isTrue);
  });

  testWidgets(
      'prompts discard dialog when back is pressed with dirty isTask change',
      (tester) async {
    final existingGroup = ItemGroup(
      id: 'g2',
      title: 'Task Check Group',
      reminderEnabled: true,
      isTask: false,
      reminderAt: DateTime(2026, 8, 17, 10, 0),
    );
    repository.saveGroups([existingGroup]);

    await pumpForm(tester, groupToEdit: existingGroup);

    // Toggle mark as task
    await tester.tap(find.byKey(const Key('reminder_is_task_switch')));
    await tester.pumpAndSettle();

    // Tap back button
    final backButton = find.byType(BackButton);
    expect(backButton, findsOneWidget);
    await tester.tap(backButton);
    await tester.pumpAndSettle();

    // Discard confirmation dialog should be shown
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('renders concise read-only view and switches to edit on tap',
      (tester) async {
    final existingGroup = ItemGroup(
      id: 'g3',
      title: 'Thursday Adhkar',
      notes: 'Weekly evening remembrance',
      reminderEnabled: true,
      reminderAnchor: ItemReminderAnchor.prayerTime,
      reminderRecurrence: ReminderRecurrence.weekly,
      reminderPrayerName: 'Yatsi',
      reminderOffsetMinutes: 10,
      reminderWeekdays: const [4],
      isTask: true,
    );
    repository.saveGroups([existingGroup]);

    await pumpForm(tester, groupToEdit: existingGroup, readOnly: true);

    // Read only view displays concise text
    expect(find.text('Text'), findsOneWidget);
    expect(find.text('Thursday Adhkar'), findsWidgets);
    expect(find.text('Weekly evening remembrance'), findsWidgets);
    expect(find.textContaining('every Thursday 10 minutes after'), findsOneWidget);

    // Form text fields should NOT be shown in read-only mode
    expect(find.byKey(const Key('group_title_field')), findsNothing);

    // Tap edit button to switch to editable mode
    await tester.tap(find.byKey(const Key('edit_group_button_bottom')));
    await tester.pumpAndSettle();

    // Now editable fields are visible
    expect(find.byKey(const Key('group_title_field')), findsOneWidget);
  });
}
