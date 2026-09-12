import 'package:flutter/widgets.dart';

import '../controller/prayer_app_controller.dart';

/// Uploads/writes automatic backups whenever the app is paused (backgrounded
/// or sent to the system tray): to Google Drive when signed in, and to the
/// chosen offline folder when one is configured.
class AutoBackupObserver extends WidgetsBindingObserver {
  AutoBackupObserver(this._controller);

  final PrayerAppController _controller;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _controller.autoBackupToGoogleDrive();
      _controller.autoBackupToFolder();
    }
  }
}
