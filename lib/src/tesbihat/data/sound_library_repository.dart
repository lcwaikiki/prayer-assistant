import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hive/hive.dart';

import '../models/sound_item.dart';

/// A sound together with its audio, as carried by backups. [bytes] is null
/// when the backup does not embed the audio.
typedef SoundWithAudio = ({SoundItem sound, Uint8List? bytes});

/// Stores sound metadata in Hive and each sound's audio in its own file.
class SoundLibraryRepository {
  SoundLibraryRepository.hive(Box<dynamic> box)
      : _box = box,
        _memorySounds = null,
        _directory = audioDirectory!;

  SoundLibraryRepository.memory([List<SoundItem>? initialSounds])
      : _box = null,
        _memorySounds = List<SoundItem>.from(initialSounds ?? const []),
        _directory = null;

  /// Folder holding the audio files of the Hive-backed library. Set once at
  /// startup.
  static String? audioDirectory;

  final Box<dynamic>? _box;
  List<SoundItem>? _memorySounds;
  final String? _directory;
  late final String _dir =
      _directory ?? Directory.systemTemp.createTempSync('sounds').path;

  static const _soundsKey = 'sound_library';

  String _pathFor(String id) => '$_dir/$id';

  List<SoundItem> loadSounds() {
    if (_memorySounds != null) {
      return List<SoundItem>.from(_memorySounds!);
    }
    final raw = _rawSounds();
    if (raw.any((m) => m.containsKey('bytes'))) {
      return _migrateLegacyAudio(raw);
    }
    return [for (final m in raw) SoundItem.fromMap(m, path: _pathFor('${m['id']}'))];
  }

  List<Map<dynamic, dynamic>> _rawSounds() =>
      (_box?.get(_soundsKey, defaultValue: <dynamic>[]) as List<dynamic>)
          .whereType<Map>()
          .toList();

  /// Moves audio that older versions stored inline as base64 into files,
  /// then compacts the box so the old data no longer loads at startup.
  List<SoundItem> _migrateLegacyAudio(List<Map<dynamic, dynamic>> raw) {
    final sounds = <SoundItem>[];
    for (final m in raw) {
      final sound = SoundItem.fromMap(m, path: _pathFor('${m['id']}'));
      final bytes = m['bytes'];
      if (bytes is String) {
        _writeAudio(sound.id, base64Decode(bytes));
      }
      sounds.add(sound);
    }
    saveSounds(sounds);
    _box?.compact();
    return sounds;
  }

  void _writeAudio(String id, Uint8List bytes) {
    final file = File(_pathFor(id));
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes, flush: true);
  }

  /// Writes the audio to its own file and adds the sound to the library.
  SoundItem addSound({
    required String title,
    required Uint8List bytes,
    String mimeType = 'audio/m4a',
    int? durationMs,
  }) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    _writeAudio(id, bytes);
    final sound = SoundItem(
      id: id,
      title: title,
      path: _pathFor(id),
      mimeType: mimeType,
      durationMs: durationMs,
      createdAt: DateTime.now(),
    );
    saveSounds([...loadSounds(), sound]);
    return sound;
  }

  /// Removes the sound's audio file. The caller saves the updated list.
  void deleteAudio(String id) {
    final file = File(_pathFor(id));
    if (file.existsSync()) file.deleteSync();
  }

  /// Replaces the library with sounds restored from a backup. A sound
  /// without audio keeps its existing local file, or is skipped when there
  /// is none.
  void restoreSounds(List<SoundWithAudio> restored) {
    final available = [
      for (final r in restored)
        if (r.bytes != null || File(_pathFor(r.sound.id)).existsSync()) r,
    ];
    final keep = {for (final r in available) r.sound.id};
    for (final old in loadSounds()) {
      if (!keep.contains(old.id)) deleteAudio(old.id);
    }
    for (final r in available) {
      if (r.bytes != null) _writeAudio(r.sound.id, r.bytes!);
    }
    saveSounds([
      for (final r in available) r.sound.copyWith(path: _pathFor(r.sound.id)),
    ]);
  }

  /// Id, title and type of every sound. Audio never changes after a sound
  /// is added, so this is enough to detect library changes cheaply.
  String soundSummary() => [
    for (final s in loadSounds()) '${s.id}|${s.title}|${s.mimeType}',
  ].join(',');

  void saveSounds(List<SoundItem> sounds) {
    if (_memorySounds != null) {
      _memorySounds = List<SoundItem>.from(sounds);
      return;
    }

    final data = sounds.map((sound) => sound.toMap()).toList(growable: false);
    _box?.put(_soundsKey, data);
  }
}
