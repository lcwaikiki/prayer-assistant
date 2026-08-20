import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/calendar/models/calendar_reminder.dart';
import 'package:prayer_assistant/src/controller/prayer_app_controller.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/services/location_resolver.dart';

import '../../helpers/mocks.dart';
import '../../helpers/test_app.dart';

void main() {
  late MockImsakiyemApi api;
  late MockLocalDatabase database;
  late MockLocationResolver locationResolver;
  late MockNotificationService notificationService;
  late MockWidgetBridgeService widgetBridge;
  late MockCalendarReminderService calendarReminderService;

  setUpAll(() {
    registerFallbackValue(
      CalendarReminder(id: 'f', title: 'f', anchorAt: DateTime(2026)),
    );
    registerFallbackValue(ReminderSetting.defaults());
    registerFallbackValue(samplePrayerDay());
    registerFallbackValue(sampleSelectedLocation());
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(
      LocationNode(id: 'f', name: 'f', englishName: 'f'),
    );
  });

  setUp(() {
    api = MockImsakiyemApi();
    database = MockLocalDatabase();
    locationResolver = MockLocationResolver();
    notificationService = MockNotificationService();
    widgetBridge = MockWidgetBridgeService();
    calendarReminderService = MockCalendarReminderService();

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
      ),
    ).thenAnswer((_) async {});
    when(
      () => notificationService.getPendingScheduledReminders(),
    ).thenAnswer((_) async => const []);
    when(
      () => notificationService.showTestNotificationNow(),
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

    when(() => database.loadSelectedLocation()).thenAnswer((_) async => null);
    when(
      () => database.loadReminderSettings(),
    ).thenAnswer((_) async => const {});
    when(
      () => database.loadStatusBarRemainingEnabled(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadRemindersSilenced(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadReminderVibrationEnabled(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadReminderSoundEnabled(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadThemePreference(),
    ).thenAnswer((_) async => null);
    when(
      () => database.loadLocalePreference(),
    ).thenAnswer((_) async => null);
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
      () => database.loadCalendarReminders(),
    ).thenAnswer((_) async => const []);
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
      () => calendarReminderService.scheduleReminder(
        any(),
        catchUp: any(named: 'catchUp'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => calendarReminderService.cancelReminder(any()),
    ).thenAnswer((_) async {});
  });

  PrayerAppController buildController() {
    return PrayerAppController(
      api: api,
      database: database,
      locationResolver: locationResolver,
      notificationService: notificationService,
      widgetBridgeService: widgetBridge,
      calendarReminderService: calendarReminderService,
    );
  }

  group('initialize', () {
    test('loads preferences and countries without a saved location', () async {
      final controller = buildController();

      await controller.initialize();

      expect(controller.isInitializing, isFalse);
      expect(controller.isBusy, isFalse);
      expect(controller.error, isNull);
      expect(controller.selectedLocation, isNull);
      expect(controller.today, isNull);
      expect(controller.yearRange, isEmpty);
      expect(controller.countries, isEmpty);
      expect(controller.tabIndex, 1);
      verify(() => widgetBridge.registerOpenHomeHandler(any())).called(1);
      verify(() => notificationService.cancelAllPrayerNotifications()).called(1);
      verify(() => widgetBridge.updateWidgetTextSize('medium')).called(1);
    });

    test('restores a saved location and refreshes prayer data', () async {
      final location = sampleSelectedLocation();
      when(() => database.loadSelectedLocation()).thenAnswer(
        (_) async => location,
      );
      when(() => api.getStates(location.countryId)).thenAnswer(
        (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
      );
      when(() => api.getDistricts(location.stateId)).thenAnswer(
        (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
      );
      final day = samplePrayerDay();
      when(
        () => database.getDay(
          districtId: any(named: 'districtId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => day);
      when(
        () => database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => [day]);

      final controller = buildController();
      await controller.initialize();

      expect(controller.error, isNull);
      expect(controller.selectedLocation!.fullName, location.fullName);
      expect(controller.states, hasLength(1));
      expect(controller.districts, hasLength(1));
      expect(controller.today, isNotNull);
      expect(controller.yearRange, hasLength(1));
      verify(
        () => notificationService.reschedulePrayerNotifications(
          days: any(named: 'days'),
          reminderSettings: any(named: 'reminderSettings'),
          locationName: any(named: 'locationName'),
          prayerNameLabel: any(named: 'prayerNameLabel'),
          vibrationEnabled: any(named: 'vibrationEnabled'),
          soundEnabled: any(named: 'soundEnabled'),
        ),
      ).called(1);
    });

    test('surfaces failures in error without throwing', () async {
      when(() => api.getCountries()).thenThrow(Exception('network down'));

      final controller = buildController();
      await controller.initialize();

      expect(controller.error, contains('network down'));
      expect(controller.isInitializing, isFalse);
      expect(controller.isBusy, isFalse);
    });

    test('reschedules enabled calendar reminders on launch', () async {
      final reminder = CalendarReminder(
        id: 'r1',
        title: 'Eid',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
      );
      when(() => database.loadCalendarReminders()).thenAnswer(
        (_) async => [reminder],
      );

      final controller = buildController();
      await controller.initialize();

      verify(
        () => calendarReminderService.scheduleReminder(
          reminder,
          catchUp: false,
        ),
      ).called(1);
      verify(() => widgetBridge.updateCalendarReminders(
        headerText: any(named: 'headerText'),
        reminders: any(named: 'reminders'),
      )).called(1);
    });
  });

  group('tab and location navigation', () {
    test('setTab updates the tab index and notifies', () {
      final controller = buildController();
      var notified = 0;
      controller.addListener(() => notified++);

      controller.setTab(2);

      expect(controller.tabIndex, 2);
      expect(notified, 1);
    });

    test('chooseCountry loads states and clears districts', () async {
      when(() => api.getStates('tr')).thenAnswer(
        (_) async => [sampleLocationNode(id: '34')],
      );
      final controller = buildController();
      await controller.chooseCountry(
        sampleLocationNode(id: 'tr', name: 'Turkiye'),
      );

      expect(controller.states, hasLength(1));
      expect(controller.districts, isEmpty);
    });

    test('chooseState loads districts', () async {
      when(() => api.getDistricts('34')).thenAnswer(
        (_) async => [sampleLocationNode(id: '541')],
      );
      final controller = buildController();
      await controller.chooseState(sampleLocationNode(id: '34'));

      expect(controller.districts, hasLength(1));
    });

    test('reloadLocationOptions retries after a failed startup fetch',
        () async {
      when(() => api.getCountries()).thenThrow(Exception('network down'));
      final controller = buildController();
      await controller.initialize();
      expect(controller.countries, isEmpty);

      when(() => api.getCountries()).thenAnswer(
        (_) async => [sampleLocationNode(id: 'tr', name: 'Turkiye')],
      );
      await controller.reloadLocationOptions();

      expect(controller.countries, hasLength(1));
      expect(controller.error, isNull);
    });

    test('reloadLocationOptions loads the saved location lists', () async {
      when(() => api.getCountries()).thenThrow(Exception('network down'));
      when(
        () => database.loadSelectedLocation(),
      ).thenAnswer((_) async => sampleSelectedLocation());
      final controller = buildController();
      await controller.initialize();
      expect(controller.countries, isEmpty);

      when(() => api.getCountries()).thenAnswer(
        (_) async => [sampleLocationNode(id: 'tr', name: 'Turkiye')],
      );
      when(() => api.getStates('tr')).thenAnswer(
        (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
      );
      when(() => api.getDistricts('34')).thenAnswer(
        (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
      );
      await controller.reloadLocationOptions();

      expect(controller.countries, hasLength(1));
      expect(controller.states, hasLength(1));
      expect(controller.districts, hasLength(1));
    });

    test('reloadLocationOptions keeps existing data without refetching',
        () async {
      when(() => api.getCountries()).thenAnswer(
        (_) async => [sampleLocationNode(id: 'tr', name: 'Turkiye')],
      );
      final controller = buildController();
      await controller.initialize();

      await controller.reloadLocationOptions();

      verify(() => api.getCountries()).called(1);
    });
  });

  group('location selection', () {
    test('saveSelectedLocation persists, force-syncs and lands on home tab',
        () async {
      when(() => api.getYearlyPrayerTimes(
        districtId: any(named: 'districtId'),
        year: any(named: 'year'),
      )).thenAnswer((_) async => [samplePrayerDay()]);
      when(
        () => database.upsertPrayerDays(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => database.saveSelectedLocation(any()),
      ).thenAnswer((_) async {});
      when(
        () => database.getDay(
          districtId: any(named: 'districtId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => samplePrayerDay());
      when(
        () => database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => [samplePrayerDay()]);

      final controller = buildController();
      await controller.saveSelectedLocation(
        country: sampleLocationNode(id: 'tr', name: 'Turkiye'),
        state: sampleLocationNode(id: '34', name: 'Istanbul'),
        district: sampleLocationNode(id: '541', name: 'Uskudar'),
      );

      expect(controller.error, isNull);
      expect(controller.tabIndex, 1);
      expect(
        controller.selectedLocation!.fullName,
        'Uskudar, Istanbul, Turkiye',
      );
      expect(controller.today, isNotNull);
      verify(() => database.saveSelectedLocation(any())).called(1);
      verify(() => api.getYearlyPrayerTimes(
        districtId: any(named: 'districtId'),
        year: any(named: 'year'),
      )).called(1);
    });

    test('autoPickFromGps resolves and returns the matched location', () async {
      final guess = DeviceLocationGuess(
        country: 'Turkey',
        state: 'Istanbul',
        city: 'Uskudar',
        district: 'Uskudar',
      );
      when(() => locationResolver.resolveFromDevice()).thenAnswer(
        (_) async => guess,
      );
      var matchCall = 0;
      when(() => locationResolver.bestMatch(any(), any())).thenAnswer((_) {
        final answers = [
          sampleLocationNode(id: 'tr', name: 'Turkiye'),
          sampleLocationNode(id: '34', name: 'Istanbul'),
          sampleLocationNode(id: '541', name: 'Uskudar'),
        ];
        return answers[matchCall++];
      });

      final controller = buildController();
      final picked = await controller.autoPickFromGps();

      expect(picked, isNotNull);
      expect(picked!.country.id, 'tr');
      expect(picked.state.id, '34');
      expect(picked.district.id, '541');
      expect(controller.error, isNull);
      expect(controller.selectedLocation, isNull);
      verifyNever(() => database.saveSelectedLocation(any()));
    });

    test('autoPickFromGps reports a country match failure', () async {
      when(() => locationResolver.resolveFromDevice()).thenAnswer(
        (_) async => DeviceLocationGuess(
          country: 'Atlantis',
          state: '',
          city: '',
          district: '',
        ),
      );
      when(() => locationResolver.bestMatch(any(), any())).thenReturn(null);

      final controller = buildController();
      final picked = await controller.autoPickFromGps();

      expect(picked, isNull);
      expect(controller.error, contains('Could not match your country'));
    });
  });

  group('nextPrayer', () {
    Future<PrayerAppController> seededController(PrayerDay day) async {
      when(
        () => database.getDay(
          districtId: any(named: 'districtId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => day);
      when(
        () => database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => [day]);
      when(() => api.getYearlyPrayerTimes(
        districtId: any(named: 'districtId'),
        year: any(named: 'year'),
      )).thenAnswer((_) async => [day]);
      when(
        () => database.upsertPrayerDays(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => database.saveSelectedLocation(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.saveSelectedLocation(
        country: sampleLocationNode(id: 'tr', name: 'Turkiye'),
        state: sampleLocationNode(id: '34', name: 'Istanbul'),
        district: sampleLocationNode(id: '541', name: 'Uskudar'),
      );
      return controller;
    }

    test('returns the first upcoming prayer of the day', () async {
      final controller = await seededController(
        _day(times: const {
          'Imsak': '05:10',
          'Gunes': '06:42',
        }),
      );

      final next = controller.nextPrayer(DateTime(2026, 8, 17, 5, 0));

      expect(next, isNotNull);
      expect(next!.name, 'Imsak');
      expect(next.time, DateTime(2026, 8, 17, 5, 10));
    });

    test('falls back to the first prayer when all times passed', () async {
      final controller = await seededController(
        _day(times: const {'Imsak': '05:10'}),
      );

      final next = controller.nextPrayer(DateTime(2026, 8, 17, 23, 0));

      expect(next!.name, 'Imsak');
    });

    test('returns null without data', () {
      final controller = buildController();

      expect(controller.nextPrayer(DateTime(2026, 8, 17, 12, 0)), isNull);
    });
  });

  group('reminder settings', () {
    test('reminderFor returns defaults for unknown prayers', () {
      final controller = buildController();

      final setting = controller.reminderFor('Imsak');

      expect(setting.minutesBefore, 10);
      expect(setting.notifyBefore, isFalse);
    });

    test('reminderFor migrates legacy settings on load', () async {
      when(() => database.loadReminderSettings()).thenAnswer(
        (_) async => {'Imsak': ReminderSetting.fromJson(true)},
      );

      final controller = buildController();
      await controller.initialize();

      expect(controller.reminderFor('Imsak').notifyBefore, isTrue);
    });

    test('updateReminderSetting persists and resyncs notifications', () async {
      when(() => database.loadSelectedLocation()).thenAnswer(
        (_) async => sampleSelectedLocation(),
      );
      final day = samplePrayerDay();
      when(
        () => database.getDay(
          districtId: any(named: 'districtId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => day);
      when(
        () => database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => [day]);
      when(
        () => database.saveReminderSettings(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.initialize();

      await controller.updateReminderSetting(
        prayer: 'Imsak',
        notifyBefore: true,
        minutesBefore: 15,
      );

      expect(controller.reminderFor('Imsak').notifyBefore, isTrue);
      expect(controller.reminderFor('Imsak').minutesBefore, 15);
      verify(() => database.saveReminderSettings(any())).called(1);
      // Once from initialize(), once from updateReminderSetting.
      verify(
        () => notificationService.reschedulePrayerNotifications(
          days: any(named: 'days'),
          reminderSettings: any(named: 'reminderSettings'),
          locationName: any(named: 'locationName'),
          prayerNameLabel: any(named: 'prayerNameLabel'),
          vibrationEnabled: any(named: 'vibrationEnabled'),
          soundEnabled: any(named: 'soundEnabled'),
        ),
      ).called(2);
    });

    test('updateReminderSetting skips notification sync for minute-only edits',
        () async {
      when(
        () => database.saveReminderSettings(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateReminderSetting(
        prayer: 'Imsak',
        customMinutesBefore: 25,
      );

      verifyNever(
        () => notificationService.reschedulePrayerNotifications(
          days: any(named: 'days'),
          reminderSettings: any(named: 'reminderSettings'),
          locationName: any(named: 'locationName'),
          prayerNameLabel: any(named: 'prayerNameLabel'),
          vibrationEnabled: any(named: 'vibrationEnabled'),
          soundEnabled: any(named: 'soundEnabled'),
        ),
      );
    });
  });

  group('preferences', () {
    test('updateAppBarRemainingPlacement persists changes and skips no-ops',
        () async {
      when(
        () => database.saveAppBarRemainingPlacement(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateAppBarRemainingPlacement(
        AppBarRemainingPlacement.trailing,
      );
      await controller.updateAppBarRemainingPlacement(
        AppBarRemainingPlacement.trailing,
      );

      expect(
        controller.appBarRemainingPlacement,
        AppBarRemainingPlacement.trailing,
      );
      verify(
        () => database.saveAppBarRemainingPlacement('trailing'),
      ).called(1);
    });

    test('updateWidgetTextSize persists and pushes to the widget bridge',
        () async {
      when(() => database.saveWidgetTextSize(any())).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateWidgetTextSize(WidgetTextSize.large);

      expect(controller.widgetTextSize, WidgetTextSize.large);
      verify(() => database.saveWidgetTextSize('large')).called(1);
      verify(() => widgetBridge.updateWidgetTextSize('large')).called(1);
    });

    test('updateThemePreference persists and exposes themeMode', () async {
      when(() => database.saveThemePreference(any())).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateThemePreference(AppThemePreference.dark);

      expect(controller.themeMode, ThemeMode.dark);
      verify(() => database.saveThemePreference('dark')).called(1);
    });

    test('updateLocalePreference re-pushes calendar reminders in the new locale',
        () async {
      final location = sampleSelectedLocation();
      when(() => database.loadSelectedLocation()).thenAnswer(
        (_) async => location,
      );
      when(() => api.getStates(location.countryId)).thenAnswer(
        (_) async => [sampleLocationNode(id: '34', name: 'Istanbul')],
      );
      when(() => api.getDistricts(location.stateId)).thenAnswer(
        (_) async => [sampleLocationNode(id: '541', name: 'Uskudar')],
      );
      final day = samplePrayerDay();
      when(
        () => database.getDay(
          districtId: any(named: 'districtId'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => day);
      when(
        () => database.getRange(
          districtId: any(named: 'districtId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) async => [day]);
      when(() => database.saveLocalePreference(any())).thenAnswer((_) async {});

      await initializeDateFormatting();
      final controller = buildController();
      await controller.initialize();
      clearInteractions(widgetBridge);

      await controller.updateLocalePreference(AppLocalePreference.tr);

      expect(controller.localePreference, AppLocalePreference.tr);
      verify(() => database.saveLocalePreference('tr')).called(1);
      verify(
        () => widgetBridge.updateCalendarReminders(
          headerText: any(named: 'headerText'),
          reminders: any(named: 'reminders'),
        ),
      ).called(1);
    });

    test('toggleThemeQuick flips between light and dark', () async {
      when(() => database.saveThemePreference(any())).thenAnswer((_) async {});
      final controller = buildController();

      await controller.toggleThemeQuick(isCurrentlyDark: false);

      expect(controller.themeMode, ThemeMode.dark);
    });

    test('updateStatusBarRemainingEnabled persists and syncs the widget',
        () async {
      when(
        () => database.saveStatusBarRemainingEnabled(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateStatusBarRemainingEnabled(false);

      expect(controller.statusBarRemainingEnabled, isFalse);
      verify(
        () => database.saveStatusBarRemainingEnabled(false),
      ).called(1);
      verify(
        () => widgetBridge.updateStatusBarConfig(
          enabled: false,
          autoRestore: false,
        ),
      ).called(1);
    });

    test('updateRemindersSilenced cancels prayer notifications', () async {
      when(
        () => database.saveRemindersSilenced(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateRemindersSilenced(true);

      expect(controller.remindersSilenced, isTrue);
      verify(() => notificationService.cancelAllPrayerNotifications()).called(1);
    });

    test('toggleReminders flips the silenced flag', () async {
      when(
        () => database.saveRemindersSilenced(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.toggleReminders();

      expect(controller.remindersSilenced, isTrue);
    });

    test('updateCalendarPrimaryDisplay and secondary date persist', () async {
      when(
        () => database.saveCalendarPrimaryDisplay(any()),
      ).thenAnswer((_) async {});
      when(
        () => database.saveShowSecondaryCalendarDate(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.updateCalendarPrimaryDisplay(
        CalendarPrimaryDisplay.gregorian,
      );
      await controller.updateShowSecondaryCalendarDate(false);

      expect(controller.calendarPrimaryDisplay, CalendarPrimaryDisplay.gregorian);
      expect(controller.showSecondaryCalendarDate, isFalse);
    });
  });

  group('calendar reminders', () {
    CalendarReminder reminder({String id = 'r1', bool enabled = true}) {
      return CalendarReminder(
        id: id,
        title: 'Reminder $id',
        anchorAt: DateTime(2026, 8, 17, 12, 0),
        enabled: enabled,
      );
    }

    test('addCalendarReminder appends, persists and schedules', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();

      await controller.addCalendarReminder(reminder());

      expect(controller.calendarReminders, hasLength(1));
      verify(() => database.saveCalendarReminder(any())).called(1);
      verify(
        () => calendarReminderService.scheduleReminder(
          any(),
          catchUp: any(named: 'catchUp'),
        ),
      ).called(1);
    });

    test('updateCalendarReminder replaces the matching entry', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.addCalendarReminder(reminder(id: 'r1', enabled: false));
      await controller.addCalendarReminder(reminder(id: 'r2'));

      await controller.updateCalendarReminder(
        reminder(id: 'r1').copyWith(title: 'Changed'),
      );

      final titles = controller.calendarReminders.map((r) => r.title);
      expect(titles, ['Changed', 'Reminder r2']);
    });

    test('deleteCalendarReminder removes and cancels scheduling', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      when(
        () => database.deleteCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.addCalendarReminder(reminder());

      await controller.deleteCalendarReminder('r1');

      expect(controller.calendarReminders, isEmpty);
      verify(() => database.deleteCalendarReminder('r1')).called(1);
      verify(() => calendarReminderService.cancelReminder('r1')).called(1);
    });

    test('toggleCalendarReminderEnabled flips the enabled flag', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.addCalendarReminder(reminder(enabled: false));

      await controller.toggleCalendarReminderEnabled('r1');

      expect(controller.calendarReminders.single.enabled, isTrue);
    });

    test('restoreCalendarReminder inserts at the given index', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.addCalendarReminder(reminder(id: 'a'));
      await controller.addCalendarReminder(reminder(id: 'b'));

      await controller.restoreCalendarReminder(
        reminder(id: 'x'),
        index: 1,
      );

      expect(
        controller.calendarReminders.map((r) => r.id),
        ['a', 'x', 'b'],
      );
    });

    test('restoreCalendarReminder skips duplicate ids', () async {
      when(
        () => database.saveCalendarReminder(any()),
      ).thenAnswer((_) async {});
      final controller = buildController();
      await controller.addCalendarReminder(reminder());

      await controller.restoreCalendarReminder(reminder(), index: 0);

      expect(controller.calendarReminders, hasLength(1));
      // Only the original addCalendarReminder scheduled the reminder.
      verify(
        () => calendarReminderService.scheduleReminder(
          any(),
          catchUp: any(named: 'catchUp'),
        ),
      ).called(1);
    });
  });

  group('notification passthroughs', () {
    test('getScheduledReminders forwards to the notification service',
        () async {
      final controller = buildController();

      expect(await controller.getScheduledReminders(), isEmpty);
    });

    test('sendTestNotificationNow forwards to the notification service',
        () async {
      final controller = buildController();

      await controller.sendTestNotificationNow();

      verify(() => notificationService.showTestNotificationNow()).called(1);
    });
  });
}

PrayerDay _day({Map<String, String>? times}) {
  final map = times ?? const {};
  return PrayerDay(
    date: DateTime(2026, 8, 17),
    hijriDate: '3 Rabi I 1448',
    imsak: map['Imsak'] ?? '05:10',
    gunes: map['Gunes'] ?? '06:42',
    ogle: map['Ogle'] ?? '12:35',
    ikindi: map['Ikindi'] ?? '16:10',
    aksam: map['Aksam'] ?? '18:20',
    yatsi: map['Yatsi'] ?? '19:45',
  );
}