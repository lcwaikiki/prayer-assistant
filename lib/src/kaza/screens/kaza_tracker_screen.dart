import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../calendar/hijri_utils.dart';
import '../../calendar/widgets/heatmap_month_calendar.dart';
import '../../l10n/l10n.dart';
import '../models/kaza_tracker.dart';
import '../widgets/kaza_calculator_dialog.dart';

/// (name, icon, prayerKey) for each tracked prayer, in display order.
typedef _KazaPrayer = (String, IconData, String);

List<_KazaPrayer> _kazaPrayers(BuildContext context) => [
  (context.l10n.prayerNameLabel('Imsak'), iconForPrayer('Imsak'), 'fajr'),
  (context.l10n.prayerNameLabel('Ogle'), iconForPrayer('Ogle'), 'dhuhr'),
  (context.l10n.prayerNameLabel('Ikindi'), iconForPrayer('Ikindi'), 'asr'),
  (context.l10n.prayerNameLabel('Aksam'), iconForPrayer('Aksam'), 'maghrib'),
  (context.l10n.prayerNameLabel('Yatsi'), iconForPrayer('Yatsi'), 'isha'),
  (context.l10n.kazaWitrLabel, iconForPrayer('Witr'), 'witr'),
];

int _rakatOf(Map<String, int> counts) => counts.entries.fold(
  0,
  (sum, entry) => sum + entry.value * KazaTracker.rakatPerPrayer[entry.key]!,
);

/// Qadaa screen: log today's prayers, see overall progress and the history.
class KazaTrackerScreen extends StatelessWidget {
  const KazaTrackerScreen({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PrayerAppController>();
    final prayers = _kazaPrayers(context);
    final today = DateUtils.dateOnly(DateTime.now());

    return Scaffold(
      appBar: showAppBar ? AppBar() : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _KazaTodayCard(date: today, prayers: prayers),
            const SizedBox(height: 12),
            _KazaProgressCard(tracker: controller.kazaTracker, prayers: prayers),
            const SizedBox(height: 16),
            _KazaDailyLogSection(
              logs: controller.kazaDailyLogs,
              prayers: prayers,
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's logging surface: goal ring, dates and the prayer tile grid.
class _KazaTodayCard extends StatelessWidget {
  const _KazaTodayCard({required this.date, required this.prayers});

  final DateTime date;
  final List<_KazaPrayer> prayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PrayerAppController>();
    final locale = Localizations.localeOf(context);
    final counts = {
      for (final (_, _, key) in prayers) key: controller.kazaCountOn(date, key),
    };
    final total = counts.values.fold(0, (sum, count) => sum + count);
    final pace = controller.kazaTracker.dailyPace;
    final hijri = formatHijriDate(
      date,
      locale.languageCode,
      offset: controller.hijriDateOffset,
    );

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _KazaGoalRing(total: total, goal: pace),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.today,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${DateFormat.MMMMEEEEd(locale.toString()).format(date)}'
                        ' · $hijri',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              total == 0
                                  ? context.l10n.kazaTapToLog
                                  : context.l10n.kazaRakatShort(
                                      _rakatOf(counts),
                                    ),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          _KazaPaceChip(pace: pace),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _KazaDayGrid(date: date, prayers: prayers),
          ],
        ),
      ),
    );
  }
}

/// Today's logged count inside a ring that fills toward the daily goal.
class _KazaGoalRing extends StatelessWidget {
  const _KazaGoalRing({required this.total, required this.goal});

