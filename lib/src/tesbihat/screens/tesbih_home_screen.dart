import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/daily_item_stat.dart';
import '../models/item.dart';
import '../state/items_notifier.dart';
import 'execution_screen.dart';
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

    return Scaffold(
      body: items.isEmpty
          ? Center(child: Text(l10n.noMilestones))
          : Column(
              children: [
                _StatsCard(
                  stats: _aggregateStats(
                    ref.watch(itemsNotifierProvider.notifier).dailyStats,
                    DateTime.now(),
                  ),
                ),
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 6),
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
                                onSelected: (action) => _handleAction(
                                  context,
                                  ref,
                                  item,
                                  index,
                                  action,
                                ),
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
