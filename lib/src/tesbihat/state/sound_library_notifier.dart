import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sound_library_repository.dart';
import '../models/sound_item.dart';

final soundLibraryRepositoryProvider = Provider<SoundLibraryRepository>((ref) {
  throw UnimplementedError('soundLibraryRepositoryProvider must be overridden');
});

final soundLibraryNotifierProvider =
    NotifierProvider<SoundLibraryNotifier, List<SoundItem>>(
  SoundLibraryNotifier.new,
);

class SoundLibraryNotifier extends Notifier<List<SoundItem>> {
  late SoundLibraryRepository _repository;

  @override
  List<SoundItem> build() {
    _repository = ref.watch(soundLibraryRepositoryProvider);
    return _repository.loadSounds();
  }

  SoundItem addSound({
    required String title,
    required Uint8List bytes,
    String mimeType = 'audio/m4a',
    int? durationMs,
  }) {
    final newSound = SoundItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Sound' : title.trim(),
      bytes: bytes,
      mimeType: mimeType,
      durationMs: durationMs,
      createdAt: DateTime.now(),
    );
    state = [...state, newSound];
    _repository.saveSounds(state);
    return newSound;
  }

  void updateSoundTitle(String id, String newTitle) {
    state = [
      for (final sound in state)
        if (sound.id == id) sound.copyWith(title: newTitle.trim()) else sound,
    ];
    _repository.saveSounds(state);
  }

  void deleteSound(String id) {
    state = state.where((sound) => sound.id != id).toList();
    _repository.saveSounds(state);
  }

  SoundItem? getSoundById(String? id) {
    if (id == null) return null;
    return state.where((sound) => sound.id == id).firstOrNull;
  }
}
