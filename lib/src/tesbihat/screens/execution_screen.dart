import 'dart:async';

import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../l10n/app_localizations.dart';
import '../../controller/prayer_app_controller.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../services/audio_player_service.dart';
import '../services/bead_overlay_service.dart';
import '../services/haptic_service.dart';
import '../services/tap_pace_tracker.dart';
import '../state/interval_sound_notifier.dart';
import '../state/items_notifier.dart';
import '../state/minimize_on_exit_notifier.dart';
import '../state/sound_library_notifier.dart';
import '../state/stealth_mode_notifier.dart';
import '../widgets/audio_speed_bar.dart';
import '../widgets/truncated_title_tooltip.dart';
import '../widgets/zoomable_notes_text.dart';
import 'item_form_screen.dart';
import '../../utils/orientation_utils.dart';
import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../models/item_group.dart';
import '../state/groups_notifier.dart';
import '../services/item_reminder_service.dart';

class ExecutionScreen extends ConsumerStatefulWidget {
  const ExecutionScreen({
    super.key,
    required this.itemId,
    this.groupId,
    this.audioPlayerService,
    this.chimePlayerService,
    this.reminderService,
  });

  final String itemId;
  final String? groupId;
  final AudioPlayerService? audioPlayerService;
  final AudioPlayerService? chimePlayerService;
  final ItemReminderService? reminderService;

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen>
    with WidgetsBindingObserver {
  PrayerAppController? _appController;
  late final AudioPlayerService _audioPlayer;
  late final AudioPlayerService _chimePlayer;
  StreamSubscription<void>? _playerCompleteSub;
  bool _isAudioPlaying = false;
  int _soundLoopCount = 0;
  double _playbackSpeed = 1.0;
  bool _isSoundControlsExpanded = false;
  bool _isNotesExpanded = false;
  bool _isTaskDone = false;
  final _overlay = BeadOverlayService();

  ItemReminderService _getReminderService() {
    if (widget.reminderService != null) {
      return widget.reminderService!;
    }
    try {
      return ref.read(itemReminderServiceProvider);
    } catch (_) {
      return ItemReminderService();
    }
  }

  LocalDatabase _getDatabase() {
    try {
      return ref.read(localDatabaseProvider);
    } catch (_) {
      return LocalDatabase();
    }
  }

  String _dateKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }

  void _checkInitialTaskCompletion(String itemId, String? groupId) {
    final today = DateTime.now();
    ItemGroup? group;
    if (groupId != null) {
      try {
        final allGroups = ref.read(groupsNotifierProvider);
        group = allGroups.where((g) => g.id == groupId).firstOrNull;
      } catch (_) {}
    }
    final taskId = (group != null && group.isTask)
        ? 'group_${group.id}'
        : 'bead_$itemId';

    if (_appController != null) {
      _isTaskDone = _appController!.isTaskCompleted(taskId, today);
    } else {
      try {
        _getDatabase().loadTaskCompletions().then((completions) {
          final key = _dateKey(today);
          final list = completions[key] ?? [];
          if (mounted && list.contains(taskId)) {
            setState(() {
              _isTaskDone = true;
            });
          }
        }).catchError((_) {});
      } catch (_) {}
    }
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }
  bool _isPromptingPermission = false;
  static int _activeExecutionScreens = 0;

  @visibleForTesting
  static int get activeExecutionScreens => _activeExecutionScreens;

  @visibleForTesting
  static set activeExecutionScreens(int value) => _activeExecutionScreens = value;

  static void _setWakelock(bool enabled) {
    WakelockPlus.toggle(enable: enabled).catchError((_) {
      // Ignore platform channel errors in unsupported environments.
    });
  }

  void _lockOrientation() {
    lockPortraitOnPhones();
  }

  void _restoreOrientation() {
    final tab = _appController?.tabIndex;
    if (tab != 0 && tab != 4) {
      SystemChrome.setPreferredOrientations([]);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PrayerAppController? nextController;
    try {
      nextController = context.read<PrayerAppController>();
    } catch (_) {
      nextController = null;
    }
    if (_appController != nextController) {
      _appController?.removeListener(_onControllerChanged);
      _appController = nextController;
      _appController?.addListener(_onControllerChanged);
    }
    _checkInitialTaskCompletion(widget.itemId, widget.groupId);
  }

  @override
  void initState() {
    super.initState();
    _activeExecutionScreens++;
    WidgetsBinding.instance.addObserver(this);
    _setWakelock(true);
    _lockOrientation();
    _audioPlayer =
        widget.audioPlayerService ?? ref.read(audioPlayerServiceProvider);
    _chimePlayer =
        widget.chimePlayerService ?? ref.read(chimePlayerServiceProvider);
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) => _onSoundComplete());

