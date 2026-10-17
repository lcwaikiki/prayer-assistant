import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';

void main() {
  group('SoundItem Model Tests', () {
    test('creates SoundItem and handles copyWith', () {
      final sound = SoundItem(
        id: 's1',
        title: 'Test Chant',
        path: '/sounds/s1',
        mimeType: 'audio/m4a',
        durationMs: 1200,
        createdAt: DateTime(2026, 10, 1, 12),
      );

      expect(sound.id, 's1');
      expect(sound.title, 'Test Chant');
      expect(sound.path, '/sounds/s1');
      expect(sound.mimeType, 'audio/m4a');
      expect(sound.durationMs, 1200);

      final modified = sound.copyWith(title: 'New Title', durationMs: 2500);
      expect(modified.id, 's1');
      expect(modified.title, 'New Title');
      expect(modified.durationMs, 2500);
      expect(modified.path, '/sounds/s1');
    });

    test('toMap holds only metadata and roundtrips with fromMap', () {
      final sound = SoundItem(
        id: 's2',
        title: 'Voice Recording',
        path: '/sounds/s2',
        mimeType: 'audio/aac',
        durationMs: 3400,
        createdAt: DateTime(2026, 10, 2, 8, 30),
      );

      final map = sound.toMap();
      expect(map['id'], 's2');
      expect(map['title'], 'Voice Recording');
      expect(map.containsKey('bytes'), isFalse);
      expect(map.containsKey('path'), isFalse);
      expect(map['mimeType'], 'audio/aac');
      expect(map['durationMs'], 3400);

      final restored = SoundItem.fromMap(map, path: '/other/s2');
      expect(restored.id, 's2');
      expect(restored.title, 'Voice Recording');
      expect(restored.path, '/other/s2');
      expect(restored.mimeType, 'audio/aac');
      expect(restored.durationMs, 3400);
      expect(restored.createdAt, sound.createdAt);
    });
  });

  group('Item Sound Speed Tests', () {
    test('serializes and deserializes soundSpeed correctly', () {
      final item = Item(
        id: 'i1',
        title: 'Custom Speed Item',
        count: 100,
        check: 33,
        setCount: 0,
        vibrationIntensity: 50,
        soundId: 'snd_123',
        soundTitle: 'Dhikr',
        soundSpeed: 1.75,
      );

      final map = item.toMap();
      expect(map['soundSpeed'], 1.75);

      final restored = Item.fromMap(map);
      expect(restored.soundSpeed, 1.75);

      final legacyMap = item.toMap()..remove('soundSpeed');
      final legacyRestored = Item.fromMap(legacyMap);
      expect(legacyRestored.soundSpeed, 1.0);
    });
  });
}
