import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../../models/calendar_week_start.dart';
import '../../models/prayer_models.dart';
import '../../tesbihat/models/item.dart';
import '../../tesbihat/models/item_group.dart';
import '../../tesbihat/models/reminder_schedulable.dart';
import '../../tesbihat/state/groups_notifier.dart';
import '../../tesbihat/state/items_notifier.dart';

import '../../tesbihat/screens/group_form_screen.dart';
import '../../tesbihat/screens/item_form_screen.dart';
import '../../utils/time_utils.dart';
import '../hijri_utils.dart';
import '../models/calendar_reminder.dart';
import '../../ui/widgets/moon_phase_widget.dart';
import 'calendar_reminder_form_screen.dart';
import 'hijri_date_picker_dialog.dart';

String _formatReminderTime(BuildContext context, CalendarReminder reminder) {
  if (reminder.anchor == CalendarReminderAnchor.prayerTime) {
    final offset = reminder.anchorOffsetMinutes;
    final prayerKey = reminder.anchorPrayerName ?? '';
    final prayerLabel = context.l10n.prayerNameLabel(prayerKey);
    final offsetStr =
        offset != 0 ? (offset > 0 ? ' (+$offset m)' : ' ($offset m)') : '';
    return '$prayerLabel$offsetStr';
  }
  final h = reminder.anchorAt.hour.toString().padLeft(2, '0');
  final m = reminder.anchorAt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String? _formatTaskTime(BuildContext context, TaskItem task) {
  if (task.reminder != null) {
    return _formatReminderTime(context, task.reminder!);
  }
  final reminderAt = task.bead?.reminderAt ?? task.group?.reminderAt;
  if (reminderAt != null) {
    final h = reminderAt.hour.toString().padLeft(2, '0');
    final m = reminderAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  return null;
}

List<TaskItem> _getAllTasks(
  PrayerAppController controller,
  List<Item> beads,
  List<ItemGroup> groups, {
  bool includeRecurring = true,
}) {
  final tasks = <TaskItem>[];
  for (final reminder in controller.calendarReminders) {
    if (!includeRecurring && reminder.recurrence != ReminderRecurrence.once) {
      continue;
    }
    if (reminder.enabled || reminder.isTask) {
      tasks.add(
        TaskItem(
          id: 'cal_${reminder.id}',
          targetId: reminder.id,
          title: reminder.title,
          type: TaskItemType.calendarReminder,
          reminder: reminder,
          occursOnDate: (d) => reminder.occursOn(d),
        ),
      );
    }
  }
  if (controller.showBeadsInCalendar) {
    for (final bead in beads) {
      if (!includeRecurring &&
          bead.reminderRecurrence != ReminderRecurrence.once) {
        continue;
      }
      if (bead.reminderEnabled || bead.isTask) {
        tasks.add(
          TaskItem(
            id: 'bead_${bead.id}',
            targetId: bead.id,
            title: bead.title,
            type: TaskItemType.bead,
            bead: bead,
            targetCount: bead.count,
            occursOnDate: (d) => bead.occursOn(d),
          ),
        );
      }
    }
    for (final group in groups) {
      if (!includeRecurring &&
          group.reminderRecurrence != ReminderRecurrence.once) {
        continue;
      }
      if (group.reminderEnabled || group.isTask) {
        tasks.add(
          TaskItem(
            id: 'group_${group.id}',
            targetId: group.id,
            title: group.title,
            type: TaskItemType.group,
            group: group,
            occursOnDate: (d) => group.occursOn(d),
          ),
        );
      }
    }
  }
  final sortOption = controller.calendarSortOption;
  tasks.sort((a, b) {
    if (sortOption == CalendarSortOption.time) {
      final timeA = a.timeMinutes ?? 9999;
      final timeB = b.timeMinutes ?? 9999;
      final timeComp = timeA.compareTo(timeB);
      if (timeComp != 0) return timeComp;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    } else {
      final titleComp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
      if (titleComp != 0) return titleComp;
      final timeA = a.timeMinutes ?? 9999;
      final timeB = b.timeMinutes ?? 9999;
      return timeA.compareTo(timeB);
    }
  });
  return tasks;
}

Future<bool?> showTaskUncheckConfirmation(
  BuildContext context,
  String taskTitle,
) {
  final l10n = context.l10n;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.calendarTaskUncheckTitle),
      content: Text(
        l10n.calendarTaskUncheckConfirm(taskTitle),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.confirm),
        ),
      ],
    ),
  );
}