    final initialItem = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (initialItem != null) {
      if (initialItem.soundSpeed > 0) {
        _playbackSpeed = initialItem.soundSpeed;
      }
    }

    _overlay.setOnTap(_onOverlayTap);
    ref.listenManual(
      itemsNotifierProvider,
      (_, _) => _syncOverlay(),
    );
    ref.listenManual(
      minimizeOnExitNotifierProvider,
      (_, enabled) {
        if (enabled) {
          _syncOverlay();
          _maybePromptOverlayPermission();
        } else {
          _overlay.disarm();
        }
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setWakelock(true);
      _lockOrientation();
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      final item = ref
          .read(itemsNotifierProvider)
          .where((element) => element.id == widget.itemId)
          .firstOrNull;
      if (item != null && item.currentProgress >= item.count) {
        ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
        ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      }
      _syncOverlay();
      _maybePromptOverlayPermission();
    });
  }

  /// Arms the floating bubble with the current progress, or disarms it
  /// when the item is missing or minimize on exit is disabled.
  void _syncOverlay() {
    final minimizeOnExit = ref.read(minimizeOnExitNotifierProvider);
    if (!minimizeOnExit) {
      _overlay.disarm();
      return;
    }
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null) {
      _overlay.disarm();
    } else {
      final closeLabel = AppLocalizations.of(context)?.beadOverlayClose;
      _overlay.arm('${item.currentProgress}', closeLabel: closeLabel);
    }
  }

  void _onOverlayTap([DateTime? timestamp]) {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null) return;
    _countBead(fromOverlay: true, timestamp: timestamp);
  }

  Future<void> _maybePromptOverlayPermission() async {
    final minimizeOnExit = ref.read(minimizeOnExitNotifierProvider);
    if (!minimizeOnExit) return;
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null) return;
    if (_isPromptingPermission || !mounted) return;
    if (!await _overlay.shouldPromptForPermission() || !mounted) return;
    _isPromptingPermission = true;
    try {
      final l10n = context.tesbihatL10n;
      final enable = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l10n.floatingCounterTitle),
          content: Text(l10n.floatingCounterBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.floatingCounterEnable),
            ),
          ],
        ),
      );
      if (enable == true) await _overlay.requestPermission();
    } finally {
      _isPromptingPermission = false;
    }
  }

  void _toggleMinimizeOnExit(bool value) {
    ref.read(minimizeOnExitNotifierProvider.notifier).setEnabled(value);
    if (value) {
      _syncOverlay();
      _maybePromptOverlayPermission();
    } else {
      _overlay.disarm();
    }
  }

  /// Counts one bead with haptic feedback; shared by the tap button and
  /// the floating bubble.
  Future<void> _countBead({bool fromOverlay = false, DateTime? timestamp}) async {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .first;
    if (item.currentProgress >= item.count) {
      ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
    } else if (item.currentProgress == 0) {
      ref.read(beadPaceTrackerProvider.notifier).reset(widget.itemId);
    }
    ref
        .read(beadPaceTrackerProvider.notifier)
        .recordTap(widget.itemId, timestamp);

    final isTargetReached = item.currentProgress + 1 >= item.count;
    if (isTargetReached && _isAudioPlaying) {
      await _audioPlayer.stop();
      setState(() => _isAudioPlaying = false);
    }

    final feedback = ref
        .read(itemsNotifierProvider.notifier)
        .incrementProgress(widget.itemId);
    final haptic = ref.read(hapticServiceProvider);

    if (feedback == TapFeedback.standard) {
      await haptic.standard(intensity: item.vibrationIntensity);
    } else if (feedback == TapFeedback.checkpoint) {
      await haptic.checkpoint(intensity: item.vibrationIntensity);
      _playIntervalChime();
    }

    if (isTargetReached && fromOverlay) {
      // When counting in minimized mode and count reached the end,
      // do not close: bring the user back to the bead execution screen!
      await _overlay.openApp();
    }
  }

  void _playIntervalChime() {
    if (ref.read(intervalSoundNotifierProvider)) {
      _chimePlayer.playAsset('audio/interval_chime.mp3').catchError((_) {});
    }
  }

  Future<void> _playCurrentSound({bool resumePosition = true}) async {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null || item.soundId == null) return;

    final sound = ref
        .read(soundLibraryNotifierProvider.notifier)
        .getSoundById(item.soundId);
    if (sound != null) {
      final posMs = resumePosition ? item.soundPositionMs : 0;
      await _audioPlayer.playFile(
        sound.path,
        mimeType: sound.mimeType,
        playbackRate: _playbackSpeed,
        position: posMs > 0 ? Duration(milliseconds: posMs) : null,
      );
    }
  }

  void _onSpeedChanged(double newSpeed) {
    setState(() => _playbackSpeed = newSpeed);
    _audioPlayer.setPlaybackRate(newSpeed);

    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item != null && item.soundSpeed != newSpeed) {
      ref
          .read(itemsNotifierProvider.notifier)
          .updateItem(item.copyWith(soundSpeed: newSpeed));
    }
  }

  Future<void> _toggleAudioPlayback() async {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null || item.soundId == null) return;

    if (_isAudioPlaying) {
      final pos = await _audioPlayer.getCurrentPosition();
      await _audioPlayer.pause();
      if (item != null && pos != null) {
        ref.read(itemsNotifierProvider.notifier).updateItem(
          item.copyWith(soundPositionMs: pos.inMilliseconds),
        );
      }
      setState(() => _isAudioPlaying = false);
    } else {
      if (item.currentProgress >= item.count) {
        return;
      }
      setState(() => _isAudioPlaying = true);
      if (_audioPlayer.state == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        _soundLoopCount = 0;
        await _playCurrentSound();
      }
    }
  }

  Future<void> _stopAudioPlayback() async {
    final pos = await _audioPlayer.getCurrentPosition();
    await _audioPlayer.stop();
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item != null && pos != null) {
      ref.read(itemsNotifierProvider.notifier).updateItem(
        item.copyWith(soundPositionMs: pos.inMilliseconds),
      );
    }
    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
        _soundLoopCount = 0;
      });
    }
  }

  Future<void> _onSoundComplete() async {
    final currentItem = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (currentItem != null && currentItem.soundPositionMs != 0) {
      ref.read(itemsNotifierProvider.notifier).updateItem(
        currentItem.copyWith(soundPositionMs: 0),
      );
    }

    if (!_isAudioPlaying || !mounted) return;
    if (currentItem == null) return;

    if (currentItem.autoCountWithSound) {
      if (currentItem.currentProgress < currentItem.count) {
        if (currentItem.currentProgress == 0) {
          ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
        }
        ref.read(beadPaceTrackerProvider.notifier).recordTap(widget.itemId);
        final feedback = ref
            .read(itemsNotifierProvider.notifier)
            .incrementProgress(widget.itemId);
        final haptic = ref.read(hapticServiceProvider);
        if (feedback == TapFeedback.standard) {
          await haptic.standard(intensity: currentItem.vibrationIntensity);
        } else if (feedback == TapFeedback.checkpoint) {
          await haptic.checkpoint(intensity: currentItem.vibrationIntensity);
          _playIntervalChime();
        }

        final updatedItem = ref
            .read(itemsNotifierProvider)
            .where((element) => element.id == widget.itemId)
            .firstOrNull;
        if (updatedItem != null &&
            updatedItem.currentProgress < updatedItem.count &&
            _isAudioPlaying) {
          await _playCurrentSound(resumePosition: false);
        } else {
          if (mounted) setState(() => _isAudioPlaying = false);
        }
      } else {
        if (mounted) setState(() => _isAudioPlaying = false);
      }
    } else {
      _soundLoopCount++;
      final remainingNeeded = currentItem.count - currentItem.currentProgress;
      if (_soundLoopCount < remainingNeeded && _isAudioPlaying) {
        await _playCurrentSound(resumePosition: false);
      } else {
        if (mounted) {
          setState(() {
            _isAudioPlaying = false;
            _soundLoopCount = 0;
          });
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_activeExecutionScreens > 0) {
        _setWakelock(true);
      }
      _lockOrientation();
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final item = ref
            .read(itemsNotifierProvider)
            .where((element) => element.id == widget.itemId)
            .firstOrNull;
        if (item != null && item.currentProgress >= item.count) {
          ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
          ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
        }
        _syncOverlay();
        _maybePromptOverlayPermission();
      });
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      if (_isAudioPlaying) {
        _audioPlayer.getCurrentPosition().then((pos) {
          if (pos != null) {
            final item = ref
                .read(itemsNotifierProvider)
                .where((element) => element.id == widget.itemId)
                .firstOrNull;
            if (item != null) {
              ref.read(itemsNotifierProvider.notifier).updateItem(
                    item.copyWith(soundPositionMs: pos.inMilliseconds),
                  );
            }
          }
        });
        _audioPlayer.pause();
        setState(() => _isAudioPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    _appController?.removeListener(_onControllerChanged);
    WidgetsBinding.instance.removeObserver(this);
    _overlay.setOnTap(null);
    _overlay.disarm();
    _activeExecutionScreens--;
    if (_activeExecutionScreens <= 0) {
      _activeExecutionScreens = 0;
      _setWakelock(false);
    }
    _playerCompleteSub?.cancel();
    if (_isAudioPlaying) {
      _audioPlayer.getCurrentPosition().then((pos) {
        if (pos != null) {
          final item = ref
              .read(itemsNotifierProvider)
              .where((element) => element.id == widget.itemId)
              .firstOrNull;
          if (item != null) {
            ref.read(itemsNotifierProvider.notifier).updateItem(
                  item.copyWith(soundPositionMs: pos.inMilliseconds),
                );
          }
        }
      });
    }
    _audioPlayer.stop();
    _chimePlayer.stop();
    _restoreOrientation();
    super.dispose();
  }

  Future<void> _completeTaskAndExit(Item item, [ItemGroup? group]) async {
    final today = DateTime.now();
    final isGroupTask = group != null && group.isTask;
    final taskId = isGroupTask ? 'group_${group.id}' : 'bead_${item.id}';

    if (_appController != null) {
      _appController!.setTaskCompletion(taskId, today, true);
      if (item.isTask) {
        _appController!.setTaskCompletion('bead_${item.id}', today, true);
      }
    } else {
      try {
        final db = _getDatabase();
        final completions = await db.loadTaskCompletions();
        final key = _dateKey(today);
        final next = Map<String, List<String>>.from(completions);
        final current = List<String>.from(next[key] ?? []);
        if (!current.contains(taskId)) {
          current.add(taskId);
        }
        if (item.isTask && !current.contains('bead_${item.id}')) {
          current.add('bead_${item.id}');
        }
        next[key] = current;
        await db.saveTaskCompletions(next);
      } catch (_) {}
    }

    final reminderService = _getReminderService();
    if (isGroupTask) {
      if (group.reminderRecurrence == ReminderRecurrence.once ||
          group.reminderRepeatCount == 1) {
        await reminderService.cancelReminder(group.id);
      } else {
        await reminderService.cancelActiveNotification(group.id);
      }
    }
    if (item.isTask || item.reminderEnabled) {
      if (item.reminderRecurrence == ReminderRecurrence.once ||
          item.reminderRepeatCount == 1) {
        await reminderService.cancelReminder(item.id);
      } else {
        await reminderService.cancelActiveNotification(item.id);
      }
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final item = ref
        .watch(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;

    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.itemNotFound)),
      );
    }

    final paceTracker = ref.watch(beadPaceTrackerProvider)[widget.itemId] ??
        ref.read(beadPaceTrackerProvider.notifier).trackerFor(widget.itemId);

    String computeTimeLeft() {
      if (item.currentProgress >= item.count) {
        return '00:00';
      }
      if (item.currentProgress == 0) {
        return paceTracker.formatRemaining(item.count);
      }
      final remaining =
          (item.count - item.currentProgress).clamp(0, item.count);
      return paceTracker.formatRemaining(remaining);
    }

    Future<void> handleTap() => _countBead();

    Future<void> confirmReset() async {
      final shouldReset = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(l10n.resetProgressTitle),
            content: Text(l10n.resetProgressBody),
            actions: [
              TextButton(
                key: const Key('cancel_reset_button'),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                key: const Key('confirm_reset_button'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n.reset),
              ),
            ],
          );
        },
      );

      if (shouldReset == true) {
        if (_isAudioPlaying) {
          await _audioPlayer.stop();
          setState(() => _isAudioPlaying = false);
        }
        ref.read(beadPaceTrackerProvider.notifier).reset(widget.itemId);
        ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
      }
    }

    Future<void> editProgressAndSetCount() async {
      var progressInput = item.currentProgress.toString();
      var setCountInput = item.setCount.toString();
      String? errorText;

      final result = await showDialog<(int, int)>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(l10n.editProgressAndSetCount),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const Key('progress_edit_field'),
                      initialValue: progressInput,
                      onChanged: (value) => progressInput = value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l10n.progressCount,
                        hintText: '0 - ${item.count}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      key: const Key('set_count_edit_field'),
                      initialValue: setCountInput,
                      onChanged: (value) => setCountInput = value,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(labelText: l10n.setCount),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                actions: [
                  TextButton(
                    key: const Key('cancel_count_set_edit_button'),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    key: const Key('save_count_set_edit_button'),
                    onPressed: () {
                      final progress = int.tryParse(progressInput.trim());
                      final setCount = int.tryParse(setCountInput.trim());
                      if (progress == null) {
                        setState(() {
                          errorText = l10n.validProgressNumber;
                        });
                        return;
                      }
                      if (progress < 0 || progress > item.count) {
                        setState(() {
                          errorText = l10n.progressBetween(item.count);
                        });
                        return;
                      }
                      if (setCount == null || setCount < 0) {
                        setState(() {
                          errorText = l10n.setCountCannotNegative;
                        });
                        return;
                      }
                      Navigator.pop(dialogContext, (progress, setCount));
                    },
                    child: Text(l10n.save),
                  ),
                ],
              );
            },
          );
        },
      );

      if (result != null) {
        if (_isAudioPlaying) {
          await _audioPlayer.stop();
          setState(() => _isAudioPlaying = false);
        }
        ref.read(beadPaceTrackerProvider.notifier).reset(widget.itemId);
        final error = ref
            .read(itemsNotifierProvider.notifier)
            .updateProgressAndSetCount(
              id: widget.itemId,
              progress: result.$1,
              setCount: result.$2,
            );
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    }

    final countValue = item.count;
    final effectiveProgress =
        item.currentProgress >= item.count ? 0 : item.currentProgress;
    final maxMinusCount = (item.count - effectiveProgress).clamp(
      0,
      item.count,
    );
    final setCountValue = item.setCount;
    final minimizeOnExit = ref.watch(minimizeOnExitNotifierProvider);
    final intervalChimeEnabled = ref.watch(intervalSoundNotifierProvider);
    final stealthMode = ref.watch(stealthModeNotifierProvider);

    final allItems = ref.watch(itemsNotifierProvider);
    ItemGroup? currentGroup;
    if (widget.groupId != null) {
      try {
        final allGroups = ref.watch(groupsNotifierProvider);
        currentGroup =
            allGroups.where((g) => g.id == widget.groupId).firstOrNull;
      } catch (_) {}
    }

    final groupMembers = widget.groupId != null
        ? allItems
            .where((element) => element.groupIds.contains(widget.groupId))
            .toList(growable: false)
        : const <Item>[];
    final groupIndex = widget.groupId != null
        ? groupMembers.indexWhere((element) => element.id == widget.itemId)
        : -1;
    final isGroupMember = widget.groupId != null && groupIndex != -1;
    final isBeadCompleted = item.currentProgress >= item.count;
    final hasNextBead = isGroupMember && (groupIndex + 1 < groupMembers.length);
    final isLastGroupBead = isGroupMember && !hasNextBead;

    final isGroupTask = currentGroup != null && currentGroup.isTask;
    final isTaskItem = item.isTask || isGroupTask;
    final shouldShowMarkAsDone = isTaskItem &&
        isBeadCompleted &&
        (!isGroupMember || isLastGroupBead);

    final taskId = isGroupTask ? 'group_${currentGroup.id}' : 'bead_${item.id}';
    final isTaskDone =
        _appController?.isTaskCompleted(taskId, DateTime.now()) ??
            _isTaskDone;
    final nextItem = hasNextBead ? groupMembers[groupIndex + 1] : null;

    void moveToNextOrGroup() {
      if (hasNextBead && nextItem != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(
            builder: (_) => ExecutionScreen(
              itemId: nextItem.id,
              groupId: widget.groupId,
              audioPlayerService: widget.audioPlayerService,
              chimePlayerService: widget.chimePlayerService,
              reminderService: widget.reminderService,
            ),
          ),
        );
      } else {
        Navigator.pop(context);
      }
    }

    return Theme(
      data: stealthMode
          ? _buildStealthTheme(Theme.of(context))
          : Theme.of(context),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: stealthMode ? Colors.black : null,
          appBar: AppBar(
            backgroundColor: stealthMode ? Colors.black : null,
            foregroundColor: stealthMode ? _stealthGray : null,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TruncatedTitleTooltip(
                    title: item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: stealthMode ? _stealthGray : null,
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton.filledTonal(
                key: const Key('toggle_stealth_mode_button'),
                tooltip: l10n.stealthMode,
                style: IconButton.styleFrom(
                  backgroundColor: stealthMode
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: stealthMode
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.outline,
                ),
                icon: Icon(
                  stealthMode
                      ? Icons.visibility_off
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => ref
                    .read(stealthModeNotifierProvider.notifier)
                    .setEnabled(!stealthMode),
              ),
              IconButton.filledTonal(
            key: const Key('toggle_interval_chime_button'),
            tooltip: l10n.intervalChime,
            style: IconButton.styleFrom(
              backgroundColor: intervalChimeEnabled
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: intervalChimeEnabled
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.outline,
            ),
            icon: Icon(
              intervalChimeEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
            ),
            onPressed: () => ref
                .read(intervalSoundNotifierProvider.notifier)
                .setEnabled(!intervalChimeEnabled),
          ),
          IconButton.filledTonal(
            key: const Key('toggle_minimize_on_exit_button'),
            tooltip: l10n.minimizeOnExit,
            style: IconButton.styleFrom(
              backgroundColor: minimizeOnExit
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              foregroundColor: minimizeOnExit
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : Theme.of(context).colorScheme.outline,
            ),
            icon: Icon(
              minimizeOnExit
                  ? Icons.picture_in_picture_alt
                  : Icons.picture_in_picture_alt_outlined,
            ),
            onPressed: () => _toggleMinimizeOnExit(!minimizeOnExit),
          ),
          IconButton(
            key: const Key('edit_item_button'),
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ItemFormScreen(
                    itemToEdit: item,
                    audioPlayerService: widget.audioPlayerService,
                  ),
                ),
              );
              if (mounted) {
                _setWakelock(true);
              }
            },
          ),
          if (shouldShowMarkAsDone)
            IconButton.filled(
              key: const Key('mark_as_done_appbar_button'),
              tooltip: isTaskDone ? l10n.done : l10n.markAsDone,
              icon: Icon(isTaskDone ? Icons.check_circle : Icons.check),
              onPressed: () => _completeTaskAndExit(item, currentGroup),
            )
          else if (isGroupMember && isBeadCompleted)
            IconButton.filled(
              key: const Key('next_group_bead_button'),
              tooltip: hasNextBead ? 'Next' : 'Done',
              icon: Icon(hasNextBead ? Icons.arrow_forward : Icons.done),
              onPressed: moveToNextOrGroup,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TopStatCard(label: l10n.count, value: '$countValue'),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TopStatCard(
                      label: l10n.maxMinusCount,
                      value: '$maxMinusCount',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TopStatCard(
                      label: l10n.timeLeft,
                      value: computeTimeLeft(),
                      valueKey: const Key('time_left_value_text'),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _TopStatCard(
                      label: l10n.setCount,
                      value: '$setCountValue',
                      valueKey: const Key('set_count_value_text'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                key: const Key('progress_bar'),
                value: item.count == 0 ? 0.0 : item.currentProgress / item.count,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                key: const Key('progress_text_long_press_target'),
                onLongPress: editProgressAndSetCount,
                child: Text(
                  '${item.currentProgress}',
                  key: const Key('progress_text'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              if (item.soundId != null) ...[
                const SizedBox(height: 8),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonal(
                                key: const Key('audio_playback_button'),
                                onPressed: item.currentProgress >= item.count
                                    ? null
                                    : _toggleAudioPlayback,
                                onLongPress: item.currentProgress >= item.count
                                    ? null
                                    : _stopAudioPlayback,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 12,
                                  ),
                                  backgroundColor: _isAudioPlaying
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                  foregroundColor: _isAudioPlaying
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isAudioPlaying
                                          ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        item.soundTitle ?? l10n.sound,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _isAudioPlaying
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withValues(alpha: 0.2)
                                                : Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${(item.count - item.currentProgress).clamp(0, item.count)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              key: const Key('toggle_sound_controls_button'),
                              onPressed: () {
                                setState(() {
                                  _isSoundControlsExpanded =
                                      !_isSoundControlsExpanded;
                                });
                              },
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                              ),
                              icon: AnimatedRotation(
                                turns: _isSoundControlsExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ],
                        ),
                        if (_isSoundControlsExpanded) ...[
                          const SizedBox(height: 8),
                          AudioSpeedBar(
                            speed: _playbackSpeed,
                            onSpeedChanged: _onSpeedChanged,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Expanded(
                child: SizedBox.expand(
                  child: OutlinedButton(
                    key: const Key('big_tap_button'),
                    onPressed: item.currentProgress >= item.count
                        ? null
                        : handleTap,
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.tap,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const Key('reset_button'),
                    onPressed: confirmReset,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.reset),
                  ),
                  if (shouldShowMarkAsDone)
                    FilledButton.icon(
                      key: const Key('mark_as_done_button'),
                      onPressed: () => _completeTaskAndExit(item, currentGroup),
                      icon: Icon(isTaskDone ? Icons.check_circle : Icons.check),
                      label: Text(isTaskDone ? l10n.done : l10n.markAsDone),
                    )
                  else if (isGroupMember && isBeadCompleted)
                    FilledButton.icon(
                      key: const Key('next_group_bead_action_button'),
                      onPressed: moveToNextOrGroup,
                      icon: Icon(hasNextBead ? Icons.arrow_forward : Icons.done),
                      label: Text(hasNextBead ? 'Next' : 'Done'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.notes,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  IconButton(
                    key: const Key('toggle_notes_expansion_button'),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: _isNotesExpanded ? 'Collapse' : 'Expand',
                    icon: Icon(
                      _isNotesExpanded
                          ? Icons.keyboard_arrow_down
                          : Icons.keyboard_arrow_up,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNotesExpanded = !_isNotesExpanded;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: double.infinity,
                height: _isNotesExpanded ? 200 : 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: ZoomableNotesText(
                  text: item.notes.isEmpty ? l10n.noNotesAdded : item.notes,
                  textKey: const Key('notes_bottom_text'),
                  style: Theme.of(context).textTheme.bodyMedium,
                  zoomable: _isNotesExpanded,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }

  static const _stealthGray = Color(0xFF8E8E93);
  static const _stealthDimGray = Color(0xFF6E6E73);

  static ThemeData _buildStealthTheme(ThemeData base) {
    const scheme = ColorScheme.dark(
      surface: Colors.black,
      surfaceContainerLow: Color(0xFF0A0A0A),
      surfaceContainer: Color(0xFF101010),
      surfaceContainerHighest: Color(0xFF141414),
      primary: _stealthGray,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF1C1C1E),
      onPrimaryContainer: _stealthGray,
      secondary: _stealthGray,
      onSecondary: Colors.black,
      onSurface: _stealthGray,
      onSurfaceVariant: _stealthDimGray,
      outline: Color(0xFF3A3A3C),
      outlineVariant: Color(0xFF2C2C2E),
    );
    return base.copyWith(
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.black,
      cardTheme: const CardThemeData(
        color: Color(0xFF0A0A0A),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: _stealthGray,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: _stealthGray,
        displayColor: _stealthGray,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _stealthGray,
        linearTrackColor: Color(0xFF1C1C1E),
      ),
    );
  }
}

class _TopStatCard extends StatelessWidget {
  const _TopStatCard({required this.label, required this.value, this.valueKey});

  final String label;
  final String value;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                key: valueKey,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
