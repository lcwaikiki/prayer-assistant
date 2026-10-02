import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/daily_item_stat.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import '../state/tesbih_selection.dart';
import 'execution_screen.dart';
import 'group_form_screen.dart';
import 'group_screen.dart';
import 'item_form_screen.dart';

enum _ItemAction { edit, duplicate, delete }
enum _GroupAction { edit, delete }

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

class TesbihHomeScreen extends ConsumerStatefulWidget {
  const TesbihHomeScreen({super.key});

  @override
  ConsumerState<TesbihHomeScreen> createState() => _TesbihHomeScreenState();
}

class _TesbihHomeScreenState extends ConsumerState<TesbihHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

  void _deleteGroupWithUndo(
    BuildContext context,
    WidgetRef ref,
    ItemGroup group, {
    required int index,
  }) {
    final l10n = context.tesbihatL10n;
    final notifier = ref.read(groupsNotifierProvider.notifier);
    notifier.deleteGroup(group.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(child: Text(l10n.deletedItem(group.title))),
            TextButton(
              onPressed: () {
                notifier.restoreGroup(group, index: index);
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
      case _ItemAction.duplicate:
        ref.read(itemsNotifierProvider.notifier).duplicateItem(item);
        break;
      case _ItemAction.delete:
        _deleteWithUndo(context, ref, item, index: index);
        break;
    }
  }

  Future<void> _handleGroupAction(
    BuildContext context,
    WidgetRef ref,
    ItemGroup group,
    int index,
    _GroupAction action,
  ) async {
    switch (action) {
      case _GroupAction.edit:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupFormScreen(groupToEdit: group),
          ),
        );
        break;
      case _GroupAction.delete:
        _deleteGroupWithUndo(context, ref, group, index: index);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final items = ref.watch(itemsNotifierProvider);
    final groups = ref.watch(groupsNotifierProvider);
    final selection = ref.watch(tesbihSelectionProvider);
    final selectionActive = selection.active;
    final ungrouped = items
        .where((item) => item.groupIds.isEmpty)
        .toList(growable: false);
    final isEmpty = groups.isEmpty && ungrouped.isEmpty;

    final q = _searchQuery.trim().toLowerCase();
    final isSearching = q.isNotEmpty;

    final filteredGroups = !isSearching
        ? groups
        : groups.where((g) {
            if (g.title.toLowerCase().contains(q) ||
                g.notes.toLowerCase().contains(q)) {
              return true;
            }
            return items
                .where((i) => i.groupIds.contains(g.id))
                .any((i) =>
                    i.title.toLowerCase().contains(q) ||
                    i.notes.toLowerCase().contains(q));
          }).toList(growable: false);

    final filteredUngrouped = !isSearching
        ? ungrouped
        : ungrouped
            .where((item) =>
                item.title.toLowerCase().contains(q) ||
                item.notes.toLowerCase().contains(q))
            .toList(growable: false);

    final totalCount = filteredGroups.length + filteredUngrouped.length;
    final noSearchResults = isSearching && totalCount == 0;

    return PopScope(
      canPop: !_isSearchOpen && !isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && (_isSearchOpen || isSearching)) {
          setState(() {
            _isSearchOpen = false;
            _searchQuery = '';
            _searchController.clear();
          });
        }
      },
      child: Scaffold(
        body: isEmpty
            ? Center(child: Text(l10n.noMilestones))
            : Column(
                children: [
                  if (_isSearchOpen || isSearching)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                      child: TextField(
                        key: const Key('tesbih_search_field'),
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          hintText: '${l10n.search}...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSearching)
                                IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                              IconButton(
                                key: const Key('tesbih_search_close_button'),
                                icon: const Icon(Icons.close, size: 18),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _isSearchOpen = false;
                                  });
                                },
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                    )
                  else
                    _StatsCard(
                      stats: _aggregateStats(
                        ref.watch(itemsNotifierProvider.notifier).dailyStats,
                        DateTime.now(),
                      ),
                      onOpenSearch: () {
                        setState(() => _isSearchOpen = true);
                      },
                    ),
                  if (noSearchResults)
                    Expanded(
                      child: Center(
                        child: Text(l10n.noResults),
                      ),
                    )
                  else
                    Expanded(
                      child: isSearching
                          ? ListView.builder(
                              padding: const EdgeInsets.only(top: 4, bottom: 6),
                              itemCount: totalCount,
                              itemBuilder: (context, index) {
                                if (index < filteredGroups.length) {
                                  final group = filteredGroups[index];
                                  final memberCount = items
                                      .where((i) => i.groupIds.contains(group.id))
                                      .length;
                                  return _GroupItemCard(
                                    key: ValueKey('group_${group.id}'),
                                    group: group,
                                    memberCount: memberCount,
                                    index: index,
                                    selectionActive: selectionActive,
                                    selected: selection.contains(group.id),
                                    onToggle: () => ref
                                        .read(tesbihSelectionProvider.notifier)
                                        .toggle(group.id),
                                    onAction: (action) => _handleGroupAction(
                                      context,
                                      ref,
                                      group,
                                      groups.indexOf(group),
                                      action,
                                    ),
                                  );
                                }
                                final itemIndex = index - filteredGroups.length;
                                final item = filteredUngrouped[itemIndex];
                                return _UngroupedItemCard(
                                  key: ValueKey('item_${item.id}'),
                                  item: item,
                                  index: index,
                                  selectionActive: selectionActive,
                                  selected: selection.contains(item.id),
                                  onToggle: () => ref
                                      .read(tesbihSelectionProvider.notifier)
                                      .toggle(item.id),
                                  onAction: (action) => _handleAction(
                                    context,
                                    ref,
                                    item,
                                    items.indexOf(item),
                                    action,
                                  ),
                                );
                              },
                            )
                          : ReorderableListView.builder(
                              padding: const EdgeInsets.only(top: 4, bottom: 6),
                              itemCount: totalCount,
                              onReorderItem: (oldIndex, newIndex) {
                                if (oldIndex < filteredGroups.length &&
                                    newIndex <= filteredGroups.length) {
                                  final targetIndex = newIndex < filteredGroups.length
                                      ? newIndex
                                      : filteredGroups.length - 1;
                                  ref
                                      .read(groupsNotifierProvider.notifier)
                                      .reorderGroups(oldIndex, targetIndex);
                                } else if (oldIndex >= filteredGroups.length &&
                                    newIndex >= filteredGroups.length) {
                                  final oldItemIndex =
                                      oldIndex - filteredGroups.length;
                                  final newItemIndex =
                                      newIndex - filteredGroups.length;
                                  final movedFullIndex = items.indexOf(
                                    ungrouped[oldItemIndex],
                                  );
                                  final targetFullIndex =
                                      newItemIndex < ungrouped.length
                                          ? items.indexOf(ungrouped[newItemIndex])
                                          : items.length - 1;
                                  ref
                                      .read(itemsNotifierProvider.notifier)
                                      .reorderItems(
                                        movedFullIndex,
                                        targetFullIndex,
                                      );
                                }
                              },
                              itemBuilder: (context, index) {
                                if (index < filteredGroups.length) {
                                  final group = filteredGroups[index];
                                  final memberCount = items
                                      .where((i) => i.groupIds.contains(group.id))
                                      .length;
                                  return _GroupItemCard(
                                    key: ValueKey('group_${group.id}'),
                                    group: group,
                                    memberCount: memberCount,
                                    index: index,
                                    selectionActive: selectionActive,
                                    selected: selection.contains(group.id),
                                    onToggle: () => ref
                                        .read(tesbihSelectionProvider.notifier)
                                        .toggle(group.id),
                                    onAction: (action) => _handleGroupAction(
                                      context,
                                      ref,
                                      group,
                                      groups.indexOf(group),
                                      action,
                                    ),
                                  );
                                }
                                final itemIndex = index - filteredGroups.length;
                                final item = filteredUngrouped[itemIndex];
                                return _UngroupedItemCard(
                                  key: ValueKey('item_${item.id}'),
                                  item: item,
                                  index: index,
                                  selectionActive: selectionActive,
                                  selected: selection.contains(item.id),
                                  onToggle: () => ref
                                      .read(tesbihSelectionProvider.notifier)
                                      .toggle(item.id),
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
        floatingActionButton: selectionActive
            ? null
            : FloatingActionButton(
                onPressed: () => _showAddMenu(context),
                child: const Icon(Icons.add),
              ),
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

class _GroupItemCard extends StatelessWidget {
  const _GroupItemCard({
    super.key,
    required this.group,
    required this.memberCount,
    required this.index,
    required this.selectionActive,
    required this.selected,
    required this.onToggle,
    required this.onAction,
  });

  final ItemGroup group;
  final int memberCount;
  final int index;
  final bool selectionActive;
  final bool selected;
  final VoidCallback onToggle;
  final ValueChanged<_GroupAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: selectionActive
            ? Checkbox(value: selected, onChanged: (_) => onToggle())
            : Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.folder_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    if (group.reminderEnabled)
                      Positioned(
                        right: 2,
                        top: 2,
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
                  ],
                ),
              ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                group.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.groups,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          group.notes.isNotEmpty
              ? '${l10n.groupMembers}: $memberCount • ${group.notes}'
              : '${l10n.groupMembers}: $memberCount',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: selectionActive
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<_GroupAction>(
                    onSelected: onAction,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: _GroupAction.edit,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.edit),
                          title: Text(l10n.edit),
                        ),
                      ),
                      PopupMenuItem(
                        value: _GroupAction.delete,
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
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
        onTap: selectionActive
            ? onToggle
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GroupScreen(groupId: group.id),
                  ),
                );
              },
      ),
    );
  }
}

