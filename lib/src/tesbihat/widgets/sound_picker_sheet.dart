import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/tesbihat_localizations.dart';
import '../models/sound_item.dart';
import '../screens/sound_library_screen.dart';
import '../state/sound_library_notifier.dart';
import 'sound_record_dialog.dart';

class SoundPickerSheet extends ConsumerWidget {
  const SoundPickerSheet({super.key});

  static Future<SoundItem?> show(BuildContext context) {
    return showModalBottomSheet<SoundItem>(
      context: context,
      showDragHandle: true,
      builder: (_) => const SoundPickerSheet(),
    );
  }

  Future<void> _pickFromLibrary(BuildContext context) async {
    final sound = await Navigator.push<SoundItem>(
      context,
      MaterialPageRoute(
        builder: (_) => const SoundLibraryScreen(isPicker: true),
      ),
    );
    if (sound != null && context.mounted) {
      Navigator.pop(context, sound);
    }
  }

  Future<void> _recordAudio(BuildContext context) async {
    final sound = await showDialog<SoundItem>(
      context: context,
      builder: (_) => const SoundRecordDialog(saveToLibrary: true),
    );
    if (sound != null && context.mounted) {
      Navigator.pop(context, sound);
    }
  }

  Future<void> _pickFromFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePickerPlatform.instance.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'ogg', 'opus', 'flac'],
    );

    if (result.isEmpty || !context.mounted) return;

    final picked = result.first;
    if (picked.path == null || !context.mounted) return;
    final bytes = await File(picked.path!).readAsBytes();

    if (bytes == null || !context.mounted) return;

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

    if (title == null || title.isEmpty || !context.mounted) return;

    final newSound = ref.read(soundLibraryNotifierProvider.notifier).addSound(
          title: title,
          bytes: bytes,
        );

    if (context.mounted) {
      Navigator.pop(context, newSound);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.tesbihatL10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.library_music_outlined),
              title: Text(l10n.pickFromLibrary),
              onTap: () => _pickFromLibrary(context),
            ),
            ListTile(
              leading: const Icon(Icons.mic_outlined),
              title: Text(l10n.recordSound),
              onTap: () => _recordAudio(context),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(l10n.pickFromFiles),
              onTap: () => _pickFromFile(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
