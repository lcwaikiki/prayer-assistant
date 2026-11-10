import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/reminder_format_utils.dart';
import '../../widgets/read_only_detail_section.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../services/audio_player_service.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import '../state/sound_library_notifier.dart';
import 'execution_screen.dart';
import 'item_form_screen.dart';

/// A modern, consistent read-only detail screen for a single Bead / Milestone.
class BeadDetailScreen extends ConsumerStatefulWidget {
  const BeadDetailScreen({
    super.key,
    required this.item,
    this.audioPlayerService,
  });

  final Item item;
  final AudioPlayerService? audioPlayerService;

  @override
  ConsumerState<BeadDetailScreen> createState() => _BeadDetailScreenState();
}

class _BeadDetailScreenState extends ConsumerState<BeadDetailScreen> {
  late AudioPlayerService _audioPlayer;
  bool _isPlayingPreview = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.item.soundSpeed;
    _audioPlayer =
        widget.audioPlayerService ?? ref.read(audioPlayerServiceProvider);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlayingPreview = false);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  Future<void> _togglePreviewSound(String filePath) async {
    if (_isPlayingPreview) {
      await _audioPlayer.stop();
      if (mounted) setState(() => _isPlayingPreview = false);
    } else {
      await _audioPlayer.playFile(
        filePath,
        playbackRate: _playbackSpeed,
      );
      if (mounted) setState(() => _isPlayingPreview = true);
    }
  }

  Future<void> _onSpeedChanged(double newSpeed, String filePath) async {
    setState(() => _playbackSpeed = newSpeed);
    await _audioPlayer.setPlaybackRate(newSpeed);
  }

  void _navigateToEdit(Item currentItem) {
    _audioPlayer.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ItemFormScreen(
          itemToEdit: currentItem,
          readOnly: false,
        ),
      ),
    );
  }

  void _startCounting(Item currentItem) {
    _audioPlayer.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExecutionScreen(itemId: currentItem.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final allItems = ref.watch(itemsNotifierProvider);
    final currentItem =
        allItems.where((i) => i.id == widget.item.id).firstOrNull ??
            widget.item;

    final isReminderEnabled = currentItem.reminderEnabled;
    final isTask = currentItem.isTask;

    final reminderSummary = formatConciseReminder(
      context: context,
      enabled: isReminderEnabled,
      isPrayerAnchor: currentItem.reminderAnchor == ItemReminderAnchor.prayerTime,
      recurrence: currentItem.reminderRecurrence,
      prayerName: currentItem.reminderPrayerName,
      offsetMinutes: currentItem.reminderOffsetMinutes,
      anchorDate: currentItem.reminderAnchorDate,
      clockTime: currentItem.reminderAt != null
          ? TimeOfDay(
              hour: currentItem.reminderAt!.hour,
              minute: currentItem.reminderAt!.minute,
            )
          : null,
      weekdays: currentItem.reminderWeekdays,
      dayOfMonth: currentItem.reminderDayOfMonth,
      yearlyDate: currentItem.reminderYearlyDate,
      monthlyBasis: currentItem.reminderMonthlyBasis,
      yearlyBasis: currentItem.reminderYearlyBasis,
      repeatCount: currentItem.reminderRepeatCount,
    );

    final sound = currentItem.soundId != null
        ? ref
            .read(soundLibraryNotifierProvider.notifier)
            .getSoundById(currentItem.soundId)
        : null;
    final soundDurationText = sound?.durationMs != null
        ? formatAudioDurationMs(sound!.durationMs!)
        : null;

    final allGroups = ref.watch(groupsNotifierProvider);
    final groupNames = allGroups
        .where((g) => currentItem.groupIds.contains(g.id))
        .map((g) => g.title)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.readOnlyBeadDetailsTitle),
        actions: [
          IconButton(
            key: const Key('edit_bead_appbar_button'),
            tooltip: l10n.editMilestone,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(currentItem),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ReadOnlyHeroHeader(
            title: currentItem.title.isEmpty
                ? l10n.createMilestone
                : currentItem.title,
            icon: Icons.touch_app_outlined,
            subtitle: currentItem.notes.isNotEmpty ? currentItem.notes : null,
            badges: [
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
              if (currentItem.soundId != null)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.volume_up, size: 16),
                  label: Text(currentItem.soundTitle ?? l10n.sound),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Circular Progress & Stats Ring
          ReadOnlyCircularProgressCard(
            currentCount: currentItem.currentProgress,
            targetCount: currentItem.count,
            checkCount: currentItem.check,
            vibrationIntensity: currentItem.vibrationIntensity,
            setCount: currentItem.setCount,
          ),
          // Pinch-to-zoom expandable notes
          if (currentItem.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            ReadOnlyZoomableNotesCard(
              notes: currentItem.notes,
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
          // Affiliated Groups
          if (groupNames.isNotEmpty) ...[
            const SizedBox(height: 4),
            ReadOnlyCardContainer(
              title: l10n.groups,
              icon: Icons.folder,
              children: [
                ReadOnlyFieldTile(
                  label: l10n.groups,
                  value: groupNames.join(', '),
                  icon: Icons.folder_open,
                ),
              ],
            ),
          ],
          // Audio Player Card
          if (sound != null) ...[
            const SizedBox(height: 4),
            ReadOnlySoundPlayerCard(
              title: currentItem.soundTitle ?? sound.title,
              duration: soundDurationText,
              speed: _playbackSpeed,
              onSpeedChanged: (s) => _onSpeedChanged(s, sound.path),
              extraDetail: currentItem.autoCountWithSound
                  ? l10n.autoCountWithSound
                  : null,
              isPlaying: _isPlayingPreview,
              onPlayPause: () => _togglePreviewSound(sound.path),
              playButtonKey: const Key('sound_preview_button'),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: ReadOnlyBottomActionBar(
        primaryLabel: l10n.readOnlyStartCounting,
        primaryIcon: Icons.play_arrow_rounded,
        primaryKey: const Key('start_counting_button'),
        onPrimaryPressed: () => _startCounting(currentItem),
        secondaryLabel: l10n.editMilestone,
        secondaryIcon: Icons.edit_outlined,
        secondaryKey: const Key('edit_bead_bottom_button'),
        onSecondaryPressed: () => _navigateToEdit(currentItem),
      ),
    );
  }
}

