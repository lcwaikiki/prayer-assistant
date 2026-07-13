import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../l10n/l10n.dart';
import '../models/prayer_models.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'location_screen.dart';
import 'preferences_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) {
        return;
      }
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
          const LocationScreen(),
          const HomeScreen(),
          const HistoryScreen(),
        ];

        return Scaffold(
          appBar: _buildAppBar(context, controller, _now),
          body: SafeArea(child: pages[controller.tabIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.tabIndex,
            onDestinationSelected: controller.setTab,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.location_on_outlined),
                selectedIcon: const Icon(Icons.location_on),
                label: context.l10n.tabLocation,
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
      0 => context.l10n.tabLocation,
      1 => context.l10n.tabToday,
      2 => context.l10n.tabDates,
      _ => context.l10n.appTitle,
    };

    final next = controller.nextPrayer(now);
    final minuteText = next == null
        ? context.l10n.remainingMinutesUnknown
        : context.l10n.remainingMinutesValue(
            next.remaining.inMinutes.clamp(0, 9999),
          );
    final isHomeTab = controller.tabIndex == 1;
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
        if (isHomeTab)
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
