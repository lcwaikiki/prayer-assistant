import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/controller/prayer_app_controller.dart';
import 'src/services/imsakiyem_api.dart';
import 'src/services/local_database.dart';
import 'src/services/location_resolver.dart';
import 'src/services/notification_service.dart';
import 'src/ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = PrayerAppController(
    api: ImsakiyemApi(),
    database: LocalDatabase(),
    locationResolver: LocationResolver(),
    notificationService: NotificationService(),
  );
  await controller.initialize();

  runApp(PrayerAssistantApp(controller: controller));
}

class PrayerAssistantApp extends StatelessWidget {
  const PrayerAssistantApp({required this.controller, super.key});

  final PrayerAppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerAppController>.value(
      value: controller,
      child: MaterialApp(
        title: 'Prayer Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1F8A70)),
          useMaterial3: true,
          cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
        ),
        home: const AppShell(),
      ),
    );
  }
}
