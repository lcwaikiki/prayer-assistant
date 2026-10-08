import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final intervalSoundNotifierProvider =
    NotifierProvider<IntervalSoundNotifier, bool>(
  IntervalSoundNotifier.new,
);

class IntervalSoundNotifier extends Notifier<bool> {
  static const prefKey = 'beads_interval_sound';

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getBool(prefKey);
      if (value != null) {
        state = value;
      }
    } catch (_) {}
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKey, enabled);
    } catch (_) {}
  }
}
