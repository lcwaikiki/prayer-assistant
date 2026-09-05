import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_week_start.dart';
import '../../models/prayer_models.dart';
import '../../ui/widgets/moon_phase_widget.dart';
import '../hijri_utils.dart';
import '../moon_phase_utils.dart';
import 'hijri_calendar_screen.dart';
import 'hijri_date_picker_dialog.dart';

String _moonCalendarTitle(String languageCode) {
  return switch (languageCode.toLowerCase()) {
    'tr' => 'Ay Takvimi & Evreleri',
    'ar' => 'تقويم أطوار القمر',
    'de' => 'Mondphasen-Kalender',
    'es' => 'Calendario de Fases Lunares',
    'fa' => 'تقویم گام‌های ماه',
    'fr' => 'Calendrier des Phases de la Lune',
    'id' => 'Kalender Fase Bulan',
    'ja' => '月齢カレンダー',
    'ru' => 'Календарь фаз Луны',
    'ur' => 'چاند کی حالتوں کا کیلنڈر',
    'zh' => '月相日历',
    _ => 'Moon Phase Calendar',
  };
}

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

String _shortHijriMonth(DateTime date, String languageCode, {int offset = 0}) {
  final month = HijriMonth.fromDate(date, offset: offset);
  final full = month.longMonthName(languageCode);
  return full.length > 3 ? '${full.substring(0, 3)}.' : full;
}

class MoonCalendarScreen extends StatelessWidget {
  const MoonCalendarScreen({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final title = _moonCalendarTitle(languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: MoonCalendarView(initialDate: initialDate),
    );
  }
}

class MoonCalendarView extends StatefulWidget {
  const MoonCalendarView({
    super.key,
    this.initialDate,
  });

  final DateTime? initialDate;

  @override
  State<MoonCalendarView> createState() => _MoonCalendarViewState();
}

class _MoonCalendarViewState extends State<MoonCalendarView> {
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
      builder: (sheetContext) => DayDetailSheet(date: date, primary: primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    return Consumer<PrayerAppController>(
        builder: (context, controller, _) {
          final primary = controller.calendarPrimaryDisplay;
          final showSecondary = controller.showSecondaryCalendarDate;
          final weekStart = controller.calendarWeekStart;
          final monthDays = _monthDays(primary);
          final int leadingBlanks = weekStart.leadingBlanks(monthDays.first);
          final today = DateTime.now();
          final locale = Localizations.localeOf(context).toString();

          // Find key lunar events for the month
          DateTime? fullMoonDate;
          DateTime? newMoonDate;
          final whiteDaysList = <DateTime>[];

          for (final date in monthDays) {
            final info = getMoonPhase(date, hijriOffset: controller.hijriDateOffset);
            if (info.isWhiteDay) {
              whiteDaysList.add(date);
            }
            if (info.phaseNameKey == 'moonPhaseFullMoon' && fullMoonDate == null) {
              fullMoonDate = date;
            }
            if (info.phaseNameKey == 'moonPhaseNewMoon' && newMoonDate == null) {
              newMoonDate = date;
            }
          }

          return Column(
            children: [
              // Display Controls Row
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
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
                        showSecondary ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => controller.updateShowSecondaryCalendarDate(
                        !showSecondary,
                      ),
                    ),
                    IconButton(
                      key: const Key('moon_calendar_today_button'),
                      tooltip: context.l10n.todayShort,
                      icon: const Icon(Icons.today),
                      onPressed: _jumpToToday,
                    ),
                    IconButton(
                      key: const Key('moon_calendar_go_to_date_button'),
                      tooltip: _goToDateTooltip(languageCode),
                      icon: const Icon(Icons.edit_calendar),
                      onPressed: () => _openGoToDate(primary),
                    ),
                  ],
                ),
              ),

              // Lunar Month Navigation Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: context.l10n.calendarPreviousMonth,
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _shiftMonth(primary, -1),
                    ),
                    Expanded(
                      child: InkWell(
                        key: const Key('moon_calendar_month_title_button'),
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _openGoToDate(primary),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            _monthTitle(context, primary),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            softWrap: true,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

              // Monthly Lunar Overview Summary Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.brightness_3, size: 20, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          whiteDaysList.isNotEmpty
                              ? 'White Days (13, 14, 15): ${DateFormat.d(locale).format(whiteDaysList.first)} - ${DateFormat.d(locale).format(whiteDaysList.last)} ${DateFormat.MMM(locale).format(whiteDaysList.last)}'
                              : (fullMoonDate != null
                                  ? 'Full Moon: ${DateFormat.MMMd(locale).format(fullMoonDate)}'
                                  : 'Moon Phase Calendar View'),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weekday Header Row
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: _WeekdayHeaderRow(locale: locale, weekStart: weekStart),
                ),
              ),

