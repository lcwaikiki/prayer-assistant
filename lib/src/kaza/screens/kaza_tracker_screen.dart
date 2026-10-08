import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../calendar/hijri_utils.dart';
import '../../l10n/l10n.dart';
import '../../l10n/prayer_names.dart';
import '../models/kaza_tracker.dart';
import '../widgets/kaza_calculator_dialog.dart';


class KazaTrackerScreen extends StatelessWidget {
  const KazaTrackerScreen({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PrayerAppController>();
    final tracker = controller.kazaTracker;
    final locale = Localizations.localeOf(context).toString();

    final prayers = [
      (context.l10n.prayerNameLabel('Imsak'), iconForPrayer('Imsak'), 'fajr'),
      (context.l10n.prayerNameLabel('Ogle'), iconForPrayer('Ogle'), 'dhuhr'),
      (context.l10n.prayerNameLabel('Ikindi'), iconForPrayer('Ikindi'), 'asr'),
      (context.l10n.prayerNameLabel('Aksam'), iconForPrayer('Aksam'), 'maghrib'),
      (context.l10n.prayerNameLabel('Yatsi'), iconForPrayer('Yatsi'), 'isha'),
      (context.l10n.kazaWitrLabel, iconForPrayer('Witr'), 'witr'),
    ];

    final estDate = tracker.estimatedCompletionDate();
    final estDateFormatted = estDate != null
        ? DateFormat.yMMMMd(locale).format(estDate)
        : null;

    final actions = [
      IconButton(
        tooltip: context.l10n.kazaCalculatorWizard,
        icon: const Icon(Icons.calculate_outlined),
        onPressed: () {
          showDialog<void>(
            context: context,
            builder: (_) => KazaCalculatorDialog(
              initialTracker: tracker,
              onSave: (updated) => controller.updateKazaTracker(updated),
            ),
          );
        },
      ),
      Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: FilledButton.tonalIcon(
          onPressed: () => controller.logFullDayKaza(),
          icon: const Icon(Icons.done_all, size: 16),
          label: Text(context.l10n.kazaBatchLogDay),
        ),
      ),
    ];

    return Scaffold(
      appBar: showAppBar
          ? AppBar(actions: actions)
          : PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions,
                ),
              ),
            ),

      body: SafeArea(
        child: ListView(
        padding: const EdgeInsets.all(12),

        children: [
          // Hero Summary Card
          Card(
            elevation: 0,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.kazaTotalRemaining,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${tracker.totalRemaining}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            context.l10n.completed,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.kazaCompletedProgress(
                              tracker.totalCompleted,
                              tracker.totalTarget,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: tracker.completionRatio,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          estDateFormatted != null
                              ? context.l10n.kazaEstimatedCompletion(estDateFormatted)
                              : context.l10n.kazaEstimatedCompletionFinished,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showEditPaceDialog(context, controller),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.l10n.kazaDailyPaceValue(tracker.dailyPace),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.edit_outlined,
                                size: 12,
                                color: theme.colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Grid of 6 Prayer Cards
          for (final item in prayers) ...[
            _KazaPrayerCard(
              name: item.$1,
              icon: item.$2,
              prayerKey: item.$3,
              target: tracker.targetFor(item.$3),
              completed: tracker.completedFor(item.$3),
              canDecrement:
                  controller.kazaCountOn(DateTime.now(), item.$3) > 0,
              onIncrement: () => controller.incrementKaza(item.$3),
              onDecrement: () => controller.decrementKaza(item.$3),
              onSetCompleted: (count) =>
                  controller.setKazaCompleted(item.$3, count),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          _KazaDailyLogSection(
            logs: controller.kazaDailyLogs,
            prayers: prayers,
          ),
        ],
        ),
      ),
    );
  }

  void _showEditPaceDialog(
    BuildContext context,
    PrayerAppController controller,
  ) {
    final paceController = TextEditingController(
      text: controller.kazaTracker.dailyPace.toString(),
    );
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.kazaSetPaceDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.l10n.kazaSetPaceDialogSubtitle,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: paceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newPace = int.tryParse(paceController.text.trim()) ?? 6;
              controller.updateKazaTracker(
                controller.kazaTracker.copyWith(dailyPace: newPace),
              );
              Navigator.of(ctx).pop();
            },
            child: Text(ctx.l10n.save),
          ),
        ],
      ),
    );
  }
}

