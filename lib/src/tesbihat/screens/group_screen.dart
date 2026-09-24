import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import 'execution_screen.dart';
import 'group_form_screen.dart';
import 'item_form_screen.dart';

enum _MemberAction { edit, duplicate, remove, delete }

class GroupScreen extends ConsumerStatefulWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  bool _selecting = false;
  final Set<String> _selected = <String>{};

  void _cancelSelection() {
    setState(() {
      _selecting = false;
      _selected.clear();
    });
  }

  Future<void> _bulkDeleteMembers(
    BuildContext context,
    List<Item> members,
  ) async {
    final l10n = context.tesbihatL10n;
    if (_selected.isEmpty) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteSelectedConfirm(_selected.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    final allItems = ref.read(itemsNotifierProvider);
    final removed = <({Item item, int index})>[
      for (final member in members)
        if (_selected.contains(member.id))
          (
            item: member,
            index: allItems.indexWhere((item) => item.id == member.id),
          ),
    ];
    final count = removed.length;
    ref.read(itemsNotifierProvider.notifier).deleteItems(
          [for (final entry in removed) entry.item.id],
        );
    _cancelSelection();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(child: Text(l10n.deletedSelected(count))),
            TextButton(
              onPressed: () {
                // Ascending order keeps every original index valid as the
                // earlier items are re-inserted first.
                final ordered = [...removed]
                  ..sort((a, b) => a.index.compareTo(b.index));
                for (final entry in ordered) {
                  ref
                      .read(itemsNotifierProvider.notifier)
                      .restoreItem(entry.item, index: entry.index);
                }
                messenger.hideCurrentSnackBar();
              },
              child: Text(l10n.undo),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMemberWithUndo(BuildContext context, Item item) {
    final l10n = context.tesbihatL10n;
    final notifier = ref.read(itemsNotifierProvider.notifier);
    final index = ref
        .read(itemsNotifierProvider)
        .indexWhere((existing) => existing.id == item.id);
    notifier.deleteItem(item.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(child: Text(l10n.deletedItem(item.title))),
            TextButton(
              onPressed: () {
                notifier.restoreItem(item, index: index);
                messenger.hideCurrentSnackBar();
              },
              child: Text(l10n.undo),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGroup(BuildContext context, WidgetRef ref) async {
    final l10n = context.tesbihatL10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteGroup),
        content: Text(l10n.deleteGroupConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    ref.read(groupsNotifierProvider.notifier).deleteGroup(widget.groupId);
    ref
        .read(itemsNotifierProvider.notifier)
        .removeGroupFromItems(widget.groupId);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _addBeads(BuildContext context, WidgetRef ref) async {
    final items = ref.read(itemsNotifierProvider);
    final candidates = items
        .where((item) => !item.groupIds.contains(widget.groupId))
        .toList(growable: false);
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tesbihatL10n.noMilestones)),
      );
      return;
    }
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(child: _AddBeadsSheet(items: candidates)),
    );

    if (selected == null || selected.isEmpty) {
      return;
    }
    ref
        .read(itemsNotifierProvider.notifier)
        .addItemsToGroup(selected.toList(growable: false), widget.groupId);
  }

  Future<void> _handleMemberAction(
    BuildContext context,
    WidgetRef ref,
    Item item,
    _MemberAction action,
  ) async {
    switch (action) {
      case _MemberAction.edit:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemFormScreen(itemToEdit: item)),
        );
        break;
      case _MemberAction.duplicate:
        ref.read(itemsNotifierProvider.notifier).duplicateItem(item);
        break;
      case _MemberAction.remove:
        ref.read(itemsNotifierProvider.notifier).removeItemFromGroup(
              item.id,
              widget.groupId,
            );
        break;
      case _MemberAction.delete:
        _deleteMemberWithUndo(context, item);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final groups = ref.watch(groupsNotifierProvider);
    ItemGroup? group;
    for (final candidate in groups) {
      if (candidate.id == widget.groupId) {
        group = candidate;
        break;
      }
    }
    final items = ref.watch(itemsNotifierProvider);
    final members = items
        .where((item) => item.groupIds.contains(widget.groupId))
        .toList(growable: false);

    if (group == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox());
    }

    return PopScope(
      canPop: !_selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selecting) {
          _cancelSelection();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: _selecting
            ? IconButton(
                key: const Key('cancel_member_selection_button'),
                tooltip: l10n.cancel,
                icon: const Icon(Icons.close),
                onPressed: _cancelSelection,
              )
            : null,
        title: _selecting
            ? Text(l10n.selectedCount(_selected.length))
            : Text(group.title),
        actions: _selecting
            ? [
                IconButton(
                  key: const Key('select_all_members_button'),
                  tooltip: l10n.selectAll,
                  icon: Icon(
                    members.isNotEmpty && _selected.length == members.length
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  onPressed: () => setState(() {
                    if (members.isNotEmpty &&
                        _selected.length == members.length) {
                      _selected.clear();
                    } else {
                      _selected
                        ..clear()
                        ..addAll(members.map((item) => item.id));
                    }
                  }),
                ),
                IconButton(
                  key: const Key('bulk_delete_members_button'),
                  tooltip: l10n.delete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _selected.isEmpty
                      ? null
                      : () => _bulkDeleteMembers(context, members),
                ),
              ]
            : [
                IconButton(
                  key: const Key('select_members_button'),
                  tooltip: l10n.select,
                  icon: const Icon(Icons.checklist),
                  onPressed: () => setState(() => _selecting = true),
                ),
                IconButton(
                  key: const Key('edit_group_button'),
                  tooltip: l10n.editGroup,
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupFormScreen(groupToEdit: group),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('delete_group_button'),
                  tooltip: l10n.deleteGroup,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _deleteGroup(context, ref),
                ),
              ],
      ),
      body: Column(
        children: [
          if (group.notes.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(group.notes),
                  ),
                ),
              ),
            ),
          Expanded(
            child: members.isEmpty
                ? Center(child: Text(l10n.noBeadsInGroup))
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 6),
                    buildDefaultDragHandles: false,
                    itemCount: members.length,
                    onReorderItem: (oldIndex, newIndex) {
                      if (_selecting) {
                        return;
                      }
                      final allItems = ref.read(itemsNotifierProvider);
                      final movedFullIndex = allItems.indexOf(members[oldIndex]);
                      final targetFullIndex = newIndex < members.length
                          ? allItems.indexOf(members[newIndex])
                          : allItems.length - 1;
                      ref
                          .read(itemsNotifierProvider.notifier)
                          .reorderItems(movedFullIndex, targetFullIndex);
                    },
                    itemBuilder: (context, index) {
                      final item = members[index];
                      return Card(
                        key: ValueKey(item.id),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: _selecting
                              ? Checkbox(
                                  value: _selected.contains(item.id),
                                  onChanged: (_) => setState(() {
                                    if (!_selected.remove(item.id)) {
                                      _selected.add(item.id);
                                    }
                                  }),
                                )
                              : item.reminderEnabled
                                  ? Icon(
                                      Icons.notifications_active,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                          title: Text(item.title),
                          subtitle: Text(
                            '${l10n.count}: ${item.count} | ${l10n.check}: ${item.check} | ${l10n.set}: ${item.setCount}\n'
                            '${l10n.progress}: ${item.currentProgress} / ${item.count}',
                          ),
                    isThreeLine: true,
                    trailing: _selecting
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<_MemberAction>(
                      onSelected: (action) =>
                          _handleMemberAction(context, ref, item, action),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: _MemberAction.edit,
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.edit),
                            title: Text(l10n.edit),
                          ),
                        ),
                        PopupMenuItem(
                          value: _MemberAction.duplicate,
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.copy_outlined),
                            title: Text(l10n.duplicate),
                          ),
                        ),
                        PopupMenuItem(
                          value: _MemberAction.remove,
                          child: ListTile(
                            dense: true,
                            leading: const Icon(Icons.playlist_remove),
                            title: Text(l10n.removeFromGroup),
                          ),
                        ),
                        PopupMenuItem(
                          value: _MemberAction.delete,
                          child: ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            title: Text(l10n.delete),
                          ),
                        ),
                      ],
                              ),
                              ReorderableDelayedDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_indicator),
                              ),
                            ],
                          ),
                    onTap: _selecting
                        ? () => setState(() {
                              if (!_selected.remove(item.id)) {
                                _selected.add(item.id);
                              }
                            })
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ExecutionScreen(itemId: item.id),
                              ),
                            );
                          },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _selecting
          ? null
          : FloatingActionButton.extended(
        key: const Key('add_bead_fab'),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          useSafeArea: true,
          builder: (context) => SafeArea(

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  key: const Key('add_existing_beads_option'),
                  leading: const Icon(Icons.playlist_add),
                  title: Text(l10n.addBeads),
                  onTap: () {
                    Navigator.pop(context);
                    _addBeads(context, ref);
                  },
                ),
                ListTile(
                  key: const Key('create_bead_in_group_option'),
                  leading: const Icon(Icons.add_circle_outline),
                  title: Text(l10n.newBead),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemFormScreen(
                          initialGroupIds: [widget.groupId],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: Text(l10n.addBead),
      ),
      ),
    );
  }
}

class _AddBeadsSheet extends StatefulWidget {
  const _AddBeadsSheet({required this.items});

  final List<Item> items;

  @override
  State<_AddBeadsSheet> createState() => _AddBeadsSheetState();
}

class _AddBeadsSheetState extends State<_AddBeadsSheet> {
  final Set<String> _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.addBeads, style: Theme.of(context).textTheme.titleMedium),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final item in widget.items)
                  CheckboxListTile(
                    key: Key('add_bead_${item.id}'),
                    title: Text(item.title),
                    value: _selected.contains(item.id),
                    onChanged: (checked) => setState(() {
                      if (checked == true) {
                        _selected.add(item.id);
                      } else {
                        _selected.remove(item.id);
                      }
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              key: const Key('add_beads_confirm'),
              onPressed: () => Navigator.pop(context, _selected),
              child: Text(l10n.addBeads),
            ),
          ),
        ],
      ),
    );
  }
}