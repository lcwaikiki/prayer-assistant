import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../../widgets/discard_confirmation_dialog.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../services/prayer_anchor_resolver.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import '../widgets/reminder_section.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({super.key, this.itemToEdit, this.initialGroupIds});

  final Item? itemToEdit;

  /// Groups pre-selected for a newly created bead (e.g. when creating a
  /// bead from inside a group).
  final List<String>? initialGroupIds;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _countController;
  late final TextEditingController _checkController;
  late final TextEditingController _setCountController;
  late int _vibrationIntensity;
  late ReminderConfig _reminderConfig;
  late Set<String> _selectedGroupIds;
  bool _saving = false;
  bool _allowPop = false;

  bool get _isEditing => widget.itemToEdit != null;

  bool get _isDirty {
    final item = widget.itemToEdit;
    final initialTitle = item?.title ?? '';
    final initialNotes = item?.notes ?? '';
    final initialCount = item != null ? item.count.toString() : '';
    final initialCheck = item != null ? item.check.toString() : '';
    final initialVibration = item?.vibrationIntensity ?? 50;
    final initialReminder = item != null
        ? ReminderConfig.fromItem(item)
        : const ReminderConfig();
    final initialGroups = item != null
        ? item.groupIds.toSet()
        : (widget.initialGroupIds ?? const []).toSet();

    if (_titleController.text != initialTitle) return true;
    if (_notesController.text != initialNotes) return true;
    if (_countController.text != initialCount) return true;
    if (_checkController.text != initialCheck) return true;
    if (_vibrationIntensity != initialVibration) return true;
    if (_reminderConfig != initialReminder) return true;
    if (!setEquals(_selectedGroupIds, initialGroups)) return true;

    return false;
  }

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
    _reminderConfig = item != null
        ? ReminderConfig.fromItem(item)
        : const ReminderConfig();
    _selectedGroupIds = item != null
        ? item.groupIds.toSet()
        : (widget.initialGroupIds ?? const []).toSet();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _countController.dispose();
    _checkController.dispose();
    _setCountController.dispose();
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final reminder = _reminderConfig;
    if (reminder.enabled &&
        reminder.anchor == ItemReminderAnchor.clockTime &&
        reminder.at == null) {
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

    var reminderAt = reminder.at;
    if (reminder.enabled &&
        reminder.anchor == ItemReminderAnchor.prayerTime) {
      setState(() => _saving = true);
      reminderAt = await resolvePrayerAnchoredTime(
        LocalDatabase(),
        prayerName: reminder.prayerName,
        offsetMinutes: reminder.offsetMinutes,
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
        reminderEnabled: reminder.enabled,
        reminderAnchor: reminder.anchor,
        reminderRecurrence: reminder.recurrence,
        reminderMonthlyBasis: reminder.monthlyBasis,
        reminderYearlyBasis: reminder.yearlyBasis,
        reminderAt: reminderAt,
        reminderAnchorDate: reminder.anchorDate,
        reminderPrayerName: reminder.prayerName,
        reminderOffsetMinutes: reminder.offsetMinutes,
        reminderRepeatCount: reminder.repeatCount,
        reminderWeekdays: reminder.recurrence == ReminderRecurrence.weekly
            ? reminder.weekdays
            : const [],
        reminderDayOfMonth: reminder.recurrence == ReminderRecurrence.monthly
            ? reminder.dayOfMonth
            : null,
        reminderYearlyDate: reminder.recurrence == ReminderRecurrence.yearly
            ? reminder.yearlyDate
            : null,
        groupIds: _selectedGroupIds.toList(growable: false),
      );
      notifier.updateItem(edited);
    } else {
      notifier.addItem(
        title: title,
        notes: notes,
        count: count,
        check: check,
        vibrationIntensity: _vibrationIntensity,
        reminderEnabled: reminder.enabled,
        reminderAnchor: reminder.anchor,
        reminderRecurrence: reminder.recurrence,
        reminderMonthlyBasis: reminder.monthlyBasis,
        reminderYearlyBasis: reminder.yearlyBasis,
        reminderAt: reminderAt,
        reminderAnchorDate: reminder.anchorDate,
        reminderPrayerName: reminder.prayerName,
        reminderOffsetMinutes: reminder.offsetMinutes,
        reminderRepeatCount: reminder.repeatCount,
        reminderWeekdays: reminder.recurrence == ReminderRecurrence.weekly
            ? reminder.weekdays
            : const [],
        reminderDayOfMonth: reminder.recurrence == ReminderRecurrence.monthly
            ? reminder.dayOfMonth
            : null,
        reminderYearlyDate: reminder.recurrence == ReminderRecurrence.yearly
            ? reminder.yearlyDate
            : null,
        groupIds: _selectedGroupIds.toList(growable: false),
      );
    }

    if (mounted) {
      setState(() => _allowPop = true);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!_isDirty) {
          setState(() => _allowPop = true);
          navigator.pop(result);
          return;
        }
        final shouldDiscard = await showDiscardConfirmationDialog(context);
        if (shouldDiscard == true && mounted) {
          setState(() => _allowPop = true);
          navigator.pop(result);
        }
      },
      child: Scaffold(
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
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.setCount,
                  helperText: l10n.setCountReadonlyHelper,
                ),
                child: Text(
                  _setCountController.text,
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
              ReminderSection(
                initial: _isEditing
                    ? ReminderConfig.fromItem(widget.itemToEdit!)
                    : null,
                onChanged: (config) => setState(() => _reminderConfig = config),
              ),
              const SizedBox(height: 20),
              _GroupSelector(
                selectedIds: _selectedGroupIds,
                onChanged: (ids) => setState(() => _selectedGroupIds = ids),
              ),
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
      ),
    );
  }
}

class _GroupSelector extends ConsumerWidget {
  const _GroupSelector({required this.selectedIds, required this.onChanged});

  final Set<String> selectedIds;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.tesbihatL10n;
    final groups = ref.watch(groupsNotifierProvider);
    if (groups.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.groups, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final group in groups)
              FilterChip(
                key: Key('group_chip_${group.id}'),
                label: Text(group.title),
                selected: selectedIds.contains(group.id),
                onSelected: (selected) {
                  final next = Set<String>.from(selectedIds);
                  if (selected) {
                    next.add(group.id);
                  } else {
                    next.remove(group.id);
                  }
                  onChanged(next);
                },
              ),
          ],
        ),
      ],
    );
  }
}