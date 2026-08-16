import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../calendar/models/calendar_reminder.dart';
import '../../l10n/prayer_names.dart';
import '../../services/local_database.dart';
import '../../utils/time_utils.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../services/prayer_anchor_resolver.dart';
import '../state/items_notifier.dart';

enum _OffsetDirection { onTime, before, after }

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.itemToEdit});

  final Item? itemToEdit;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _countController;
  late final TextEditingController _checkController;
  late final TextEditingController _setCountController;
  late int _vibrationIntensity;
  late bool _reminderEnabled;
  late ItemReminderAnchor _reminderAnchor;
  late ReminderRecurrence _recurrence;
  late CalendarBasis _monthlyBasis;
  late CalendarBasis _yearlyBasis;
  DateTime? _reminderAt;
  DateTime? _reminderAnchorDate;
  late String _reminderPrayerName;
  late _OffsetDirection _offsetDirection;
  late final TextEditingController _offsetMinutesController;
  final FocusNode _offsetMinutesFocus = FocusNode();
  bool _saving = false;

  bool get _isEditing => widget.itemToEdit != null;

  @override
  void initState() {
    super.initState();
    final item = widget.itemToEdit;
    _titleController = TextEditingController(text: item?.title ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _countController = TextEditingController(
      text: item != null ? item.count.toString() : '',
    );
    _checkController = TextEditingController(
      text: item != null ? item.check.toString() : '',
    );
    _setCountController = TextEditingController(
      text: item != null ? item.setCount.toString() : '0',
    );
    _vibrationIntensity = item?.vibrationIntensity ?? 50;
    _reminderEnabled = item?.reminderEnabled ?? false;
    _reminderAnchor = item?.reminderAnchor ?? ItemReminderAnchor.clockTime;
    _recurrence = item?.reminderRecurrence ?? ReminderRecurrence.once;
    _monthlyBasis = item?.reminderMonthlyBasis ?? CalendarBasis.gregorian;
    _yearlyBasis = item?.reminderYearlyBasis ?? CalendarBasis.gregorian;
    _reminderAt = item?.reminderAt;
    _reminderAnchorDate = item?.reminderAnchorDate;
    _reminderPrayerName = item?.reminderPrayerName ?? prayerOrder.first;
    final initialOffset = item?.reminderOffsetMinutes ?? 0;
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
    _countController.dispose();
    _checkController.dispose();
    _setCountController.dispose();
    _offsetMinutesController.dispose();
    _offsetMinutesFocus.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.tesbihatL10n.requiredField(fieldName);
    }
    return null;
  }

  String? _countValidator(String? value) {
    final l10n = context.tesbihatL10n;
    final emptyError = _requiredValidator(value, l10n.countField);
    if (emptyError != null) return emptyError;

    final count = int.tryParse(value!.trim());
    if (count == null || count <= 0) {
      return l10n.countPositive;
    }
    return null;
  }

  String? _checkValidator(String? value) {
    final l10n = context.tesbihatL10n;
    final emptyError = _requiredValidator(value, l10n.check);
    if (emptyError != null) return emptyError;

    final check = int.tryParse(value!.trim());
    final count = int.tryParse(_countController.text.trim());
    if (check == null) {
      return l10n.fieldMustBeInteger(l10n.check);
    }
    if (check <= 0) return l10n.checkGreaterThanZero;
    if (count == null || count <= 0) return l10n.enterValidCountFirst;
    if (check * 2 > count) return l10n.checkHalfError;
    return null;
  }

  Future<void> _pickReminderTime() async {
    if (_recurrence == ReminderRecurrence.daily) {
      final initial = _reminderAt ?? DateTime.now();
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null) {
        return;
      }
      setState(() {
        _reminderAt = DateTime(
          initial.year,
          initial.month,
          initial.day,
          time.hour,
          time.minute,
        );
      });
    } else {
      final now = DateTime.now();
      final date = await showDatePicker(
        context: context,
        initialDate: _reminderAt ?? now,
        firstDate: now,
        lastDate: now.add(const Duration(days: 3650)),
      );
      if (date == null || !mounted) {
        return;
      }
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderAt ?? now),
      );
      if (time == null) {
        return;
      }
      setState(() {
        _reminderAt = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  String _reminderLabel(TesbihatLocalizations l10n) {
    final reminderAt = _reminderAt;
    if (reminderAt == null) {
      return l10n.reminderNotSet;
    }
    if (_recurrence == ReminderRecurrence.daily) {
      return DateFormat('HH:mm').format(reminderAt);
    }
    return DateFormat('EEE, dd MMM yyyy HH:mm').format(reminderAt);
  }

  Future<void> _pickAnchorDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderAnchorDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) {
      return;
    }
    setState(() {
      _reminderAnchorDate = DateTime(date.year, date.month, date.day);
    });
  }

  String _anchorDateLabel(TesbihatLocalizations l10n) {
    final anchorDate = _reminderAnchorDate;
    if (anchorDate == null) {
      return l10n.reminderPickDate;
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

  Widget _recurrenceChips(TesbihatLocalizations l10n) {
    ChoiceChip chip(ReminderRecurrence value, String label) => ChoiceChip(
          label: Text(label),
          selected: _recurrence == value,
          onSelected: (selected) {
            if (!selected) return;
            setState(() => _recurrence = value);
          },
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(ReminderRecurrence.once, l10n.reminderRepeatOnce),
        chip(ReminderRecurrence.daily, l10n.reminderRepeatDaily),
        chip(ReminderRecurrence.weekly, l10n.reminderRepeatWeekly),
        chip(ReminderRecurrence.monthly, l10n.reminderRepeatMonthly),
        chip(ReminderRecurrence.yearly, l10n.reminderRepeatYearly),
      ],
    );
  }

  Widget _basisChips(TesbihatLocalizations l10n, bool monthly) {
    final current = monthly ? _monthlyBasis : _yearlyBasis;
    ChoiceChip chip(CalendarBasis basis) => ChoiceChip(
          label: Text(
            basis == CalendarBasis.gregorian
                ? l10n.reminderBasisGregorian
                : l10n.reminderBasisHijri,
          ),
          selected: current == basis,
          onSelected: (selected) {
            if (!selected) return;
            setState(() {
              if (monthly) {
                _monthlyBasis = basis;
              } else {
                _yearlyBasis = basis;
              }
            });
          },
        );
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip(CalendarBasis.gregorian),
        chip(CalendarBasis.hijri),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_reminderEnabled &&
        _reminderAnchor == ItemReminderAnchor.clockTime &&
        _reminderAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tesbihatL10n.reminderPickDateTime)),
      );
      return;
    }

    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final count = int.parse(_countController.text.trim());
    final check = int.parse(_checkController.text.trim());
    final setCount = _isEditing ? widget.itemToEdit!.setCount : 0;
    final offsetMinutes = _computeOffsetMinutes();

    var reminderAt = _reminderAt;
    if (_reminderEnabled && _reminderAnchor == ItemReminderAnchor.prayerTime) {
      setState(() => _saving = true);
      reminderAt = await resolvePrayerAnchoredTime(
        LocalDatabase(),
        prayerName: _reminderPrayerName,
        offsetMinutes: offsetMinutes,
      );
      if (!mounted) {
        return;
      }
      setState(() => _saving = false);
    }

    final notifier = ref.read(itemsNotifierProvider.notifier);

    if (_isEditing) {
      final edited = widget.itemToEdit!.copyWith(
        title: title,
        notes: notes,
        count: count,
        check: check,
        setCount: setCount,
        vibrationIntensity: _vibrationIntensity,
        currentProgress: widget.itemToEdit!.currentProgress.clamp(0, count),
        reminderEnabled: _reminderEnabled,
        reminderAnchor: _reminderAnchor,
        reminderRecurrence: _recurrence,
        reminderMonthlyBasis: _monthlyBasis,
        reminderYearlyBasis: _yearlyBasis,
        reminderAt: reminderAt,
        reminderAnchorDate: _reminderAnchorDate,
        reminderPrayerName: _reminderPrayerName,
        reminderOffsetMinutes: offsetMinutes,
      );
      notifier.updateItem(edited);
    } else {
      notifier.addItem(
        title: title,
        notes: notes,
        count: count,
        check: check,
        vibrationIntensity: _vibrationIntensity,
        reminderEnabled: _reminderEnabled,
        reminderAnchor: _reminderAnchor,
        reminderRecurrence: _recurrence,
        reminderMonthlyBasis: _monthlyBasis,
        reminderYearlyBasis: _yearlyBasis,
        reminderAt: reminderAt,
        reminderAnchorDate: _reminderAnchorDate,
        reminderPrayerName: _reminderPrayerName,
        reminderOffsetMinutes: offsetMinutes,
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final appL10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final offsetMagnitude = int.tryParse(_offsetMinutesController.text.trim());
    final isCustomOffsetMinutes =
        offsetMagnitude == null ||
        !_minuteOptions.contains(offsetMagnitude) ||
        _offsetMinutesFocus.hasFocus;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editMilestone : l10n.createMilestone),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('title_field'),
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.title),
              validator: (value) => _requiredValidator(value, l10n.title),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('notes_field'),
              controller: _notesController,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: l10n.notes,
                alignLabelWithHint: true,
                hintText: l10n.notesHint,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('count_field'),
              controller: _countController,
              decoration: InputDecoration(labelText: l10n.countField),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _countValidator,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('check_field'),
              controller: _checkController,
              decoration: InputDecoration(
                labelText: l10n.checkInterval,
                helperText: l10n.checkHelper,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _checkValidator,
            ),
            const SizedBox(height: 12),
            _isEditing
                ? InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.setCount,
                      helperText: l10n.setCountReadonlyHelper,
                    ),
                    child: Text(
                      _setCountController.text,
                      key: const Key('set_count_readonly_value'),
                    ),
                  )
                : InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.setCount,
                      helperText: l10n.setCountReadonlyHelper,
                    ),
                    child: Text(
                      '0',
                      key: const Key('set_count_readonly_value'),
                    ),
                  ),
            const SizedBox(height: 20),
            Text(
              '${l10n.vibrationIntensity}: $_vibrationIntensity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              key: const Key('intensity_slider'),
              value: _vibrationIntensity.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: _vibrationIntensity.toString(),
              onChanged: (value) {
                setState(() {
                  _vibrationIntensity = value.round();
                });
              },
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              key: const Key('reminder_enable_switch'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.reminderTitle),
              subtitle: Text(l10n.reminderEnable),
              value: _reminderEnabled,
              onChanged: (value) => setState(() => _reminderEnabled = value),
            ),
            if (_reminderEnabled) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l10n.reminderAnchorTime),
                    selected: _reminderAnchor == ItemReminderAnchor.clockTime,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(
                        () => _reminderAnchor = ItemReminderAnchor.clockTime,
                      );
                    },
                  ),
                  ChoiceChip(
                    label: Text(l10n.reminderAnchorPrayer),
                    selected: _reminderAnchor == ItemReminderAnchor.prayerTime,
                    onSelected: (selected) {
                      if (!selected) return;
                      setState(
                        () => _reminderAnchor = ItemReminderAnchor.prayerTime,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_reminderAnchor == ItemReminderAnchor.clockTime) ...[
                Text(
                  l10n.reminderRecurrenceLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _recurrenceChips(l10n),
                if (_recurrence == ReminderRecurrence.monthly) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.reminderMonthlyBasisLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _basisChips(l10n, true),
                ],
                if (_recurrence == ReminderRecurrence.yearly) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.reminderYearlyBasisLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _basisChips(l10n, false),
                ],
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  key: const Key('reminder_time_button'),
                  onPressed: _pickReminderTime,
                  icon: const Icon(Icons.schedule_outlined),
                  label: Text(_reminderLabel(l10n)),
                ),
              ] else ...[
                DropdownButtonFormField<String>(
                  key: const Key('reminder_prayer_dropdown'),
                  initialValue: _reminderPrayerName,
                  decoration: InputDecoration(
                    labelText: l10n.reminderSelectPrayer,
                  ),
                  items: prayerOrder
                      .map(
                        (key) => DropdownMenuItem(
                          value: key,
                          child: Text(
                            AppLocalizations.of(context)!.prayerNameLabel(key),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _reminderPrayerName = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.reminderRecurrenceLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                _recurrenceChips(l10n),
                if (_recurrence == ReminderRecurrence.monthly) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.reminderMonthlyBasisLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _basisChips(l10n, true),
                ],
                if (_recurrence == ReminderRecurrence.yearly) ...[
                  const SizedBox(height: 12),
                  Text(
                    l10n.reminderYearlyBasisLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  _basisChips(l10n, false),
                ],
                if (_recurrence != ReminderRecurrence.daily) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('reminder_anchor_date_button'),
                    onPressed: _pickAnchorDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_anchorDateLabel(l10n)),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(l10n.reminderOffsetOnTime),
                      selected: _offsetDirection == _OffsetDirection.onTime,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(
                          () => _offsetDirection = _OffsetDirection.onTime,
                        );
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.reminderOffsetBefore),
                      selected: _offsetDirection == _OffsetDirection.before,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(
                          () => _offsetDirection = _OffsetDirection.before,
                        );
                      },
                    ),
                    ChoiceChip(
                      label: Text(l10n.reminderOffsetAfter),
                      selected: _offsetDirection == _OffsetDirection.after,
                      onSelected: (selected) {
                        if (!selected) return;
                        setState(
                          () => _offsetDirection = _OffsetDirection.after,
                        );
                      },
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
                          label: Text(appL10n.minutesValue(option)),
                          selected: !isCustomOffsetMinutes &&
                              offsetMagnitude == option,
                          onSelected: (selected) {
                            if (!selected) return;
                            setState(() {
                              _offsetMinutesController.text =
                                  option.toString();
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
                                appL10n.custom,
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
                                  key: const Key(
                                    'reminder_offset_minutes_field',
                                  ),
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
              ],
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEditing ? l10n.update : l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
