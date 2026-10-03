import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/sound_item.dart';
import '../services/audio_player_service.dart';
import '../state/sound_library_notifier.dart';
import '../widgets/sound_record_dialog.dart';

class SoundLibraryScreen extends ConsumerStatefulWidget {
  const SoundLibraryScreen({
    super.key,
    this.isPicker = false,
  });

  final bool isPicker;

  @override
  ConsumerState<SoundLibraryScreen> createState() => _SoundLibraryScreenState();
}

class _SoundLibraryScreenState extends ConsumerState<SoundLibraryScreen> {
  late final AudioPlayerService _playerService;
  String? _currentlyPlayingId;

  @override
  void initState() {
    super.initState();
    _playerService = AudioPlayerService();
    _playerService.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _currentlyPlayingId = null);
      }
    });
  }

  @override
  void dispose() {
    _playerService.dispose();
    super.dispose();
  }

  Future<void> _togglePlaySound(SoundItem sound) async {
    if (_currentlyPlayingId == sound.id) {
      await _playerService.pause();
      setState(() => _currentlyPlayingId = null);
    } else {
      await _playerService.playBytes(sound.bytes, mimeType: sound.mimeType);
      setState(() => _currentlyPlayingId = sound.id);
    }
  }

  Future<void> _recordNewSound() async {
    await _playerService.stop();
    setState(() => _currentlyPlayingId = null);

    if (!mounted) return;
    final result = await showDialog<SoundItem>(
      context: context,
      builder: (_) => const SoundRecordDialog(saveToLibrary: true),
    );

    if (result != null && widget.isPicker && mounted) {
      Navigator.pop(context, result);
    }
  }

  Future<void> _importAudioFile() async {
    await _playerService.stop();
    setState(() => _currentlyPlayingId = null);

    final result = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'opus', 'flac'],
    );

    if (result.isEmpty) return;

    final picked = result.first;
    if (picked.path == null || !mounted) return;
    final bytes = await File(picked.path!).readAsBytes();

    if (bytes == null || !mounted) return;

    final defaultName = picked.name.split('.').first;
    final titleController = TextEditingController(text: defaultName);

    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tesbihatL10n.soundName),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.tesbihatL10n.soundName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tesbihatL10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, titleController.text.trim()),
            child: Text(context.tesbihatL10n.save),
          ),
        ],
      ),
    );

    if (title == null || title.isEmpty || !mounted) return;

    final newSound = ref.read(soundLibraryNotifierProvider.notifier).addSound(
          title: title,
          bytes: bytes,
        );

    if (widget.isPicker && mounted) {
      Navigator.pop(context, newSound);
    }
  }

  Future<void> _renameSound(SoundItem sound) async {
    final titleController = TextEditingController(text: sound.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tesbihatL10n.rename),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.tesbihatL10n.soundName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tesbihatL10n.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, titleController.text.trim()),
            child: Text(context.tesbihatL10n.save),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      ref
          .read(soundLibraryNotifierProvider.notifier)
          .updateSoundTitle(sound.id, newTitle);
    }
  }

  Future<void> _deleteSound(SoundItem sound) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tesbihatL10n.delete),
        content: Text(sound.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.tesbihatL10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.tesbihatL10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_currentlyPlayingId == sound.id) {
        await _playerService.stop();
        setState(() => _currentlyPlayingId = null);
      }
      ref.read(soundLibraryNotifierProvider.notifier).deleteSound(sound.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.tesbihatL10n;
    final sounds = ref.watch(soundLibraryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.soundLibrary),
        actions: [
          IconButton(
            tooltip: l10n.recordSound,
            icon: const Icon(Icons.mic),
            onPressed: _recordNewSound,
          ),
          IconButton(
            tooltip: l10n.pickFromFiles,
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: _importAudioFile,
          ),
        ],
      ),
      body: sounds.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.library_music_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noSoundsInLibrary,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: _recordNewSound,
                          icon: const Icon(Icons.mic),
                          label: Text(l10n.recordSound),
                        ),
                        OutlinedButton.icon(
                          onPressed: _importAudioFile,
                          icon: const Icon(Icons.file_upload_outlined),
                          label: Text(l10n.pickFromFiles),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: sounds.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final sound = sounds[index];
                final isPlaying = _currentlyPlayingId == sound.id;

                return Card(
                  child: ListTile(
                    leading: IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                      iconSize: 36,
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () => _togglePlaySound(sound),
                    ),
                    title: Text(
                      sound.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${sound.createdAt.year}-${sound.createdAt.month.toString().padLeft(2, '0')}-${sound.createdAt.day.toString().padLeft(2, '0')}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isPicker)
                          FilledButton(
                            onPressed: () => Navigator.pop(context, sound),
                            child: Text(l10n.select),
                          )
                        else ...[
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            tooltip: l10n.rename,
                            onPressed: () => _renameSound(sound),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n.delete,
                            onPressed: () => _deleteSound(sound),
                          ),
                        ],
                      ],
                    ),
                    onTap: widget.isPicker
                        ? () => Navigator.pop(context, sound)
                        : () => _togglePlaySound(sound),
                  ),
                );
              },
            ),
    );
  }
}
