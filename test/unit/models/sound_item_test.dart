import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';

void main() {
  group('SoundItem Model Tests', () {
    test('creates SoundItem and handles copyWith', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final sound = SoundItem(
        id: 's1',
        title: 'Test Chant',
        bytes: bytes,
        mimeType: 'audio/m4a',
        durationMs: 1200,
        createdAt: DateTime(2026, 10, 1, 12),
      );

      expect(sound.id, 's1');
      expect(sound.title, 'Test Chant');
      expect(sound.bytes, bytes);
      expect(sound.mimeType, 'audio/m4a');
      expect(sound.durationMs, 1200);

      final modified = sound.copyWith(title: 'New Title', durationMs: 2500);
      expect(modified.id, 's1');
      expect(modified.title, 'New Title');
      expect(modified.durationMs, 2500);
      expect(modified.bytes, bytes);
    });

    test('roundtrips toMap and fromMap with Base64 encoding', () {
      final bytes = Uint8List.fromList([10, 20, 30, 40, 50, 60]);
      final sound = SoundItem(
        id: 's2',
        title: 'Voice Recording',
        bytes: bytes,
        mimeType: 'audio/aac',
        durationMs: 3400,
        createdAt: DateTime(2026, 10, 2, 8, 30),
      );

      final map = sound.toMap();
      expect(map['id'], 's2');
      expect(map['title'], 'Voice Recording');
      expect(map['bytes'], base64Encode(bytes));
      expect(map['mimeType'], 'audio/aac');
      expect(map['durationMs'], 3400);

      final restored = SoundItem.fromMap(map);
      expect(restored.id, 's2');
      expect(restored.title, 'Voice Recording');
      expect(restored.bytes, bytes);
      expect(restored.mimeType, 'audio/aac');
      expect(restored.durationMs, 3400);
      expect(restored.createdAt, sound.createdAt);
    });
  });
}
