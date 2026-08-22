import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../l10n/prayer_names.dart';
import '../models/kaza_tracker.dart';
import '../widgets/kaza_calculator_dialog.dart';


class KazaTrackerScreen extends StatelessWidget {
  const KazaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<PrayerAppController>();
    final tracker = controller.kazaTracker;
    final locale = Localizations.localeOf(context).toString();

    final prayers = [
      (context.l10n.prayerNameLabel('Imsak'), Icons.wb_twilight, 'fajr'),
      (context.l10n.prayerNameLabel('Ogle'), Icons.wb_sunny_outlined, 'dhuhr'),
      (context.l10n.prayerNameLabel('Ikindi'), Icons.wb_sunny, 'asr'),
      (context.l10n.prayerNameLabel('Aksam'), Icons.nights_stay_outlined, 'maghrib'),
      (context.l10n.prayerNameLabel('Yatsi'), Icons.nights_stay, 'isha'),
      (context.l10n.kazaWitrLabel, Icons.star_outline, 'witr'),
    ];


    final estDate = tracker.estimatedCompletionDate();
    final estDateFormatted = estDate != null
        ? DateFormat.yMMMMd(locale).format(estDate)
        : null;

    return Scaffold(
      appBar: AppBar(
        actions: [

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
        ],
      ),
      body: ListView(
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
              onIncrement: () => controller.incrementKaza(item.$3),
              onDecrement: () => controller.decrementKaza(item.$3),
              onSetCompleted: (count) {
                final current = tracker;
                KazaTracker updated;
                switch (item.$3) {
                  case 'fajr':
                    updated = current.copyWith(fajrCompleted: count);
                    break;
                  case 'dhuhr':
                    updated = current.copyWith(dhuhrCompleted: count);
                    break;
                  case 'asr':
                    updated = current.copyWith(asrCompleted: count);
                    break;
                  case 'maghrib':
                    updated = current.copyWith(maghribCompleted: count);
                    break;
                  case 'isha':
                    updated = current.copyWith(ishaCompleted: count);
                    break;
                  case 'witr':
                    updated = current.copyWith(witrCompleted: count);
                    break;
                  default:
                    return;
                }
                controller.updateKazaTracker(updated);
              },
            ),
            const SizedBox(height: 8),
          ],
        ],
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

class _KazaPrayerCard extends StatelessWidget {
  const _KazaPrayerCard({
    required this.name,
    required this.icon,
    required this.prayerKey,
    required this.target,
    required this.completed,
    required this.onIncrement,
    required this.onDecrement,
    required this.onSetCompleted,
  });

  final String name;
  final IconData icon;
  final String prayerKey;
  final int target;
  final int completed;
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
              onPressed: completed > 0 ? onDecrement : null,
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