List<DateTime> _getWeekDays(DateTime centerDate, CalendarWeekStart weekStart) {
  final currentWeekday = centerDate.weekday; // 1 (Mon) .. 7 (Sun)
  int diff;
  if (weekStart == CalendarWeekStart.sunday) {
    diff = currentWeekday % 7;
  } else {
    diff = currentWeekday - 1;
  }
  final weekStartDate = centerDate.subtract(Duration(days: diff));
  return List.generate(
    7,
    (i) => DateTime(weekStartDate.year, weekStartDate.month, weekStartDate.day + i),
  );
}

String _shortHijriMonth(DateTime date, String languageCode, {int offset = 0}) {
  final month = HijriMonth.fromDate(date, offset: offset);
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
class HijriCalendarView extends ConsumerStatefulWidget {
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
  ConsumerState<HijriCalendarView> createState() => _HijriCalendarViewState();
}

class _HijriCalendarViewState extends ConsumerState<HijriCalendarView> {
  late DateTime _focusedDate;
  bool _autoOpenTriggered = false;
  String? _selectedTaskId;

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
          DayDetailSheet(date: date, primary: primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final beads = ref.watch(itemsNotifierProvider);
    final groups = ref.watch(groupsNotifierProvider);
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        final primary = controller.calendarPrimaryDisplay;
        final showSecondary = controller.showSecondaryCalendarDate;
        final weekStart = controller.calendarWeekStart;
        final monthDays = _monthDays(primary);
        final int leadingBlanks = weekStart.leadingBlanks(monthDays.first);
        final today = DateTime.now();
        final locale = Localizations.localeOf(context).toString();
        final allTasks = _getAllTasks(
          controller,
          beads,
          groups,
          includeRecurring: false,
        );
        final selectedTask = allTasks.cast<TaskItem?>().firstWhere(
              (t) => t?.id == _selectedTaskId,
              orElse: () => null,
            );

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
                      showSecondary ? Icons.visibility : Icons.visibility_off,
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
                    tooltip: context.l10n.calendarGoToDate,
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
            if (allTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          isExpanded: true,
                          value: selectedTask?.id,
                          hint: const Text('Track Task in Month: All'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Events & Reminders'),
                            ),
                            for (final task in allTasks)
                              DropdownMenuItem<String?>(
                                value: task.id,
                                child: Builder(
                                  builder: (context) {
                                    final showTime = controller.calendarSortOption ==
                                        CalendarSortOption.time;
                                    final timeStr = showTime
                                        ? _formatTaskTime(context, task)
                                        : null;
                                    final typeStr = task.type == TaskItemType.bead
                                        ? "Bead"
                                        : (task.type == TaskItemType.group
                                            ? "Group"
                                            : "Reminder");
                                    final label = timeStr != null
                                        ? '$timeStr • ${task.title} ($typeStr)'
                                        : '${task.title} ($typeStr)';
                                    return Text(
                                      label,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedTaskId = val),
                        ),
                      ),
                    ),
                    if (_selectedTaskId != null)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        tooltip: 'Clear Task Filter',
                        visualDensity: VisualDensity.compact,
                        onPressed: () =>
                            setState(() => _selectedTaskId = null),
                      ),
                    PopupMenuButton<CalendarSortOption>(
                      key: const Key('month_calendar_sort_menu_button'),
                      tooltip: context.l10n.calendarSortOption,
                      icon: Icon(
                        controller.calendarSortOption == CalendarSortOption.time
                            ? Icons.access_time
                            : Icons.sort_by_alpha,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      initialValue: controller.calendarSortOption,
                      onSelected: (option) =>
                          controller.updateCalendarSortOption(option),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: CalendarSortOption.alphabetical,
                          child: Row(
                            children: [
                              const Icon(Icons.sort_by_alpha, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l10n.calendarSortByName),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: CalendarSortOption.time,
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(context.l10n.calendarSortByTime),
                            ],
                          ),
                        ),
                      ],
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
                child: _WeekdayHeaderRow(locale: locale, weekStart: weekStart),
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
                          final hasReminder = controller.showCalendarReminderDots &&
                              controller.calendarReminders.any(
                                (reminder) =>
                                    reminder.enabled &&
                                    reminder.recurrence == ReminderRecurrence.once &&
                                    reminder.occursOn(date),
                              );
                          final isHoliday = controller.showIslamicHolidays &&
                              islamicHolidayKey(date, offset: controller.hijriDateOffset) != null;
                          final dateKey =
                              '${date.year.toString().padLeft(4, '0')}-'
                              '${date.month.toString().padLeft(2, '0')}-'
                              '${date.day.toString().padLeft(2, '0')}';
                          final hasFastingLog = controller.showFastingBadges &&
                              controller.fastingLogs.containsKey(dateKey);
                          final languageCode =
                              Localizations.localeOf(context).languageCode;
                          final hijri = hijriCalendarWithOffset(
                            date,
                            controller.hijriDateOffset,
                          );
                          final taskOccurs = selectedTask?.occursOn(date) ?? false;
                          final isTaskCompleted = selectedTask != null &&
                              controller.isTaskCompleted(selectedTask.id, date);
                          return _DayCell(
                            primaryLabel:
                                primary == CalendarPrimaryDisplay.hijri
                                ? hijri.hDay.toString()
                                : date.day.toString(),
                            secondaryLabel: showSecondary
                                ? (primary == CalendarPrimaryDisplay.hijri
                                      ? '${date.day} ${DateFormat.MMM(locale).format(date)}'
                                      : '${hijri.hDay} ${_shortHijriMonth(date, languageCode, offset: controller.hijriDateOffset)}')
                                : null,
                            isToday: isToday,
                            hasReminder: hasReminder,
                            isHoliday: isHoliday,
                            hasFastingLog: hasFastingLog,
                            taskOccurs: taskOccurs,
                            isTaskCompleted: isTaskCompleted,
                            onToggleTask: selectedTask == null || !taskOccurs
                                ? null
                                : () async {
                                    if (isTaskCompleted) {
                                      final confirm =
                                          await showTaskUncheckConfirmation(
                                        context,
                                        selectedTask.title,
                                      );
                                      if (confirm == true) {
                                        controller.setTaskCompletion(
                                          selectedTask.id,
                                          date,
                                          false,
                                        );
                                      }
                                    } else {
                                      controller.setTaskCompletion(
                                        selectedTask.id,
                                        date,
                                        true,
                                      );
                                    }
                                  },
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

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.isToday,
    required this.hasReminder,
    required this.isHoliday,
    required this.hasFastingLog,
    required this.onTap,
    this.taskOccurs = false,
    this.isTaskCompleted = false,
    this.onToggleTask,
  });

  final String primaryLabel;
  final String? secondaryLabel;
  final bool isToday;
  final bool hasReminder;
  final bool isHoliday;
  final bool hasFastingLog;
  final VoidCallback onTap;
  final bool taskOccurs;
  final bool isTaskCompleted;
  final VoidCallback? onToggleTask;

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
                  if (taskOccurs)
                    GestureDetector(
                      onTap: onToggleTask,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          isTaskCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: 16,
                          color: isTaskCompleted
                              ? (isToday
                                  ? colors.onPrimaryContainer
                                  : colors.primary)
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else if (hasReminder || hasFastingLog)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasReminder)
                          Container(
                            margin: const EdgeInsets.only(top: 3, right: 2),
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isToday ? colors.onPrimaryContainer : colors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (hasFastingLog)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.nights_stay,
                              size: 8,
                              color: isToday ? colors.onPrimaryContainer : Colors.amber.shade800,
                            ),
                          ),
                      ],
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