  final int total;
  final int goal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = goal <= 0 ? 0.0 : (total / goal).clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: 64,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: ratio),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (_, value, _) => CircularProgressIndicator(
              value: value,
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$total',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  '/ $goal',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The daily goal; tapping it edits the pace.
class _KazaPaceChip extends StatelessWidget {
  const _KazaPaceChip({required this.pace});

  final int pace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showEditPaceDialog(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_outlined, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              context.l10n.kazaDailyPaceValue(pace),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPaceDialog(BuildContext context) {
    final controller = context.read<PrayerAppController>();
    final paceController = TextEditingController(text: '$pace');
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
              autofocus: true,
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
              final newPace = int.tryParse(paceController.text.trim()) ?? pace;
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

/// Six prayer tiles for [date] plus an "All prayers" -/+ row.
class _KazaDayGrid extends StatelessWidget {
  const _KazaDayGrid({required this.date, required this.prayers});

  final DateTime date;
  final List<_KazaPrayer> prayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PrayerAppController>();
    final counts = {
      for (final (_, _, key) in prayers) key: controller.kazaCountOn(date, key),
    };

    Widget tile(_KazaPrayer prayer) {
      final (name, icon, key) = prayer;
      return Expanded(
        child: _KazaPrayerTile(
          name: name,
          icon: icon,
          rakat: KazaTracker.rakatPerPrayer[key]!,
          count: counts[key]!,
          onIncrement: () => controller.setKazaDayCount(date, key, counts[key]! + 1),
          onDecrement: () => controller.setKazaDayCount(date, key, counts[key]! - 1),
        ),
      );
    }

    return Column(
      children: [
        for (final row in [prayers.sublist(0, 3), prayers.sublist(3)]) ...[
          Row(
            children: [
              tile(row[0]),
              const SizedBox(width: 8),
              tile(row[1]),
              const SizedBox(width: 8),
              tile(row[2]),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.kazaAllPrayers,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.kazaAllPrayers,
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: counts.values.any((count) => count > 0)
                  ? () => controller.adjustKazaDay(date, -1)
                  : null,
            ),
            IconButton.filledTonal(
              tooltip: context.l10n.kazaAllPrayers,
              icon: const Icon(Icons.add),
              onPressed: () {
                HapticFeedback.selectionClick();
                controller.adjustKazaDay(date, 1);
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// One prayer for a day: tap to log one, the corner minus removes one.
/// The dots show the prayer's raka'at and light up once it is logged.
class _KazaPrayerTile extends StatelessWidget {
  const _KazaPrayerTile({
    required this.name,
    required this.icon,
    required this.rakat,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  final String name;
  final IconData icon;
  final int rakat;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final logged = count > 0;

    return Material(
      color: logged
          ? scheme.primary.withValues(alpha: 0.16)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: logged
              ? scheme.primary.withValues(alpha: 0.45)
              : scheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onIncrement();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 4, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: scheme.primary),
                  const Spacer(),
                  SizedBox.square(
                    dimension: 28,
                    child: logged
                        ? IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            icon: const Icon(Icons.remove),
                            onPressed: onDecrement,
                          )
                        : null,
                  ),
                ],
              ),
              Text(
                '$count',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: logged ? scheme.onSurface : scheme.outline,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  for (var i = 0; i < rakat; i++)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: logged ? scheme.primary : scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lifetime progress against the targets, with a per-prayer breakdown.
class _KazaProgressCard extends StatelessWidget {
  const _KazaProgressCard({required this.tracker, required this.prayers});

  final KazaTracker tracker;
  final List<_KazaPrayer> prayers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final number = NumberFormat.decimalPattern(locale);
    final estDate = tracker.estimatedCompletionDate();
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.kazaOverallProgress,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.kazaCalculatorWizard,
                  icon: const Icon(Icons.calculate_outlined, size: 20),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => KazaCalculatorDialog(
                      initialTracker: tracker,
                      onSave: context
                          .read<PrayerAppController>()
                          .updateKazaTracker,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            number.format(tracker.totalRemaining),
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            context.l10n.kazaTotalRemaining,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      context.l10n.kazaCompletedProgress(
                        tracker.totalCompleted,
                        tracker.totalTarget,
                      ),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: tracker.completionRatio,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 16, color: muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        estDate != null
                            ? context.l10n.kazaEstimatedCompletion(
                                DateFormat.yMMMMd(locale).format(estDate),
                              )
                            : context.l10n.kazaEstimatedCompletionFinished,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
              title: Text(
                context.l10n.kazaPerPrayer,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              children: [
                for (final prayer in prayers)
                  _KazaPrayerProgressRow(prayer: prayer, tracker: tracker),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A prayer's completed/target; tapping edits its completed total.
class _KazaPrayerProgressRow extends StatelessWidget {
  const _KazaPrayerProgressRow({required this.prayer, required this.tracker});

  final _KazaPrayer prayer;
  final KazaTracker tracker;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (name, icon, key) = prayer;
    final completed = tracker.completedFor(key);
    final target = tracker.targetFor(key);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showEditCompletedDialog(context, name, key, completed),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 10),
            SizedBox(
              width: 72,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: target == 0 ? 0 : (completed / target).clamp(0.0, 1.0),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$completed / $target',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit_outlined,
              size: 14,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCompletedDialog(
    BuildContext context,
    String name,
    String key,
    int completed,
  ) {
    final controller = context.read<PrayerAppController>();
    final countController = TextEditingController(text: '$completed');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.kazaEditCompletedTitle(name)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ctx.l10n.kazaBaselineHint,
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: countController,
              keyboardType: TextInputType.number,
              autofocus: true,
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
              final count =
                  int.tryParse(countController.text.trim()) ?? completed;
              controller.setKazaCompleted(key, count);
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
  final List<_KazaPrayer> prayers;

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
                onPressed: () => _showLogCalendar(context),
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
                      prayers,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// Opens a month calendar of logged qadaa; tapping a day edits it.
  void _showLogCalendar(BuildContext context) {
    final controller = context.read<PrayerAppController>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: HeatmapMonthCalendar(
            title: sheetContext.l10n.kazaDailyLogTitle,
            countFor: (date) => KazaTracker.prayerKeys.fold(
              0,
              (sum, key) => sum + controller.kazaCountOn(date, key),
            ),
            goal: controller.kazaTracker.dailyPace,
            lastDate: DateUtils.dateOnly(DateTime.now()),
            onDayTap: (date) => _showDayEditor(sheetContext, date, prayers),
          ),
        ),
      ),
    );
  }
}

void _showDayEditor(
  BuildContext context,
  DateTime date,
  List<_KazaPrayer> prayers,
) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _KazaDayEditorSheet(date: date, prayers: prayers),
  );
}

/// Edits the qadaa counts logged on a single day, starting at [date].
class _KazaDayEditorSheet extends StatefulWidget {
  const _KazaDayEditorSheet({required this.date, required this.prayers});

  final DateTime date;
  final List<_KazaPrayer> prayers;

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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
            const SizedBox(height: 12),
            _KazaDayGrid(date: _date, prayers: widget.prayers),
          ],
        ),
      ),
    );
  }
}

const double _kLogCountCellWidth = 30;
const double _kLogTotalCellWidth = 56;
const _kLogRowPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 10);

/// Daily log table header: a prayer icon per column, then the total.
class _KazaLogHeaderRow extends StatelessWidget {
  const _KazaLogHeaderRow({required this.prayers});

  final List<_KazaPrayer> prayers;

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
                    context.l10n.kazaRakatShort(_rakatOf(counts)),
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
