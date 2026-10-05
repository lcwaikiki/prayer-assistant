import 'dart:async';

import 'package:audioplayers/audioplayers.dart' show PlayerState;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/tesbihat_localizations.dart';
import '../services/audio_player_service.dart';
import '../services/bead_overlay_service.dart';
import '../services/haptic_service.dart';
import '../services/tap_pace_tracker.dart';
import '../state/items_notifier.dart';
import '../state/sound_library_notifier.dart';
import '../widgets/audio_speed_bar.dart';
import 'item_form_screen.dart';

class ExecutionScreen extends ConsumerStatefulWidget {
  const ExecutionScreen({
    super.key,
    required this.itemId,
    this.audioPlayerService,
  });

  final String itemId;
  final AudioPlayerService? audioPlayerService;

  @override
  ConsumerState<ExecutionScreen> createState() => _ExecutionScreenState();
}

class _ExecutionScreenState extends ConsumerState<ExecutionScreen>
    with WidgetsBindingObserver {
  late final AudioPlayerService _audioPlayer;
  StreamSubscription<void>? _playerCompleteSub;
  bool _isAudioPlaying = false;
  int _soundLoopCount = 0;
  double _playbackSpeed = 1.0;
  bool _isSoundControlsExpanded = false;
  final _overlay = BeadOverlayService();
  bool _isPromptingPermission = false;

  void _setWakelock(bool enabled) {
    WakelockPlus.toggle(enable: enabled).catchError((_) {
      // Ignore platform channel errors in unsupported environments.
    });
  }

  void _lockOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setWakelock(true);
    _lockOrientation();
    _audioPlayer = widget.audioPlayerService ?? AudioPlayerService();
    _playerCompleteSub = _audioPlayer.onPlayerComplete.listen((_) => _onSoundComplete());

    final initialItem = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (initialItem != null && initialItem.soundSpeed > 0) {
      _playbackSpeed = initialItem.soundSpeed;
    }

    _overlay.setOnTap(_onOverlayTap);
    ref.listenManual(
      itemsNotifierProvider,
      (_, _) => _syncOverlay(),
      fireImmediately: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lockOrientation();
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      final item = ref
          .read(itemsNotifierProvider)
          .where((element) => element.id == widget.itemId)
          .firstOrNull;
      if (item != null && item.currentProgress >= item.count) {
        ref.read(itemsNotifierProvider.notifier).resetProgress(widget.itemId);
      }
      _maybePromptOverlayPermission();
    });
  }

  /// Arms the floating bubble with the current progress, or disarms it
  /// when the item is missing or complete.
  void _syncOverlay() {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null || item.currentProgress >= item.count) {
      _overlay.disarm();
    } else {
      _overlay.arm('${item.currentProgress}');
    }
  }

  void _onOverlayTap() {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null || item.currentProgress >= item.count) return;
    _countBead();
  }

  Future<void> _maybePromptOverlayPermission() async {
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

  /// Counts one bead with haptic feedback; shared by the tap button and
  /// the floating bubble.
  Future<void> _countBead() async {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .first;
    ref.read(beadPaceTrackerProvider.notifier).recordTap(widget.itemId);

    if (item.currentProgress + 1 >= item.count && _isAudioPlaying) {
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
    }
  }

  Future<void> _playCurrentSound() async {
    final item = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (item == null || item.soundId == null) return;

    final sound = ref
        .read(soundLibraryNotifierProvider.notifier)
        .getSoundById(item.soundId);
    if (sound != null) {
      await _audioPlayer.playBytes(
        sound.bytes,
        mimeType: sound.mimeType,
        playbackRate: _playbackSpeed,
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
      await _audioPlayer.pause();
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
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isAudioPlaying = false;
        _soundLoopCount = 0;
      });
    }
  }

  Future<void> _onSoundComplete() async {
    if (!_isAudioPlaying || !mounted) return;
    final currentItem = ref
        .read(itemsNotifierProvider)
        .where((element) => element.id == widget.itemId)
        .firstOrNull;
    if (currentItem == null) return;

    if (currentItem.autoCountWithSound) {
      if (currentItem.currentProgress < currentItem.count) {
        ref.read(beadPaceTrackerProvider.notifier).recordTap(widget.itemId);
        final feedback = ref
            .read(itemsNotifierProvider.notifier)
            .incrementProgress(widget.itemId);
        final haptic = ref.read(hapticServiceProvider);
        if (feedback == TapFeedback.standard) {
          await haptic.standard(intensity: currentItem.vibrationIntensity);
        } else if (feedback == TapFeedback.checkpoint) {
          await haptic.checkpoint(intensity: currentItem.vibrationIntensity);
        }

        final updatedItem = ref
            .read(itemsNotifierProvider)
            .where((element) => element.id == widget.itemId)
            .firstOrNull;
        if (updatedItem != null &&
            updatedItem.currentProgress < updatedItem.count &&
            _isAudioPlaying) {
          await _playCurrentSound();
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
        await _playCurrentSound();
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
      _lockOrientation();
      _syncOverlay();
      _maybePromptOverlayPermission();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
      if (_isAudioPlaying) {
        _audioPlayer.pause();
        setState(() => _isAudioPlaying = false);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlay.setOnTap(null);
    _overlay.disarm();
    _setWakelock(false);
    _playerCompleteSub?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
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
      if (item.currentProgress == 0 || item.currentProgress >= item.count) {
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
        ref.read(beadPaceTrackerProvider.notifier).pauseSession(widget.itemId);
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
    final maxMinusCount = (item.count - item.currentProgress).clamp(
      0,
      item.count,
    );
    final setCountValue = item.setCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(
            key: const Key('edit_item_button'),
            tooltip: l10n.edit,
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => ItemFormScreen(itemToEdit: item),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),
              LinearProgressIndicator(
                key: const Key('progress_bar'),
                value: item.count == 0 ? 0.0 : item.currentProgress / item.count,
                minHeight: 10,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 16),
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
                const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              Expanded(
                child: SizedBox.expand(
                  child: OutlinedButton(
                    key: const Key('big_tap_button'),
                    onPressed: item.currentProgress >= item.count
                        ? null
                        : handleTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      l10n.tap,
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('reset_button'),
                onPressed: confirmReset,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.reset),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.notes,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: SingleChildScrollView(
                  child: Text(
                    item.notes.isEmpty ? l10n.noNotesAdded : item.notes,
                    key: const Key('notes_bottom_text'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
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
