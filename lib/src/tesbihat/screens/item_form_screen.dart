import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../services/local_database.dart';
import '../../utils/reminder_format_utils.dart';
import '../../widgets/discard_confirmation_dialog.dart';
import '../../widgets/read_only_detail_section.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../services/audio_player_service.dart';
import '../services/haptic_service.dart';
import '../services/prayer_anchor_resolver.dart';
import '../state/groups_notifier.dart';
import '../state/items_notifier.dart';
import '../state/sound_library_notifier.dart';
import '../widgets/audio_speed_bar.dart';
import '../widgets/sound_picker_sheet.dart';
import 'execution_screen.dart';
import '../widgets/reminder_section.dart';

class ItemFormScreen extends ConsumerStatefulWidget {
  const ItemFormScreen({
    super.key,
    this.itemToEdit,
    this.initialGroupIds,
    this.readOnly = false,
    this.audioPlayerService,
  });

  final Item? itemToEdit;

  /// Groups pre-selected for a newly created bead (e.g. when creating a
  /// bead from inside a group).
  final List<String>? initialGroupIds;
  final bool readOnly;
  final AudioPlayerService? audioPlayerService;

  @override
  ConsumerState<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends ConsumerState<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late bool _readOnly = widget.readOnly;
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _countController;
  late final TextEditingController _checkController;
  late final TextEditingController _setCountController;
  late int _vibrationIntensity;
  late ReminderConfig _reminderConfig;
  late Set<String> _selectedGroupIds;
  String? _soundId;
  String? _soundTitle;
  double _playbackSpeed = 1.0;
  int _playbackPositionMs = 0;
  bool _isSoundControlsExpanded = false;
  late bool _autoCountWithSound;
  late final AudioPlayerService _audioPlayer;
  StreamSubscription<void>? _playerCompleteSubscription;
  bool _isPlayingPreview = false;
  bool _saving = false;

  bool get _isEditing => widget.itemToEdit != null;

  static int _normalizeVibration(int? intensity) {
    if (intensity == null) return 4;
    if (intensity > 8) {
      return (((intensity - 1) * 7) ~/ 99) + 1;
    }
    return intensity.clamp(1, 8);
  }

