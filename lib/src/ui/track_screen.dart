import 'package:flutter/material.dart';

import '../kaza/screens/kaza_tracker_screen.dart';
import '../l10n/l10n.dart';
import 'analytics_dashboard_screen.dart';
import 'fasting_screen.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(
                text: context.l10n.prayerAnalyticsTitle,
                icon: const Icon(Icons.insights),
              ),
              Tab(
                text: context.l10n.prayerQadaaTitle,
                icon: const Icon(Icons.history_toggle_off),
              ),

              Tab(
                text: context.l10n.fastingTitle,
                icon: const Icon(Icons.nights_stay),
              ),
            ],
          ),
          const Expanded(
            child: TabBarView(
              children: [
                AnalyticsDashboardScreen(),
                KazaTrackerScreen(showAppBar: false),
                FastingScreen(showAppBar: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
