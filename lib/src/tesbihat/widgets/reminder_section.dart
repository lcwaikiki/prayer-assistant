import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../calendar/hijri_utils.dart';
import '../../calendar/models/calendar_reminder.dart';
import '../../calendar/screens/calendar_anchor_date_picker.dart';
import '../../l10n/prayer_names.dart';
import '../../utils/time_utils.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/item_group.dart';

enum _OffsetDirection { onTime, before, after }

/// Immutable snapshot of every reminder option, shared between bead and
/// group reminders so they offer the exact same feature set.
class ReminderConfig {
  const ReminderConfig({
    this.enabled = false,
    this.anchor = ItemReminderAnchor.clockTime,
    this.recurrence = ReminderRecurrence.once,
    this.monthlyBasis = CalendarBasis.gregorian,
    this.yearlyBasis = CalendarBasis.gregorian,
    this.at,
    this.anchorDate,
    this.prayerName,
    this.offsetMinutes = 0,
    this.repeatCount,
    this.weekdays = const [],
    this.dayOfMonth,
    this.yearlyDate,
  });

  factory ReminderConfig.fromItem(Item item) {
    return ReminderConfig(
      enabled: item.reminderEnabled,
      anchor: item.reminderAnchor,
      recurrence: item.reminderRecurrence,
      monthlyBasis: item.reminderMonthlyBasis,
      yearlyBasis: item.reminderYearlyBasis,
      at: item.reminderAt,
      anchorDate: item.reminderAnchorDate,
      prayerName: item.reminderPrayerName,
      offsetMinutes: item.reminderOffsetMinutes,
      repeatCount: item.reminderRepeatCount,
      weekdays: item.reminderWeekdays,
      dayOfMonth: item.reminderDayOfMonth,
      yearlyDate: item.reminderYearlyDate,
    );
  }

  factory ReminderConfig.fromGroup(ItemGroup group) {
    return ReminderConfig(
      enabled: group.reminderEnabled,
      anchor: group.reminderAnchor,
      recurrence: group.reminderRecurrence,
      monthlyBasis: group.reminderMonthlyBasis,
      yearlyBasis: group.reminderYearlyBasis,
      at: group.reminderAt,
      anchorDate: group.reminderAnchorDate,
      prayerName: group.reminderPrayerName,
      offsetMinutes: group.reminderOffsetMinutes,
      repeatCount: group.reminderRepeatCount,
      weekdays: group.reminderWeekdays,
      dayOfMonth: group.reminderDayOfMonth,
      yearlyDate: group.reminderYearlyDate,
    );
  }

  final bool enabled;
  final ItemReminderAnchor anchor;
  final ReminderRecurrence recurrence;
  final CalendarBasis monthlyBasis;
  final CalendarBasis yearlyBasis;
  final DateTime? at;
  final DateTime? anchorDate;
  final String? prayerName;
  final int offsetMinutes;
  final int? repeatCount;
  final List<int> weekdays;
  final int? dayOfMonth;
  final DateTime? yearlyDate;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderConfig &&
        other.enabled == enabled &&
        other.anchor == anchor &&
        other.recurrence == recurrence &&
        other.monthlyBasis == monthlyBasis &&
        other.yearlyBasis == yearlyBasis &&
        other.at == at &&
        other.anchorDate == anchorDate &&
        other.prayerName == prayerName &&
        other.offsetMinutes == offsetMinutes &&
        other.repeatCount == repeatCount &&
        listEquals(other.weekdays, weekdays) &&
        other.dayOfMonth == dayOfMonth &&
        other.yearlyDate == yearlyDate;
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        anchor,
        recurrence,
        monthlyBasis,
        yearlyBasis,
        at,
        anchorDate,
        prayerName,
        offsetMinutes,
        repeatCount,
        Object.hashAll(weekdays),
        dayOfMonth,
        yearlyDate,
      );
}

/// The full reminder editor (enable switch, anchor choice, recurrence,
/// repeat count, recurrence-day selectors, time/anchor-date pickers and
/// prayer offset), shared by the bead form and the group form so both offer
/// identical reminder options.
class ReminderSection extends ConsumerStatefulWidget {
  const ReminderSection({
    super.key,
    required this.onChanged,
    this.initial,
  });

  final ValueChanged<ReminderConfig> onChanged;
  final ReminderConfig? initial;

