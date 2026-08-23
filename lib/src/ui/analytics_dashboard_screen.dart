import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../calendar/hijri_utils.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../l10n/prayer_names.dart';
import '../models/prayer_models.dart';
import '../services/prayer_analytics_service.dart';

String _shortHijriMonth(DateTime date, String languageCode) {
  final month = HijriMonth.fromDate(date);
  final full = month.longMonthName(languageCode);
  return full.length > 3 ? '${full.substring(0, 3)}.' : full;
}

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
  late DateTime _focusedDate = DateTime.now();
  AnalyticsTimeRange _selectedRange = AnalyticsTimeRange.last30Days;
  final PrayerAnalyticsService _analyticsService =
      const PrayerAnalyticsService();

  void _shiftMonth(CalendarPrimaryDisplay primary, int delta) {
    setState(() {
      _focusedDate = primary == CalendarPrimaryDisplay.hijri
          ? HijriMonth.fromDate(_focusedDate).shift(delta).gregorianStart
          : DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
    });
  }

  void _jumpToToday() {
    setState(() => _focusedDate = DateTime.now());
  }

  List<DateTime> _monthDays(CalendarPrimaryDisplay primary) {
    if (primary == CalendarPrimaryDisplay.gregorian) {
      final daysInMonth = DateTime(
        _focusedDate.year,
        _focusedDate.month + 1,
        0,
      ).day;
      return List.generate(
        daysInMonth,
        (i) => DateTime(_focusedDate.year, _focusedDate.month, i + 1),
      );
    }
    final hijriMonth = HijriMonth.fromDate(_focusedDate);
    final start = hijriMonth.gregorianStart;
    return List.generate(
      hijriMonth.daysInMonth,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }

  String _monthTitle(BuildContext context, CalendarPrimaryDisplay primary) {
    if (primary == CalendarPrimaryDisplay.gregorian) {
      return DateFormat(
        'MMMM yyyy',
        Localizations.localeOf(context).toString(),
      ).format(_focusedDate);
    }
    final hijriMonth = HijriMonth.fromDate(_focusedDate);
    final languageCode = Localizations.localeOf(context).languageCode;
    return '${hijriMonth.longMonthName(languageCode)} ${hijriMonth.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final primary = controller.calendarPrimaryDisplay;
        final showSecondary = controller.showSecondaryCalendarDate;
        final completions = controller.prayerCompletions;
        final streaks = _analyticsService.calculateStreaks(completions);
        final monthDays = _monthDays(primary);
        final leadingBlanks = monthDays.first.weekday % 7;
        final today = DateTime.now();
        final locale = Localizations.localeOf(context).toString();

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
                                  Text(
                                    '${context.l10n.totalPrayersCompleted}: $totalLogged',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
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

                // 3. Monthly Completion Heatmap Grid (Matching HijriCalendarView)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.monthlyHeatmapTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              tooltip: showSecondary
                                  ? context.l10n.calendarHideSecondary
                                  : context.l10n.calendarShowSecondary,
                              icon: Icon(
                                showSecondary
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () => controller
                                  .updateShowSecondaryCalendarDate(!showSecondary),
                            ),
                            IconButton(
                              tooltip: context.l10n.todayShort,
                              icon: const Icon(Icons.today),
                              onPressed: _jumpToToday,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: SegmentedButton<CalendarPrimaryDisplay>(
                                segments: [
                                  ButtonSegment(
                                    value: CalendarPrimaryDisplay.hijri,
                                    label: Text(
                                      context.l10n.calendarYearlyBasisHijri,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: CalendarPrimaryDisplay.gregorian,
                                    label: Text(
                                      context.l10n.calendarYearlyBasisGregorian,
                                    ),
                                  ),
                                ],
                                selected: {primary},
                                onSelectionChanged: (selection) => controller
                                    .updateCalendarPrimaryDisplay(
                                        selection.first),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              tooltip: context.l10n.calendarPreviousMonth,
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () => _shiftMonth(primary, -1),
                            ),
                            Expanded(
                              child: Text(
                                _monthTitle(context, primary),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                softWrap: true,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              tooltip: context.l10n.calendarNextMonth,
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _shiftMonth(primary, 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _WeekdayHeaderRow(locale: locale),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: leadingBlanks + monthDays.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            childAspectRatio: 0.85,
                          ),
                          itemBuilder: (context, index) {
                            if (index < leadingBlanks) {
                              return const SizedBox();
                            }
                            final date = monthDays[index - leadingBlanks];
                            final count = _analyticsService.completedCountForDay(
                              completions,
                              date,
                            );
                            final isToday = date.year == today.year &&
                                date.month == today.month &&
                                date.day == today.day;
                            final languageCode =
                                Localizations.localeOf(context).languageCode;

                            final primaryLabel =
                                primary == CalendarPrimaryDisplay.hijri
                                    ? HijriCalendar.fromDate(date).hDay.toString()
                                    : date.day.toString();

                            final secondaryLabel = showSecondary
                                ? (primary == CalendarPrimaryDisplay.hijri
                                    ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                                    : '${HijriCalendar.fromDate(date).hDay} ${_shortHijriMonth(date, languageCode)}')
                                : null;

                            return _AnalyticsDayCell(
                              primaryLabel: primaryLabel,
                              secondaryLabel: secondaryLabel,
                              completedCount: count,
                              isToday: isToday,
                              date: date,
                            );
                          },
                        ),
                      ],
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

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    final labels = List.generate(
      7,
      (i) => DateFormat.E(locale).format(DateTime(2024, 1, 7 + i)),
    );
    final style = Theme.of(context).textTheme.labelMedium;
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
      ],
    );
  }
}

class _AnalyticsDayCell extends StatelessWidget {
  const _AnalyticsDayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.completedCount,
    required this.isToday,
    required this.date,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final int completedCount;
  final bool isToday;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = (completedCount / 5).clamp(0.0, 1.0);

    Color bgColor;
    Color primaryTextColor;
    Color secondaryTextColor;

    if (completedCount == 0) {
      bgColor = colorScheme.surfaceContainerHighest;
      primaryTextColor = colorScheme.onSurface;
      secondaryTextColor = colorScheme.onSurfaceVariant;
    } else if (ratio < 0.5) {
      bgColor = colorScheme.primary.withOpacity(0.3);
      primaryTextColor = colorScheme.onSurface;
      secondaryTextColor = colorScheme.onSurfaceVariant;
    } else if (ratio < 1.0) {
      bgColor = colorScheme.primary.withOpacity(0.65);
      primaryTextColor = Colors.white;
      secondaryTextColor = Colors.white70;
    } else {
      bgColor = colorScheme.primary;
      primaryTextColor = colorScheme.onPrimary;
      secondaryTextColor = colorScheme.onPrimary.withOpacity(0.8);
    }

    final dateStr = DateFormat('MMM d').format(date);

    return Tooltip(
      message: '$dateStr: $completedCount/5 prayers completed',
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        padding: const EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            if (secondaryLabel != null) ...[
              const SizedBox(height: 1),
              Text(
                secondaryLabel!,
                style: TextStyle(
                  fontSize: 8.5,
                  color: secondaryTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (completedCount > 0) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: primaryTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$completedCount/5',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ),
            ],
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
