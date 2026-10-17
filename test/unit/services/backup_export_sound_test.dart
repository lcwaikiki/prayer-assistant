import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';
import 'package:prayer_assistant/src/services/backup_export_service.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';

void main() {
  group('BackupExportService with SoundLibrary Tests', () {
    test('embeds sound audio files and parses them back faithfully', () {
      const service = BackupExportService();
      final dir = Directory.systemTemp.createTempSync('backup_sound_test');
      final audio = Uint8List.fromList([100, 101, 102, 103]);
      final file = File('${dir.path}/snd_1')..writeAsBytesSync(audio);
      final sound1 = SoundItem(
        id: 'snd_1',
        title: 'Allahu Akbar Recitation',
        path: file.path,
        mimeType: 'audio/m4a',
        durationMs: 950,
        createdAt: DateTime(2026, 5, 1, 10, 30),
      );

      final jsonString = service.generateJsonBackup(
        kazaTracker: const KazaTracker(),
        prayerCompletions: {},
        calendarReminders: [],
        tesbihItems: [],
        tesbihGroups: [],
        tesbihStats: [],
        preferences: {},
        soundLibrary: [sound1],
      );

      final parsed = service.parseAndValidateBackup(jsonString);
      final restoredSounds = parsed['soundLibrary'] as List<SoundWithAudio>;

      expect(restoredSounds.length, 1);
      expect(restoredSounds.first.sound.id, 'snd_1');
      expect(restoredSounds.first.sound.title, 'Allahu Akbar Recitation');
      expect(restoredSounds.first.bytes, audio);
      expect(restoredSounds.first.sound.mimeType, 'audio/m4a');
      expect(restoredSounds.first.sound.durationMs, 950);
      dir.deleteSync(recursive: true);
    });

    test('omits sound audio when includeSoundAudio is false', () {
      const service = BackupExportService();
      final sound = SoundItem(
        id: 'snd_2',
        title: 'On Drive',
        path: '/missing/snd_2',
        createdAt: DateTime(2026, 5, 2),
      );

      final jsonString = service.generateJsonBackup(
        kazaTracker: const KazaTracker(),
        prayerCompletions: {},
        calendarReminders: [],
        tesbihItems: [],
        tesbihGroups: [],
        tesbihStats: [],
        preferences: {},
        soundLibrary: [sound],
        includeSoundAudio: false,
      );

      expect(jsonString, isNot(contains('"bytes"')));
      final parsed = service.parseAndValidateBackup(jsonString);
      final restored = parsed['soundLibrary'] as List<SoundWithAudio>;
      expect(restored.single.sound.id, 'snd_2');
      expect(restored.single.bytes, isNull);
    });
  });
}
