import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/controller/prayer_app_controller.dart';
import 'package:prayer_assistant/src/kaza/models/kaza_tracker.dart';
import 'package:prayer_assistant/src/models/calendar_week_start.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/tesbihat/data/item_history_repository.dart';

import 'package:prayer_assistant/src/tesbihat/data/item_repository.dart';
import 'package:prayer_assistant/src/tesbihat/models/item.dart';
import 'package:prayer_assistant/src/tesbihat/models/item_group.dart';
import 'package:prayer_assistant/src/tesbihat/state/items_notifier.dart';
import 'package:provider/provider.dart' as provider;

import 'mocks.dart';
import 'test_app.dart';

/// Builds a [PrayerAppController] wired to mocktail mocks, with default
/// stubs for the happy paths. Tests can customize behavior by re-stubbing
/// the exposed mocks before [controller] is used.
class TestHarness {
  TestHarness._(
    this.controller,
    this.api,
    this.database,
    this.locationResolver,
    this.notificationService,
    this.widgetBridge,
    this.calendarReminderService,
    this.itemReminderService,
    this.itemRepository,
    this.itemHistoryRepository,
  );

  factory TestHarness.create() {
    final api = MockImsakiyemApi();
    final database = MockLocalDatabase();
    final locationResolver = MockLocationResolver();
    final notificationService = MockNotificationService();
    final widgetBridge = MockWidgetBridgeService();
    final calendarReminderService = MockCalendarReminderService();
    final itemReminderService = MockItemReminderService();

    registerFallbackValue(CalendarWeekStart.sunday);
    registerFallbackValue(CalendarPrimaryDisplay.hijri);
    registerFallbackValue(
      CalendarReminder(id: 'f', title: 'f', anchorAt: DateTime(2026)),
    );
    registerFallbackValue(ReminderSetting.defaults());
    registerFallbackValue(samplePrayerDay());
    registerFallbackValue(sampleSelectedLocation());
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(
      Item(
        id: 'f',
        title: 'f',
        count: 33,
        check: 11,
        setCount: 11,
        vibrationIntensity: 50,
      ),
    );
    registerFallbackValue(const ItemGroup(id: 'g', title: 'g'));
    registerFallbackValue(const KazaTracker());


    when(() => notificationService.initialize()).thenAnswer((_) async {});
    when(
      () => notificationService.cancelAllPrayerNotifications(),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.reschedulePrayerNotifications(
        days: any(named: 'days'),
        reminderSettings: any(named: 'reminderSettings'),
        locationName: any(named: 'locationName'),
        prayerNameLabel: any(named: 'prayerNameLabel'),
        vibrationEnabled: any(named: 'vibrationEnabled'),
        soundEnabled: any(named: 'soundEnabled'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.getPendingScheduledReminders(),
    ).thenAnswer((_) async => const []);
    when(
      () => notificationService.showTestNotificationNow(
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => widgetBridge.updateStatusBarConfig(
        enabled: any(named: 'enabled'),
        autoRestore: any(named: 'autoRestore'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => widgetBridge.updateWidgetTextSize(any()),
    ).thenAnswer((_) async {});
    when(
      () => widgetBridge.updateWidgetMmssThreshold(any()),
    ).thenAnswer((_) async {});
    when(
      () => widgetBridge.updateFromPrayerDays(
        days: any(named: 'days'),
        now: any(named: 'now'),
        locale: any(named: 'locale'),
        locationLabel: any(named: 'locationLabel'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => widgetBridge.updateCalendarReminders(
        headerText: any(named: 'headerText'),
        reminders: any(named: 'reminders'),
      ),
    ).thenAnswer((_) async {});

    when(() => api.getCountries()).thenAnswer((_) async => const []);
    when(() => api.getStates(any())).thenAnswer((_) async => const []);
    when(() => api.getDistricts(any())).thenAnswer((_) async => const []);
    when(
      () => api.getYearlyPrayerTimes(
        districtId: any(named: 'districtId'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => [samplePrayerDay()]);

    when(() => database.loadSelectedLocation()).thenAnswer((_) async => null);
    when(
      () => database.loadReminderSettings(),
    ).thenAnswer((_) async => const {});
    when(
      () => database.loadStatusBarRemainingEnabled(),
    ).thenAnswer((_) async => null);
    when(() => database.loadRemindersSilenced()).thenAnswer((_) async => null);
    when(
      () => database.loadReminderVibrationEnabled(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadReminderSoundEnabled(),
    ).thenAnswer((_) async => null);
    when(() => database.loadThemePreference()).thenAnswer((_) async => null);
    when(() => database.loadLocalePreference()).thenAnswer((_) async => null);
    when(
      () => database.loadAppBarRemainingPlacement(),
    ).thenAnswer((_) async => null);
    when(() => database.loadWidgetTextSize()).thenAnswer((_) async => null);
    when(
      () => database.loadWidgetMmssThreshold(),
    ).thenAnswer((_) async => 60);
    when(
      () => database.loadCalendarPrimaryDisplay(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadShowSecondaryCalendarDate(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadCalendarWeekStart(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadHijriDateOffset(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadShowIslamicHolidays(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadShowFastingBadges(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadDefaultCalendarDisplay(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadShowCalendarReminderDots(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadPrayerCompletions(),
    ).thenAnswer((_) async => const <String, List<String>>{});
    when(
      () => database.savePrayerCompletions(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.loadCalendarReminders(),
    ).thenAnswer((_) async => const []);
    when(
      () => database.loadKazaTracker(),
    ).thenAnswer((_) async => const KazaTracker());
    when(
      () => database.saveKazaTracker(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.loadFastingLogs(),
    ).thenAnswer((_) async => const {});
    when(
      () => database.saveFastingLogs(any()),
    ).thenAnswer((_) async {});




    when(
      () => database.hasSufficientYearData(
        districtId: any(named: 'districtId'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => true);
    when(
      () => database.getDay(
        districtId: any(named: 'districtId'),
        date: any(named: 'date'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => database.getRange(
        districtId: any(named: 'districtId'),
        start: any(named: 'start'),
        end: any(named: 'end'),
      ),
    ).thenAnswer((_) async => const []);

    when(
      () => calendarReminderService.scheduleReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => calendarReminderService.cancelReminder(any()),
    ).thenAnswer((_) async {});

    when(
      () => itemReminderService.scheduleReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => itemReminderService.cancelReminder(any()),
    ).thenAnswer((_) async {});
    when(
      () => itemReminderService.scheduleGroupReminder(any()),
    ).thenAnswer((_) async {});

    when(() => database.saveSelectedLocation(any())).thenAnswer((_) async {});
    when(() => database.saveReminderSettings(any())).thenAnswer((_) async {});
    when(
      () => database.saveAppBarRemainingPlacement(any()),
    ).thenAnswer((_) async {});
    when(() => database.saveWidgetTextSize(any())).thenAnswer((_) async {});
    when(
      () => database.saveCalendarPrimaryDisplay(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveShowSecondaryCalendarDate(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveCalendarWeekStart(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveHijriDateOffset(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveShowIslamicHolidays(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveShowFastingBadges(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveDefaultCalendarDisplay(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveShowCalendarReminderDots(any()),
    ).thenAnswer((_) async {});
    when(() => database.saveCalendarReminder(any())).thenAnswer((_) async {});
    when(() => database.deleteCalendarReminder(any())).thenAnswer((_) async {});
    when(
      () => database.saveStatusBarRemainingEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => database.saveRemindersSilenced(any())).thenAnswer((_) async {});
    when(
      () => database.saveReminderVibrationEnabled(any()),
    ).thenAnswer((_) async {});
    when(
      () => database.saveReminderSoundEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => database.saveThemePreference(any())).thenAnswer((_) async {});
    when(() => database.saveLocalePreference(any())).thenAnswer((_) async {});
    when(
      () => database.upsertPrayerDays(any(), any()),
    ).thenAnswer((_) async {});

    final controller = PrayerAppController(
      api: api,
      database: database,
      locationResolver: locationResolver,
      notificationService: notificationService,
      widgetBridgeService: widgetBridge,
      calendarReminderService: calendarReminderService,
    );

    return TestHarness._(
      controller,
      api,
      database,
      locationResolver,
      notificationService,
      widgetBridge,
      calendarReminderService,
      itemReminderService,
      ItemRepository.memory(),
      ItemHistoryRepository.memory(),
    );
  }

  final PrayerAppController controller;
  final MockImsakiyemApi api;
  final MockLocalDatabase database;
  final MockLocationResolver locationResolver;
  final MockNotificationService notificationService;
  final MockWidgetBridgeService widgetBridge;
  final MockCalendarReminderService calendarReminderService;
  final MockItemReminderService itemReminderService;
  ItemRepository itemRepository;
  ItemHistoryRepository itemHistoryRepository;

  /// Runs the controller's full startup sequence against the current stubs.
  Future<void> initialize() => controller.initialize();
}

/// Pumps [child] under the full localization + Provider setup, with
/// [harness]'s controller provided and Riverpod providers overridden with
/// harness-owned implementations. [extraOverrides] can add more Riverpod
/// overrides (e.g. a haptic service mock). Disposes the controller
/// afterwards.
Future<void> pumpWithHarness(
  WidgetTester tester,
  TestHarness harness,
  Widget child, {
  Locale? locale,
  bool settle = true,
  List<Override> extraOverrides = const [],
}) async {
  addTearDown(harness.controller.dispose);
  final app = provider.ChangeNotifierProvider<PrayerAppController>.value(
    value: harness.controller,
    child: ProviderScope(
      overrides: [
        itemRepositoryProvider.overrideWithValue(harness.itemRepository),
        itemHistoryRepositoryProvider.overrideWithValue(
          harness.itemHistoryRepository,
        ),
        itemReminderServiceProvider.overrideWithValue(
          harness.itemReminderService,
        ),
        ...extraOverrides,
      ],
      child: testLocalizedApp(child: child, locale: locale),
    ),
  );
  await pumpLocalized(tester, app, settle: settle);
}
