import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../models/prayer_models.dart';
import '../hijri_utils.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_form_screen.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key, this.initialDate});

  final DateTime? initialDate;

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late DateTime _focusedDate;

  @override
  void initState() {
    super.initState();
    _focusedDate = widget.initialDate ?? DateTime.now();
  }

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
    return '${hijriMonth.longMonthName} ${hijriMonth.year}';
  }

  void _openDayDetail(PrayerAppController controller, DateTime date) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) =>
          _DayDetailSheet(controller: controller, date: date),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final primary = controller.calendarPrimaryDisplay;
        final showSecondary = controller.showSecondaryCalendarDate;
        final monthDays = _monthDays(primary);
        final leadingBlanks = monthDays.first.weekday % 7;
        final today = DateTime.now();
        final locale = Localizations.localeOf(context).toString();

        return Scaffold(
          appBar: AppBar(
            title: Row(
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
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.calendarNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftMonth(primary, 1),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: context.l10n.todayShort,
                icon: const Icon(Icons.today),
                onPressed: _jumpToToday,
              ),
              IconButton(
                tooltip: context.l10n.calendarSwapPrimary,
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => controller.updateCalendarPrimaryDisplay(
                  primary == CalendarPrimaryDisplay.hijri
                      ? CalendarPrimaryDisplay.gregorian
                      : CalendarPrimaryDisplay.hijri,
                ),
              ),
              IconButton(
                tooltip: showSecondary
                    ? context.l10n.calendarHideSecondary
                    : context.l10n.calendarShowSecondary,
                icon: Icon(
                  showSecondary ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => controller.updateShowSecondaryCalendarDate(
                  !showSecondary,
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              _WeekdayHeaderRow(locale: locale),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                      ),
                  itemCount: leadingBlanks + monthDays.length,
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) {
                      return const SizedBox.shrink();
                    }
                    final date = monthDays[index - leadingBlanks];
                    final isToday =
                        date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    final hasReminder = controller.calendarReminders.any(
                      (reminder) => reminder.enabled && reminder.occursOn(date),
                    );
                    return _DayCell(
                      primaryLabel: primary == CalendarPrimaryDisplay.hijri
                          ? HijriCalendar.fromDate(date).hDay.toString()
                          : date.day.toString(),
                      secondaryLabel: showSecondary
                          ? (primary == CalendarPrimaryDisplay.hijri
                                ? date.day.toString()
                                : HijriCalendar.fromDate(date).hDay.toString())
                          : null,
                      isToday: isToday,
                      hasReminder: hasReminder,
                      onTap: () => _openDayDetail(controller, date),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeekdayHeaderRow extends StatelessWidget {
  const _WeekdayHeaderRow({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    // 2024-01-07 was a Sunday; used purely to derive locale-correct short
    // weekday labels in Sunday-first order.
    final labels = List.generate(
      7,
      (i) => DateFormat.E(locale).format(DateTime(2024, 1, 7 + i)),
    );
    final style = Theme.of(context).textTheme.labelMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: labels
            .map(
              (label) => Expanded(
                child: Center(child: Text(label, style: style)),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isToday,
    required this.hasReminder,
    required this.onTap,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool isToday;
  final bool hasReminder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? colors.primaryContainer : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryLabel,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: isToday ? colors.onPrimaryContainer : null,
              ),
            ),
            if (secondaryLabel != null)
              Text(
                secondaryLabel!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? colors.onPrimaryContainer
                      : colors.onSurfaceVariant,
                ),
              ),
            if (hasReminder)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isToday ? colors.onPrimaryContainer : colors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({required this.controller, required this.date});

  final PrayerAppController controller;
  final DateTime date;

  String _recurrenceLabel(BuildContext context, CalendarReminder reminder) {
    final l10n = context.l10n;
    switch (reminder.recurrence) {
      case ReminderRecurrence.once:
        return l10n.calendarRecurrenceOnce;
      case ReminderRecurrence.daily:
        return l10n.calendarRecurrenceDaily;
      case ReminderRecurrence.weekly:
        return l10n.calendarRecurrenceWeekly;
      case ReminderRecurrence.monthly:
        return l10n.calendarRecurrenceMonthly;
      case ReminderRecurrence.yearly:
        final basis = reminder.yearlyBasis == YearlyCalendarBasis.hijri
            ? l10n.calendarYearlyBasisHijri
            : l10n.calendarYearlyBasisGregorian;
        return '${l10n.calendarRecurrenceYearly} • $basis';
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CalendarReminder reminder,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.calendarDeleteReminderConfirmTitle),
        content: Text(
          l10n.calendarDeleteReminderConfirmMessage(reminder.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.calendarDeleteReminder),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteCalendarReminder(reminder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final reminders = controller.calendarReminders
        .where((reminder) => reminder.occursOn(date))
        .toList(growable: false);
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat.yMMMMd(locale).format(date),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.calendarNoRemindersOnDay),
              )
            else
              ...reminders.map(
                (reminder) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(reminder.title),
                  subtitle: Text(_recurrenceLabel(context, reminder)),
                  leading: Switch(
                    value: reminder.enabled,
                    onChanged: (_) => controller.toggleCalendarReminderEnabled(
                      reminder.id,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: l10n.calendarEditReminder,
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  CalendarReminderFormScreen(reminder: reminder),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: l10n.calendarDeleteReminder,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, reminder),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        CalendarReminderFormScreen(initialDate: date),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.calendarAddReminder),
            ),
          ],
        ),
      ),
    );
  }
}
