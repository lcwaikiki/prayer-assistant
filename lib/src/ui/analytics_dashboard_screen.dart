import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../calendar/widgets/heatmap_month_calendar.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_names.dart';
import '../services/prayer_analytics_service.dart';

enum AnalyticsTimeRange {
  last30Days,
  allTime,
}

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.last30Days;
  final PrayerAnalyticsService _analyticsService =
      const PrayerAnalyticsService();

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final completions = controller.prayerCompletions;
        final streaks = _analyticsService.calculateStreaks(completions);

        final DateTimeRange? range =
            _selectedRange == AnalyticsTimeRange.last30Days
                ? DateTimeRange(
                    start: DateTime.now().subtract(const Duration(days: 29)),
                    end: DateTime.now(),
                  )
                : null;

        final stats = _analyticsService.calculatePrayerBreakdown(
          completions,
          range: range,
        );
        final overallRate = _analyticsService.calculateOverallRate(
          completions,
          range: range,
        );
        final totalLogged =
            _analyticsService.calculateTotalPrayersLogged(completions);

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Streak Cards Row
                Row(
                  children: [
                    Expanded(
                      child: _StreakCard(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.orange,
                        title: context.l10n.currentStreak,
                        value: '${streaks.currentStreak}',
                        unit: context.l10n.daysUnit,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StreakCard(
                        icon: Icons.emoji_events,
                        iconColor: Colors.amber,
                        title: context.l10n.longestStreak,
                        value: '${streaks.longestStreak}',
                        unit: context.l10n.daysUnit,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Overall Consistency & Totals Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: overallRate / 100,
                                strokeWidth: 7,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                              ),
                              Center(
                                child: Text(
                                  '${overallRate.round()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.overallConsistency,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${context.l10n.totalPrayersCompleted}: $totalLogged',
                                      style:
                                          Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Monthly Completion Heatmap Grid
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: HeatmapMonthCalendar(
                      title: context.l10n.monthlyHeatmapTitle,
                      countFor: (date) => _analyticsService
                          .completedCountForDay(completions, date),
                      goal: 5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Per-Prayer Breakdown Header & Filter Toggle (Responsive Layout)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.completionBreakdownTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<AnalyticsTimeRange>(
                        segments: [
                          ButtonSegment(
                            value: AnalyticsTimeRange.last30Days,
                            label: Text(context.l10n.last30Days),
                          ),
                          ButtonSegment(
                            value: AnalyticsTimeRange.allTime,
                            label: Text(context.l10n.allTime),
                          ),
                        ],
                        selected: {_selectedRange},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            _selectedRange = newSelection.first;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Per-Prayer Breakdown List
                for (final stat in stats)
                  _PrayerStatRow(
                    stat: stat,
                    label: context.l10n.prayerNameLabel(stat.prayerKey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.unit,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerStatRow extends StatelessWidget {
  const _PrayerStatRow({
    required this.stat,
    required this.label,
  });

  final PrayerStat stat;
  final String label;

  @override
  Widget build(BuildContext context) {
    final pct = stat.percentage.round();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$pct% (${stat.completedCount}/${stat.totalDays})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: stat.percentage / 100,
                minHeight: 8,
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
