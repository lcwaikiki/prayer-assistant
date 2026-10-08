import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_week_start.dart';
import '../../models/prayer_models.dart';
import '../hijri_utils.dart';

/// Month calendar whose days are shaded by [countFor] against [goal], with
/// the calendar tab's Hijri/Gregorian switch, secondary date toggle, month
/// navigation and today shortcut. Display settings are the app's shared
/// calendar settings.
class HeatmapMonthCalendar extends StatefulWidget {
  const HeatmapMonthCalendar({
    super.key,
    required this.title,
    required this.countFor,
    required this.goal,
    this.onDayTap,
    this.lastDate,
  });

  final String title;
  final int Function(DateTime date) countFor;
  final int goal;
  final ValueChanged<DateTime>? onDayTap;

  /// Days after this are dimmed and cannot be tapped.
  final DateTime? lastDate;

  @override
  State<HeatmapMonthCalendar> createState() => _HeatmapMonthCalendarState();
}

class _HeatmapMonthCalendarState extends State<HeatmapMonthCalendar> {
  late DateTime _focusedDate = DateTime.now();

  void _shiftMonth(CalendarPrimaryDisplay primary, int delta) {
    setState(() {
      _focusedDate = primary == CalendarPrimaryDisplay.hijri
          ? HijriMonth.fromDate(_focusedDate).shift(delta).gregorianStart
          : DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
    });
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
    final controller = context.watch<PrayerAppController>();
    final primary = controller.calendarPrimaryDisplay;
    final showSecondary = controller.showSecondaryCalendarDate;
    final weekStart = controller.calendarWeekStart;
    final monthDays = _monthDays(primary);
    final leadingBlanks = weekStart.leadingBlanks(monthDays.first);
    final today = DateTime.now();
    final locale = Localizations.localeOf(context).toString();
    final languageCode = Localizations.localeOf(context).languageCode;
    final lastDate = widget.lastDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: showSecondary
                  ? context.l10n.calendarHideSecondary
                  : context.l10n.calendarShowSecondary,
              icon: Icon(
                showSecondary ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () =>
                  controller.updateShowSecondaryCalendarDate(!showSecondary),
            ),
            IconButton(
              tooltip: context.l10n.todayShort,
              icon: const Icon(Icons.today),
              onPressed: () => setState(() => _focusedDate = DateTime.now()),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<CalendarPrimaryDisplay>(
            segments: [
              ButtonSegment(
                value: CalendarPrimaryDisplay.hijri,
                label: Text(context.l10n.calendarYearlyBasisHijri),
              ),
              ButtonSegment(
                value: CalendarPrimaryDisplay.gregorian,
                label: Text(context.l10n.calendarYearlyBasisGregorian),
              ),
            ],
            selected: {primary},
            onSelectionChanged: (selection) =>
                controller.updateCalendarPrimaryDisplay(selection.first),
          ),
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
        _WeekdayHeaderRow(locale: locale, weekStart: weekStart),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: leadingBlanks + monthDays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return const SizedBox();
            }
            final date = monthDays[index - leadingBlanks];
            final enabled = lastDate == null || !date.isAfter(lastDate);
            return _HeatmapDayCell(
              primaryLabel: primary == CalendarPrimaryDisplay.hijri
                  ? HijriCalendar.fromDate(date).hDay.toString()
                  : date.day.toString(),
              secondaryLabel: showSecondary
                  ? (primary == CalendarPrimaryDisplay.hijri
                        ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                        : '${HijriCalendar.fromDate(date).hDay} '
                              '${_shortHijriMonth(date, languageCode)}')
                  : null,
              count: widget.countFor(date),
              goal: widget.goal,
              isToday: DateUtils.isSameDay(date, today),
              onTap: enabled && widget.onDayTap != null
                  ? () => widget.onDayTap!(date)
                  : null,
              dimmed: !enabled,
            );
          },
        ),
      ],
    );
  }
}

String _shortHijriMonth(DateTime date, String languageCode) {
  final full = HijriMonth.fromDate(date).longMonthName(languageCode);
  return full.length > 3 ? '${full.substring(0, 3)}.' : full;
}

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow({required this.locale, required this.weekStart});

  final String locale;
  final CalendarWeekStart weekStart;

  @override
  Widget build(BuildContext context) {
    final startOffset = weekStart == CalendarWeekStart.sunday ? 7 : 8;
    final labels = List.generate(
      7,
      (i) => DateFormat.E(locale).format(DateTime(2024, 1, startOffset + i)),
    );
    final style = Theme.of(context).textTheme.labelMedium;
    return Row(
      children: [
        for (final label in labels)
          Expanded(
            child: Text(label, textAlign: TextAlign.center, style: style),
          ),
      ],
    );
  }
}

class _HeatmapDayCell extends StatelessWidget {
  const _HeatmapDayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.count,
    required this.goal,
    required this.isToday,
    required this.onTap,
    required this.dimmed,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final int count;
  final int goal;
  final bool isToday;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ratio = goal <= 0 ? 0.0 : (count / goal).clamp(0.0, 1.0);

    final (bgColor, primaryTextColor, secondaryTextColor) = switch (ratio) {
      _ when count == 0 => (
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurface,
        colorScheme.onSurfaceVariant,
      ),
      < 0.5 => (
        colorScheme.primary.withValues(alpha: 0.3),
        colorScheme.onSurface,
        colorScheme.onSurfaceVariant,
      ),
      < 1.0 => (
        colorScheme.primary.withValues(alpha: 0.65),
        Colors.white,
        Colors.white70,
      ),
      _ => (
        colorScheme.primary,
        colorScheme.onPrimary,
        colorScheme.onPrimary.withValues(alpha: 0.8),
      ),
    };

    final cell = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: isToday
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          padding: const EdgeInsets.all(2),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      primaryLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    if (secondaryLabel != null)
                      Text(
                        secondaryLabel!,
                        style: TextStyle(
                          fontSize: 8,
                          color: secondaryTextColor,
                        ),
                        maxLines: 1,
                      ),
                    if (count > 0) ...[
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: primaryTextColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$count/$goal',
                          maxLines: 1,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return dimmed ? Opacity(opacity: 0.35, child: cell) : cell;
  }
}
