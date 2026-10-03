import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../services/audio_player_service.dart';
import '../services/audio_recorder_service.dart';
import '../state/sound_library_notifier.dart';

class SoundRecordDialog extends ConsumerStatefulWidget {
  const SoundRecordDialog({
    super.key,
    this.initialTitle = '',
    this.saveToLibrary = true,
  });

  final String initialTitle;
  final bool saveToLibrary;

  @override
  ConsumerState<SoundRecordDialog> createState() => _SoundRecordDialogState();
}

class _SoundRecordDialogState extends ConsumerState<SoundRecordDialog> {
  late final TextEditingController _titleController;
  late final AudioRecorderService _recorderService;
  late final AudioPlayerService _playerService;

  bool _isRecording = false;
  bool _isPlaying = false;
  Uint8List? _recordedBytes;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _recorderService = AudioRecorderService();
    _playerService = AudioPlayerService();

    _playerService.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _recorderService.dispose();
    _playerService.dispose();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    setState(() => _errorMessage = null);
    if (_isRecording) {
      final bytes = await _recorderService.stopRecording();
      setState(() {
        _isRecording = false;
        _recordedBytes = bytes;
      });
    } else {
      final hasPermission = await _recorderService.hasPermission();
      if (!hasPermission) {
        setState(() {
          _errorMessage = context.tesbihatL10n.microphonePermissionRequired;
        });
        return;
      }
      if (_isPlaying) {
        await _playerService.stop();
        setState(() => _isPlaying = false);
      }
      await _recorderService.startRecording();
      setState(() {
        _isRecording = true;
        _recordedBytes = null;
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_recordedBytes == null) return;
    if (_isPlaying) {
      await _playerService.pause();
      setState(() => _isPlaying = false);
    } else {
      await _playerService.playBytes(_recordedBytes!);
      setState(() => _isPlaying = true);
    }
  }

  void _onSave() {
    if (_recordedBytes == null) return;
    final title = _titleController.text.trim().isEmpty
        ? 'Recording ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}'
        : _titleController.text.trim();

    if (widget.saveToLibrary) {
      final sound = ref.read(soundLibraryNotifierProvider.notifier).addSound(
            title: title,
            bytes: _recordedBytes!,
          );
      Navigator.pop(context, sound);
    } else {
      Navigator.pop(context, (title: title, bytes: _recordedBytes!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;

    return AlertDialog(
      title: Text(l10n.recordSound),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: l10n.soundName,
                hintText: l10n.soundNameHint,
              ),
            ),
            const SizedBox(height: 24),
            if (_isRecording) ...[
              const Icon(Icons.mic, color: Colors.red, size: 56),
              const SizedBox(height: 8),
              Text(
                l10n.recording,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else if (_recordedBytes != null) ...[
              Icon(Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary, size: 48),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _togglePlayback,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? l10n.pause : l10n.play),
              ),
            ] else ...[
              const Icon(Icons.mic_none, size: 48, color: Colors.grey),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording
                    ? Colors.red
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.fiber_manual_record),
              label: Text(
                _isRecording ? l10n.stopRecording : l10n.startRecording,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _recordedBytes != null && !_isRecording ? _onSave : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