              // Monthly 7-Column Moon Phase Grid
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final rowCount =
                            ((leadingBlanks + monthDays.length) / 7).ceil();
                        final cellWidth = (constraints.maxWidth - 8) / 7;
                        final preferredCellHeight = cellWidth / 0.65;
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
                            final hijri = hijriCalendarWithOffset(
                              date,
                              controller.hijriDateOffset,
                            );

                            final moonInfo = getMoonPhase(
                              date,
                              hijriOffset: controller.hijriDateOffset,
                            );

                            return _MoonDayCell(
                              date: date,
                              primaryLabel: primary == CalendarPrimaryDisplay.hijri
                                  ? hijri.hDay.toString()
                                  : date.day.toString(),
                              secondaryLabel: showSecondary
                                  ? (primary == CalendarPrimaryDisplay.hijri
                                        ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                                        : '${hijri.hDay} ${_shortHijriMonth(date, languageCode, offset: controller.hijriDateOffset)}')
                                  : null,
                              moonInfo: moonInfo,
                              isToday: isToday,
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

class _MoonDayCell extends StatelessWidget {
  const _MoonDayCell({
    required this.date,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.moonInfo,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final String primaryLabel;
  final String? secondaryLabel;
  final MoonPhaseInfo moonInfo;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isWhiteDay = moonInfo.isWhiteDay;
    final isFullMoon = moonInfo.phaseNameKey == 'moonPhaseFullMoon';

    final moonColor = isDark ? const Color(0xFFFDE047) : const Color(0xFFF59E0B);
    final shadowColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday
              ? colors.primaryContainer
              : (isWhiteDay
                  ? colors.primary.withValues(alpha: 0.08)
                  : (isFullMoon ? Colors.amber.withValues(alpha: 0.12) : null)),
          borderRadius: BorderRadius.circular(10),
          border: isWhiteDay && !isToday
              ? Border.all(color: colors.primary.withValues(alpha: 0.5), width: 1.5)
              : (isFullMoon && !isToday
                  ? Border.all(color: const Color(0xFFF59E0B), width: 1.2)
                  : null),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Vector Moon Phase graphic
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CustomPaint(
                      painter: MoonPhasePainter(
                        phaseValue: moonInfo.phaseValue,
                        moonColor: moonColor,
                        shadowColor: shadowColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Date Labels
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        primaryLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: isToday || isWhiteDay || isFullMoon
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isToday
                              ? colors.onPrimaryContainer
                              : (isWhiteDay
                                  ? colors.primary
                                  : (isFullMoon ? Colors.amber.shade800 : null)),
                        ),
                      ),
                      if (secondaryLabel != null)
                        Text(
                          secondaryLabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isToday
                                ? colors.onPrimaryContainer
                                : colors.onSurfaceVariant,
                            fontSize: 8,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Illumination percentage or White Day badge
                  isWhiteDay
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'W${moonInfo.whiteDayNumber}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        )
                      : Text(
                          '${moonInfo.illumination.round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 7.5,
                            color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
