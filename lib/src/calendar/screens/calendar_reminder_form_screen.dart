import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controller/prayer_app_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../services/local_database.dart';
import '../../widgets/discard_confirmation_dialog.dart';

import '../../tesbihat/services/audio_player_service.dart';
import '../../tesbihat/services/prayer_anchor_resolver.dart';
import '../../tesbihat/state/sound_library_notifier.dart';
import '../../tesbihat/widgets/sound_picker_sheet.dart';
import '../../utils/time_utils.dart';
import '../hijri_utils.dart';
import '../models/calendar_reminder.dart';
import 'calendar_anchor_date_picker.dart';

enum _OffsetDirection { onTime, before, after }

class CalendarReminderFormScreen extends ConsumerStatefulWidget {
  const CalendarReminderFormScreen({
    super.key,
    this.reminder,
    this.reminderId,
    this.initialDate,
    this.readOnly = false,
    this.audioPlayerService,
    this.database,
  });

  /// Non-null when editing an existing reminder.
  final CalendarReminder? reminder;
  final String? reminderId;

  /// Pre-fills the date when creating a new reminder from a tapped day.
  final DateTime? initialDate;
  final bool readOnly;
  final AudioPlayerService? audioPlayerService;
  final LocalDatabase? database;

  @override
  ConsumerState<CalendarReminderFormScreen> createState() =>
      _CalendarReminderFormScreenState();
}

