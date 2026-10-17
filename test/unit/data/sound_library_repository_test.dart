import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> box;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('sound_repo_test');
    Hive.init('${tempDir.path}/hive');
    box = await Hive.openBox<dynamic>('items_box');
    SoundLibraryRepository.audioDirectory = '${tempDir.path}/sounds';
  });

  tearDown(() async {
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  test('migrates legacy inline base64 audio into files', () {
    final audio = Uint8List.fromList([1, 2, 3, 4]);
    box.put('sound_library', [
      {
        'id': 'old1',
        'title': 'Legacy',
        'bytes': base64Encode(audio),
        'mimeType': 'audio/m4a',
        'createdAt': '2026-01-01T00:00:00.000',
      },
    ]);

    final sounds = SoundLibraryRepository.hive(box).loadSounds();

    expect(sounds.single.id, 'old1');
    expect(sounds.single.title, 'Legacy');
    expect(File(sounds.single.path).readAsBytesSync(), audio);
    final stored = (box.get('sound_library') as List).single as Map;
    expect(stored.containsKey('bytes'), isFalse);
  });

  test('restoreSounds writes audio files and drops removed sounds', () {
    final repo = SoundLibraryRepository.hive(box);
    final old = repo.addSound(title: 'Old', bytes: Uint8List.fromList([9]));

    final restored = SoundItem(
      id: 'r1',
      title: 'Restored',
      path: '',
      createdAt: DateTime(2026, 2, 2),
    );
    repo.restoreSounds([(sound: restored, bytes: Uint8List.fromList([7, 8]))]);

    final sounds = repo.loadSounds();
    expect(sounds.single.id, 'r1');
    expect(File(sounds.single.path).readAsBytesSync(), [7, 8]);
    expect(File(old.path).existsSync(), isFalse);
  });

  test('restoreSounds without audio keeps an existing file and skips the rest',
      () {
    final repo = SoundLibraryRepository.hive(box);
    final existing = repo.addSound(title: 'Here', bytes: Uint8List.fromList([5]));
    SoundItem meta(String id) =>
        SoundItem(id: id, title: id, path: '', createdAt: DateTime(2026));

    repo.restoreSounds([
      (sound: meta(existing.id), bytes: null),
      (sound: meta('gone'), bytes: null),
    ]);

    final sounds = repo.loadSounds();
    expect(sounds.map((s) => s.id), [existing.id]);
    expect(File(sounds.single.path).readAsBytesSync(), [5]);
  });
}
