import 'package:hive/hive.dart';

import '../models/sound_item.dart';

class SoundLibraryRepository {
  SoundLibraryRepository.hive(Box<dynamic> box)
      : _box = box,
        _memorySounds = null;

  SoundLibraryRepository.memory([List<SoundItem>? initialSounds])
      : _box = null,
        _memorySounds = List<SoundItem>.from(initialSounds ?? const []);

  final Box<dynamic>? _box;
  List<SoundItem>? _memorySounds;

  static const _soundsKey = 'sound_library';

  List<SoundItem> loadSounds() {
    if (_memorySounds != null) {
      return List<SoundItem>.from(_memorySounds!);
    }

    final raw =
        _box?.get(_soundsKey, defaultValue: <dynamic>[]) as List<dynamic>?;
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((map) => SoundItem.fromMap(map))
        .toList(growable: false);
  }

  void saveSounds(List<SoundItem> sounds) {
    if (_memorySounds != null) {
      _memorySounds = List<SoundItem>.from(sounds);
      return;
    }

    final data = sounds.map((sound) => sound.toMap()).toList(growable: false);
    _box?.put(_soundsKey, data);
  }
}
