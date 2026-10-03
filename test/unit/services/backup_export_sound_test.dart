import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';
import 'package:prayer_assistant/src/services/backup_export_service.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';

void main() {
  group('BackupExportService with SoundLibrary Tests', () {
    test('exports sound library and parses it back faithfully', () {
      const service = BackupExportService();
      final sound1 = SoundItem(
        id: 'snd_1',
        title: 'Allahu Akbar Recitation',
        bytes: Uint8List.fromList([100, 101, 102, 103]),
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
      final restoredSounds = parsed['soundLibrary'] as List<SoundItem>;

      expect(restoredSounds.length, 1);
      expect(restoredSounds.first.id, 'snd_1');
      expect(restoredSounds.first.title, 'Allahu Akbar Recitation');
      expect(restoredSounds.first.bytes, sound1.bytes);
      expect(restoredSounds.first.mimeType, 'audio/m4a');
      expect(restoredSounds.first.durationMs, 950);
    });
  });
}
