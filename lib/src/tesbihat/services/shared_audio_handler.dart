import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../calendar/models/calendar_reminder.dart';
import '../../controller/prayer_app_controller.dart';
import '../../navigation.dart';
import '../../services/local_database.dart';
import '../l10n/tesbihat_localizations.dart';
import '../models/item.dart';
import '../models/sound_item.dart';
import '../state/items_notifier.dart';
import '../state/sound_library_notifier.dart';

class SharedAudioHandler {
  static StreamSubscription<List<SharedMediaFile>>? _intentDataStreamSubscription;
  static bool _initialized = false;

  static void initialize(ProviderContainer container) {
    if (_initialized) return;
    _initialized = true;

    // Listen to media sharing while app is in memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          _processSharedMedia(value, container);
        }
      },
      onError: (_) {},
    );

    // Get the media sharing coming from outside the app while the app was closed
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      if (value.isNotEmpty) {
        _processSharedMedia(value, container);
        ReceiveSharingIntent.instance.reset();
      }
    }).catchError((_) {});
  }

  static void dispose() {
    _intentDataStreamSubscription?.cancel();
    _intentDataStreamSubscription = null;
    _initialized = false;
  }

  static Future<void> _processSharedMedia(
    List<SharedMediaFile> files,
    ProviderContainer container,
  ) async {
    for (final file in files) {
      final path = file.path;
      if (path.isEmpty) continue;

      final isAudio = file.type == SharedMediaType.video ||
          file.type == SharedMediaType.file ||
          path.endsWith('.mp3') ||
          path.endsWith('.m4a') ||
          path.endsWith('.wav') ||
          path.endsWith('.aac') ||
          path.endsWith('.ogg') ||
          path.endsWith('.opus') ||
          path.endsWith('.flac');

      if (!isAudio) continue;

      try {
        final ioFile = File(path);
        if (!await ioFile.exists()) continue;
        final bytes = await ioFile.readAsBytes();
        final rawName = path.split(Platform.pathSeparator).last;
        final name = rawName.contains('.')
            ? rawName.substring(0, rawName.lastIndexOf('.'))
            : rawName;

        final context = rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          showAttachOrSaveDialog(context, bytes, name, container);
        }
        break;
      } catch (_) {}
    }
  }

  static Future<void> showAttachOrSaveDialog(
    BuildContext context,
    Uint8List bytes,
    String defaultName,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

    final l10n = context.tesbihatL10n;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sharedAudioReceived,
                  style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.sharedAudioPrompt,
                  style: Theme.of(sheetContext).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.circle_outlined),
                  title: Text(l10n.attachSoundToExistingBead),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAttachToExistingBeadDialog(context, bytes, defaultName, container);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.event_note_outlined),
                  title: Text(l10n.attachSoundToExistingReminder),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAttachToExistingReminderDialog(context, bytes, defaultName, container);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.library_music_outlined),
                  title: Text(l10n.saveToSoundLibrary),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _saveToLibraryWithPrompt(context, bytes, defaultName, container);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _saveToLibraryWithPrompt(
    BuildContext context,
    Uint8List bytes,
    String defaultName,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

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

    if (title != null && title.isNotEmpty) {
      container.read(soundLibraryNotifierProvider.notifier).addSound(
            title: title,
            bytes: bytes,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tesbihatL10n.soundSavedSuccess)),
        );
      }
    }
  }

  static Future<void> _showAttachToExistingBeadDialog(
    BuildContext context,
    Uint8List bytes,
    String defaultName,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

    final items = container.read(itemsNotifierProvider);
    if (items.isEmpty) {
      // If no beads exist, save to library instead
      _saveToLibraryWithPrompt(context, bytes, defaultName, container);
      return;
    }

    final selectedItem = await showDialog<Item>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tesbihatL10n.attachSoundToExistingBead),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Text('${item.currentProgress}/${item.count}'),
                onTap: () => Navigator.pop(dialogContext, item),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tesbihatL10n.cancel),
          ),
        ],
      ),
    );

    if (selectedItem != null) {
      final newSound = container
          .read(soundLibraryNotifierProvider.notifier)
          .addSound(title: defaultName, bytes: bytes);

      final updated = selectedItem.copyWith(
        soundId: newSound.id,
        soundTitle: newSound.title,
      );
      container.read(itemsNotifierProvider.notifier).updateItem(updated);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tesbihatL10n.soundAttached)),
        );
      }
    }
  }

  static Future<void> _showAttachToExistingReminderDialog(
    BuildContext context,
    Uint8List bytes,
    String defaultName,
    ProviderContainer container,
  ) async {
    if (!context.mounted) return;

    List<CalendarReminder> reminders = [];
    try {
      final controller = context.read<PrayerAppController>();
      reminders = controller.calendarReminders.where((r) => !r.isTask).toList();
    } catch (_) {
      try {
        final dbReminders = await LocalDatabase().loadCalendarReminders();
        reminders = dbReminders.where((r) => !r.isTask).toList();
      } catch (_) {}
    }

    if (reminders.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.tesbihatL10n.cancel, // or feedback
            ),
          ),
        );
      }
      if (context.mounted) {
        _saveToLibraryWithPrompt(context, bytes, defaultName, container);
      }
      return;
    }

    final selectedReminder = await showDialog<CalendarReminder>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tesbihatL10n.attachSoundToExistingReminder),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              return ListTile(
                leading: Icon(
                  reminder.soundId != null
                      ? Icons.music_note
                      : Icons.notifications_none,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(reminder.title),
                subtitle: Text(reminder.notes.isNotEmpty
                    ? reminder.notes
                    : reminder.recurrence.name),
                onTap: () => Navigator.pop(dialogContext, reminder),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tesbihatL10n.cancel),
          ),
        ],
      ),
    );

    if (selectedReminder != null) {
      final newSound = container
          .read(soundLibraryNotifierProvider.notifier)
          .addSound(title: defaultName, bytes: bytes);

      final updated = selectedReminder.copyWith(
        soundId: newSound.id,
        soundTitle: newSound.title,
      );

      try {
        final controller = context.read<PrayerAppController>();
        await controller.updateCalendarReminder(updated);
      } catch (_) {
        await LocalDatabase().saveCalendarReminder(updated);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tesbihatL10n.soundAttached)),
        );
      }
    }
  }
}
