import 'package:flutter/material.dart';

/// Attached to the app's single [MaterialApp] so services with no
/// [BuildContext] of their own (e.g. notification tap handlers) can still
/// push routes on the app's root navigator.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