  bool get _isDirty {
    final item = widget.itemToEdit;
    final initialTitle = item?.title ?? '';
    final initialNotes = item?.notes ?? '';
    final initialCount = item != null ? item.count.toString() : '';
    // Empty and "0" both mean "no checkpoints", so normalize for comparison.
    final initialCheck =
        (item == null || item.check == 0) ? '' : item.check.toString();
    final initialVibration = _normalizeVibration(item?.vibrationIntensity);
    final initialReminder = item != null
        ? ReminderConfig.fromItem(item)
        : const ReminderConfig();
    final initialGroups = item != null
        ? item.groupIds.toSet()
        : (widget.initialGroupIds ?? const []).toSet();
    final initialSoundId = item?.soundId;
    final initialAutoCount = item?.autoCountWithSound ?? true;

    if (_titleController.text != initialTitle) return true;
    if (_notesController.text != initialNotes) return true;
    if (_countController.text != initialCount) return true;
    if (_checkController.text != initialCheck) return true;
    if (_vibrationIntensity != initialVibration) return true;
    if (_reminderConfig.isDirtyComparedTo(initialReminder)) return true;
    if (!setEquals(_selectedGroupIds, initialGroups)) return true;
    if (_soundId != initialSoundId) return true;
    if (_autoCountWithSound != initialAutoCount) return true;
    if ((_playbackSpeed - (item?.soundSpeed ?? 1.0)).abs() > 0.001) return true;

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
      text: (item == null || item.check == 0) ? '' : item.check.toString(),
    );
    _setCountController = TextEditingController(
      text: item != null ? item.setCount.toString() : '0',
    );
    _vibrationIntensity = _normalizeVibration(item?.vibrationIntensity);
    _reminderConfig = item != null
        ? ReminderConfig.fromItem(item)
        : const ReminderConfig();
    _selectedGroupIds = item != null
        ? item.groupIds.toSet()
        : (widget.initialGroupIds ?? const []).toSet();
    _soundId = item?.soundId;
    _soundTitle = item?.soundTitle;
    _playbackSpeed = item?.soundSpeed ?? 1.0;
    _playbackPositionMs = item?.soundPositionMs ?? 0;
    _autoCountWithSound = item?.autoCountWithSound ?? true;
    _audioPlayer =
        widget.audioPlayerService ?? ref.read(audioPlayerServiceProvider);
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          _playbackPositionMs = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.stop();
    _titleController.dispose();
    _notesController.dispose();
    _countController.dispose();
    _checkController.dispose();
    _setCountController.dispose();
    super.dispose();
  }

  void _onSpeedChanged(double newSpeed) {
    setState(() => _playbackSpeed = newSpeed);
    _audioPlayer.setPlaybackRate(newSpeed);
  }

  Future<void> _togglePreviewSound() async {
    if (_soundId == null) return;
    if (_isPlayingPreview) {
      final pos = await _audioPlayer.getCurrentPosition();
      await _audioPlayer.pause();
      if (mounted) {
        setState(() {
          _isPlayingPreview = false;
          if (pos != null) _playbackPositionMs = pos.inMilliseconds;
        });
      }
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
      final startPos = _playbackPositionMs > 0
          ? Duration(milliseconds: _playbackPositionMs)
          : null;
      await _audioPlayer.playFile(
        sound.path,
        mimeType: sound.mimeType,
        playbackRate: _playbackSpeed,
        position: startPos,
      );
      setState(() => _isPlayingPreview = true);
    }
  }

  Future<void> _pickSound() async {
    if (_isPlayingPreview) {
      await _audioPlayer.stop();
      if (!mounted) return;
      setState(() => _isPlayingPreview = false);
    }
    if (!mounted) return;
    final sound = await SoundPickerSheet.show(context);
    if (sound != null && mounted) {
      setState(() {
        if (_soundId != sound.id) {
          _playbackPositionMs = 0;
        }
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
      _playbackPositionMs = 0;
    });
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
    // Empty or 0 both mean "no checkpoints".
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final check = int.tryParse(value.trim());
    final count = int.tryParse(_countController.text.trim());
    if (check == null) {
      return l10n.fieldMustBeInteger(l10n.check);
    }
    if (check < 0) return l10n.checkGreaterThanZero;
    if (check == 0) return null;
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
    final check = int.tryParse(_checkController.text.trim()) ?? 0;
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
        isTask: reminder.isTask,
        soundId: _soundId,
        soundTitle: _soundTitle,
        autoCountWithSound: _autoCountWithSound,
        soundSpeed: _playbackSpeed,
        soundPositionMs: _soundId == widget.itemToEdit!.soundId
            ? _playbackPositionMs
            : 0,
        clearSound: _soundId == null,
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
        isTask: reminder.isTask,
        soundId: _soundId,
        soundTitle: _soundTitle,
        autoCountWithSound: _autoCountWithSound,
        soundSpeed: _playbackSpeed,
        soundPositionMs: _playbackPositionMs,
      );
    }

    if (mounted) {
      await _audioPlayer.stop();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_isDirty) {
          if (context.mounted) {
            Navigator.of(context).pop(result);
          }
          return;
        }
        final shouldDiscard = await showDiscardConfirmationDialog(context);
        if (shouldDiscard == true && context.mounted) {
          Navigator.of(context).pop(result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.editMilestone : l10n.createMilestone),
          actions: [
            if (_readOnly) ...[
              IconButton(
                key: const Key('edit_item_button'),
                tooltip: l10n.edit,
                icon: const Icon(Icons.edit),
                onPressed: () => setState(() => _readOnly = false),
              ),
              if (widget.itemToEdit != null)
                IconButton(
                  key: const Key('execute_item_button'),
                  tooltip: l10n.execute,
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ExecutionScreen(
                          itemId: widget.itemToEdit!.id,
                        ),
                      ),
                    );
                  },
                ),
            ] else ...[
              IconButton(
                key: const Key('save_item_button'),
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
          child: _readOnly
              ? _buildReadOnlyView(context, l10n)
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      TextFormField(
                        key: const Key('title_field'),
                        controller: _titleController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(labelText: l10n.title),
                        validator: (value) =>
                            _requiredValidator(value, l10n.title),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('notes_field'),
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
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('count_field'),
                        controller: _countController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(labelText: l10n.countField),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _countValidator,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const Key('check_field'),
                        controller: _checkController,
                        readOnly: _readOnly,
                        decoration: InputDecoration(
                          labelText: l10n.checkInterval,
                          helperText: l10n.checkHelper,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.vibrationIntensity}: $_vibrationIntensity',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          IconButton(
                            key: const Key('vibration_preview_button'),
                            icon: const Icon(Icons.vibration),
                            tooltip: l10n.previewVibration,
                            onPressed: () {
                              ref.read(hapticServiceProvider).standard(
                                intensity: _vibrationIntensity,
                              );
                            },
                          ),
                        ],
                      ),
                      Slider(
                        key: const Key('intensity_slider'),
                        value: _vibrationIntensity.clamp(1, 8).toDouble(),
                        min: 1,
                        max: 8,
                        divisions: 7,
                        label: _vibrationIntensity.toString(),
                        onChanged: _readOnly
                            ? null
                            : (value) {
                                setState(() {
                                  _vibrationIntensity = value.round();
                                });
                              },
                        onChangeEnd: (value) {
                          ref.read(hapticServiceProvider).standard(
                            intensity: value.round(),
                          );
                        },
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
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
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonal(
                                  key: const Key('sound_preview_button'),
                                  onPressed: _togglePreviewSound,
                                  onLongPress: () async {
                                    await _audioPlayer.stop();
                                    if (mounted) {
                                      setState(() => _isPlayingPreview = false);
                                    }
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    backgroundColor: _isPlayingPreview
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                    foregroundColor: _isPlayingPreview
                                        ? Theme.of(context)
                                            .colorScheme
                                            .onPrimary
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
                                        _isPlayingPreview
                                            ? Icons.pause_circle_filled
                                            : Icons.play_circle_filled,
                                        size: 26,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _soundTitle ?? l10n.sound,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                              if (!_readOnly) ...[
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.swap_horiz),
                                  tooltip: l10n.pickFromLibrary,
                                  onPressed: _pickSound,
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.close),
                                  tooltip: l10n.removeSound,
                                  onPressed: _removeSound,
                                  style: IconButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_isSoundControlsExpanded) ...[
                            const SizedBox(height: 8),
                            AudioSpeedBar(
                              speed: _playbackSpeed,
                              onSpeedChanged: _onSpeedChanged,
                            ),
                          ],
                          const SizedBox(height: 4),
                          SwitchListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.autoCountWithSound),
                            subtitle: Text(
                              l10n.autoCountWithSoundSubtitle,
                            ),
                            value: _autoCountWithSound,
                            onChanged: _readOnly
                                ? null
                                : (value) => setState(
                                      () => _autoCountWithSound = value,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: _readOnly ? null : _pickSound,
                    icon: const Icon(Icons.music_note_outlined),
                    label: Text(
                      '${l10n.recordSound} / ${l10n.pickFromLibrary}',
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ReminderSection(
                  readOnly: _readOnly,
                  initial: _isEditing
                      ? ReminderConfig.fromItem(widget.itemToEdit!)
                      : null,
                  onChanged: (config) =>
                      setState(() => _reminderConfig = config),
                ),
                const SizedBox(height: 20),
                _GroupSelector(
                  selectedIds: _selectedGroupIds,
                  onChanged: (ids) =>
                      setState(() => _selectedGroupIds = ids),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyView(BuildContext context, TesbihatLocalizations l10n) {
    final title = _titleController.text.trim();
    final notes = _notesController.text.trim();
    final targetCount =
        int.tryParse(_countController.text) ?? widget.itemToEdit?.count ?? 33;
    final progress = widget.itemToEdit?.currentProgress ?? 0;
    final progressFraction =
        targetCount > 0 ? (progress / targetCount).clamp(0.0, 1.0) : 0.0;

    final reminderCfg = _reminderConfig;
    final isReminderEnabled = reminderCfg.enabled;
    final isTask = reminderCfg.isTask;

    final reminderSummary = formatConciseReminder(
      context: context,
      enabled: isReminderEnabled,
      isPrayerAnchor: reminderCfg.anchor == ItemReminderAnchor.prayerTime,
      recurrence: reminderCfg.recurrence,
      prayerName: reminderCfg.prayerName,
      offsetMinutes: reminderCfg.offsetMinutes,
      anchorDate: reminderCfg.anchorDate,
      clockTime: reminderCfg.at != null
          ? TimeOfDay(
              hour: reminderCfg.at!.hour,
              minute: reminderCfg.at!.minute,
            )
          : null,
      weekdays: reminderCfg.weekdays,
      dayOfMonth: reminderCfg.dayOfMonth,
      yearlyDate: reminderCfg.yearlyDate,
      monthlyBasis: reminderCfg.monthlyBasis,
      yearlyBasis: reminderCfg.yearlyBasis,
      repeatCount: reminderCfg.repeatCount,
    );

    final sound = _soundId != null
        ? ref.read(soundLibraryNotifierProvider.notifier).getSoundById(_soundId)
        : null;
    final soundDurationText = sound?.durationMs != null
        ? formatAudioDurationMs(sound!.durationMs!)
        : null;

    final allGroups = ref.watch(groupsNotifierProvider);
    final groupNames = allGroups
        .where((g) => _selectedGroupIds.contains(g.id))
        .map((g) => g.title)
        .toList(growable: false);

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        ReadOnlyHeroHeader(
          title: title.isEmpty ? l10n.createMilestone : title,
          icon: Icons.touch_app_outlined,
          subtitle: notes.isNotEmpty ? notes : null,
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
            if (_soundId != null)
              Chip(
                visualDensity: VisualDensity.compact,
                avatar: const Icon(Icons.volume_up, size: 16),
                label: Text(_soundTitle ?? l10n.sound),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ReadOnlyCardContainer(
          title: l10n.title,
          icon: Icons.info_outline,
          children: [
            ReadOnlyFieldTile(
              label: 'Text',
              value: title.isEmpty ? '-' : title,
              icon: Icons.title,
            ),
            if (notes.isNotEmpty)
              ReadOnlyFieldTile(
                label: l10n.notes,
                value: notes,
                icon: Icons.notes,
              ),
            ReadOnlyFieldTile(
              label: 'Reminder at',
              value: reminderSummary,
              icon: Icons.alarm,
              isHighlighted: isReminderEnabled,
            ),
            ReadOnlyFieldTile(
              label: l10n.markAsTask,
              value: isTask ? 'Yes' : 'No',
              icon: Icons.task_alt,
            ),
          ],
        ),
        ReadOnlyCardContainer(
          title: l10n.count,
          icon: Icons.adjust,
          children: [
            ReadOnlyFieldTile(
              label: 'Target & Check',
              value:
                  '${l10n.count}: ${_countController.text} • ${l10n.check}: ${_checkController.text} • ${l10n.set}: ${_setCountController.text}',
              icon: Icons.format_list_numbered,
            ),
            ReadOnlyFieldTile(
              label: l10n.progress,
              value:
                  '$progress / ${_countController.text} (${(progressFraction * 100).toInt()}%)',
              icon: Icons.trending_up,
              customChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$progress / ${_countController.text} (${(progressFraction * 100).toInt()}%)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            ReadOnlyFieldTile(
              label: l10n.vibrationIntensity,
              value: '$_vibrationIntensity%',
              icon: Icons.vibration,
            ),
          ],
        ),
        if (groupNames.isNotEmpty)
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
        ReadOnlyCardContainer(
          title: l10n.sound,
          icon: Icons.music_note,
          children: [
            if (_soundId == null)
              ReadOnlyFieldTile(
                label: l10n.sound,
                value: l10n.noSoundAttached,
                icon: Icons.music_off,
              )
            else ...[
              ReadOnlySoundPlayerCard(
                title: _soundTitle ?? sound?.title ?? l10n.sound,
                duration: soundDurationText,
                speed: _playbackSpeed,
                extraDetail: _autoCountWithSound ? l10n.autoCountWithSound : null,
                isPlaying: _isPlayingPreview,
                onPlayPause: _togglePreviewSound,
                playButtonKey: const Key('sound_preview_button'),
              ),
              if (soundDurationText != null)
                ReadOnlyFieldTile(
                  label: 'Duration',
                  value: soundDurationText,
                  icon: Icons.timer_outlined,
                ),
              ReadOnlyFieldTile(
                label: 'Playback speed',
                value: '${_playbackSpeed}x',
                icon: Icons.speed,
              ),
              ReadOnlyFieldTile(
                label: l10n.autoCountWithSound,
                value: _autoCountWithSound ? 'Yes' : 'No',
                icon: Icons.repeat,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
      ],
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