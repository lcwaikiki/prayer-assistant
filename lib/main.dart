import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'src/controller/prayer_app_controller.dart';
import 'src/l10n/locale_options.dart';
import 'src/services/imsakiyem_api.dart';
import 'src/services/local_database.dart';
import 'src/services/location_resolver.dart';
import 'src/services/notification_service.dart';
import 'src/services/widget_bridge_service.dart';
import 'src/tesbihat/data/item_repository.dart';
import 'src/tesbihat/l10n/tesbihat_localizations.dart';
import 'src/tesbihat/state/items_notifier.dart';
import 'src/ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  final itemsBox = await Hive.openBox<dynamic>('items_box');

  final controller = PrayerAppController(
    api: ImsakiyemApi(),
    database: LocalDatabase(),
    locationResolver: LocationResolver(),
    notificationService: NotificationService(),
    widgetBridgeService: WidgetBridgeService(),
  );
  await controller.initialize();

  runApp(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(ItemRepository.hive(itemsBox)),
      ],
      child: PrayerAssistantApp(controller: controller),
    ),
  );
}

class PrayerAssistantApp extends StatelessWidget {
  const PrayerAssistantApp({required this.controller, super.key});

  final PrayerAppController controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PrayerAppController>.value(
      value: controller,
      child: Consumer<PrayerAppController>(
        builder: (context, controller, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          themeMode: controller.themeMode,
          locale: controller.appLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...TesbihatLocalizations.localizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: supportedAppLocales,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F8A70),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F8A70),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
          ),
          home: const AppShell(),
        ),
      ),
    );
  }
}
