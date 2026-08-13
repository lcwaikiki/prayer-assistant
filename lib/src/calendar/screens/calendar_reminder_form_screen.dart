import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../l10n/l10n.dart';
import '../models/calendar_reminder.dart';

class CalendarReminderFormScreen extends StatefulWidget {
  const CalendarReminderFormScreen({super.key, this.reminder, this.initialDate});

  /// Non-null when editing an existing reminder.
  final CalendarReminder? reminder;

  /// Pre-fills the date when creating a new reminder from a tapped day.
  final DateTime? initialDate;

  @override
  State<CalendarReminderFormScreen> createState() =>
      _CalendarReminderFormScreenState();
}

class _CalendarReminderFormScreenState
    extends State<CalendarReminderFormScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _anchorAt;
  late ReminderRecurrence _recurrence;
  late YearlyCalendarBasis _yearlyBasis;
  String? _titleError;

  bool get _isEditing => widget.reminder != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.reminder;
    _titleController = TextEditingController(text: reminder?.title ?? '');
    _notesController = TextEditingController(text: reminder?.notes ?? '');
    final baseDate =
        reminder?.anchorAt ?? widget.initialDate ?? DateTime.now();
    final now = TimeOfDay.now();
    _anchorAt = reminder?.anchorAt ??
        DateTime(baseDate.year, baseDate.month, baseDate.day, now.hour, now.minute);
    _recurrence = reminder?.recurrence ?? ReminderRecurrence.once;
    _yearlyBasis = reminder?.yearlyBasis ?? YearlyCalendarBasis.gregorian;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _anchorAt,
      firstDate: DateTime(1937),
      lastDate: DateTime(2077),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _anchorAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _anchorAt.hour,
        _anchorAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_anchorAt),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _anchorAt = DateTime(
        _anchorAt.year,
        _anchorAt.month,
        _anchorAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = context.l10n.calendarReminderTitleRequired);
      return;
    }
    final controller = context.read<PrayerAppController>();
    final reminder = CalendarReminder(
      id: widget.reminder?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: _notesController.text.trim(),
      anchorAt: _anchorAt,
      recurrence: _recurrence,
      yearlyBasis: _yearlyBasis,
      enabled: widget.reminder?.enabled ?? true,
    );
    if (_isEditing) {
      controller.updateCalendarReminder(reminder);
    } else {
      controller.addCalendarReminder(reminder);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? l10n.calendarReminderFormTitleEdit
              : l10n.calendarReminderFormTitleNew,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: l10n.calendarReminderTitleLabel,
              hintText: l10n.calendarReminderTitleHint,
              errorText: _titleError,
            ),
            onChanged: (_) {
              if (_titleError != null) {
                setState(() => _titleError = null);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              labelText: l10n.calendarReminderNotesLabel,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Text(
            l10n.calendarReminderDateTimeLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Text(DateFormat.yMMMd(locale).format(_anchorAt)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTime,
                  child: Text(TimeOfDay.fromDateTime(_anchorAt).format(context)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            l10n.calendarReminderRecurrenceLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RecurrenceChip(
                label: l10n.calendarRecurrenceOnce,
                selected: _recurrence == ReminderRecurrence.once,
                onSelected: () =>
                    setState(() => _recurrence = ReminderRecurrence.once),
              ),
              _RecurrenceChip(
                label: l10n.calendarRecurrenceDaily,
                selected: _recurrence == ReminderRecurrence.daily,
                onSelected: () =>
                    setState(() => _recurrence = ReminderRecurrence.daily),
              ),
              _RecurrenceChip(
                label: l10n.calendarRecurrenceWeekly,
                selected: _recurrence == ReminderRecurrence.weekly,
                onSelected: () =>
                    setState(() => _recurrence = ReminderRecurrence.weekly),
              ),
              _RecurrenceChip(
                label: l10n.calendarRecurrenceMonthly,
                selected: _recurrence == ReminderRecurrence.monthly,
                onSelected: () =>
                    setState(() => _recurrence = ReminderRecurrence.monthly),
              ),
              _RecurrenceChip(
                label: l10n.calendarRecurrenceYearly,
                selected: _recurrence == ReminderRecurrence.yearly,
                onSelected: () =>
                    setState(() => _recurrence = ReminderRecurrence.yearly),
              ),
            ],
          ),
          if (_recurrence == ReminderRecurrence.yearly) ...[
            const SizedBox(height: 20),
            Text(
              l10n.calendarYearlyBasisLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _RecurrenceChip(
                  label: l10n.calendarYearlyBasisGregorian,
                  selected: _yearlyBasis == YearlyCalendarBasis.gregorian,
                  onSelected: () => setState(
                    () => _yearlyBasis = YearlyCalendarBasis.gregorian,
                  ),
                ),
                _RecurrenceChip(
                  label: l10n.calendarYearlyBasisHijri,
                  selected: _yearlyBasis == YearlyCalendarBasis.hijri,
                  onSelected: () => setState(
                    () => _yearlyBasis = YearlyCalendarBasis.hijri,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(onPressed: _save, child: Text(l10n.save)),
        ],
      ),
    );
  }
}

class _RecurrenceChip extends StatelessWidget {
  const _RecurrenceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        if (isSelected) {
          onSelected();
        }
      },
    );
  }
}
