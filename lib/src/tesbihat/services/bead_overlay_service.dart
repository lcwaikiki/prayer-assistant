import 'dart:io';

import 'package:flutter/services.dart';

/// Android floating bead counter shown when the user presses Home on the
/// execution screen. No-op on other platforms.
class BeadOverlayService {
  static const _channel = MethodChannel('prayer_assistant/bead_overlay');

  bool get isSupported => Platform.isAndroid;

  /// Registers the handler invoked when the bubble is tapped.
  void setOnTap(VoidCallback? onTap) {
    _channel.setMethodCallHandler(
      onTap == null
          ? null
          : (call) async {
              if (call.method == 'tap') onTap();
            },
    );
  }

  /// Enables the bubble for the next Home press, showing [text].
  Future<void> arm(String text) async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('arm', {'text': text});
  }

  /// Disables and hides the bubble.
  Future<void> disarm() async {
    if (!isSupported) return;
    await _channel.invokeMethod<void>('disarm');
  }

  Future<bool> hasPermission() async =>
      await _channel.invokeMethod<bool>('hasPermission') ?? false;

  Future<void> requestPermission() =>
      _channel.invokeMethod<void>('requestPermission');

  /// True whenever overlay permission is missing on supported platforms.
  Future<bool> shouldPromptForPermission() async {
    if (!isSupported) return false;
    return !(await hasPermission());
  }
}
