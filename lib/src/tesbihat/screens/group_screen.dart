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

enum _MemberAction { edit, remove, delete }

class GroupScreen extends ConsumerWidget {
  const GroupScreen({super.key, required this.groupId});

  final String groupId;

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
    ref.read(groupsNotifierProvider.notifier).deleteGroup(groupId);
    ref.read(itemsNotifierProvider.notifier).removeGroupFromItems(groupId);
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _addBeads(BuildContext context, WidgetRef ref) async {
    final items = ref.read(itemsNotifierProvider);
    final candidates = items
        .where((item) => !item.groupIds.contains(groupId))
        .toList(growable: false);
    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tesbihatL10n.noMilestones)),
      );
      return;
    }
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      builder: (context) => _AddBeadsSheet(items: candidates),
    );
    if (selected == null || selected.isEmpty) {
      return;
    }
    ref
        .read(itemsNotifierProvider.notifier)
        .addItemsToGroup(selected.toList(growable: false), groupId);
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
      case _MemberAction.remove:
        ref.read(itemsNotifierProvider.notifier).removeItemFromGroup(
              item.id,
              groupId,
            );
        break;
      case _MemberAction.delete:
        ref.read(itemsNotifierProvider.notifier).deleteItem(item.id);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.tesbihatL10n;
    final groups = ref.watch(groupsNotifierProvider);
    ItemGroup? group;
    for (final candidate in groups) {
      if (candidate.id == groupId) {
        group = candidate;
        break;
      }
    }
    final items = ref.watch(itemsNotifierProvider);
    final members = items
        .where((item) => item.groupIds.contains(groupId))
        .toList(growable: false);

    if (group == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(group.title),
        actions: [
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
      body: members.isEmpty
          ? Center(child: Text(l10n.noBeadsInGroup))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 6),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final item = members[index];
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: item.reminderEnabled
                        ? Icon(
                            Icons.notifications_active,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    title: Text(item.title),
                    subtitle: Text(
                      '${l10n.count}: ${item.count} | ${l10n.check}: ${item.check} | ${l10n.set}: ${item.setCount}\n'
                      '${l10n.progress}: ${item.currentProgress} / ${item.count}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<_MemberAction>(
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ExecutionScreen(itemId: item.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_bead_fab'),
        onPressed: () => showModalBottomSheet<void>(
          context: context,
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
                          initialGroupIds: [groupId],
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