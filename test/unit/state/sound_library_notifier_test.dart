import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/data/sound_library_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/sound_item.dart';
import 'package:prayer_assistant/src/tesbihat/state/sound_library_notifier.dart';

void main() {
  group('SoundLibraryNotifier & Repository Tests', () {
    test('initializes with repository sounds and performs CRUD', () {
      final initialSound = SoundItem(
        id: 'init_1',
        title: 'Initial Sound',
        bytes: Uint8List.fromList([1, 2, 3]),
        createdAt: DateTime(2026, 1, 1),
      );

      final repo = SoundLibraryRepository.memory([initialSound]);
      final container = ProviderContainer(
        overrides: [
          soundLibraryRepositoryProvider.overrideWithValue(repo),
        ],
      );

      final sounds = container.read(soundLibraryNotifierProvider);
      expect(sounds.length, 1);
      expect(sounds.first.id, 'init_1');

      // Add a sound
      final added = container.read(soundLibraryNotifierProvider.notifier).addSound(
            title: 'Chant 1',
            bytes: Uint8List.fromList([4, 5, 6]),
          );

      expect(container.read(soundLibraryNotifierProvider).length, 2);
      expect(added.title, 'Chant 1');
      expect(repo.loadSounds().length, 2);

      // Rename sound
      container.read(soundLibraryNotifierProvider.notifier).updateSoundTitle(
            added.id,
            'Updated Chant',
          );
      final fetched = container
          .read(soundLibraryNotifierProvider.notifier)
          .getSoundById(added.id);
      expect(fetched?.title, 'Updated Chant');

      // Delete sound
      container.read(soundLibraryNotifierProvider.notifier).deleteSound('init_1');
      expect(container.read(soundLibraryNotifierProvider).length, 1);
      expect(repo.loadSounds().length, 1);
    });
  });
}
