import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/screens/group_screen.dart';
import 'package:prayer_assistant/src/tesbihat/screens/item_form_screen.dart';

import '../helpers/test_harness.dart';

Item _item(String id, {List<String> groupIds = const []}) {
  return Item(
    id: id,
    title: 'Bead $id',
    count: 33,
    check: 11,
    setCount: 0,
    vibrationIntensity: 50,
    groupIds: groupIds,
  );
}

Future<void> _dragHandle(
  WidgetTester tester, {
  required int handleIndex,
  required double dy,
}) async {
  final handle = find.byIcon(Icons.drag_indicator).at(handleIndex);
  final gesture = await tester.startGesture(tester.getCenter(handle));
  await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
  const steps = 6;
  for (var i = 0; i < steps; i++) {
    await gesture.moveBy(Offset(0, dy / steps));
    await tester.pump(const Duration(milliseconds: 60));
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

/// The vertical distance between two adjacent member rows.
double _rowExtent(WidgetTester tester) {
  final handles = find.byIcon(Icons.drag_indicator);
  return tester.getCenter(handles.at(1)).dy - tester.getCenter(handles.at(0)).dy;
}

void main() {
  testWidgets('shows the members of the group', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
      _item('b', groupIds: ['g1', 'g2']),
      _item('c'),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
      const ItemGroup(id: 'g2', title: 'Night Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    expect(find.text('Morning Adhkar'), findsOneWidget);
    expect(find.text('Bead a'), findsOneWidget);
    expect(find.text('Bead b'), findsOneWidget);
    expect(find.text('Bead c'), findsNothing);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('bulk delete removes the selected members', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
      _item('b', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(find.byKey(const Key('select_members_button')));
    await tester.pumpAndSettle();
    expect(find.text('0 selected'), findsOneWidget);

    await tester.tap(find.text('Bead a'));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byKey(const Key('bulk_delete_members_button')));
    await tester.pumpAndSettle();
    expect(find.text('Delete 1 selected items?'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsNothing);
    expect(find.text('Bead b'), findsOneWidget);
    expect(harness.itemRepository.loadItems().map((i) => i.id), ['b']);
    expect(find.text('1 deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsOneWidget);
    expect(find.text('Bead b'), findsOneWidget);
    expect(harness.itemRepository.loadItems().map((i) => i.id), ['a', 'b']);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dragging a bead reorders it inside the group', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
      _item('b', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    expect(
      harness.itemRepository.loadItems().map((i) => i.id),
      ['a', 'b'],
    );

    final handle = find.byIcon(Icons.drag_indicator).first;
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      harness.itemRepository.loadItems().map((i) => i.id),
      ['b', 'a'],
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dragging with three members moves only the dragged bead', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
      _item('b', groupIds: ['g1']),
      _item('c', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await _dragHandle(tester, handleIndex: 0, dy: _rowExtent(tester));
    expect(
      harness.itemRepository.loadItems().map((i) => i.id),
      ['b', 'a', 'c'],
    );

    await _dragHandle(tester, handleIndex: 2, dy: -_rowExtent(tester) * 2.5);
    expect(
      harness.itemRepository.loadItems().map((i) => i.id),
      ['c', 'b', 'a'],
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('deleting a member offers undo', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsNothing);
    expect(find.text('"Bead a" deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsOneWidget);
    expect(harness.itemRepository.loadItems(), hasLength(1));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('back cancels member selection instead of leaving the group', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(find.byKey(const Key('select_members_button')));
    await tester.pumpAndSettle();
    expect(find.text('0 selected'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('0 selected'), findsNothing);
    expect(find.byKey(const Key('select_members_button')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('select all toggles back to deselect all', (tester) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
      _item('b', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(find.byKey(const Key('select_members_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('select_all_members_button')));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    expect(find.byIcon(Icons.deselect), findsOneWidget);

    await tester.tap(find.byKey(const Key('select_all_members_button')));
    await tester.pumpAndSettle();
    expect(find.text('0 selected'), findsOneWidget);
    expect(find.byIcon(Icons.select_all), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('shows the empty hint when the group has no members', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item('a')]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Empty Group'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    expect(find.text('No beads in this group yet.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('adds existing beads to the group from the bottom sheet', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([_item('a')]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    expect(find.text('Bead a'), findsNothing);

    await tester.tap(find.byKey(const Key('add_bead_fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add_existing_beads_option')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bead a'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add_beads_confirm')));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsOneWidget);
    expect(
      harness.itemRepository.loadItems().single.groupIds,
      contains('g1'),
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('creates a new bead inside the group from the FAB', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory();
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(find.byKey(const Key('add_bead_fab')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('create_bead_in_group_option')));
    await tester.pumpAndSettle();

    expect(find.byType(ItemFormScreen), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('removes a bead from the group via its popup menu', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(
      find.byWidgetPredicate((widget) => widget is PopupMenuButton).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from group'));
    await tester.pumpAndSettle();

    expect(find.text('Bead a'), findsNothing);
    expect(
      harness.itemRepository.loadItems().single.groupIds,
      isEmpty,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('deleting the group confirms and strips memberships', (
    tester,
  ) async {
    final harness = TestHarness.create();
    harness.itemRepository = ItemRepository.memory([
      _item('a', groupIds: ['g1']),
    ]);
    harness.itemRepository.saveGroups([
      const ItemGroup(id: 'g1', title: 'Morning Adhkar'),
    ]);
    await harness.initialize();

    await pumpWithHarness(tester, harness, const GroupScreen(groupId: 'g1'));

    await tester.tap(find.byKey(const Key('delete_group_button')));
    await tester.pumpAndSettle();
    expect(
      find.text('Delete this group? Its beads are kept.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(harness.itemRepository.loadGroups(), isEmpty);
    expect(harness.itemRepository.loadItems().single.groupIds, isEmpty);

    await tester.pumpWidget(const SizedBox());
  });
}