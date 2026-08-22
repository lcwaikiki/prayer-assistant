import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Consumer;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';

import 'src/calendar/services/calendar_midnight_scheduler.dart';
import 'src/calendar/services/calendar_reminder_service.dart';
import 'src/controller/prayer_app_controller.dart';
import 'src/l10n/locale_options.dart';
import 'src/navigation.dart';
import 'src/services/imsakiyem_api.dart';
import 'src/services/local_database.dart';
import 'src/services/location_resolver.dart';
import 'src/services/notification_service.dart';
import 'src/services/notification_tap_handler.dart';
import 'src/services/widget_bridge_service.dart';
import 'src/supplications/services/wisdom_service.dart';
import 'src/tesbihat/data/item_history_repository.dart';
import 'src/tesbihat/data/item_repository.dart';
import 'src/tesbihat/l10n/tesbihat_localizations.dart';
import 'src/tesbihat/services/item_reminder_service.dart';
import 'src/tesbihat/services/midnight_reminder_scheduler.dart';
import 'src/tesbihat/state/items_notifier.dart';
import 'src/ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  await WisdomService.instance.init();

  await Hive.initFlutter();

  final itemsBox = await Hive.openBox<dynamic>('items_box');
  final itemHistoryBox = await Hive.openBox<dynamic>('item_history_box');

  final calendarReminderService = CalendarReminderService();
  await calendarReminderService.initialize();

  final controller = PrayerAppController(
    api: ImsakiyemApi(),
    database: LocalDatabase(),
    locationResolver: LocationResolver(),
    notificationService: NotificationService(),
    widgetBridgeService: WidgetBridgeService(),
    calendarReminderService: calendarReminderService,
  );
  await controller.initialize();

  final itemReminderService = ItemReminderService();
  await itemReminderService.initialize();
  await MidnightReminderScheduler.initializeAndSchedule();
  await CalendarMidnightScheduler.initializeAndSchedule();

  runApp(
    ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(ItemRepository.hive(itemsBox)),
        itemHistoryRepositoryProvider.overrideWithValue(
          ItemHistoryRepository.hive(itemHistoryBox),
        ),
        itemReminderServiceProvider.overrideWithValue(itemReminderService),
      ],
      child: PrayerAssistantApp(controller: controller),
    ),
  );

  // Deferred until after the first frame so rootNavigatorKey's Navigator
  // actually exists to push onto, in case the app was cold-started by
  // tapping a reminder notification. The payload's feature prefix decides
  // which screen opens.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    handleAppLaunchFromNotification();
  });
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
          navigatorKey: rootNavigatorKey,
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
