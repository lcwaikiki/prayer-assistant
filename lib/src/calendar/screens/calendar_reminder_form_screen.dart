import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/local_database.dart';
import '../../tesbihat/services/prayer_anchor_resolver.dart';
import '../../utils/time_utils.dart';
import '../models/calendar_reminder.dart';
import 'calendar_anchor_date_picker.dart';

enum _OffsetDirection { onTime, before, after }

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
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late DateTime _anchorAt;
  late ReminderRecurrence _recurrence;
  late CalendarBasis _monthlyBasis;
  late CalendarBasis _yearlyBasis;
  late CalendarReminderAnchor _anchor;
  late String _anchorPrayerName;
  late _OffsetDirection _offsetDirection;
  late final TextEditingController _offsetMinutesController;
  final FocusNode _offsetMinutesFocus = FocusNode();
  DateTime? _anchorDate;
  String? _titleError;
  bool _saving = false;

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
    _monthlyBasis = reminder?.monthlyBasis ?? CalendarBasis.gregorian;
    _yearlyBasis = reminder?.yearlyBasis ?? CalendarBasis.gregorian;
    _anchor = reminder?.anchor ?? CalendarReminderAnchor.clockTime;
    _anchorPrayerName = reminder?.anchorPrayerName ?? prayerOrder.first;
    _anchorDate = reminder?.anchorDate;
    final initialOffset = reminder?.anchorOffsetMinutes ?? 0;
    _offsetDirection = initialOffset == 0
        ? _OffsetDirection.onTime
        : (initialOffset < 0 ? _OffsetDirection.before : _OffsetDirection.after);
    _offsetMinutesController = TextEditingController(
      text: initialOffset == 0 ? '10' : initialOffset.abs().toString(),
    );
    _offsetMinutesFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _offsetMinutesController.dispose();
    _offsetMinutesFocus.dispose();
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

  Future<void> _pickAnchorDate() async {
    final hijriPreferred =
        (_recurrence == ReminderRecurrence.monthly &&
            _monthlyBasis == CalendarBasis.hijri) ||
        (_recurrence == ReminderRecurrence.yearly &&
            _yearlyBasis == CalendarBasis.hijri);
    final picked = await showAnchorDatePicker(
      context,
      initialDate: _anchorDate ?? DateTime.now(),
      hijriPreferred: hijriPreferred,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _anchorDate = picked;
    });
  }

  String _anchorDateLabel(AppLocalizations l10n) {
    final anchorDate = _anchorDate;
    if (anchorDate == null) {
      return l10n.calendarPickAnchorDate;
    }
    return DateFormat('EEE, dd MMM yyyy').format(anchorDate);
  }

  int _computeOffsetMinutes() {
    if (_offsetDirection == _OffsetDirection.onTime) {
      return 0;
    }
    final parsed = int.tryParse(_offsetMinutesController.text.trim()) ?? 0;
    // A blank/invalid custom field would otherwise silently collapse to an
    // offset of 0 (i.e. behave like "on time" instead of before/after).
    final magnitude = parsed <= 0 ? 1 : parsed;
    return _offsetDirection == _OffsetDirection.before
        ? -magnitude
        : magnitude;
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = context.l10n.calendarReminderTitleRequired);
      return;
    }

    final offsetMinutes = _computeOffsetMinutes();
    var anchorAt = _anchorAt;
    if (_anchor == CalendarReminderAnchor.prayerTime) {
      setState(() => _saving = true);
      final resolved = await resolvePrayerAnchoredTime(
        LocalDatabase(),
        prayerName: _anchorPrayerName,
        offsetMinutes: offsetMinutes,
      );
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
      anchorAt = resolved ?? anchorAt;
    }

    final controller = context.read<PrayerAppController>();
    final reminder = CalendarReminder(
      id: widget.reminder?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: _notesController.text.trim(),
      anchorAt: anchorAt,
      recurrence: _recurrence,
      monthlyBasis: _monthlyBasis,
      yearlyBasis: _yearlyBasis,
      anchor: _anchor,
      anchorPrayerName: _anchorPrayerName,
      anchorOffsetMinutes: offsetMinutes,
      anchorDate: _anchorDate,
      enabled: widget.reminder?.enabled ?? true,
    );
    if (_isEditing) {
      controller.updateCalendarReminder(reminder);
    } else {
      controller.addCalendarReminder(reminder);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final offsetMagnitude = int.tryParse(_offsetMinutesController.text.trim());
    final isCustomOffsetMinutes =
        offsetMagnitude == null ||
        !_minuteOptions.contains(offsetMagnitude) ||
        _offsetMinutesFocus.hasFocus;
    final colorScheme = Theme.of(context).colorScheme;

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
          SegmentedButton<CalendarReminderAnchor>(
            segments: [
              ButtonSegment(
                value: CalendarReminderAnchor.clockTime,
                label: Text(l10n.calendarAnchorClockTime),
                icon: const Icon(Icons.event),
              ),
              ButtonSegment(
                value: CalendarReminderAnchor.prayerTime,
                label: Text(l10n.calendarAnchorPrayerTime),
                icon: const Icon(Icons.mosque_outlined),
              ),
            ],
            selected: {_anchor},
            onSelectionChanged: (selection) =>
                setState(() => _anchor = selection.first),
          ),
          const SizedBox(height: 20),
          if (_anchor == CalendarReminderAnchor.clockTime) ...[
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
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceOnce,
                  selected: _recurrence == ReminderRecurrence.once,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.once),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceDaily,
                  selected: _recurrence == ReminderRecurrence.daily,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.daily),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceWeekly,
                  selected: _recurrence == ReminderRecurrence.weekly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.weekly),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceMonthly,
                  selected: _recurrence == ReminderRecurrence.monthly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.monthly),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceYearly,
                  selected: _recurrence == ReminderRecurrence.yearly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.yearly),
                ),
              ],
            ),
            if (_recurrence == ReminderRecurrence.monthly) ...[
              const SizedBox(height: 20),
              Text(
                l10n.calendarMonthlyBasisLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisGregorian,
                    selected: _monthlyBasis == CalendarBasis.gregorian,
                    onSelected: () => setState(
                      () => _monthlyBasis = CalendarBasis.gregorian,
                    ),
                  ),
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisHijri,
                    selected: _monthlyBasis == CalendarBasis.hijri,
                    onSelected: () => setState(
                      () => _monthlyBasis = CalendarBasis.hijri,
                    ),
                  ),
                ],
              ),
            ],
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
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisGregorian,
                    selected: _yearlyBasis == CalendarBasis.gregorian,
                    onSelected: () => setState(
                      () => _yearlyBasis = CalendarBasis.gregorian,
                    ),
                  ),
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisHijri,
                    selected: _yearlyBasis == CalendarBasis.hijri,
                    onSelected: () => setState(
                      () => _yearlyBasis = CalendarBasis.hijri,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            DropdownButtonFormField<String>(
              initialValue: _anchorPrayerName,
              decoration: InputDecoration(labelText: l10n.calendarSelectPrayer),
              items: prayerOrder
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Text(l10n.prayerNameLabel(key)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _anchorPrayerName = value);
                }
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChipOption(
                  label: l10n.calendarOffsetOnTime,
                  selected: _offsetDirection == _OffsetDirection.onTime,
                  onSelected: () =>
                      setState(() => _offsetDirection = _OffsetDirection.onTime),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarOffsetBefore,
                  selected: _offsetDirection == _OffsetDirection.before,
                  onSelected: () =>
                      setState(() => _offsetDirection = _OffsetDirection.before),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarOffsetAfter,
                  selected: _offsetDirection == _OffsetDirection.after,
                  onSelected: () =>
                      setState(() => _offsetDirection = _OffsetDirection.after),
                ),
              ],
            ),
            if (_offsetDirection != _OffsetDirection.onTime) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ..._minuteOptions.map(
                    (option) => ChoiceChip(
                      label: Text(l10n.minutesValue(option)),
                      selected:
                          !isCustomOffsetMinutes && offsetMagnitude == option,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(() {
                          _offsetMinutesController.text = option.toString();
                          _offsetMinutesFocus.unfocus();
                        });
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _offsetMinutesFocus.requestFocus(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      decoration: BoxDecoration(
                        color: isCustomOffsetMinutes
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCustomOffsetMinutes
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: isCustomOffsetMinutes ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: isCustomOffsetMinutes
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.custom,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontWeight: isCustomOffsetMinutes
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isCustomOffsetMinutes
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 44,
                            child: TextField(
                              controller: _offsetMinutesController,
                              focusNode: _offsetMinutesFocus,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (_) => setState(() {}),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isCustomOffsetMinutes
                                        ? colorScheme.onPrimaryContainer
                                        : colorScheme.onSurface,
                                  ),
                              decoration: const InputDecoration(
                                isDense: true,
                                isCollapsed: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceOnce,
                  selected: _recurrence == ReminderRecurrence.once,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.once),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceDaily,
                  selected: _recurrence == ReminderRecurrence.daily,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.daily),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceWeekly,
                  selected: _recurrence == ReminderRecurrence.weekly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.weekly),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceMonthly,
                  selected: _recurrence == ReminderRecurrence.monthly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.monthly),
                ),
                _ChoiceChipOption(
                  label: l10n.calendarRecurrenceYearly,
                  selected: _recurrence == ReminderRecurrence.yearly,
                  onSelected: () =>
                      setState(() => _recurrence = ReminderRecurrence.yearly),
                ),
              ],
            ),
            if (_recurrence == ReminderRecurrence.monthly) ...[
              const SizedBox(height: 20),
              Text(
                l10n.calendarMonthlyBasisLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisGregorian,
                    selected: _monthlyBasis == CalendarBasis.gregorian,
                    onSelected: () => setState(
                      () => _monthlyBasis = CalendarBasis.gregorian,
                    ),
                  ),
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisHijri,
                    selected: _monthlyBasis == CalendarBasis.hijri,
                    onSelected: () => setState(
                      () => _monthlyBasis = CalendarBasis.hijri,
                    ),
                  ),
                ],
              ),
            ],
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
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisGregorian,
                    selected: _yearlyBasis == CalendarBasis.gregorian,
                    onSelected: () => setState(
                      () => _yearlyBasis = CalendarBasis.gregorian,
                    ),
                  ),
                  _ChoiceChipOption(
                    label: l10n.calendarYearlyBasisHijri,
                    selected: _yearlyBasis == CalendarBasis.hijri,
                    onSelected: () => setState(
                      () => _yearlyBasis = CalendarBasis.hijri,
                    ),
                  ),
                ],
              ),
            ],
            if (_recurrence != ReminderRecurrence.daily) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _pickAnchorDate,
                icon: const Icon(Icons.calendar_month_outlined),
                label: Text(_anchorDateLabel(l10n)),
              ),
            ],
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChipOption extends StatelessWidget {
  const _ChoiceChipOption({
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