class _CalendarReminderFormScreenState
    extends ConsumerState<CalendarReminderFormScreen> {
  static const List<int> _minuteOptions = <int>[5, 10, 15, 20, 30, 45, 60];

  late bool _readOnly = widget.readOnly;
  CalendarReminder? _reminder;
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
  late final TextEditingController _repeatCountController;
  final FocusNode _offsetMinutesFocus = FocusNode();
  DateTime? _anchorDate;
  String? _titleError;
  int? _repeatCount;
  String? _repeatCountError;
  late List<int> _weekdays;
  late int _dayOfMonth;
  late DateTime _yearlyDate;
  late List<DateTime> _excludedDates;
  late bool _isTask;
  String? _soundId;
  String? _soundTitle;
  late final AudioPlayerService _audioPlayer;
  StreamSubscription<void>? _playerCompleteSubscription;
  bool _isPlayingPreview = false;
  bool _saving = false;
  bool _allowPop = false;

  late DateTime _initialAnchorAt;
  late List<int> _initialWeekdays;
  late int _initialDayOfMonth;
  late DateTime _initialYearlyDate;
  late List<DateTime> _initialExcludedDates;
  String? _initialSoundId;
  String? _initialSoundTitle;

  bool get _isEditing => _reminder != null || widget.reminder != null;

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  /// Order-independent, date-only comparison of two excluded-date lists.
  static bool _sameDayList(List<DateTime> a, List<DateTime> b) =>
      a.length == b.length &&
      a.every((date) => b.any((other) => _sameDay(date, other)));

  bool get _isDirty {
    final reminder = _reminder ?? widget.reminder;
    final initialTitle = reminder?.title ?? '';
    final initialNotes = reminder?.notes ?? '';
    final initialRepeatCount = reminder?.repeatCount;
    final initialRecurrence = reminder?.recurrence ?? ReminderRecurrence.once;
    final initialMonthlyBasis = reminder?.monthlyBasis ?? CalendarBasis.gregorian;
    final initialYearlyBasis = reminder?.yearlyBasis ?? CalendarBasis.gregorian;
    final initialAnchor = reminder?.anchor ?? CalendarReminderAnchor.clockTime;
    final initialAnchorPrayerName = reminder?.anchorPrayerName ?? prayerOrder.first;
    final initialAnchorDate = reminder?.anchorDate;
    final initialOffset = reminder?.anchorOffsetMinutes ?? 0;
    final initialOffsetDirection = initialOffset == 0
        ? _OffsetDirection.onTime
        : (initialOffset < 0 ? _OffsetDirection.before : _OffsetDirection.after);
    final initialOffsetMinutesText =
        initialOffset == 0 ? '10' : initialOffset.abs().toString();

    if (_titleController.text.trim() != initialTitle) return true;
    if (_notesController.text.trim() != initialNotes) return true;
    if (_isTask != (reminder?.isTask ?? false)) return true;
    if (_soundId != _initialSoundId) return true;
    if (_soundTitle != _initialSoundTitle) return true;
    if (_repeatCount != initialRepeatCount) return true;
    if (_repeatCountController.text.trim() !=
        (initialRepeatCount?.toString() ?? '')) {
      return true;
    }
    if (_anchorAt != _initialAnchorAt) return true;
    if (_recurrence != initialRecurrence) return true;
    if (_monthlyBasis != initialMonthlyBasis) return true;
    if (_yearlyBasis != initialYearlyBasis) return true;
    if (_anchor != initialAnchor) return true;
    if (_anchorPrayerName != initialAnchorPrayerName) return true;
    if (_anchorDate != initialAnchorDate) return true;
    if (_offsetDirection != initialOffsetDirection) return true;
    if (_offsetMinutesController.text.trim() != initialOffsetMinutesText) return true;
    if (_dayOfMonth != _initialDayOfMonth) return true;
    if (_yearlyDate != _initialYearlyDate) return true;
    if (!_sameDayList(_excludedDates, _initialExcludedDates)) return true;

    if (_weekdays.length != _initialWeekdays.length) return true;
    for (var i = 0; i < _weekdays.length; i++) {
      if (!_initialWeekdays.contains(_weekdays[i])) return true;
    }

    return false;
  }

  void _populateFromReminder(CalendarReminder? reminder) {
    _titleController.text = reminder?.title ?? '';
    _notesController.text = reminder?.notes ?? '';
    _isTask = reminder?.isTask ?? false;
    _soundId = reminder?.soundId;
    _soundTitle = reminder?.soundTitle;
    _repeatCount = reminder?.repeatCount;
    _repeatCountController.text = reminder?.repeatCount?.toString() ?? '';
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
    _offsetMinutesController.text =
        initialOffset == 0 ? '10' : initialOffset.abs().toString();
    final anchorDay = _anchorDate ?? _anchorAt;
    final storedWeekdays = reminder?.weekdays ?? const <int>[];
    _weekdays = storedWeekdays.isEmpty
        ? <int>[anchorDay.weekday]
        : List<int>.from(storedWeekdays);
    _dayOfMonth = reminder?.dayOfMonth ?? anchorDay.day;
    _yearlyDate =
        reminder?.yearlyDate ?? DateTime(anchorDay.year, anchorDay.month, anchorDay.day);
    _excludedDates = List<DateTime>.from(reminder?.excludedDates ?? const []);

    _initialAnchorAt = _anchorAt;
    _initialWeekdays = List<int>.from(_weekdays);
    _initialDayOfMonth = _dayOfMonth;
    _initialYearlyDate = _yearlyDate;
    _initialExcludedDates = List<DateTime>.from(_excludedDates);
    _initialSoundId = _soundId;
    _initialSoundTitle = _soundTitle;
  }

  LocalDatabase _getDatabase(BuildContext context) {
    if (widget.database != null) return widget.database!;
    try {
      return context.read<PrayerAppController>().database;
    } catch (_) {
      return LocalDatabase();
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _repeatCountController = TextEditingController();
    _offsetMinutesController = TextEditingController();
    _offsetMinutesFocus.addListener(() => setState(() {}));
    _audioPlayer = widget.audioPlayerService ?? AudioPlayerService();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlayingPreview = false);
      }
    });

    _reminder = widget.reminder;
    _populateFromReminder(_reminder);

    final targetId = widget.reminder?.id ?? widget.reminderId;
    if (_reminder == null && targetId != null && targetId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        CalendarReminder? found;
        try {
          final controller = context.read<PrayerAppController>();
          for (final r in controller.calendarReminders) {
            if (r.id == targetId) {
              found = r;
              break;
            }
          }
        } catch (_) {}
        if (found == null && mounted) {
          try {
            final db = _getDatabase(context);
            final dbReminders = await db.loadCalendarReminders();
            for (final r in dbReminders) {
              if (r.id == targetId) {
                found = r;
                break;
              }
            }
          } catch (_) {}
        }
        if (found != null && mounted) {
          setState(() {
            _reminder = found;
            _populateFromReminder(found);
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.stop();
    if (widget.audioPlayerService == null) {
      _audioPlayer.dispose();
    }
    _titleController.dispose();
    _notesController.dispose();
    _offsetMinutesController.dispose();
    _repeatCountController.dispose();
    _offsetMinutesFocus.dispose();
    super.dispose();
  }

  Future<void> _togglePreviewSound() async {
    if (_soundId == null) return;
    if (_isPlayingPreview) {
      await _audioPlayer.pause();
      setState(() => _isPlayingPreview = false);
      return;
    }

    if (_audioPlayer.state == PlayerState.paused) {
      await _audioPlayer.resume();
      setState(() => _isPlayingPreview = true);
      return;
    }

    final sound =
        ref.read(soundLibraryNotifierProvider.notifier).getSoundById(_soundId);
    if (sound != null) {
      await _audioPlayer.playBytes(sound.bytes, mimeType: sound.mimeType);
      setState(() => _isPlayingPreview = true);
    }
  }

  Future<void> _pickSound() async {
    if (_isPlayingPreview) {
      await _audioPlayer.stop();
      setState(() => _isPlayingPreview = false);
    }
    final sound = await SoundPickerSheet.show(context);
    if (sound != null && mounted) {
      setState(() {
        _soundId = sound.id;
        _soundTitle = sound.title;
      });
    }
  }

  void _removeSound() {
    if (_isPlayingPreview) {
      _audioPlayer.stop();
      setState(() => _isPlayingPreview = false);
    }
    setState(() {
      _soundId = null;
      _soundTitle = null;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showAnchorDatePicker(
      context,
      initialDate: _anchorAt,
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

  /// FilterChip toggling a finite repeat count on/off (off = repeat
  /// forever), with a text field beside it to enter the count (2-100).
  /// Only shown when the recurrence isn't [ReminderRecurrence.once].
  Widget _buildRepeatCountControl(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            FilterChip(
              key: const Key('repeat_count_chip'),
              label: Text(l10n.calendarRepeatCountLabel),
              selected: _repeatCount != null,
              onSelected: (selected) => setState(() {
                _repeatCount = selected ? 2 : null;
                _repeatCountError = null;
              }),
            ),
            if (_repeatCount != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  key: const Key('repeat_count_field'),
                  controller: _repeatCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: l10n.calendarRepeatCountLabel,
                    errorText: _repeatCountError,
                  ),
                  onChanged: (_) {
                    if (_repeatCountError != null) {
                      setState(() => _repeatCountError = null);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        Text(
          l10n.calendarRepeatCountHelper,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  /// Blank means "repeat forever"; otherwise must be 2-100. Sets
  /// [_repeatCountError] when invalid. Only meaningful when the recurrence
  /// isn't [ReminderRecurrence.once] (a single occurrence can't repeat).
  int? _parseRepeatCount(AppLocalizations l10n) {
    if (_repeatCount == null) {
      return null;
    }
    final raw = _repeatCountController.text.trim();
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed < 2 || parsed > 100) {
      setState(() => _repeatCountError = l10n.calendarRepeatCountError);
      return null;
    }
    return parsed;
  }

  /// The shared recurrence extras: repeat count, monthly/yearly basis chips
  /// and the explicit recurrence-day selectors (weekday multi-select for
  /// weekly, day-of-month for monthly, month+day for yearly). Rendered in
  /// both the clock-time and prayer-time sections.
  Widget _buildRecurrenceOptions(AppLocalizations l10n, String locale) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_recurrence != ReminderRecurrence.once) ...[
          const SizedBox(height: 20),
          _buildRepeatCountControl(l10n),
        ],
        if (_recurrence == ReminderRecurrence.monthly) ...[
          const SizedBox(height: 20),
          Text(l10n.calendarMonthlyBasisLabel, style: labelStyle),
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
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            key: const Key('day_of_month_field'),
            initialValue: _dayOfMonth,
            decoration: InputDecoration(
              labelText: l10n.calendarDayOfMonthLabel,
            ),
            items: [
              for (var day = 1; day <= 31; day++)
                DropdownMenuItem(value: day, child: Text('$day')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _dayOfMonth = value);
              }
            },
          ),
        ],
        if (_recurrence == ReminderRecurrence.yearly) ...[
          const SizedBox(height: 20),
          Text(l10n.calendarYearlyBasisLabel, style: labelStyle),
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  key: const Key('yearly_month_field'),
                  initialValue: _yearlyDate.month,
                  decoration: InputDecoration(
                    labelText: l10n.calendarYearlyMonthLabel,
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
                    setState(() {
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
                    labelText: l10n.calendarYearlyDayLabel,
                  ),
                  items: [
                    for (var day = 1; day <= 31; day++)
                      DropdownMenuItem(value: day, child: Text('$day')),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
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
          const SizedBox(height: 20),
          Text(l10n.calendarRepeatDaysLabel, style: labelStyle),
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
                  onSelected: (selected) => setState(() {
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

  /// Lists the individually skipped occurrences ("delete this occurrence")
  /// with a per-date restore action and a "restore all" action. The list is
  /// carried into the saved reminder so editing other fields never silently
  /// re-enables them.
  Widget _buildExcludedDatesSection(AppLocalizations l10n, String locale) {
    if (_excludedDates.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.calendarExcludedOccurrencesLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            TextButton.icon(
              key: const Key('restore_all_excluded_dates'),
              onPressed: () => setState(() => _excludedDates = <DateTime>[]),
              icon: const Icon(Icons.restore),
              label: Text(l10n.calendarRestoreAllOccurrences),
            ),
          ],
        ),
        for (final date in _excludedDates)
          ListTile(
            key: Key('excluded_date_${_dateKey(date)}'),
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.event_busy),
            title: Text(DateFormat.yMMMd(locale).format(date)),
            trailing: IconButton(
              key: Key('restore_excluded_date_${_dateKey(date)}'),
              tooltip: l10n.calendarRestoreOccurrence,
              icon: const Icon(Icons.restore),
              onPressed: () => setState(() {
                _excludedDates = _excludedDates
                    .where((excluded) => !_sameDay(excluded, date))
                    .toList(growable: false);
              }),
            ),
          ),
      ],
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = context.l10n.calendarReminderTitleRequired);
      return;
    }

    final repeatCount = _parseRepeatCount(context.l10n);
    if (_repeatCountError != null) {
      return;
    }

    final offsetMinutes = _computeOffsetMinutes();
    var anchorAt = _anchorAt;
    if (_anchor == CalendarReminderAnchor.prayerTime) {
      setState(() => _saving = true);
      final resolved = await resolvePrayerAnchoredTime(
        _getDatabase(context),
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
      id: _reminder?.id ??
          widget.reminder?.id ??
          widget.reminderId ??
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
      enabled: _reminder?.enabled ?? widget.reminder?.enabled ?? true,
      repeatCount: _recurrence == ReminderRecurrence.once
          ? null
          : repeatCount,
      weekdays: _recurrence == ReminderRecurrence.weekly
          ? List<int>.from(_weekdays)
          : const [],
      dayOfMonth: _recurrence == ReminderRecurrence.monthly
          ? _dayOfMonth
          : null,
      yearlyDate: _recurrence == ReminderRecurrence.yearly
          ? _yearlyDate
          : null,
      excludedDates: _excludedDates,
      isTask: _isTask,
      soundId: _soundId,
      soundTitle: _soundTitle,
    );
    if (_isEditing) {
      controller.updateCalendarReminder(reminder);
    } else {
      controller.addCalendarReminder(reminder);
    }
    if (mounted) {
      await _audioPlayer.stop();
      _allowPop = true;
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

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!_isDirty) {
          await _audioPlayer.stop();
          setState(() {
            _allowPop = true;
          });
          navigator.pop();
          return;
        }
        final shouldDiscard = await showDiscardConfirmationDialog(context);
        if (shouldDiscard == true && mounted) {
          await _audioPlayer.stop();
          setState(() {
            _allowPop = true;
          });
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing
                ? l10n.calendarReminderFormTitleEdit
                : l10n.calendarReminderFormTitleNew,
          ),
          actions: [
            if (_readOnly)
              IconButton(
                tooltip: l10n.calendarEditReminder,
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _readOnly = false),
              )
            else
              IconButton(
                key: const Key('save_reminder_button'),
                tooltip: l10n.save,
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                onPressed: _saving ? null : _save,
              ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              IgnorePointer(
                ignoring: _readOnly,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 12),
                    SwitchListTile(
                      key: const Key('calendar_reminder_is_task_switch'),
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.calendarMarkAsTask),
                      subtitle: Text(l10n.calendarMarkAsTaskSubtitle),
                      value: _isTask,
                      onChanged: (value) => setState(() => _isTask = value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.sound,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              if (_soundId != null) ...[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          key: const Key('reminder_sound_preview_button'),
                          icon: Icon(
                            _isPlayingPreview
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                          ),
                          iconSize: 32,
                          color: colorScheme.primary,
                          onPressed: _togglePreviewSound,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _soundTitle ?? l10n.sound,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!_readOnly) ...[
                          IconButton(
                            key: const Key('reminder_sound_swap_button'),
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: l10n.pickFromLibrary,
                            onPressed: _pickSound,
                          ),
                          IconButton(
                            key: const Key('reminder_sound_remove_button'),
                            icon: const Icon(Icons.close),
                            tooltip: l10n.removeSound,
                            onPressed: _removeSound,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  key: const Key('reminder_pick_sound_button'),
                  onPressed: _readOnly ? null : _pickSound,
                  icon: const Icon(Icons.music_note_outlined),
                  label: Text(
                    '${l10n.recordSound} / ${l10n.pickFromLibrary}',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              IgnorePointer(
                ignoring: _readOnly,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      _buildRecurrenceOptions(l10n, locale),
                    ] else ...[
                      DropdownButtonFormField<String>(
                        initialValue: _anchorPrayerName,
                        decoration: InputDecoration(labelText: l10n.calendarSelectPrayer),
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
                                    Text(l10n.prayerNameLabel(key)),
                                  ],
                                ),
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
                      _buildRecurrenceOptions(l10n, locale),
                      if (_recurrence != ReminderRecurrence.daily) ...[
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _pickAnchorDate,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(_anchorDateLabel(l10n)),
                        ),
                      ],
                    ],
                    _buildExcludedDatesSection(l10n, locale),
                  ],
                ),
              ),
              if (_readOnly) ...[
                const SizedBox(height: 28),
                OutlinedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: Text(l10n.calendarEditReminder),
                  onPressed: () => setState(() => _readOnly = false),
                ),
              ],
            ],
          ),
        ),
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
