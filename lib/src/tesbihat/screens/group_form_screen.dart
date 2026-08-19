import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../services/prayer_anchor_resolver.dart';
import '../state/groups_notifier.dart';
import '../widgets/reminder_section.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  const GroupFormScreen({super.key, this.groupToEdit});

  final ItemGroup? groupToEdit;

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late ReminderConfig _reminderConfig;
  bool _saving = false;

  bool get _isEditing => widget.groupToEdit != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.groupToEdit?.title ?? '');
    _reminderConfig = widget.groupToEdit != null
        ? ReminderConfig.fromGroup(widget.groupToEdit!)
        : const ReminderConfig();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
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
    var reminderAt = reminder.at;
    if (reminder.enabled && reminder.anchor == ItemReminderAnchor.prayerTime) {
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

    final notifier = ref.read(groupsNotifierProvider.notifier);
    if (_isEditing) {
      notifier.updateGroup(
        widget.groupToEdit!.copyWith(
          title: title,
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
        ),
      );
    } else {
      notifier.addGroup(
        title: title,
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
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editGroup : l10n.newGroup),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: const Key('group_title_field'),
              controller: _titleController,
              decoration: InputDecoration(labelText: l10n.groupName),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField(l10n.groupName);
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ReminderSection(
              initial: _isEditing
                  ? ReminderConfig.fromGroup(widget.groupToEdit!)
                  : null,
              onChanged: (config) => _reminderConfig = config,
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
    );
  }
}