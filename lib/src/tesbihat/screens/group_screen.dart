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
  const GroupScreen({
    super.key,
    required this.groupId,
    this.readOnly = false,
  });

  final String groupId;
  final bool readOnly;

  @override
  ConsumerState<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends ConsumerState<GroupScreen> {
  late bool _readOnly = widget.readOnly;
  bool _selecting = false;
  final Set<String> _selected = <String>{};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    final q = _searchQuery.trim().toLowerCase();
    final isSearching = q.isNotEmpty;
    final filteredMembers = !isSearching
        ? members
        : members
            .where((item) =>
                item.title.toLowerCase().contains(q) ||
                item.notes.toLowerCase().contains(q))
            .toList(growable: false);

    return PopScope(
      canPop: !_selecting && !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (_selecting) {
            _cancelSelection();
          } else if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          }
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: _isSearching
            ? IconButton(
                key: const Key('close_group_search_button'),
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                }),
              )
            : _selecting
                ? IconButton(
                    key: const Key('cancel_member_selection_button'),
                    tooltip: l10n.cancel,
                    icon: const Icon(Icons.close),
                    onPressed: _cancelSelection,
                  )
                : null,
        title: _isSearching
            ? TextField(
                key: const Key('group_search_field'),
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '${l10n.search}...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              )
            : _selecting
                ? Text(l10n.selectedCount(_selected.length))
                : Text(group.title),
        actions: _isSearching
            ? [
                if (_searchQuery.isNotEmpty)
                  IconButton(
                    key: const Key('clear_group_search_button'),
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  ),
              ]
            : _selecting
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
                : _readOnly
                    ? [
                        IconButton(
                          key: const Key('group_search_button'),
                          tooltip: l10n.search,
                          icon: const Icon(Icons.search),
                          onPressed: () => setState(() => _isSearching = true),
                        ),
                        IconButton(
                          key: const Key('edit_group_screen_button'),
                          tooltip: l10n.edit,
                          icon: const Icon(Icons.edit),
                          onPressed: () => setState(() => _readOnly = false),
                        ),
                      ]
                    : [
                        IconButton(
                          key: const Key('group_search_button'),
                          tooltip: l10n.search,
                          icon: const Icon(Icons.search),
                          onPressed: () => setState(() => _isSearching = true),
                        ),
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
          if (group.notes.trim().isNotEmpty && !isSearching)
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
                : filteredMembers.isEmpty
                    ? Center(child: Text(l10n.noResults))
                    : isSearching
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 6),
                            itemCount: filteredMembers.length,
                            itemBuilder: (context, index) {
                              final item = filteredMembers[index];
                              return _GroupMemberCard(
                                key: ValueKey(item.id),
                                item: item,
                                selecting: _selecting,
                                selected: _selected.contains(item.id),
                                readOnly: _readOnly,
                                onToggleSelect: () => setState(() {
                                  if (!_selected.remove(item.id)) {
                                    _selected.add(item.id);
                                  }
                                }),
                                onTap: () {
                                  if (_selecting) {
                                    setState(() {
                                      if (!_selected.remove(item.id)) {
                                        _selected.add(item.id);
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => ExecutionScreen(
                                          itemId: item.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onAction: (action) => _handleMemberAction(
                                  context,
                                  ref,
                                  item,
                                  action,
                                ),
                              );
                            },
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.only(bottom: 6),
                            buildDefaultDragHandles: false,
                            itemCount: members.length,
                            onReorderItem: (oldIndex, newIndex) {
                              if (_selecting || _readOnly) {
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
                              return _GroupMemberCard(
                                key: ValueKey(item.id),
                                item: item,
                                selecting: _selecting,
                                selected: _selected.contains(item.id),
                                readOnly: _readOnly,
                                dragHandleIndex:
                                    (_selecting || _readOnly) ? null : index,
                                onToggleSelect: () => setState(() {
                                  if (!_selected.remove(item.id)) {
                                    _selected.add(item.id);
                                  }
                                }),
                                onTap: () {
                                  if (_selecting) {
                                    setState(() {
                                      if (!_selected.remove(item.id)) {
                                        _selected.add(item.id);
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => ExecutionScreen(
                                          itemId: item.id,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                onAction: (action) => _handleMemberAction(
                                  context,
                                  ref,
                                  item,
                                  action,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: (_selecting || _readOnly)
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

class _GroupMemberCard extends StatelessWidget {
  const _GroupMemberCard({
    super.key,
    required this.item,
    required this.selecting,
    required this.selected,
    required this.readOnly,
    required this.onToggleSelect,
    required this.onTap,
    required this.onAction,
    this.dragHandleIndex,
  });

  final Item item;
  final bool selecting;
  final bool selected;
  final bool readOnly;
  final VoidCallback onToggleSelect;
  final VoidCallback onTap;
  final ValueChanged<_MemberAction> onAction;
  final int? dragHandleIndex;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final theme = Theme.of(context);
    final progressFraction = item.count > 0
        ? (item.currentProgress / item.count).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: selecting
            ? Checkbox(value: selected, onChanged: (_) => onToggleSelect())
            : SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progressFraction,
                      strokeWidth: 3,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                    Icon(
                      Icons.touch_app_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    if (item.reminderEnabled)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (item.soundId != null)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.volume_up,
                            key: Key('item_sound_badge_icon'),
                            size: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${l10n.count}: ${item.count} | ${l10n.check}: ${item.check} | ${l10n.set}: ${item.setCount}\n'
          '${l10n.progress}: ${item.currentProgress} / ${item.count}',
        ),
        isThreeLine: true,
        trailing: (selecting || readOnly)
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<_MemberAction>(
                    onSelected: onAction,
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
                  if (dragHandleIndex != null)
                    ReorderableDelayedDragStartListener(
                      index: dragHandleIndex!,
                      child: const Icon(Icons.drag_indicator),
                    ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}