class _KazaDailyLogSection extends StatelessWidget {
  const _KazaDailyLogSection({required this.logs, required this.prayers});

  final Map<String, Map<String, int>> logs;

  /// (name, icon, prayerKey) for each tracked prayer, in display order.
  final List<(String, IconData, String)> prayers;

  Map<String, String> get prayerNames => {
    for (final (name, _, key) in prayers) key: name,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateKeys = logs.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.kazaDailyLogTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.l10n.kazaDailyLogPickDate,
                icon: const Icon(Icons.edit_calendar_outlined, size: 20),
                onPressed: () => _pickDateAndEdit(context),
              ),
            ],
          ),
        ),
        if (dateKeys.isEmpty)
          Padding(
            padding: const EdgeInsets.all(4),
            child: Text(
              context.l10n.kazaDailyLogEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        if (dateKeys.isNotEmpty)
          Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              children: [
                _KazaLogHeaderRow(prayers: prayers),
                for (final dateKey in dateKeys) ...[
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  _KazaLogTableRow(
                    date: DateTime.parse(dateKey),
                    counts: logs[dateKey]!,
                    prayerKeys: [for (final (_, _, key) in prayers) key],
                    onTap: () => _showDayEditor(
                      context,
                      DateTime.parse(dateKey),
                      prayerNames,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickDateAndEdit(BuildContext context) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(today.year - 100),
      lastDate: today,
    );
    if (date == null || !context.mounted) return;
    _showDayEditor(context, date, prayerNames);
  }
}

void _showDayEditor(
  BuildContext context,
  DateTime date,
  Map<String, String> prayerNames,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _KazaDayEditorSheet(date: date, prayerNames: prayerNames),
  );
}

/// Edits the qadaa counts logged on a single day, starting at [date].
class _KazaDayEditorSheet extends StatefulWidget {
  const _KazaDayEditorSheet({required this.date, required this.prayerNames});

  final DateTime date;
  final Map<String, String> prayerNames;

  @override
  State<_KazaDayEditorSheet> createState() => _KazaDayEditorSheetState();
}

class _KazaDayEditorSheetState extends State<_KazaDayEditorSheet> {
  late DateTime _date = DateUtils.dateOnly(widget.date);

  void _shiftDay(int days) {
    setState(() => _date = DateUtils.addDaysToDate(_date, days));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PrayerAppController>();
    final locale = Localizations.localeOf(context);
    final isToday = DateUtils.isSameDay(_date, DateTime.now());
    final counts = {
      for (final key in widget.prayerNames.keys)
        key: controller.kazaCountOn(_date, key),
    };

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: context.l10n.kazaPreviousDay,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftDay(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        DateFormat.yMMMMEEEEd(locale.toString()).format(_date),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatHijriDate(
                          _date,
                          locale.languageCode,
                          offset: controller.hijriDateOffset,
                        ),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.kazaNextDay,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isToday ? null : () => _shiftDay(1),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _KazaDayCountRow(
              name: context.l10n.kazaAllPrayers,
              bold: true,
              canDecrement: counts.values.any((count) => count > 0),
              onDecrement: () => controller.adjustKazaDay(_date, -1),
              onIncrement: () => controller.adjustKazaDay(_date, 1),
            ),
            const Divider(),
            for (final MapEntry(key: prayerKey, value: name)
                in widget.prayerNames.entries)
              _KazaDayCountRow(
                name: name,
                count: counts[prayerKey],
                canDecrement: counts[prayerKey]! > 0,
                onDecrement: () => controller.setKazaDayCount(
                  _date,
                  prayerKey,
                  counts[prayerKey]! - 1,
                ),
                onIncrement: () => controller.setKazaDayCount(
                  _date,
                  prayerKey,
                  counts[prayerKey]! + 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A label with -/+ buttons; [count] is left blank when null.
class _KazaDayCountRow extends StatelessWidget {
  const _KazaDayCountRow({
    required this.name,
    required this.canDecrement,
    required this.onDecrement,
    required this.onIncrement,
    this.count,
    this.bold = false,
  });

  final String name;
  final int? count;
  final bool bold;
  final bool canDecrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: canDecrement ? onDecrement : null,
        ),
        SizedBox(
          width: 36,
          child: Text(
            count?.toString() ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}

const double _kLogCountCellWidth = 30;
const double _kLogTotalCellWidth = 56;
const _kLogRowPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

/// Daily log table header: a prayer icon per column, then the total.
class _KazaLogHeaderRow extends StatelessWidget {
  const _KazaLogHeaderRow({required this.prayers});

  final List<(String, IconData, String)> prayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      padding: _kLogRowPadding,
      child: Row(
        children: [
          const Spacer(),
          for (final (name, icon, _) in prayers)
            SizedBox(
              width: _kLogCountCellWidth,
              child: Tooltip(
                message: name,
                child: Icon(icon, size: 18, color: theme.colorScheme.primary),
              ),
            ),
          SizedBox(
            width: _kLogTotalCellWidth,
            child: Text(
              'Σ',
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One day in the daily log table; tapping it opens the day editor.
class _KazaLogTableRow extends StatelessWidget {
  const _KazaLogTableRow({
    required this.date,
    required this.counts,
    required this.prayerKeys,
    required this.onTap,
  });

  final DateTime date;
  final Map<String, int> counts;
  final List<String> prayerKeys;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    final isThisYear = date.year == DateTime.now().year;
    final total = counts.values.fold(0, (sum, count) => sum + count);
    final rakat = counts.entries.fold(
      0,
      (sum, entry) =>
          sum +
          entry.value * KazaTracker.rakatPerPrayer[entry.key]!,
    );
    final muted = theme.colorScheme.outline;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: _kLogRowPadding,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday
                        ? context.l10n.today
                        : DateFormat.MMMd(locale).format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isToday ? theme.colorScheme.primary : null,
                    ),
                  ),
                  Text(
                    (isThisYear
                            ? DateFormat.EEEE(locale)
                            : DateFormat.E(locale).add_y())
                        .format(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            for (final key in prayerKeys)
              SizedBox(
                width: _kLogCountCellWidth,
                child: Text(
                  (counts[key] ?? 0) > 0 ? '${counts[key]}' : '–',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: (counts[key] ?? 0) > 0 ? null : muted,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            SizedBox(
              width: _kLogTotalCellWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$total',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    context.l10n.kazaRakatShort(rakat),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KazaPrayerCard extends StatelessWidget {
  const _KazaPrayerCard({
    required this.name,
    required this.icon,
    required this.prayerKey,
    required this.target,
    required this.completed,
    required this.canDecrement,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetCompleted,
  });

  final String name;
  final IconData icon;
  final String prayerKey;
  final int target;
  final int completed;

  /// Whether today has a logged prayer that the minus button can remove.
  final bool canDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final ValueChanged<int> onSetCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = (target - completed).clamp(0, 999999);
    final ratio = target == 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showManualEditCountDialog(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          context.l10n.kazaRemainingCount(remaining),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: ratio,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$completed / $target',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.remove_circle_outline, size: 20),
              onPressed: canDecrement ? onDecrement : null,
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: onIncrement,
            ),
          ],
        ),
      ),
    );
  }

  void _showManualEditCountDialog(BuildContext context) {
    final countController = TextEditingController(text: completed.toString());
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.kazaEditCompletedTitle(name)),
        content: TextField(
          controller: countController,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final newCount = int.tryParse(countController.text.trim()) ?? completed;
              onSetCompleted(newCount);
              Navigator.of(ctx).pop();
            },
            child: Text(ctx.l10n.save),
          ),
        ],
      ),
    );

  }
}
