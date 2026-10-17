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
    // Only `paused`: `hidden` also fires while returning to the app, which
    // would start a full backup right as the user comes back.
    if (state == AppLifecycleState.paused) {
      _controller.autoBackupToGoogleDrive();
      _controller.autoBackupToFolder();
    } else if (state == AppLifecycleState.resumed) {
      _controller.reloadTaskCompletions();
      _controller.reloadPrayerCompletions();
      _controller.syncQadaaWidget();
      _controller.syncSoundsToDrive();
    }
  }
}