  @override
  ConsumerState<ReminderSection> createState() => _ReminderSectionState();
}

class _ReminderSectionState extends ConsumerState<ReminderSection> {
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  late bool _enabled;
  late ItemReminderAnchor _anchor;
  late ReminderRecurrence _recurrence;
  late CalendarBasis _monthlyBasis;
  late CalendarBasis _yearlyBasis;
  DateTime? _at;
  DateTime? _anchorDate;
  late String _prayerName;
  late _OffsetDirection _offsetDirection;
  late final TextEditingController _offsetMinutesController;
  late final TextEditingController _repeatCountController;
  final FocusNode _offsetMinutesFocus = FocusNode();
  int? _repeatCount;
  late List<int> _weekdays;
  late int _dayOfMonth;
  late DateTime _yearlyDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _enabled = initial?.enabled ?? false;
    _anchor = initial?.anchor ?? ItemReminderAnchor.clockTime;
    _recurrence = initial?.recurrence ?? ReminderRecurrence.once;
    _monthlyBasis = initial?.monthlyBasis ?? CalendarBasis.gregorian;
    _yearlyBasis = initial?.yearlyBasis ?? CalendarBasis.gregorian;
    _at = initial?.at;
    _anchorDate = initial?.anchorDate;
    _prayerName = initial?.prayerName ?? prayerOrder.first;
    final initialOffset = initial?.offsetMinutes ?? 0;
    _offsetDirection = initialOffset == 0
        ? _OffsetDirection.onTime
        : (initialOffset < 0 ? _OffsetDirection.before : _OffsetDirection.after);
    _offsetMinutesController = TextEditingController(
      text: initialOffset == 0 ? '10' : initialOffset.abs().toString(),
    );
    _repeatCount = initial?.repeatCount;
    _repeatCountController = TextEditingController(
      text: initial?.repeatCount?.toString() ?? '',
    );
    _offsetMinutesFocus.addListener(() => setState(() {}));
    final now = DateTime.now();
    final anchorDay = _anchorDate ?? _at ?? now;
    final storedWeekdays = initial?.weekdays ?? const <int>[];
    _weekdays = storedWeekdays.isEmpty
        ? <int>[anchorDay.weekday]
        : List<int>.from(storedWeekdays);
    _dayOfMonth = initial?.dayOfMonth ?? anchorDay.day;
    _yearlyDate = initial?.yearlyDate ??
        DateTime(anchorDay.year, anchorDay.month, anchorDay.day);
  }

  @override
  void dispose() {
    _offsetMinutesController.dispose();
    _repeatCountController.dispose();
    _offsetMinutesFocus.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      ReminderConfig(
        enabled: _enabled,
        anchor: _anchor,
        recurrence: _recurrence,
        monthlyBasis: _monthlyBasis,
        yearlyBasis: _yearlyBasis,
        at: _at,
        anchorDate: _anchorDate ??
            (_recurrence != ReminderRecurrence.once
                ? (_at ?? DateTime.now())
                : null),
        prayerName: _prayerName,
        offsetMinutes: _computeOffsetMinutes(),
        repeatCount: _repeatCount == null
            ? null
            : int.tryParse(_repeatCountController.text.trim()),
        weekdays: List<int>.from(_weekdays),
        dayOfMonth: _dayOfMonth,
        yearlyDate: _yearlyDate,
      ),
    );
  }

  void _mutate(VoidCallback change) {
    setState(change);
    _notify();
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

  /// FilterChip toggling a finite repeat count on/off (off = repeat
  /// forever), with a text field beside it to enter the count (2-100).
  /// Only shown when the recurrence isn't [ReminderRecurrence.once].
  Widget _buildRepeatCountControl(TesbihatLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilterChip(
              key: const Key('reminder_repeat_count_chip'),
              label: Text(l10n.reminderRepeatCountLabel),
              selected: _repeatCount != null,
              onSelected: (selected) => _mutate(() {
                _repeatCount = selected ? 2 : null;
              }),
            ),
            if (_repeatCount != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('reminder_repeat_count_field'),
                  controller: _repeatCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.reminderRepeatCountLabel,
                  ),
                  validator: _repeatCountValidator,
                  onChanged: (_) => _notify(),
                ),
              ),
            ],
          ],
        ),
        Text(
          l10n.reminderRepeatCountHelper,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// The count must be 2-100 when the chip is on.
  String? _repeatCountValidator(String? value) {
    final raw = value?.trim() ?? '';
    final count = int.tryParse(raw);
    if (count == null || count < 2 || count > 100) {
      return context.tesbihatL10n.reminderRepeatCountRangeError;
    }
    return null;
  }

  Future<void> _pickReminderTime() async {
    if (_recurrence == ReminderRecurrence.daily) {
      final initial = _at ?? DateTime.now();
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );
      if (time == null) {
        return;
      }
      _mutate(() {
        _at = DateTime(
          initial.year,
          initial.month,
          initial.day,
          time.hour,
          time.minute,
        );
      });
    } else {
      final now = DateTime.now();
      final date = await showAnchorDatePicker(
        context,
        initialDate: _at ?? now,
      );
      if (date == null || !mounted) {
        return;
      }
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_at ?? now),
      );
      if (time == null) {
        return;
      }
      _mutate(() {
        _at = DateTime(
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
    final at = _at;
    if (at == null) {
      return l10n.reminderNotSet;
    }
    if (_recurrence == ReminderRecurrence.daily) {
      return DateFormat('HH:mm').format(at);
    }
    return DateFormat('EEE, dd MMM yyyy HH:mm').format(at);
  }

  Future<void> _pickAnchorDate() async {
    final hijriPreferred =
        (_recurrence == ReminderRecurrence.monthly &&
            _monthlyBasis == CalendarBasis.hijri) ||
        (_recurrence == ReminderRecurrence.yearly &&
            _yearlyBasis == CalendarBasis.hijri);
    final date = await showAnchorDatePicker(
      context,
      initialDate: _anchorDate ?? DateTime.now(),
      hijriPreferred: hijriPreferred,
    );
    if (date == null || !mounted) {
      return;
    }
    _mutate(() {
      _anchorDate = date;
    });
  }

  String _anchorDateLabel(TesbihatLocalizations l10n) {
    final anchorDate = _anchorDate;
    if (anchorDate == null) {
      return l10n.reminderPickDate;
    }
    return DateFormat('EEE, dd MMM yyyy').format(anchorDate);
  }

  Widget _recurrenceChips(TesbihatLocalizations l10n) {
    ChoiceChip chip(ReminderRecurrence value, String label) => ChoiceChip(
          label: Text(label),
          selected: _recurrence == value,
          onSelected: (selected) {
            if (!selected) return;
            _mutate(() {
              _recurrence = value;
              if (value != ReminderRecurrence.once && _anchorDate == null) {
                _anchorDate = _at ?? DateTime.now();
              }
            });
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
            _mutate(() {
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

  /// The shared recurrence extras: repeat count, monthly/yearly basis chips
  /// and the explicit recurrence-day selectors (weekday multi-select for
  /// weekly, day-of-month for monthly, month+day for yearly). Rendered in
  /// both the clock-time and prayer-time sections.
  Widget _buildRecurrenceOptions(TesbihatLocalizations l10n, String locale) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recurrence != ReminderRecurrence.once) ...[
          const SizedBox(height: 12),
          _buildRepeatCountControl(l10n),
        ],
        if (_recurrence == ReminderRecurrence.monthly) ...[
          const SizedBox(height: 12),
          Text(l10n.reminderMonthlyBasisLabel, style: labelStyle),
          const SizedBox(height: 8),
          _basisChips(l10n, true),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: const Key('day_of_month_field'),
            initialValue: _dayOfMonth,
            decoration: InputDecoration(
              labelText: l10n.reminderDayOfMonthLabel,
            ),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text('$day')),
            ],
            onChanged: (value) {
              if (value != null) {
                _mutate(() => _dayOfMonth = value);
              }
            },
          ),
        ],
        if (_recurrence == ReminderRecurrence.yearly) ...[
          const SizedBox(height: 12),
          Text(l10n.reminderYearlyBasisLabel, style: labelStyle),
          const SizedBox(height: 8),
          _basisChips(l10n, false),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: const Key('yearly_month_field'),
                  initialValue: _yearlyDate.month,
                  decoration: InputDecoration(
                    labelText: l10n.reminderYearlyMonthLabel,
                  ),
                  items: [
                    for (var month = 1; month <= 12; month++)
                      DropdownMenuItem(
                        value: month,
                        child: Text(_monthLabel(month, locale)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _mutate(() {
                      _yearlyDate = DateTime(
                        _yearlyDate.year,
                        value,
                        _yearlyDate.day,
                      );
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: const Key('yearly_day_field'),
                  initialValue: _yearlyDate.day,
                  decoration: InputDecoration(
                    labelText: l10n.reminderYearlyDayLabel,
                  ),
                  items: [
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('$day')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    _mutate(() {
                      _yearlyDate = DateTime(
                        _yearlyDate.year,
                        _yearlyDate.month,
                        value,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
        if (_recurrence == ReminderRecurrence.weekly) ...[
          const SizedBox(height: 12),
          Text(l10n.reminderRepeatDaysLabel, style: labelStyle),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var weekday = 1; weekday <= 7; weekday++)
                FilterChip(
                  key: Key('weekday_chip_$weekday'),
                  label: Text(
                    DateFormat.E(locale).format(DateTime(2024, 1, weekday)),
                  ),
                  selected: _weekdays.contains(weekday),
                  onSelected: (selected) => _mutate(() {
                    if (selected) {
                      if (!_weekdays.contains(weekday)) {
                        _weekdays.add(weekday);
                      }
                    } else if (_weekdays.length > 1) {
                      _weekdays.remove(weekday);
                    }
                  }),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Localized month name for the yearly selector: Gregorian when the basis
  /// is Gregorian, Hijri otherwise.
  String _monthLabel(int month, String locale) {
    if (_yearlyBasis == CalendarBasis.hijri) {
      return HijriMonth(1446, month)
          .longMonthName(Localizations.localeOf(context).languageCode);
    }
    return DateFormat.MMMM(locale).format(DateTime(2024, month, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final appL10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final colorScheme = Theme.of(context).colorScheme;
    final offsetMagnitude = int.tryParse(_offsetMinutesController.text.trim());
    final isCustomOffsetMinutes =
        offsetMagnitude == null ||
        !_minuteOptions.contains(offsetMagnitude) ||
        _offsetMinutesFocus.hasFocus;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const Key('reminder_enable_switch'),
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.reminderTitle),
          subtitle: Text(l10n.reminderEnable),
          value: _enabled,
          onChanged: (value) => _mutate(() => _enabled = value),
        ),
        if (_enabled) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l10n.reminderAnchorTime),
                selected: _anchor == ItemReminderAnchor.clockTime,
                onSelected: (selected) {
                  if (!selected) return;
                  _mutate(() => _anchor = ItemReminderAnchor.clockTime);
                },
              ),
              ChoiceChip(
                label: Text(l10n.reminderAnchorPrayer),
                selected: _anchor == ItemReminderAnchor.prayerTime,
                onSelected: (selected) {
                  if (!selected) return;
                  _mutate(() => _anchor = ItemReminderAnchor.prayerTime);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_anchor == ItemReminderAnchor.clockTime) ...[
            Text(
              l10n.reminderRecurrenceLabel,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _recurrenceChips(l10n),
            _buildRecurrenceOptions(l10n, locale),
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
              initialValue: _prayerName,
              decoration: InputDecoration(
                labelText: l10n.reminderSelectPrayer,
              ),
              items: prayerOrder
                  .map(
                    (key) => DropdownMenuItem(
                      value: key,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            iconForPrayer(key),
                            size: 18,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.prayerNameLabel(key),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),

              onChanged: (value) {
                if (value != null) {
                  _mutate(() => _prayerName = value);
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
            _buildRecurrenceOptions(l10n, locale),
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
                    _mutate(() => _offsetDirection = _OffsetDirection.onTime);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.reminderOffsetBefore),
                  selected: _offsetDirection == _OffsetDirection.before,
                  onSelected: (selected) {
                    if (!selected) return;
                    _mutate(() => _offsetDirection = _OffsetDirection.before);
                  },
                ),
                ChoiceChip(
                  label: Text(l10n.reminderOffsetAfter),
                  selected: _offsetDirection == _OffsetDirection.after,
                  onSelected: (selected) {
                    if (!selected) return;
                    _mutate(() => _offsetDirection = _OffsetDirection.after);
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
                        _mutate(() {
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
                              onChanged: (_) => _notify(),
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
      ],
    );
  }
}