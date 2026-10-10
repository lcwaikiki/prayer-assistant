import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Locks portrait on phones; tablets (shortest side >= 600 dp) keep free rotation.
void lockPortraitOnPhones() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortestSide = view.physicalSize.shortestSide / view.devicePixelRatio;
  SystemChrome.setPreferredOrientations(
    shortestSide >= 600
        ? const []
        : const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
}
