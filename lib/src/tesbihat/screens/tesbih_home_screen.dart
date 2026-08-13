import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../state/items_notifier.dart';
import 'execution_screen.dart';
import 'item_form_screen.dart';

enum _ItemAction { edit, delete }

class TesbihHomeScreen extends ConsumerWidget {
  const TesbihHomeScreen({super.key});

  void _deleteWithUndo(
    BuildContext context,
    WidgetRef ref,
    Item item, {
    required int index,
  }) {
    final l10n = context.tesbihatL10n;
    final notifier = ref.read(itemsNotifierProvider.notifier);
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

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Item item,
    int index,
    _ItemAction action,
  ) async {
    switch (action) {
      case _ItemAction.edit:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ItemFormScreen(itemToEdit: item)),
        );
        break;
      case _ItemAction.delete:
        _deleteWithUndo(context, ref, item, index: index);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.tesbihatL10n;
    final items = ref.watch(itemsNotifierProvider);

    return Scaffold(
      body: items.isEmpty
          ? Center(child: Text(l10n.noMilestones))
          : ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                ref
                    .read(itemsNotifierProvider.notifier)
                    .reorderItems(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  key: ValueKey(item.id),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    title: Text(item.title),
                    subtitle: Text(
                      '${l10n.count}: ${item.count} | ${l10n.check}: ${item.check} | ${l10n.set}: ${item.setCount}\n'
                      '${l10n.progress}: ${item.currentProgress} / ${item.count}',
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<_ItemAction>(
                          onSelected: (action) =>
                              _handleAction(context, ref, item, index, action),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: _ItemAction.edit,
                              child: ListTile(
                                dense: true,
                                leading: const Icon(Icons.edit),
                                title: Text(l10n.edit),
                              ),
                            ),
                            PopupMenuItem(
                              value: _ItemAction.delete,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ItemFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
