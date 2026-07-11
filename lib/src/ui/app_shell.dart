import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'location_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

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
          body: SafeArea(child: pages[controller.tabIndex]),
          bottomNavigationBar: NavigationBar(
            selectedIndex: controller.tabIndex,
            onDestinationSelected: controller.setTab,
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on),
                label: 'Location',
              ),
              NavigationDestination(
                icon: Icon(Icons.mosque_outlined),
                selectedIcon: Icon(Icons.mosque),
                label: 'Today',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(Icons.calendar_month),
                label: 'Dates',
              ),
            ],
          ),
        );
      },
    );
  }
}