class DayDetailSheet extends ConsumerStatefulWidget {
  const DayDetailSheet({super.key, required this.date, required this.primary});

  final DateTime date;
  final CalendarPrimaryDisplay primary;

  @override
  ConsumerState<DayDetailSheet> createState() => _DayDetailSheetState();
}

class _DayDetailSheetState extends ConsumerState<DayDetailSheet> {
  late DateTime _date = widget.date;
  bool _showWeekTasks = false;
  bool _tasksExpanded = true;
  bool _prayerMoonExpanded = true;
  bool _isTaskSearchOpen = false;
  final TextEditingController _taskSearchController = TextEditingController();
  String _taskSearchQuery = '';

  @override
  void dispose() {
    _taskSearchController.dispose();
    super.dispose();
  }

  void _shiftDay(int delta) {
    setState(() {
      _date = DateTime(_date.year, _date.month, _date.day + delta);
    });
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  void _openTaskTarget(
    BuildContext context,
    TaskItem task,
    PrayerAppController controller,
    List<Item> beads,
    List<ItemGroup> groups, {
    DateTime? taskDate,
  }) {
    switch (task.type) {
      case TaskItemType.bead:
        final item = task.bead ??
            beads.where((b) => b.id == task.targetId).firstOrNull;
        if (item != null) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          try {
            context.read<PrayerAppController>().setTab(4);
          } catch (_) {}
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ItemFormScreen(
                itemToEdit: item,
                readOnly: true,
              ),
            ),
          );
        }
      case TaskItemType.group:
        final group = task.group ??
            groups.where((g) => g.id == task.targetId).firstOrNull;
        if (group != null) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          try {
            context.read<PrayerAppController>().setTab(4);
          } catch (_) {}
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => GroupFormScreen(
                groupToEdit: group,
                readOnly: true,
              ),
            ),
          );
        }
      case TaskItemType.calendarReminder:
        final reminder = task.reminder ??
            controller.calendarReminders
                .where((r) => r.id == task.targetId)
                .firstOrNull;
        if (reminder != null) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => CalendarReminderFormScreen(
                reminder: reminder,
                readOnly: true,
              ),
            ),
          );
        } else if (taskDate != null &&
            (_date.year != taskDate.year ||
                _date.month != taskDate.month ||
                _date.day != taskDate.day)) {
          setState(() {
            _date = taskDate;
            _showWeekTasks = false;
          });
        }
    }
  }

  Widget _buildTaskItemWidget(
    BuildContext context,
    PrayerAppController controller,
    List<Item> beads,
    List<ItemGroup> groups,
    TaskItem task,
    DateTime date, {
    required String keyPrefix,
  }) {
    final isCompleted = controller.isTaskCompleted(task.id, date);
    return ListTile(
      key: Key('${keyPrefix}_task_${task.id}_${_dateKey(date)}'),
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Checkbox(
        value: isCompleted,
        onChanged: (_) async {
          if (isCompleted) {
            final confirm = await showTaskUncheckConfirmation(
              context,
              task.title,
            );
            if (confirm == true) {
              controller.setTaskCompletion(task.id, date, false);
            }
          } else {
            controller.setTaskCompletion(task.id, date, true);
          }
        },
      ),
      title: Text(
        task.title,
        style: TextStyle(
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Builder(
        builder: (context) {
          final showTime =
              controller.calendarSortOption == CalendarSortOption.time;
          final timeStr = showTime ? _formatTaskTime(context, task) : null;
          final baseSubtitle = task.type == TaskItemType.bead
              ? (task.targetCount != null
                  ? context.l10n.calendarTaskBeadTarget(task.targetCount!)
                  : context.l10n.calendarTaskGroupReminder)
              : (task.type == TaskItemType.group
                  ? context.l10n.calendarTaskGroupReminder
                  : context.l10n.calendarTaskCalendarReminder);
          return Text(
            timeStr != null ? '$timeStr • $baseSubtitle' : baseSubtitle,
          );
        },
      ),
      onTap: () => _openTaskTarget(
        context,
        task,
        controller,
        beads,
        groups,
      ),
    );
  }

  List<Widget> _buildDayTasksList(
    BuildContext context,
    PrayerAppController controller,
    List<Item> beads,
    List<ItemGroup> groups,
    List<TaskItem> allTasks,
    DateTime date,
  ) {
    final dayTasks =
        allTasks.where((t) => t.occursOn(date)).toList(growable: false);
    if (dayTasks.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _taskSearchQuery.trim().isNotEmpty
                ? context.l10n.noResults
                : context.l10n.calendarNoTasksOnDay,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ];
    }
    return dayTasks.map((task) {
      return _buildTaskItemWidget(
        context,
        controller,
        beads,
        groups,
        task,
        date,
        keyPrefix: 'day',
      );
    }).toList(growable: false);
  }

  List<Widget> _buildWeekTasksList(
    BuildContext context,
    PrayerAppController controller,
    List<Item> beads,
    List<ItemGroup> groups,
    List<TaskItem> allTasks,
    DateTime centerDate,
    String locale,
  ) {
    final weekDays = _getWeekDays(centerDate, controller.calendarWeekStart);
    final widgets = <Widget>[];
    for (final day in weekDays) {
      final dayTasks =
          allTasks.where((t) => t.occursOn(day)).toList(growable: false);
      if (dayTasks.isEmpty) continue;
      final dayLabel = DateFormat.MMMEd(locale).format(day);
      final isToday = day.year == DateTime.now().year &&
          day.month == DateTime.now().month &&
          day.day == DateTime.now().day;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            isToday ? '$dayLabel (${context.l10n.today})' : dayLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isToday ? Theme.of(context).colorScheme.primary : null,
                ),
          ),
        ),
      );
      for (final task in dayTasks) {
        widgets.add(
          _buildTaskItemWidget(
            context,
            controller,
            beads,
            groups,
            task,
            day,
            keyPrefix: 'week',
          ),
        );
      }
    }
    if (widgets.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            _taskSearchQuery.trim().isNotEmpty
                ? context.l10n.noResults
                : context.l10n.calendarNoTasksOnWeek,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ];
    }
    return widgets;
  }

  String _hijriDateLabel(BuildContext context, DateTime date, String languageCode) {
    final controller = context.read<PrayerAppController>();
    final hijri = hijriCalendarWithOffset(date, controller.hijriDateOffset);
    return '${hijri.hDay} '
        '${HijriMonth.fromDate(date, offset: controller.hijriDateOffset).longMonthName(languageCode)} '
        '${hijri.hYear}';
  }

  String _primaryDateLabel(BuildContext context, CalendarPrimaryDisplay primary, String locale) {
    return primary == CalendarPrimaryDisplay.gregorian
        ? DateFormat.yMMMMd(locale).format(_date)
        : _hijriDateLabel(context, _date, locale.split('-').first);
  }

  String _secondaryDateLabel(BuildContext context, CalendarPrimaryDisplay primary, String locale) {
    return primary == CalendarPrimaryDisplay.gregorian
        ? _hijriDateLabel(context, _date, locale.split('-').first)
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

  Future<void> _deleteOccurrence(
    BuildContext context,
    PrayerAppController controller,
    CalendarReminder reminder,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.calendarDeleteOccurrence),
        content: Text(l10n.calendarDeleteOccurrenceConfirm),
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
    if (confirmed != true || !context.mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final day = _date;
    await controller.excludeCalendarReminderOccurrence(reminder.id, day);
    if (!context.mounted) {
      return;
    }
    Navigator.pop(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Expanded(child: Text(l10n.calendarOccurrenceDeleted)),
            TextButton(
              onPressed: () {
                controller.restoreCalendarReminderOccurrence(reminder.id, day);
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
    final beads = ref.watch(itemsNotifierProvider);
    final groups = ref.watch(groupsNotifierProvider);
    final controller = context.watch<PrayerAppController>();
    final allTasks = _getAllTasks(controller, beads, groups);
    final sortOption = controller.calendarSortOption;
    final reminders = controller.calendarReminders
        .where((reminder) => reminder.occursOn(_date))
        .toList(growable: true)
      ..sort((a, b) {
        if (sortOption == CalendarSortOption.time) {
          final timeA = a.timeMinutes;
          final timeB = b.timeMinutes;
          final timeComp = timeA.compareTo(timeB);
          if (timeComp != 0) return timeComp;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        } else {
          final titleComp =
              a.title.toLowerCase().compareTo(b.title.toLowerCase());
          if (titleComp != 0) return titleComp;
          return a.timeMinutes.compareTo(b.timeMinutes);
        }
      });
    final locale = Localizations.localeOf(context).toString();
    final String? holiday = controller.showIslamicHolidays
        ? islamicHolidayForDate(
            _date,
            (key) => switch (key) {
              'holiday_islamic_new_year' => l10n.holiday_islamic_new_year,
              'holiday_ashura' => l10n.holiday_ashura,
              'holiday_mawlid' => l10n.holiday_mawlid,
              'holiday_isra_miraj' => l10n.holiday_isra_miraj,
              'holiday_laylat_barat' => l10n.holiday_laylat_barat,
              'holiday_ramadan_first' => l10n.holiday_ramadan_first,
              'holiday_laylat_qadr' => l10n.holiday_laylat_qadr,
              'holiday_eid_fitr' => l10n.holiday_eid_fitr,
              'holiday_arafah' => l10n.holiday_arafah,
              'holiday_eid_adha' => l10n.holiday_eid_adha,
              _ => key,
            },
            offset: controller.hijriDateOffset,
          )
        : null;
    final weekDays = _getWeekDays(_date, controller.calendarWeekStart);
    final totalTasks = _showWeekTasks
        ? weekDays.fold<int>(
            0,
            (sum, d) => sum + allTasks.where((t) => t.occursOn(d)).length,
          )
        : allTasks.where((t) => t.occursOn(_date)).length;
    final completedTasks = _showWeekTasks
        ? weekDays.fold<int>(
            0,
            (sum, d) =>
                sum +
                allTasks
                    .where((t) =>
                        t.occursOn(d) && controller.isTaskCompleted(t.id, d))
                    .length,
          )
        : allTasks
            .where((t) =>
                t.occursOn(_date) && controller.isTaskCompleted(t.id, _date))
            .length;

    return PopScope(
      canPop: !_isTaskSearchOpen && _taskSearchQuery.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && (_isTaskSearchOpen || _taskSearchQuery.isNotEmpty)) {
          setState(() {
            _isTaskSearchOpen = false;
            _taskSearchQuery = '';
            _taskSearchController.clear();
          });
        }
      },
      child: SafeArea(
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
                        _primaryDateLabel(context, widget.primary, locale),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _secondaryDateLabel(context, widget.primary, locale),
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
            if (holiday != null) ...[
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.amber.shade900,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            const SizedBox(height: 12),
            Builder(
              builder: (context) {
                final day = controller.prayerDayFor(_date);
                return Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: const Key('prayer_times_expansion_tile'),
                      initiallyExpanded: _prayerMoonExpanded,
                      onExpansionChanged: (expanded) =>
                          setState(() => _prayerMoonExpanded = expanded),
                      tilePadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      childrenPadding:
                          const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      leading: Icon(
                        day != null ? Icons.access_time_filled : Icons.nightlight_round,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        day != null
                            ? '${context.l10n.datesPrayerTimesTab} & ${context.l10n.moonPhaseTitle}'
                            : context.l10n.moonPhaseTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      children: [
                        MoonPhaseCard(
                          date: _date,
                          hijriOffset: controller.hijriDateOffset,
                        ),
                        if (day != null) ...[
                          const SizedBox(height: 12),
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
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            if (reminders.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.calendarNoRemindersOnDay),
              )
            else
              ...reminders.map(
                (reminder) {
                  final showTime =
                      controller.calendarSortOption == CalendarSortOption.time;
                  final timeStr =
                      showTime ? _formatReminderTime(context, reminder) : null;
                  final recurrenceText = _recurrenceLabel(context, reminder);
                  final subtitleText = timeStr != null
                      ? '$timeStr • $recurrenceText'
                      : recurrenceText;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => CalendarReminderFormScreen(
                            reminder: reminder,
                            readOnly: true,
                          ),
                        ),
                      );
                    },
                    title: Text(reminder.title),
                    subtitle: Text(subtitleText),
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
                        if (reminder.recurrence != ReminderRecurrence.once)
                          IconButton(
                            key: Key('delete_occurrence_${reminder.id}'),
                            tooltip: l10n.calendarDeleteOccurrence,
                            icon: const Icon(Icons.event_busy),
                            onPressed: () =>
                                _deleteOccurrence(context, controller, reminder),
                          ),
                        IconButton(
                          tooltip: l10n.calendarDeleteReminder,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _deleteWithUndo(context, controller, reminder),
                        ),
                      ],
                    ),
                  );
                },
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
            const SizedBox(height: 12),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  key: const Key('tasks_expansion_tile'),
                  initiallyExpanded: _tasksExpanded,
                  onExpansionChanged: (expanded) =>
                      setState(() => _tasksExpanded = expanded),
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  childrenPadding:
                      const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  leading: Icon(
                    Icons.task_alt,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.calendarTasksToDos,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n.calendarTasksCompletedCount(
                            completedTasks,
                            totalTasks,
                          ),
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  children: [
                    if (_isTaskSearchOpen || _taskSearchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextField(
                          key: const Key('tasks_search_field'),
                          controller: _taskSearchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            hintText: '${l10n.search}...',
                            prefixIcon: const Icon(Icons.search, size: 20),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_taskSearchQuery.isNotEmpty)
                                  IconButton(
                                    key: const Key('tasks_search_clear_button'),
                                    icon: const Icon(Icons.clear, size: 18),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 32,
                                      minHeight: 32,
                                    ),
                                    onPressed: () {
                                      _taskSearchController.clear();
                                      setState(() => _taskSearchQuery = '');
                                    },
                                  ),
                                IconButton(
                                  key: const Key('tasks_search_close_button'),
                                  icon: const Icon(Icons.close, size: 18),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                  onPressed: () {
                                    _taskSearchController.clear();
                                    setState(() {
                                      _taskSearchQuery = '';
                                      _isTaskSearchOpen = false;
                                    });
                                  },
                                ),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (value) =>
                              setState(() => _taskSearchQuery = value),
                        ),
                      )
                    else
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          PopupMenuButton<CalendarSortOption>(
                            key: const Key('calendar_sort_menu_button'),
                            tooltip: l10n.calendarSortOption,
                            initialValue: controller.calendarSortOption,
                            onSelected: (option) =>
                                controller.updateCalendarSortOption(option),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: CalendarSortOption.alphabetical,
                                child: Row(
                                  children: [
                                    const Icon(Icons.sort_by_alpha, size: 18),
                                    const SizedBox(width: 8),
                                    Text(l10n.calendarSortByName),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: CalendarSortOption.time,
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 18),
                                    const SizedBox(width: 8),
                                    Text(l10n.calendarSortByTime),
                                  ],
                                ),
                              ),
                            ],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    controller.calendarSortOption ==
                                            CalendarSortOption.time
                                        ? Icons.access_time
                                        : Icons.sort_by_alpha,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    controller.calendarSortOption ==
                                            CalendarSortOption.time
                                        ? l10n.calendarSortByTime
                                        : l10n.calendarSortByName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                value: false,
                                label: Text(l10n.calendarTasksFilterDay),
                              ),
                              ButtonSegment(
                                value: true,
                                label: Text(l10n.calendarTasksFilterWeek),
                              ),
                            ],
                            selected: {_showWeekTasks},
                            onSelectionChanged: (selection) => setState(
                              () => _showWeekTasks = selection.first,
                            ),
                            style: const ButtonStyle(
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          FilterChip(
                            key: const Key('day_detail_toggle_beads_button'),
                            tooltip: controller.showBeadsInCalendar
                                ? l10n.calendarHideBeads
                                : l10n.calendarShowBeads,
                            avatar: Icon(
                              controller.showBeadsInCalendar
                                  ? Icons.check
                                  : Icons.circle_outlined,
                              size: 14,
                              color: controller.showBeadsInCalendar
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            label: Text(
                              l10n.tabTesbih,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            selected: controller.showBeadsInCalendar,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            onSelected: (selected) =>
                                controller.updateShowBeadsInCalendar(selected),
                          ),
                          IconButton(
                            key: const Key('tasks_search_button'),
                            tooltip: l10n.search,
                            icon: const Icon(Icons.search, size: 20),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: () =>
                                setState(() => _isTaskSearchOpen = true),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),
                    Builder(
                      builder: (context) {
                        final q = _taskSearchQuery.trim().toLowerCase();
                        final filteredTasks = q.isEmpty
                            ? allTasks
                            : allTasks
                                .where((t) =>
                                    t.title.toLowerCase().contains(q) ||
                                    t.notes.toLowerCase().contains(q))
                                .toList(growable: false);

                        if (!_showWeekTasks) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildDayTasksList(
                              context,
                              controller,
                              beads,
                              groups,
                              filteredTasks,
                              _date,
                            ),
                          );
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: _buildWeekTasksList(
                              context,
                              controller,
                              beads,
                              groups,
                              filteredTasks,
                              _date,
                              locale,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
