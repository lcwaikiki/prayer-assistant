import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

import '../../l10n/l10n.dart';
import '../../models/prayer_models.dart';
import '../hijri_utils.dart';

/// Modal picker for a single date, styled like the calendar tab's month
/// grid: a Hijri/Gregorian primary display with the other shown as a
/// secondary label, month navigation, and a today shortcut. Returns the
/// picked date with its time part dropped, or null when dismissed.
Future<DateTime?> showAnchorDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  bool hijriPreferred = false,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _AnchorDatePickerSheet(
      initialDate: initialDate,
      hijriPreferred: hijriPreferred,
    ),
  );

}

class _AnchorDatePickerSheet extends StatefulWidget {
  const _AnchorDatePickerSheet({
    this.initialDate,
    this.hijriPreferred = false,
  });

  final DateTime? initialDate;

  /// Opens in Hijri primary display when true (e.g. when the reminder's
  /// recurrence basis is Hijri); otherwise defaults to Gregorian.
  final bool hijriPreferred;

  @override
  State<_AnchorDatePickerSheet> createState() => _AnchorDatePickerSheetState();
}

class _AnchorDatePickerSheetState extends State<_AnchorDatePickerSheet> {
  late DateTime _focusedDate;
  late CalendarPrimaryDisplay _primary;
  bool _showSecondary = true;
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate;
    _focusedDate = initial ?? DateTime.now();
    _primary = widget.hijriPreferred
        ? CalendarPrimaryDisplay.hijri
        : CalendarPrimaryDisplay.gregorian;
    _selected = initial == null
        ? null
        : DateTime(initial.year, initial.month, initial.day);
  }

  void _shiftMonth(int delta) {
    setState(() {
      _focusedDate = _primary == CalendarPrimaryDisplay.hijri
          ? HijriMonth.fromDate(_focusedDate).shift(delta).gregorianStart
          : DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
    });
  }

  void _jumpToToday() {
    setState(() => _focusedDate = DateTime.now());
  }

  List<DateTime> _monthDays() {
    if (_primary == CalendarPrimaryDisplay.gregorian) {
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

  String _monthTitle(BuildContext context) {
    if (_primary == CalendarPrimaryDisplay.gregorian) {
      return DateFormat(
        'MMMM yyyy',
        Localizations.localeOf(context).toString(),
      ).format(_focusedDate);
    }
    final hijriMonth = HijriMonth.fromDate(_focusedDate);
    final languageCode = Localizations.localeOf(context).languageCode;
    return '${hijriMonth.longMonthName(languageCode)} ${hijriMonth.year}';
  }

  void _select(DateTime date) {
    Navigator.pop(context, DateTime(date.year, date.month, date.day));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final monthDays = _monthDays();
    final leadingBlanks = monthDays.first.weekday % 7;
    final today = DateTime.now();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.calendarPickAnchorDate,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<CalendarPrimaryDisplay>(
                    segments: [
                      ButtonSegment(
                        value: CalendarPrimaryDisplay.hijri,
                        label: Text(l10n.calendarYearlyBasisHijri),
                      ),
                      ButtonSegment(
                        value: CalendarPrimaryDisplay.gregorian,
                        label: Text(l10n.calendarYearlyBasisGregorian),
                      ),
                    ],
                    selected: {_primary},
                    onSelectionChanged: (selection) =>
                        setState(() => _primary = selection.first),
                  ),
                ),
                IconButton(
                  tooltip: _showSecondary
                      ? l10n.calendarHideSecondary
                      : l10n.calendarShowSecondary,
                  icon: Icon(
                    _showSecondary
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _showSecondary = !_showSecondary),
                ),
                IconButton(
                  tooltip: l10n.todayShort,
                  icon: const Icon(Icons.today),
                  onPressed: _jumpToToday,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  tooltip: l10n.calendarPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shiftMonth(-1),
                ),
                Expanded(
                  child: Text(
                    _monthTitle(context),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: l10n.calendarNextMonth,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shiftMonth(1),
                ),
              ],
            ),
            _WeekdayHeaderRow(locale: locale),
            SizedBox(
              height: 280,
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.85,
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
                  final isSelected =
                      _selected != null &&
                      _selected!.year == date.year &&
                      _selected!.month == date.month &&
                      _selected!.day == date.day;
                  return _PickerDayCell(
                    primaryLabel:
                        _primary == CalendarPrimaryDisplay.hijri
                            ? HijriCalendar.fromDate(date).hDay.toString()
                            : date.day.toString(),
                    secondaryLabel: _showSecondary
                        ? (_primary == CalendarPrimaryDisplay.hijri
                              ? date.day.toString()
                              : HijriCalendar.fromDate(date).hDay.toString())
                        : null,
                    isToday: isToday,
                    isSelected: isSelected,
                    onTap: () => _select(date),
                  );
                },
              ),
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

class _PickerDayCell extends StatelessWidget {
  const _PickerDayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool isToday;
  final bool isSelected;
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
              : (isSelected ? colors.secondaryContainer : null),
          borderRadius: BorderRadius.circular(10),
          border: isSelected && !isToday
              ? Border.all(color: colors.secondary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              primaryLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: isToday || isSelected
                    ? FontWeight.w700
                    : FontWeight.w500,
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
          ],
        ),
      ),
    );
  }
}