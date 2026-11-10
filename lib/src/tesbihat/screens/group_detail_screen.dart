import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/reminder_format_utils.dart';
import '../../widgets/read_only_detail_section.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/item_group.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import 'bead_detail_screen.dart';
import 'group_form_screen.dart';
import 'group_screen.dart';

/// A modern, consistent read-only detail screen for a Bead Group.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({
    super.key,
    required this.group,
  });

  final ItemGroup group;

  void _navigateToEdit(BuildContext context, ItemGroup currentGroup) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupFormScreen(
          groupToEdit: currentGroup,
          readOnly: false,
        ),
      ),
    );
  }

  void _startGroupSession(BuildContext context, ItemGroup currentGroup) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupScreen(groupId: currentGroup.id),
      ),
    );
  }

  void _openMemberDetail(BuildContext context, Item member) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BeadDetailScreen(item: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.tesbihatL10n;
    final allGroups = ref.watch(groupsNotifierProvider);
    final currentGroup =
        allGroups.where((g) => g.id == group.id).firstOrNull ?? group;

    final allItems = ref.watch(itemsNotifierProvider);
    final groupMembers = allItems
        .where((i) => i.groupIds.contains(currentGroup.id))
        .toList(growable: false);

    final isReminderEnabled = currentGroup.reminderEnabled;
    final isTask = currentGroup.isTask;

    final reminderSummary = formatConciseReminder(
      context: context,
      enabled: isReminderEnabled,
      isPrayerAnchor: currentGroup.reminderAnchor == ItemReminderAnchor.prayerTime,
      recurrence: currentGroup.reminderRecurrence,
      prayerName: currentGroup.reminderPrayerName,
      offsetMinutes: currentGroup.reminderOffsetMinutes,
      anchorDate: currentGroup.reminderAnchorDate,
      clockTime: currentGroup.reminderAt != null
          ? TimeOfDay(
              hour: currentGroup.reminderAt!.hour,
              minute: currentGroup.reminderAt!.minute,
            )
          : null,
      weekdays: currentGroup.reminderWeekdays,
      dayOfMonth: currentGroup.reminderDayOfMonth,
      yearlyDate: currentGroup.reminderYearlyDate,
      monthlyBasis: currentGroup.reminderMonthlyBasis,
      yearlyBasis: currentGroup.reminderYearlyBasis,
      repeatCount: currentGroup.reminderRepeatCount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readOnlyGroupDetailsTitle),
        actions: [
          IconButton(
            key: const Key('edit_group_appbar_button'),
            tooltip: l10n.editGroup,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(context, currentGroup),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ReadOnlyHeroHeader(
            title: currentGroup.title.isEmpty
                ? l10n.newGroup
                : currentGroup.title,
            icon: Icons.folder_rounded,
            subtitle: currentGroup.notes.isNotEmpty ? currentGroup.notes : null,
            badges: [
              Chip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.tag_rounded, size: 16),
                label: Text('${groupMembers.length} ${l10n.milestones}'),
              ),
              if (isTask)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(l10n.markAsTask),
                ),
              if (isReminderEnabled)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.notifications_active, size: 16),
                  label: Text(l10n.reminderTitle),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Group Sequence Members Chain
          ReadOnlyGroupSequenceCard(
            members: groupMembers,
            title: l10n.groupMembers,
            onMemberTap: (member) => _openMemberDetail(context, member),
          ),
          // Pinch-to-zoom Expandable Notes Card
          if (currentGroup.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            ReadOnlyZoomableNotesCard(
              notes: currentGroup.notes,
              title: l10n.notes,
              icon: Icons.menu_book_rounded,
            ),
          ],
          // Prayer-relative or absolute schedule
          if (isReminderEnabled) ...[
            const SizedBox(height: 4),
            ReadOnlyTimingHeroCard(
              timingSummary: reminderSummary,
              isEnabled: isReminderEnabled,
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: ReadOnlyBottomActionBar(
        primaryLabel: l10n.readOnlyStartGroupSession,
        primaryIcon: Icons.play_arrow_rounded,
        primaryKey: const Key('start_group_session_button'),
        onPrimaryPressed: () => _startGroupSession(context, currentGroup),
        secondaryLabel: l10n.editGroup,
        secondaryIcon: Icons.edit_outlined,
        secondaryKey: const Key('edit_group_bottom_button'),
        onSecondaryPressed: () => _navigateToEdit(context, currentGroup),
      ),
    );
  }
}

