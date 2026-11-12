import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final stealthModeNotifierProvider =
    NotifierProvider<StealthModeNotifier, bool>(
  StealthModeNotifier.new,
);

class StealthModeNotifier extends Notifier<bool> {
  static const prefKey = 'beads_stealth_mode';

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

