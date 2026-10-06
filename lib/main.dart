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
import 'src/services/auto_backup_observer.dart';
import 'src/services/imsakiyem_api.dart';
import 'src/services/local_database.dart';
import 'src/services/location_resolver.dart';
import 'src/services/native_reminder_service.dart';
import 'src/services/notification_service.dart';
import 'src/services/notification_tap_handler.dart';
import 'src/services/widget_bridge_service.dart';
import 'src/supplications/services/wisdom_service.dart';
import 'src/tesbihat/data/item_history_repository.dart';
import 'src/tesbihat/data/item_repository.dart';
import 'src/tesbihat/data/sound_library_repository.dart';
import 'src/tesbihat/services/item_reminder_service.dart';
import 'src/tesbihat/services/midnight_reminder_scheduler.dart';
import 'src/tesbihat/services/shared_audio_handler.dart';
import 'src/tesbihat/state/groups_notifier.dart';
import 'src/tesbihat/state/items_notifier.dart';
import 'src/tesbihat/state/sound_library_notifier.dart';
import 'src/ui/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NativeReminderService.initializeNotificationTapHandler(handleNotificationTap);

  final calendarReminderService = CalendarReminderService();

  final initResults = await Future.wait([
    initializeDateFormatting(),
    WisdomService.instance.init(),
    Hive.initFlutter().then((_) => Future.wait([
      Hive.openBox<dynamic>('items_box'),
      Hive.openBox<dynamic>('item_history_box'),
    ])),
    calendarReminderService.initialize(),
  ]);

  final hiveBoxes = initResults[2] as List<dynamic>;
  final itemsBox = hiveBoxes[0] as Box<dynamic>;
  final itemHistoryBox = hiveBoxes[1] as Box<dynamic>;

  final controller = PrayerAppController(
    api: ImsakiyemApi(),
    database: LocalDatabase(),
    locationResolver: LocationResolver(),
    notificationService: NotificationService(),
    widgetBridgeService: WidgetBridgeService(),
    calendarReminderService: calendarReminderService,
  );
  await controller.initialize();

  WidgetsBinding.instance.addObserver(AutoBackupObserver(controller));

  final itemReminderService = ItemReminderService();
  itemReminderService.currentLocale = controller.resolvedLocale;
  await itemReminderService.initialize();

  final repository = ItemRepository.hive(itemsBox);

  controller.onLocaleChanged = (locale) async {
    itemReminderService.currentLocale = locale;
    final currentItems = repository.loadItems();
    final currentGroups = repository.loadGroups();
    for (final item in currentItems) {
      if (item.reminderEnabled) {
        await itemReminderService.scheduleReminder(item, locale: locale, catchUp: false);
      }
    }
    for (final group in currentGroups) {
      if (group.reminderEnabled) {
        await itemReminderService.scheduleGroupReminder(group, locale: locale, catchUp: false);
      }
    }
  };

  final container = ProviderContainer(
    overrides: [
      itemRepositoryProvider.overrideWithValue(ItemRepository.hive(itemsBox)),
      soundLibraryRepositoryProvider.overrideWithValue(
        SoundLibraryRepository.hive(itemsBox),
      ),
      itemHistoryRepositoryProvider.overrideWithValue(
        ItemHistoryRepository.hive(itemHistoryBox),
      ),
      itemReminderServiceProvider.overrideWithValue(itemReminderService),
    ],
  );
  controller.onAppDataRestored = () async {
    container.read(itemHistoryRepositoryProvider).reload();
    container.invalidate(itemsNotifierProvider);
    container.invalidate(groupsNotifierProvider);
    container.invalidate(soundLibraryNotifierProvider);
    final restoredItems = repository.loadItems();
    final restoredGroups = repository.loadGroups();
    for (final item in restoredItems) {
      if (item.reminderEnabled) {
        await itemReminderService.scheduleReminder(item, locale: controller.resolvedLocale, catchUp: false);
      } else {
        await itemReminderService.cancelReminder(item.id);
      }
    }
    for (final group in restoredGroups) {
      if (group.reminderEnabled) {
        await itemReminderService.scheduleGroupReminder(group, locale: controller.resolvedLocale, catchUp: false);
      } else {
        await itemReminderService.cancelReminder(group.id);
      }
    }
  };

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: PrayerAssistantApp(controller: controller),
    ),
  );

  // Deferred until after the first frame so rootNavigatorKey's Navigator
  // actually exists to push onto, in case the app was cold-started by
  // tapping a reminder notification. The payload's feature prefix decides
  // which screen opens.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    handleAppLaunchFromNotification();
    SharedAudioHandler.initialize(container);
    MidnightReminderScheduler.initializeAndSchedule();
    CalendarMidnightScheduler.initializeAndSchedule();
    _scheduleInitialBeadsReminders(
      repository,
      itemReminderService,
      controller.resolvedLocale,
    );
  });
}

Future<void> _scheduleInitialBeadsReminders(
  ItemRepository repository,
  ItemReminderService reminderService,
  Locale locale,
) async {
  final items = repository.loadItems();
  final groups = repository.loadGroups();
  for (final item in items) {
    if (item.reminderEnabled) {
      await reminderService.scheduleReminder(item, locale: locale, catchUp: false);
    }
  }
  for (final group in groups) {
    if (group.reminderEnabled) {
      await reminderService.scheduleGroupReminder(group, locale: locale, catchUp: false);
    }
  }
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
