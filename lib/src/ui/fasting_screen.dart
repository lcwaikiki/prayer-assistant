import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../calendar/hijri_utils.dart';
import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/calendar_week_start.dart';
import '../models/fasting_models.dart';
import '../models/prayer_models.dart';
import 'widgets/iftar_suhoor_countdown_card.dart';
import 'widgets/moon_phase_widget.dart';
import '../calendar/screens/moon_calendar_screen.dart';

String _shortHijriMonth(DateTime date, String languageCode) {
  final month = HijriMonth.fromDate(date);
  final full = month.longMonthName(languageCode);
  return full.length > 3 ? '${full.substring(0, 3)}.' : full;
}

class FastingScreen extends StatefulWidget {
  const FastingScreen({
    super.key,
    this.showAppBar = true,
  });

  final bool showAppBar;

  @override
  State<FastingScreen> createState() => _FastingScreenState();
}


class _FastingScreenState extends State<FastingScreen> {
  late DateTime _focusedDate = DateTime.now();

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

  void _openFastingLogDialog(
    BuildContext context,
    PrayerAppController controller,
    DateTime date,
  ) {
    final existing = controller.getFastingLog(date);
    final dateStr = DateFormat('EEEE, MMM d, yyyy').format(date);

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.logFastAction,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(context.l10n.fastingTypeRamadan),
                  trailing: existing?.type == FastingType.ramadan
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.toggleFastingLog(date, FastingType.ramadan);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.wb_sunny_outlined, color: Colors.blue),
                  title: Text(context.l10n.fastingTypeSunnah),
                  trailing: existing?.type == FastingType.sunnah
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.toggleFastingLog(date, FastingType.sunnah);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.purple),
                  title: Text(context.l10n.fastingTypeQadaa),
                  trailing: existing?.type == FastingType.qadaa
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () {
                    controller.toggleFastingLog(date, FastingType.qadaa);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                if (existing != null) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: Text(context.l10n.removeFastLog),
                    onTap: () {
                      controller.removeFastingLog(date);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final primary = controller.calendarPrimaryDisplay;
        final showSecondary = controller.showSecondaryCalendarDate;
        final weekStart = controller.calendarWeekStart;
        final monthDays = _monthDays(primary);
        final int leadingBlanks = weekStart.leadingBlanks(monthDays.first);
        final today = DateTime.now();
        final locale = Localizations.localeOf(context).toString();
        final fastingLogs = controller.fastingLogs;

        // Calculate statistics
        final totalLogged = fastingLogs.length;
        final ramadanCount = fastingLogs.values
            .where((l) => l.type == FastingType.ramadan)
            .length;
        final sunnahCount = fastingLogs.values
            .where((l) => l.type == FastingType.sunnah)
            .length;
        final qadaaCount = fastingLogs.values
            .where((l) => l.type == FastingType.qadaa)
            .length;

        // Upcoming Sunnah Days in next 7 days
        final upcomingSunnah = <SunnahDayInfo>[];
        for (int i = 0; i < 7; i++) {
          final checkDate = today.add(Duration(days: i));
          final info = SunnahDayInfo.checkDate(checkDate);
          if (info != null && !info.categories.contains(SunnahCategory.ramadan)) {
            upcomingSunnah.add(info);
          }
        }

        return Scaffold(
          appBar: widget.showAppBar
              ? AppBar(
                  title: Text(context.l10n.fastingTitle),
                )
              : null,
          body: SingleChildScrollView(

            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Live Countdown Card
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: IftarSuhoorCountdownCard(),
                ),

                // Moon Phase & White Days Card
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: MoonPhaseCard(
                    date: today,
                    hijriOffset: controller.hijriDateOffset,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MoonCalendarScreen(initialDate: today),
                        ),
                      );
                    },
                  ),
                ),


                // 2. Summary Statistics Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: context.l10n.totalFastsLogged,
                          value: '$totalLogged',
                          icon: Icons.calendar_today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          title: context.l10n.fastingTypeRamadan,
                          value: '$ramadanCount',
                          icon: Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: context.l10n.fastingTypeSunnah,
                          value: '$sunnahCount',
                          icon: Icons.wb_sunny_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          title: context.l10n.fastingTypeQadaa,
                          value: '$qadaaCount',
                          icon: Icons.history,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Upcoming Sunnah Fasting Days
                if (upcomingSunnah.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.l10n.upcomingSunnahDays,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 105,
                    child: ListView.builder(

                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingSunnah.length,
                      itemBuilder: (context, index) {
                        final info = upcomingSunnah[index];
                        final dateStr = DateFormat('E, MMM d').format(info.date);
                        final isToday = info.date.year == today.year &&
                            info.date.month == today.month &&
                            info.date.day == today.day;
                        final logged = controller.getFastingLog(info.date);

                        return Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            color: isToday
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : null,
                            child: InkWell(
                              onTap: () => _openFastingLogDialog(
                                context,
                                controller,
                                info.date,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dateStr,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (logged != null)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      info.categories.contains(
                                              SunnahCategory.whiteDays)
                                          ? context.l10n.whiteDaysTitle
                                          : context.l10n.mondayThursdayTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 10),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Annual Fasting Habit Calendar Logger
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.l10n.fastingCalendarLogger,
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
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () => controller
                                    .updateShowSecondaryCalendarDate(
                                        !showSecondary),
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
                                child:
                                    SegmentedButton<CalendarPrimaryDisplay>(
                                  segments: [
                                    ButtonSegment(
                                      value: CalendarPrimaryDisplay.hijri,
                                      label: Text(
                                        context.l10n.calendarYearlyBasisHijri,
                                      ),
                                    ),
                                    ButtonSegment(
                                      value:
                                          CalendarPrimaryDisplay.gregorian,
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
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
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
                              final isToday = date.year == today.year &&
                                  date.month == today.month &&
                                  date.day == today.day;
                              final languageCode =
                                  Localizations.localeOf(context).languageCode;
                              final logged = controller.getFastingLog(date);

                              final primaryLabel =
                                  primary == CalendarPrimaryDisplay.hijri
                                      ? HijriCalendar.fromDate(date)
                                          .hDay
                                          .toString()
                                      : date.day.toString();

                              final secondaryLabel = showSecondary
                                  ? (primary == CalendarPrimaryDisplay.hijri
                                      ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                                      : '${HijriCalendar.fromDate(date).hDay} ${_shortHijriMonth(date, languageCode)}')
                                  : null;

                              return _FastingDayCell(
                                primaryLabel: primaryLabel,
                                secondaryLabel: secondaryLabel,
                                log: logged,
                                isToday: isToday,
                                onTap: () => _openFastingLogDialog(
                                  context,
                                  controller,
                                  date,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _FastingDayCell extends StatelessWidget {
  const _FastingDayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.log,
    required this.isToday,
    required this.onTap,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final FastingLog? log;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color bgColor = colorScheme.surfaceContainerHighest;
    Color primaryTextColor = colorScheme.onSurface;
    Color secondaryTextColor = colorScheme.onSurfaceVariant;
    IconData? logIcon;
    Color? iconColor;

    if (log != null) {
      switch (log!.type) {
        case FastingType.ramadan:
          bgColor = Colors.amber.withOpacity(0.25);
          logIcon = Icons.star;
          iconColor = Colors.amber;
          break;
        case FastingType.sunnah:
          bgColor = Colors.blue.withOpacity(0.25);
          logIcon = Icons.wb_sunny_outlined;
          iconColor = Colors.blue;
          break;
        case FastingType.qadaa:
          bgColor = Colors.purple.withOpacity(0.25);
          logIcon = Icons.history;
          iconColor = Colors.purple;
          break;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
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
                  if (logIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(logIcon, size: 11, color: iconColor),
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
