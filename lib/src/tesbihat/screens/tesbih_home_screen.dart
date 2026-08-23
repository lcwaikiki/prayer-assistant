import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/daily_item_stat.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import 'execution_screen.dart';
import 'group_form_screen.dart';
import 'group_screen.dart';
import 'item_form_screen.dart';

enum _ItemAction { edit, delete }

String _dayKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

({int today, int last7Days, int total}) _aggregateStats(
  List<DailyItemStat> stats,
  DateTime now,
) {
  final todayKey = _dayKey(now);
  final weekStart = DateTime(now.year, now.month, now.day - 6);
  final weekStartKey = _dayKey(weekStart);
  var today = 0;
  var last7Days = 0;
  var total = 0;
  for (final stat in stats) {
    if (stat.dateKey == todayKey) {
      today += stat.count;
    }
    if (stat.dateKey.compareTo(weekStartKey) >= 0) {
      last7Days += stat.count;
    }
    total += stat.count;
  }
  return (today: today, last7Days: last7Days, total: total);
}

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
    final groups = ref.watch(groupsNotifierProvider);
    final ungrouped = items
        .where((item) => item.groupIds.isEmpty)
        .toList(growable: false);
    final isEmpty = groups.isEmpty && ungrouped.isEmpty;

    return Scaffold(
      body: isEmpty
          ? Center(child: Text(l10n.noMilestones))
          : Column(
              children: [
                _StatsCard(
                  stats: _aggregateStats(
                    ref.watch(itemsNotifierProvider.notifier).dailyStats,
                    DateTime.now(),
                  ),
                ),
                if (groups.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.groups,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _GroupCardList(groups: groups),
                ],
                if (ungrouped.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.milestones,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Expanded(
                  child: ungrouped.isEmpty
                      ? const SizedBox.shrink()
                      : ReorderableListView.builder(
                          padding: const EdgeInsets.only(bottom: 6),
                          itemCount: ungrouped.length,
                          onReorder: (oldIndex, newIndex) {
                            // Reordering happens inside the filtered ungrouped
                            // list; map back onto the full items list (which
                            // also holds grouped beads).
                            final movedFullIndex = items.indexOf(
                              ungrouped[oldIndex],
                            );
                            final nextUngrouped = [...ungrouped];
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final moved = nextUngrouped.removeAt(oldIndex);
                            nextUngrouped.insert(newIndex, moved);
                            final fullIndex = items.indexOf(
                              nextUngrouped[newIndex],
                            );
                            ref
                                .read(itemsNotifierProvider.notifier)
                                .reorderItems(movedFullIndex, fullIndex);
                          },
                          itemBuilder: (context, index) {
                            final item = ungrouped[index];
                            return _UngroupedItemCard(
                              item: item,
                              index: index,
                              key: ValueKey(item.id),
                              onAction: (action) => _handleAction(
                                context,
                                ref,
                                item,
                                items.indexOf(item),
                                action,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenu(BuildContext context) {
    final l10n = context.tesbihatL10n;
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('new_bead_option'),
              leading: const Icon(Icons.add_circle_outline),
              title: Text(l10n.newBead),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ItemFormScreen()),
                );
              },
            ),
            ListTile(
              key: const Key('new_group_option'),
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l10n.newGroup),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GroupFormScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _UngroupedItemCard extends StatelessWidget {
  const _UngroupedItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.onAction,
  });

  final Item item;
  final int index;
  final ValueChanged<_ItemAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<_ItemAction>(
              onSelected: onAction,
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
                    leading: const Icon(Icons.delete, color: Colors.red),
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
  }
}

class _GroupCardList extends ConsumerWidget {
  const _GroupCardList({required this.groups});

  final List<ItemGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsNotifierProvider);
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: groups.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final group = groups[index];
          final memberCount = items
              .where((item) => item.groupIds.contains(group.id))
              .length;
          return Card(
            key: ValueKey(group.id),
            margin: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupScreen(groupId: group.id),
                ),
              ),
              child: SizedBox(
                width: 140,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            group.reminderEnabled
                                ? Icons.notifications_active
                                : Icons.folder_outlined,
                            size: 20,
                            color: group.reminderEnabled
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                          const Spacer(),
                          Text(
                            '$memberCount',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        group.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.stats});

  final ({int today, int last7Days, int total}) stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Text(
              l10n.statsTitle,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _StatTile(label: l10n.statsToday, value: stats.today),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.statsLast7Days,
                  value: stats.last7Days,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(label: l10n.statsTotal, value: stats.total),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
