import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../kaza/screens/kaza_tracker_screen.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';
import '../tesbihat/screens/tesbih_home_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'preferences_screen.dart';
import 'qibla_screen.dart';
import 'track_screen.dart';


class AppShell extends StatefulWidget {
  const AppShell({super.key, this.qiblaScreen});

  /// Injectable qibla tab content so tests can avoid the magnetometer and
  /// geolocator platform channels. Defaults to [QiblaScreen].
  final Widget? qiblaScreen;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Timer? _timer;
  DateTime _now = DateTime.now();
  late final PrayerAppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<PrayerAppController>();
    _controller.addListener(_onTabChange);
    _updateOrientation(_controller.tabIndex);
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onTabChange);
    _timer?.cancel();
    SystemChrome.setPreferredOrientations([]);
    super.dispose();
  }

  void _onTabChange() {
    _updateOrientation(_controller.tabIndex);
  }

  void _updateOrientation(int tabIndex) {
    if (tabIndex == 4) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PrayerAppController>(
      builder: (context, controller, _) {
        if (controller.isInitializing) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final pages = <Widget>[
          widget.qiblaScreen ?? const QiblaScreen(),
          const TrackScreen(),
          const HomeScreen(),
          const HistoryScreen(),
          const TesbihHomeScreen(),
        ];

        return Scaffold(
          appBar: _buildAppBar(context, controller, _now),
          body: SafeArea(
            child: _LazyIndexedStack(
              index: controller.tabIndex,
              children: pages,
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.tabIndex,
            onDestinationSelected: controller.setTab,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.explore_outlined),
                selectedIcon: const Icon(Icons.explore),
                label: context.l10n.qiblaTitle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.track_changes_outlined),
                selectedIcon: const Icon(Icons.track_changes),
                label: context.l10n.trackTabTitle,
              ),

              NavigationDestination(
                icon: const Icon(Icons.mosque_outlined),
                selectedIcon: const Icon(Icons.mosque),
                label: context.l10n.tabToday,
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month),
                label: context.l10n.tabDates,
              ),
              NavigationDestination(
                icon: const Icon(Icons.circle_outlined),
                selectedIcon: const Icon(Icons.circle),
                label: context.l10n.tabTesbih,
              ),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    PrayerAppController controller,
    DateTime now,
  ) {
    final tabTitle = switch (controller.tabIndex) {
      0 => context.l10n.qiblaTitle,
      1 => context.l10n.kazaTitle,
      2 => context.l10n.tabToday,
      3 => context.l10n.tabDates,
      4 => context.l10n.tabTesbih,
      _ => context.l10n.appTitle,
    };

    final next = controller.nextPrayer(now);
    final minuteText = next == null
        ? context.l10n.remainingMinutesUnknown
        : context.l10n.remainingMinutesValue(
            next.remaining.inMinutes.clamp(0, 9999),
          );
    final isHomeTab = controller.tabIndex == 2;

    final placement = isHomeTab
        ? controller.appBarRemainingPlacement
        : AppBarRemainingPlacement.hidden;

    Widget titleWidget = Text(tabTitle);
    Widget? trailing;

    if (placement == AppBarRemainingPlacement.title) {
      titleWidget = Text('$tabTitle • $minuteText');
    } else if (placement == AppBarRemainingPlacement.subtitle) {
      titleWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(tabTitle),
          Text(minuteText, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
    } else if (placement == AppBarRemainingPlacement.trailing) {
      trailing = Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Chip(label: Text(minuteText)),
      );
    }

    return AppBar(
      title: titleWidget,
      actions: [
        if (trailing != null) trailing,
        IconButton(
          tooltip: controller.remindersSilenced
              ? context.l10n.tooltipRemindersOn
              : context.l10n.tooltipRemindersOff,
          icon: Icon(
            controller.remindersSilenced
                ? Icons.notifications_off_outlined
                : Icons.notifications_active_outlined,
          ),
          onPressed: controller.toggleReminders,
        ),
        IconButton(
          tooltip: context.l10n.tooltipToggleLightDark,
          icon: Icon(
            Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode_outlined
                : Icons.dark_mode_outlined,
          ),
          onPressed: () => controller.toggleThemeQuick(
            isCurrentlyDark: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        IconButton(
          tooltip: context.l10n.tooltipPreferences,
          icon: const Icon(Icons.tune),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PreferencesScreen(),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Renders one of [children] at [index], building each page lazily on its
/// first visit and keeping it mounted afterwards so its state (scroll
/// positions, tab selections, built table rows) survives tab switches.
class _LazyIndexedStack extends StatefulWidget {
  const _LazyIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<_LazyIndexedStack> {
  late final List<bool> _visited = List<bool>.filled(
    widget.children.length,
    false,
  );

  @override
  Widget build(BuildContext context) {
    _visited[widget.index] = true;
    return IndexedStack(
      index: widget.index,
      sizing: StackFit.expand,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_visited[i]) widget.children[i] else const SizedBox.shrink(),
      ],
    );
  }
}
