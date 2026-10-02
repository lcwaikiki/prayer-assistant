import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../../widgets/discard_confirmation_dialog.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../services/prayer_anchor_resolver.dart';
import '../state/groups_notifier.dart';
import '../widgets/reminder_section.dart';
import 'group_screen.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  const GroupFormScreen({
    super.key,
    this.groupToEdit,
    this.readOnly = false,
  });

  final ItemGroup? groupToEdit;
  final bool readOnly;

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _readOnly = widget.readOnly;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late ReminderConfig _reminderConfig;
  bool _saving = false;
  bool _allowPop = false;

  bool get _isEditing => widget.groupToEdit != null;

  bool get _isDirty {
    final initialTitle = widget.groupToEdit?.title ?? '';
    final initialNotes = widget.groupToEdit?.notes ?? '';
    final initialReminder = widget.groupToEdit != null
        ? ReminderConfig.fromGroup(widget.groupToEdit!)
        : const ReminderConfig();
    if (_titleController.text != initialTitle) return true;
    if (_notesController.text != initialNotes) return true;
    if (_reminderConfig != initialReminder) return true;
    return false;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.groupToEdit?.title ?? '',
    );
    _notesController = TextEditingController(
      text: widget.groupToEdit?.notes ?? '',
    );
    _reminderConfig = widget.groupToEdit != null
        ? ReminderConfig.fromGroup(widget.groupToEdit!)
        : const ReminderConfig();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
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
          notes: _notesController.text.trim(),
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
        notes: _notesController.text.trim(),
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
          title: Text(_isEditing ? l10n.editGroup : l10n.newGroup),
          actions: [
            if (_readOnly) ...[
              IconButton(
                key: const Key('edit_group_button'),
                tooltip: l10n.edit,
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _readOnly = false),
              ),
              if (widget.groupToEdit != null)
                IconButton(
                  key: const Key('view_group_beads_button'),
                  tooltip: l10n.groupMembers,
                  icon: const Icon(Icons.format_list_bulleted),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => GroupScreen(
                          groupId: widget.groupToEdit!.id,
                        ),
                      ),
                    );
                  },
                ),
            ] else ...[
              IconButton(
                key: const Key('save_group_button'),
                tooltip: _isEditing ? l10n.update : l10n.save,
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
          ],
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                IgnorePointer(
                  ignoring: _readOnly,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        key: const Key('group_title_field'),
                        controller: _titleController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(labelText: l10n.groupName),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.requiredField(l10n.groupName);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('group_notes_field'),
                        controller: _notesController,
                        readOnly: _readOnly,
                        minLines: 3,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: l10n.notes,
                          alignLabelWithHint: true,
                          hintText: l10n.notesHint,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ReminderSection(
                        readOnly: _readOnly,
                        initial: _isEditing
                            ? ReminderConfig.fromGroup(widget.groupToEdit!)
                            : null,
                        onChanged: (config) =>
                            setState(() => _reminderConfig = config),
                      ),
                    ],
                  ),
                ),
                if (_readOnly) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const Key('edit_group_button_bottom'),
                          icon: const Icon(Icons.edit),
                          label: Text(l10n.edit),
                          onPressed: () => setState(() => _readOnly = false),
                        ),
                      ),
                      if (widget.groupToEdit != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            key: const Key('view_group_beads_button_bottom'),
                            icon: const Icon(Icons.format_list_bulleted),
                            label: Text(l10n.groupMembers),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (_) => GroupScreen(
                                    groupId: widget.groupToEdit!.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}