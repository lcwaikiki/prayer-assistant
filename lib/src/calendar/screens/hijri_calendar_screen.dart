import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../l10n/prayer_names.dart';
import '../../models/prayer_models.dart';

import '../../utils/time_utils.dart';
import '../hijri_utils.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_form_screen.dart';
import 'hijri_date_picker_dialog.dart';

String _goToDateTooltip(String languageCode) {
  return switch (languageCode.toLowerCase()) {
    'tr' => 'Tarihe git',
    'ar' => 'الانتقال إلى تاريخ',
    'de' => 'Zu Datum springen',
    'es' => 'Ir a fecha',
    'fa' => 'رفتن به تاریخ',
    'fr' => 'Aller à la date',
    'id' => 'Buka tanggal',
    'ja' => '日付へ移動',
    'ru' => 'Перейти к дате',
    'ur' => 'تاریخ پر جائیں',
    'zh' => '前往日期',
    _ => 'Go to date',
  };
}

String _shortHijriMonth(DateTime date, String languageCode) {
  final month = HijriMonth.fromDate(date);
  final full = month.longMonthName(languageCode);
  return full.length > 3 ? '${full.substring(0, 3)}.' : full;
}

/// Full-screen wrapper around [HijriCalendarView], used when the calendar
/// is pushed on its own (e.g. from a reminder notification tap) rather than
/// embedded as a tab.
class HijriCalendarScreen extends StatelessWidget {
  const HijriCalendarScreen({
    super.key,
    this.initialDate,
    this.openDetailOnLaunch = false,
  });

  final DateTime? initialDate;
  final bool openDetailOnLaunch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.datesCalendarTab)),
      body: HijriCalendarView(
        initialDate: initialDate,
        openDetailOnLaunch: openDetailOnLaunch,
      ),
    );
  }
}

/// The Hijri/Gregorian monthly calendar body: month navigation, the
/// primary/secondary calendar controls, and the day grid. Embeddable
/// directly (e.g. as a tab) or wrapped by [HijriCalendarScreen].
class HijriCalendarView extends StatefulWidget {
  const HijriCalendarView({
    super.key,
    this.initialDate,
    this.openDetailOnLaunch = false,
  });

  final DateTime? initialDate;

  /// When true, automatically opens the day-detail sheet for [initialDate]
  /// once the view is built (used when arriving from a reminder
  /// notification tap).
  final bool openDetailOnLaunch;

  @override
  State<HijriCalendarView> createState() => _HijriCalendarViewState();
}

class _HijriCalendarViewState extends State<HijriCalendarView> {
  late DateTime _focusedDate;
  bool _autoOpenTriggered = false;

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

  Future<void> _openGoToDate(CalendarPrimaryDisplay primary) async {
    if (primary == CalendarPrimaryDisplay.hijri) {
      final picked = await showHijriDatePickerDialog(
        context,
        initialDate: _focusedDate,
      );
      if (picked != null && mounted) {
        setState(() => _focusedDate = picked);
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: _focusedDate,
        firstDate: DateTime(1937, 3, 14),
        lastDate: DateTime(2077, 11, 16),
      );
      if (picked != null && mounted) {
        setState(() => _focusedDate = picked);
      }
    }
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

  void _openDayDetail(DateTime date, CalendarPrimaryDisplay primary) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) =>
          _DayDetailSheet(date: date, primary: primary),
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

