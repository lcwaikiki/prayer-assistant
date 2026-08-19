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