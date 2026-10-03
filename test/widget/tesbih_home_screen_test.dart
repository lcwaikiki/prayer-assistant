import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/daily_item_stat.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_screen.dart';
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
  List<String> groupIds = const [],
  bool reminderEnabled = false,
  String? soundId,
  String? soundTitle,
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
    groupIds: groupIds,
    reminderEnabled: reminderEnabled,
    soundId: soundId,
    soundTitle: soundTitle,
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

  testWidgets('lists seeded items with their stats and badges', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(soundId: 'snd_1', soundTitle: 'SubhanAllah'),
      _item(id: 'b', title: 'Salavat', count: 100, check: 25, reminderEnabled: true),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('Tasbih'), findsOneWidget);
    expect(find.text('Salavat'), findsOneWidget);
    expect(find.textContaining('Progress: 0 / 33'), findsOneWidget);
    expect(find.textContaining('Count: 100'), findsOneWidget);

    // Verify sound badge and reminder badge icons
    expect(find.byKey(const Key('item_sound_badge_icon')), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows aggregated daily history stats', (tester) async {
    final now = DateTime.now();
    final todayKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final fiveDaysAgo = now.subtract(const Duration(days: 3));
    final fiveDaysKey = '${fiveDaysAgo.year.toString().padLeft(4, '0')}-${fiveDaysAgo.month.toString().padLeft(2, '0')}-${fiveDaysAgo.day.toString().padLeft(2, '0')}';
    final old = now.subtract(const Duration(days: 20));
    final oldKey = '${old.year.toString().padLeft(4, '0')}-${old.month.toString().padLeft(2, '0')}-${old.day.toString().padLeft(2, '0')}';

    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item(), _item(id: 'b')]);
    harness.itemHistoryRepository = ItemHistoryRepository.memory([
      DailyItemStat(itemId: 'a', dateKey: todayKey, count: 5),
      DailyItemStat(itemId: 'b', dateKey: todayKey, count: 3),
      DailyItemStat(itemId: 'a', dateKey: fiveDaysKey, count: 4),
      DailyItemStat(itemId: 'a', dateKey: oldKey, count: 4),
    ]);
    await harness.initialize();


    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('History'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('7 days'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows zero stats when no taps have been recorded', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item()]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('0'), findsNWidgets(3));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the add button opens the create form', (tester) async {
    final harness = TestHarness.create();
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Bead'), findsOneWidget);
    expect(find.text('New Group'), findsOneWidget);

    await tester.tap(find.text('New Bead'));
    await tester.pumpAndSettle();

    expect(find.text('Create Beads'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping an item opens the edit screen read only with execution button', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item()]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    await tester.tap(find.text('Tasbih'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Beads'), findsOneWidget);
    expect(find.text('Execute'), findsOneWidget);

    await tester.tap(find.text('Execute'));
    await tester.pumpAndSettle();

    expect(find.text('TAP'), findsOneWidget);
    expect(find.byKey(const Key('big_tap_button')), findsOneWidget);

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

  testWidgets('filters beads and groups by title and notes and toggles search bar', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(id: '1', title: 'SubhanAllah', notes: 'Praise be to God'),
      _item(id: '2', title: 'Alhamdulillah', notes: 'All praise to Allah'),
      _item(id: '3', title: 'AllahuAkbar', notes: 'God is greatest'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.text('SubhanAllah'), findsOneWidget);
    expect(find.text('Alhamdulillah'), findsOneWidget);
    expect(find.text('AllahuAkbar'), findsOneWidget);
    expect(find.byKey(const Key('tesbih_search_toggle_button')), findsOneWidget);
    expect(find.byKey(const Key('tesbih_search_field')), findsNothing);

    // Tap search icon in history stats row to open search box
    await tester.tap(find.byKey(const Key('tesbih_search_toggle_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tesbih_search_field')), findsOneWidget);
    expect(find.byKey(const Key('tesbih_search_toggle_button')), findsNothing);

    // Search by title
    await tester.enterText(find.byKey(const Key('tesbih_search_field')), 'Alhamd');
    await tester.pumpAndSettle();

    expect(find.text('SubhanAllah'), findsNothing);
    expect(find.text('Alhamdulillah'), findsOneWidget);
    expect(find.text('AllahuAkbar'), findsNothing);

    // Search by notes
    await tester.enterText(find.byKey(const Key('tesbih_search_field')), 'greatest');
    await tester.pumpAndSettle();

    expect(find.text('SubhanAllah'), findsNothing);
    expect(find.text('Alhamdulillah'), findsNothing);
    expect(find.text('AllahuAkbar'), findsOneWidget);

    // Search with no matching results
    await tester.enterText(find.byKey(const Key('tesbih_search_field')), 'nonexistent');
    await tester.pumpAndSettle();

    expect(find.text('No matching items found.'), findsOneWidget);

    // Close search box to restore compact history row
    await tester.tap(find.byKey(const Key('tesbih_search_close_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tesbih_search_field')), findsNothing);
    expect(find.byKey(const Key('tesbih_search_toggle_button')), findsOneWidget);
    expect(find.text('SubhanAllah'), findsOneWidget);
    expect(find.text('Alhamdulillah'), findsOneWidget);
    expect(find.text('AllahuAkbar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('groups are listed together with beads in the main list and can be opened or deleted', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(id: '1', title: 'SubhanAllah', count: 33),
      _item(id: '2', title: 'Morning Adhkar 1', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Daily Adhkar Group', notes: 'Daily routine'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    // Both group and ungrouped bead are listed together
    expect(find.text('Daily Adhkar Group'), findsOneWidget);
    expect(find.text('SubhanAllah'), findsOneWidget);
    expect(find.textContaining('1 • Daily routine'), findsOneWidget);

    // Tapping the group navigates to GroupScreen
    await tester.tap(find.text('Daily Adhkar Group'));
    await tester.pumpAndSettle();

    expect(find.byType(GroupScreen), findsOneWidget);

    // Pop back to home screen
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Daily Adhkar Group'), findsOneWidget);

    // Delete group via its popup menu
    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Daily Adhkar Group'), findsNothing);
    expect(find.text('"Daily Adhkar Group" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    // Undo restore
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Daily Adhkar Group'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('tapping back navigation button cancels search bar', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item(id: '1', title: 'SubhanAllah'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const TesbihHomeScreen());

    expect(find.byKey(const Key('tesbih_search_toggle_button')), findsOneWidget);
    expect(find.byKey(const Key('tesbih_search_field')), findsNothing);

    // Open search
    await tester.tap(find.byKey(const Key('tesbih_search_toggle_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tesbih_search_field')), findsOneWidget);

    // Type a query
    await tester.enterText(find.byKey(const Key('tesbih_search_field')), 'xyz');
    await tester.pumpAndSettle();

    // Trigger back navigation
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    // Search bar should be closed and history stats restored
    expect(find.byKey(const Key('tesbih_search_field')), findsNothing);
    expect(find.byKey(const Key('tesbih_search_toggle_button')), findsOneWidget);
    expect(find.text('SubhanAllah'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}