        if (widget.openDetailOnLaunch && !_autoOpenTriggered) {
          _autoOpenTriggered = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _openDayDetail(_focusedDate, primary);
            }
          });
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: SegmentedButton<CalendarPrimaryDisplay>(
                      segments: [
                        ButtonSegment(
                          value: CalendarPrimaryDisplay.hijri,
                          label: Text(context.l10n.calendarYearlyBasisHijri),
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
                          .updateCalendarPrimaryDisplay(selection.first),
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
                  IconButton(
                    key: const Key('calendar_today_button'),
                    tooltip: context.l10n.todayShort,
                    icon: const Icon(Icons.today),
                    onPressed: _jumpToToday,
                  ),
                  IconButton(
                    key: const Key('calendar_go_to_date_button'),
                    tooltip: _goToDateTooltip(Localizations.localeOf(context).languageCode),
                    icon: const Icon(Icons.edit_calendar),
                    onPressed: () => _openGoToDate(primary),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.calendarPreviousMonth,
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _shiftMonth(primary, -1),
                  ),
                  Expanded(
                    child: InkWell(
                      key: const Key('calendar_month_title_button'),
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openGoToDate(primary),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          _monthTitle(context, primary),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          softWrap: true,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.calendarNextMonth,
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _shiftMonth(primary, 1),
                  ),
                ],
              ),
            ),
            // On wide screens (tablets) a full-width 7-column grid makes each
            // day cell enormous and the month require scrolling. Cap the grid
            // (and its weekday header) at a phone-sized width and center it so
            // cells stay a comfortable size.
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: _WeekdayHeaderRow(locale: locale),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Prefer the phone-style cell aspect (0.85), but shrink
                      // cells vertically just enough that every row fits in the
                      // available height (tablet landscape) instead of forcing
                      // the month to scroll.
                      final rowCount =
                          ((leadingBlanks + monthDays.length) / 7).ceil();
                      final cellWidth = (constraints.maxWidth - 8) / 7;
                      final preferredCellHeight = cellWidth / 0.85;
                      final fitCellHeight =
                          (constraints.maxHeight - 8) / rowCount;
                      final cellHeight = fitCellHeight < preferredCellHeight
                          ? fitCellHeight
                          : preferredCellHeight;
                      final aspectRatio = cellWidth / cellHeight;
                      return GridView.builder(
                        padding: const EdgeInsets.all(4),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: aspectRatio,
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
                            (reminder) =>
                                reminder.enabled && reminder.occursOn(date),
                          );
                          final isHoliday =
                              islamicHolidayKey(date) != null;
                          final languageCode =
                              Localizations.localeOf(context).languageCode;
                          return _DayCell(
                            primaryLabel:
                                primary == CalendarPrimaryDisplay.hijri
                                ? HijriCalendar.fromDate(date).hDay.toString()
                                : date.day.toString(),
                            secondaryLabel: showSecondary
                                ? (primary == CalendarPrimaryDisplay.hijri
                                      ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                                      : '${HijriCalendar.fromDate(date).hDay} ${_shortHijriMonth(date, languageCode)}')
                                : null,
                            isToday: isToday,
                            hasReminder: hasReminder,
                            isHoliday: isHoliday,
                            onTap: () => _openDayDetail(date, primary),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
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
    required this.isHoliday,
    required this.onTap,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool isToday;
  final bool hasReminder;
  final bool isHoliday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? colors.primaryContainer
              : (isHoliday ? Colors.amber.withAlpha(40) : null),
          borderRadius: BorderRadius.circular(10),
          border: isHoliday && !isToday
              ? Border.all(color: Colors.amber.shade700, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isToday || isHoliday
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isToday
                    ? colors.onPrimaryContainer
                    : (isHoliday ? Colors.amber.shade800 : null),
              ),
            ),
            if (secondaryLabel != null)
              Text(
                secondaryLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? colors.onPrimaryContainer
                      : (isHoliday
                          ? Colors.amber.shade700
                          : colors.onSurfaceVariant),
                  fontSize: 9,
                ),
              ),
            if (hasReminder)
              Container(
                margin: const EdgeInsets.only(top: 3),
                width: 5,
                height: 5,
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

class _DayDetailSheet extends StatefulWidget {
  const _DayDetailSheet({required this.date, required this.primary});

  final DateTime date;
  final CalendarPrimaryDisplay primary;

  @override
  State<_DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends State<_DayDetailSheet> {
  late DateTime _date = widget.date;

  void _shiftDay(int delta) {
    setState(() {
      _date = DateTime(_date.year, _date.month, _date.day + delta);
    });
  }

  String _hijriDateLabel(DateTime date, String languageCode) {
    final hijri = HijriCalendar.fromDate(date);
    return '${hijri.hDay} '
        '${HijriMonth.fromDate(date).longMonthName(languageCode)} '
        '${hijri.hYear}';
  }

  String _primaryDateLabel(CalendarPrimaryDisplay primary, String locale) {
    return primary == CalendarPrimaryDisplay.gregorian
        ? DateFormat.yMMMMd(locale).format(_date)
        : _hijriDateLabel(_date, locale.split('-').first);
  }

  String _secondaryDateLabel(CalendarPrimaryDisplay primary, String locale) {
    return primary == CalendarPrimaryDisplay.gregorian
        ? _hijriDateLabel(_date, locale.split('-').first)
        : DateFormat.yMMMMd(locale).format(_date);
  }

  String _recurrenceLabel(BuildContext context, CalendarReminder reminder) {
    final l10n = context.l10n;
    if (reminder.anchor == CalendarReminderAnchor.prayerTime) {
      return '${l10n.calendarAnchorPrayerTime} • ${l10n.prayerNameLabel(reminder.anchorPrayerName ?? '')}';
    }
    switch (reminder.recurrence) {
      case ReminderRecurrence.once:
        return l10n.calendarRecurrenceOnce;
      case ReminderRecurrence.daily:
        return l10n.calendarRecurrenceDaily;
      case ReminderRecurrence.weekly:
        return l10n.calendarRecurrenceWeekly;
      case ReminderRecurrence.monthly:
        final basis = reminder.monthlyBasis == CalendarBasis.hijri
            ? l10n.calendarYearlyBasisHijri
            : l10n.calendarYearlyBasisGregorian;
        return '${l10n.calendarRecurrenceMonthly} • $basis';
      case ReminderRecurrence.yearly:
        final basis = reminder.yearlyBasis == CalendarBasis.hijri
            ? l10n.calendarYearlyBasisHijri
            : l10n.calendarYearlyBasisGregorian;
        return '${l10n.calendarRecurrenceYearly} • $basis';
    }
  }

  void _deleteWithUndo(
    BuildContext context,
    PrayerAppController controller,
    CalendarReminder reminder,
  ) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final index = controller.calendarReminders.indexWhere(
      (existing) => existing.id == reminder.id,
    );
    controller.deleteCalendarReminder(reminder.id);
    // Close the sheet first: a SnackBar attached to the underlying page's
    // Scaffold renders *behind* an open modal bottom sheet, making Undo
    // unreachable. Closing also reveals the refreshed calendar grid (the
    // day's reminder dot) immediately behind the closing sheet.
    Navigator.pop(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(child: Text(l10n.calendarReminderDeleted(reminder.title))),
            TextButton(
              onPressed: () {
                controller.restoreCalendarReminder(reminder, index: index);
                messenger.hideCurrentSnackBar();
              },
              child: Text(l10n.undo),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<PrayerAppController>();
    final reminders = controller.calendarReminders
        .where((reminder) => reminder.occursOn(_date))
        .toList(growable: false);
    final locale = Localizations.localeOf(context).toString();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.calendarPreviousDay,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftDay(-1),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _primaryDateLabel(widget.primary, locale),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _secondaryDateLabel(widget.primary, locale),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.calendarNextDay,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftDay(1),
                ),
              ],
            ),
            if (islamicHolidayForDate(_date, (key) {
                  return switch (key) {
                    'holiday_islamic_new_year' =>
                      l10n.holiday_islamic_new_year,
                    'holiday_ashura' => l10n.holiday_ashura,
                    'holiday_mawlid' => l10n.holiday_mawlid,
                    'holiday_isra_miraj' => l10n.holiday_isra_miraj,
                    'holiday_laylat_barat' =>
                      l10n.holiday_laylat_barat,
                    'holiday_ramadan_first' =>
                      l10n.holiday_ramadan_first,
                    'holiday_laylat_qadr' => l10n.holiday_laylat_qadr,
                    'holiday_eid_fitr' => l10n.holiday_eid_fitr,
                    'holiday_arafah' => l10n.holiday_arafah,
                    'holiday_eid_adha' => l10n.holiday_eid_adha,
                    _ => key,
                  };
                }) case final holiday?) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade700, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        holiday,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (controller.prayerDayFor(_date) case final day?) ...[
              const SizedBox(height: 8),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: [
                      for (final entry in prayerOrder.indexed) ...[
                        if (entry.$1 > 0) const Divider(height: 8),
                        Row(
                          children: [
                            Icon(
                              iconForPrayer(entry.$2),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                context.l10n.prayerNameLabel(entry.$2),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),

                            Text(
                              prayerMapForDay(day)[entry.$2] ?? '--:--',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
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
                    onChanged: (_) =>
                        controller.toggleCalendarReminderEnabled(reminder.id),
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
                              builder: (_) => CalendarReminderFormScreen(
                                reminder: reminder,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: l10n.calendarDeleteReminder,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            _deleteWithUndo(context, controller, reminder),
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
                        CalendarReminderFormScreen(initialDate: _date),
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