class _UngroupedItemCard extends StatelessWidget {
  const _UngroupedItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.selectionActive,
    required this.selected,
    required this.onToggle,
    required this.onAction,
  });

  final Item item;
  final int index;
  final bool selectionActive;
  final bool selected;
  final VoidCallback onToggle;
  final ValueChanged<_ItemAction> onAction;

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
        leading: selectionActive
            ? Checkbox(value: selected, onChanged: (_) => onToggle())
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
        trailing: selectionActive
            ? null
            : Row(
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
                        value: _ItemAction.duplicate,
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.copy_outlined),
                          title: Text(l10n.duplicate),
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
        onTap: selectionActive
            ? onToggle
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ExecutionScreen(itemId: item.id),
                  ),
                );
              },
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.stats,
    required this.onOpenSearch,
  });

  final ({int today, int last7Days, int total}) stats;
  final VoidCallback onOpenSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.statsTitle,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 24,
              child: VerticalDivider(width: 14, thickness: 1),
            ),
            Expanded(
              child: _StatTile(label: l10n.statsToday, value: stats.today),
            ),
            Expanded(
              child: _StatTile(
                label: l10n.statsLast7Days,
                value: stats.last7Days,
              ),
            ),
            Expanded(
              child: _StatTile(label: l10n.statsTotal, value: stats.total),
            ),
            IconButton(
              key: const Key('tesbih_search_toggle_button'),
              icon: const Icon(Icons.search, size: 20),
              tooltip: l10n.search,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: onOpenSearch,
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

