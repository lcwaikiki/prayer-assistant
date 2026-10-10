import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/prayer_app_controller.dart';
import '../kaza/screens/kaza_tracker_screen.dart';
import '../l10n/l10n.dart';
import 'analytics_dashboard_screen.dart';
import 'fasting_screen.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 3,
    vsync: this,
  );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = context.select<PrayerAppController, int?>(
      (controller) => controller.pendingTrackTab,
    );
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tabController.animateTo(pending);
        context.read<PrayerAppController>().consumePendingTrackTab();
      });
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
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
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AnalyticsDashboardScreen(),
              KazaTrackerScreen(showAppBar: false),
              FastingScreen(showAppBar: false),
            ],
          ),
        ),
      ],
    );
  }
}
