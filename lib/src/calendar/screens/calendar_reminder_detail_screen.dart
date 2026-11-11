import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../../../l10n/app_localizations.dart';
import '../../controller/prayer_app_controller.dart';
import '../../tesbihat/services/audio_player_service.dart';
import '../../tesbihat/state/sound_library_notifier.dart';
import '../../utils/reminder_format_utils.dart';
import '../../widgets/read_only_detail_section.dart';
import '../models/calendar_reminder.dart';
import 'calendar_reminder_form_screen.dart';

/// A modern, consistent read-only detail screen for a Calendar / Task Reminder.
class CalendarReminderDetailScreen extends ConsumerStatefulWidget {
  const CalendarReminderDetailScreen({
    super.key,
    required this.reminder,
    this.audioPlayerService,
  });

  final CalendarReminder reminder;
  final AudioPlayerService? audioPlayerService;

  @override
  ConsumerState<CalendarReminderDetailScreen> createState() =>
      _CalendarReminderDetailScreenState();
}

class _CalendarReminderDetailScreenState
    extends ConsumerState<CalendarReminderDetailScreen> {
  late AudioPlayerService _audioPlayer;
  bool _isPlayingPreview = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.reminder.soundSpeed;
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

  Future<void> _onSpeedChanged(
    double newSpeed,
    String filePath,
    CalendarReminder currentReminder,
  ) async {
    setState(() => _playbackSpeed = newSpeed);
    await _audioPlayer.setPlaybackRate(newSpeed);

    if (currentReminder.soundSpeed != newSpeed) {
      final controller = provider.Provider.of<PrayerAppController>(
        context,
        listen: false,
      );
      await controller.updateCalendarReminder(
        currentReminder.copyWith(soundSpeed: newSpeed),
      );
    }
  }

  void _navigateToEdit(CalendarReminder currentReminder) {
    _audioPlayer.stop();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CalendarReminderFormScreen(
          reminder: currentReminder,
          readOnly: false,
        ),
      ),
    );
  }

  Future<void> _toggleCompleted(
    CalendarReminder currentReminder,
    bool isTask,
  ) async {
    final controller = provider.Provider.of<PrayerAppController>(
      context,
      listen: false,
    );
    if (isTask) {
      final today = DateTime.now();
      controller.setTaskCompletion('cal_${currentReminder.id}', today, true);
      if (currentReminder.recurrence == ReminderRecurrence.once ||
          currentReminder.repeatCount == 1) {
        await controller.calendarReminderService.cancelReminder(currentReminder.id);
      } else {
        await controller.calendarReminderService.cancelActiveNotification(currentReminder.id);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } else {
      controller.toggleCalendarReminderEnabled(currentReminder.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final controller = provider.Provider.of<PrayerAppController>(context);
    final currentReminder = controller.calendarReminders
            .where((r) => r.id == widget.reminder.id)
            .firstOrNull ??
        widget.reminder;

    final isReminderEnabled = currentReminder.enabled;
    final isTask = currentReminder.isTask;

    final reminderSummary = formatConciseReminder(
      context: context,
      enabled: isReminderEnabled,
      isPrayerAnchor: currentReminder.anchor == CalendarReminderAnchor.prayerTime,
      prayerName: currentReminder.anchorPrayerName,
      offsetMinutes: currentReminder.anchorOffsetMinutes,
      recurrence: currentReminder.recurrence,
      anchorAt: currentReminder.anchorAt,
      clockTime: TimeOfDay(
        hour: currentReminder.anchorAt.hour,
        minute: currentReminder.anchorAt.minute,
      ),
      anchorDate: currentReminder.anchorDate,
      weekdays: currentReminder.weekdays,
      dayOfMonth: currentReminder.dayOfMonth,
      yearlyDate: currentReminder.yearlyDate,
      monthlyBasis: currentReminder.monthlyBasis,
      yearlyBasis: currentReminder.yearlyBasis,
      repeatCount: currentReminder.repeatCount,
    );

    final sound = currentReminder.soundId != null
        ? ref
            .read(soundLibraryNotifierProvider.notifier)
            .getSoundById(currentReminder.soundId)
        : null;
    final soundDurationText = sound?.durationMs != null
        ? formatAudioDurationMs(sound!.durationMs!)
        : null;

    final titleText = currentReminder.title.isEmpty
        ? (l10n?.readOnlyReminderDetailsTitle ?? 'Reminder Details')
        : currentReminder.title;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.readOnlyReminderDetailsTitle ?? 'Reminder Details'),
        actions: [
          IconButton(
            key: const Key('edit_reminder_appbar_button'),
            tooltip: l10n?.calendarReminderFormTitleEdit ?? 'Edit Reminder',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _navigateToEdit(currentReminder),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ReadOnlyHeroHeader(
            title: titleText,
            icon: Icons.event_note,
            subtitle: currentReminder.notes.isNotEmpty
                ? currentReminder.notes
                : null,
            badges: [
              if (isTask)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(l10n?.calendarMarkAsTask ?? 'Task'),
                ),
              if (isReminderEnabled)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.notifications_active, size: 16),
                  label: Text(
                    l10n?.calendarReminderDateTimeLabel ?? 'Alarm Enabled',
                  ),
                ),
              if (currentReminder.soundId != null)
                Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.volume_up, size: 16),
                  label: Text(
                    currentReminder.soundTitle ?? l10n?.sound ?? 'Sound',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Timing & Recurrence Hero Card
          ReadOnlyTimingHeroCard(
            timingSummary: reminderSummary,
            isEnabled: isReminderEnabled,
          ),
          // Pinch-to-zoom expandable notes
          if (currentReminder.notes.isNotEmpty) ...[
            const SizedBox(height: 4),
            ReadOnlyZoomableNotesCard(
              notes: currentReminder.notes,
              title: l10n?.readOnlySupplicationNotes ??
                  l10n?.calendarReminderNotesLabel ??
                  'Supplication Notes',
              icon: Icons.menu_book_rounded,
            ),
          ],
          // Audio Player Card
          if (sound != null) ...[
            const SizedBox(height: 4),
            ReadOnlySoundPlayerCard(
              title: currentReminder.soundTitle ?? sound.title,
              duration: soundDurationText,
              speed: _playbackSpeed,
              onSpeedChanged: (s) => _onSpeedChanged(s, sound.path, currentReminder),
              isPlaying: _isPlayingPreview,
              onPlayPause: () => _togglePreviewSound(sound.path),
              playButtonKey: const Key('sound_preview_button'),
            ),
          ],
          // Snooze Options Preview
          const SizedBox(height: 4),
          const ReadOnlySnoozePreviewCard(
            intervals: [5, 10, 15],
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: ReadOnlyBottomActionBar(
        primaryLabel: isTask
            ? (l10n?.readOnlyMarkAsDone ?? 'Mark as Done')
            : (isReminderEnabled
                ? (l10n?.readOnlyDisableReminder ?? 'Disable Reminder')
                : (l10n?.readOnlyEnableReminder ?? 'Enable Reminder')),
        primaryIcon: isTask
            ? Icons.check_circle_outline_rounded
            : (isReminderEnabled
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined),
        primaryKey: const Key('toggle_done_reminder_button'),
        onPrimaryPressed: () => _toggleCompleted(currentReminder, isTask),
        secondaryLabel: l10n?.calendarReminderFormTitleEdit ?? 'Edit Reminder',
        secondaryIcon: Icons.edit_outlined,
        secondaryKey: const Key('edit_reminder_bottom_button'),
        onSecondaryPressed: () => _navigateToEdit(currentReminder),
      ),
    );
  }
}

