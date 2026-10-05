import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/local_database.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

final minimizeOnExitNotifierProvider =
    NotifierProvider<MinimizeOnExitNotifier, bool>(
  MinimizeOnExitNotifier.new,
);

class MinimizeOnExitNotifier extends Notifier<bool> {
  LocalDatabase? _database;

  @override
  bool build() {
    try {
      _database = ref.watch(localDatabaseProvider);
      _load();
    } catch (_) {}
    return true;
  }

  Future<void> _load() async {
    try {
      final value = await _database?.loadBeadsMinimizeOnExit();
      if (value != null) {
        state = value;
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      await _database?.saveBeadsMinimizeOnExit(enabled);
    } catch (_) {}
  }
}
