import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/locale_options.dart';
import '../l10n/prayer_names.dart';
import '../models/prayer_models.dart';
import '../services/imsakiyem_api.dart';
import '../services/local_database.dart';
import '../services/location_resolver.dart';
import '../services/notification_service.dart';
import '../services/widget_bridge_service.dart';
import '../utils/time_utils.dart';

class PrayerAppController extends ChangeNotifier {
  PrayerAppController({
    required this.api,
    required this.database,
    required this.locationResolver,
    required this.notificationService,
    required this.widgetBridgeService,
  });

  final ImsakiyemApi api;
  final LocalDatabase database;
  final LocationResolver locationResolver;
  final NotificationService notificationService;
  final WidgetBridgeService widgetBridgeService;

  bool _isInitializing = true;
  bool _isBusy = false;
  String? _error;
  int _tabIndex = 1;

  List<LocationNode> _countries = const <LocationNode>[];
  List<LocationNode> _states = const <LocationNode>[];
  List<LocationNode> _districts = const <LocationNode>[];

  SelectedLocation? _selectedLocation;
  PrayerDay? _today;
  List<PrayerDay> _yearRange = const <PrayerDay>[];
  Map<String, ReminderSetting> _reminderSettings = <String, ReminderSetting>{};
  AppBarRemainingPlacement _appBarRemainingPlacement =
      AppBarRemainingPlacement.title;
  bool _statusBarRemainingEnabled = true;
  bool _remindersSilenced = false;
  AppThemePreference _themePreference = AppThemePreference.system;
  AppLocalePreference _localePreference = AppLocalePreference.system;

  bool get isInitializing => _isInitializing;
  bool get isBusy => _isBusy;
  String? get error => _error;
  int get tabIndex => _tabIndex;

  List<LocationNode> get countries => _countries;
  List<LocationNode> get states => _states;
  List<LocationNode> get districts => _districts;

  SelectedLocation? get selectedLocation => _selectedLocation;
  PrayerDay? get today => _today;
  List<PrayerDay> get yearRange => _yearRange;
  Map<String, ReminderSetting> get reminderSettings => _reminderSettings;
  AppBarRemainingPlacement get appBarRemainingPlacement =>
      _appBarRemainingPlacement;
  bool get statusBarRemainingEnabled => _statusBarRemainingEnabled;
  bool get remindersSilenced => _remindersSilenced;
  AppThemePreference get themePreference => _themePreference;
  ThemeMode get themeMode => switch (_themePreference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
  AppLocalePreference get localePreference => _localePreference;
  Locale? get appLocale => _localePreference.locale;
  Locale get resolvedLocale => appLocale ?? PlatformDispatcher.instance.locale;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      widgetBridgeService.registerOpenHomeHandler(() => setTab(1));
      await notificationService.initialize();
      _selectedLocation = await database.loadSelectedLocation();
      _reminderSettings = await database.loadReminderSettings();
      _statusBarRemainingEnabled =
          await database.loadStatusBarRemainingEnabled() ?? true;
      _remindersSilenced = await database.loadRemindersSilenced() ?? false;
      final rawThemePreference = await database.loadThemePreference();
      var themePreference = AppThemePreference.system;
      for (final item in AppThemePreference.values) {
        if (item.name == rawThemePreference) {
          themePreference = item;
          break;
        }
      }
      _themePreference = themePreference;
      final rawLocalePreference = await database.loadLocalePreference();
      var localePreference = AppLocalePreference.system;
      for (final item in AppLocalePreference.values) {
        if (item.name == rawLocalePreference) {
          localePreference = item;
          break;
        }
      }
      _localePreference = localePreference;
      final rawAppBarPlacement = await database.loadAppBarRemainingPlacement();
      var placement = AppBarRemainingPlacement.title;
      for (final item in AppBarRemainingPlacement.values) {
        if (item.name == rawAppBarPlacement) {
          placement = item;
          break;
        }
      }
      _appBarRemainingPlacement = placement;
      await _syncStatusBarConfig();
      _countries = await api.getCountries();
      if (_selectedLocation != null) {
        await _loadStates(_selectedLocation!.countryId);
        await _loadDistricts(_selectedLocation!.stateId);
        await refreshPrayerData(forceSync: false);
      } else {
        await notificationService.cancelAllPrayerNotifications();
        await widgetBridgeService.updateFromPrayerDays(
          days: const <PrayerDay>[],
          now: DateTime.now(),
          locale: resolvedLocale,
        );
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isInitializing = false;
      _setLoading(false);
    }
  }

  void setTab(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  Future<void> chooseCountry(LocationNode? country) async {
    if (country == null) {
      return;
    }
    _states = const <LocationNode>[];
    _districts = const <LocationNode>[];
    await _loadStates(country.id);
    notifyListeners();
  }

  Future<void> chooseState(LocationNode? state) async {
    if (state == null) {
      return;
    }
    _districts = const <LocationNode>[];
    await _loadDistricts(state.id);
    notifyListeners();
  }

  Future<void> saveSelectedLocation({
    required LocationNode country,
    required LocationNode state,
    required LocationNode district,
  }) async {
    _setLoading(true);
    try {
      final selected = SelectedLocation(
        countryId: country.id,
        countryName: country.name,
        stateId: state.id,
        stateName: state.name,
        districtId: district.id,
        districtName: district.name,
      );
      _selectedLocation = selected;
      await database.saveSelectedLocation(selected);
      await refreshPrayerData(forceSync: true);
      _tabIndex = 1;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> autoPickFromGps() async {
    _setLoading(true);
    try {
      final guess = await locationResolver.resolveFromDevice();
      final country = locationResolver.bestMatch(_countries, [
        guess.country,
        'Turkiye',
        'Turkey',
      ]);
      if (country == null) {
        throw Exception(
          'Could not match your country with available API locations.',
        );
      }
      await _loadStates(country.id);
      final state = locationResolver.bestMatch(_states, [
        guess.state,
        guess.city,
      ]);
      if (state == null) {
        throw Exception(
          'Could not match your city/state from GPS. Please choose manually.',
        );
      }
      await _loadDistricts(state.id);
      final district = locationResolver.bestMatch(_districts, [
        guess.city,
        guess.state,
      ]);
      if (district == null) {
        throw Exception(
          'Could not match district from GPS. Please choose manually.',
        );
      }
      await saveSelectedLocation(
        country: country,
        state: state,
        district: district,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshPrayerData({required bool forceSync}) async {
    final selected = _selectedLocation;
    if (selected == null) {
      return;
    }
    _setLoading(true);
    try {
      final now = DateTime.now();
      final currentYear = now.year;
      await _syncYearIfNeeded(
        selected.districtId,
        currentYear,
        forceSync: forceSync,
      );
      await _loadVisibleData(selected.districtId);
      await _syncNotifications();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  NextPrayerInfo? nextPrayer(DateTime now) {
    return _findFirstUpcomingPrayer(now);
  }

  ReminderSetting reminderFor(String prayer) {
    return _reminderSettings[prayer] ?? ReminderSetting.defaults();
  }

  Future<void> updateReminderSetting({
    required String prayer,
    int? minutesBefore,
    int? customMinutesBefore,
    bool? notifyOnTime,
    bool? notifyBefore,
  }) async {
    final updated = Map<String, ReminderSetting>.from(_reminderSettings);
    final current = reminderFor(prayer);
    final next = current.copyWith(
      minutesBefore: minutesBefore,
      customMinutesBefore: customMinutesBefore,
      notifyOnTime: notifyOnTime,
      notifyBefore: notifyBefore,
    );
    updated[prayer] = next;
    _reminderSettings = updated;
    await database.saveReminderSettings(updated);
    notifyListeners();
    final shouldSyncNotifications =
        minutesBefore != null ||
        notifyOnTime != null ||
        notifyBefore != null;
    if (!shouldSyncNotifications) {
      return;
    }
    try {
      await _syncNotifications();
    } catch (_) {
      // Settings are saved; notification sync can fail without blocking UI.
    }
  }

  Future<void> updateAppBarRemainingPlacement(
    AppBarRemainingPlacement placement,
  ) async {
    if (_appBarRemainingPlacement == placement) {
      return;
    }
    _appBarRemainingPlacement = placement;
    await database.saveAppBarRemainingPlacement(placement.name);
    notifyListeners();
  }

  Future<void> updateStatusBarRemainingEnabled(bool enabled) async {
    if (_statusBarRemainingEnabled == enabled) {
      return;
    }
    _statusBarRemainingEnabled = enabled;
    await database.saveStatusBarRemainingEnabled(enabled);
    await _syncStatusBarConfig();
    notifyListeners();
  }

  Future<void> updateRemindersSilenced(bool silenced) async {
    if (_remindersSilenced == silenced) {
      return;
    }
    _remindersSilenced = silenced;
    await database.saveRemindersSilenced(silenced);
    try {
      await _syncNotifications();
    } catch (_) {
      // Preference is saved; notification sync can fail without blocking UI.
    }
    notifyListeners();
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    if (_themePreference == preference) {
      return;
    }
    _themePreference = preference;
    await database.saveThemePreference(preference.name);
    notifyListeners();
  }

  Future<void> updateLocalePreference(AppLocalePreference preference) async {
    if (_localePreference == preference) {
      return;
    }
    _localePreference = preference;
    await database.saveLocalePreference(preference.name);
    notifyListeners();
    if (_selectedLocation != null && _yearRange.isNotEmpty) {
      final now = DateTime.now();
      await widgetBridgeService.updateFromPrayerDays(
        days: _yearRange,
        now: now,
        locale: resolvedLocale,
      );
      try {
        await _syncNotifications();
      } catch (_) {}
    }
  }

  Future<void> toggleThemeQuick({required bool isCurrentlyDark}) async {
    final next = isCurrentlyDark
        ? AppThemePreference.light
        : AppThemePreference.dark;
    await updateThemePreference(next);
  }

  Future<void> toggleReminders() {
    return updateRemindersSilenced(!_remindersSilenced);
  }

  Future<void> _loadStates(String countryId) async {
    _states = await api.getStates(countryId);
  }

  Future<void> _loadDistricts(String stateId) async {
    _districts = await api.getDistricts(stateId);
  }

  Future<void> _syncYearIfNeeded(
    String districtId,
    int year, {
    required bool forceSync,
  }) async {
    final alreadyCached = await database.hasSufficientYearData(
      districtId: districtId,
      year: year,
    );
    if (!forceSync && alreadyCached) {
      return;
    }
    final days = await api.getYearlyPrayerTimes(
      districtId: districtId,
      year: year,
    );
    await database.upsertPrayerDays(districtId, days);
  }

  Future<void> _loadVisibleData(String districtId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = DateTime(now.year, 12, 31);
    final todayDate = DateTime(now.year, now.month, now.day);
    _today = await database.getDay(districtId: districtId, date: todayDate);

    _yearRange = await database.getRange(
      districtId: districtId,
      start: start,
      end: end,
    );
    await widgetBridgeService.updateFromPrayerDays(
      days: _yearRange,
      now: now,
      locale: resolvedLocale,
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  Future<void> _syncNotifications() async {
    final selected = _selectedLocation;
    if (selected == null || _remindersSilenced) {
      await notificationService.cancelAllPrayerNotifications();
      return;
    }
    await notificationService.reschedulePrayerNotifications(
      days: _yearRange,
      reminderSettings: _reminderSettings,
      locationName: selected.fullName,
      prayerNameLabel: (key) => localizedPrayerName(resolvedLocale, key),
    );
  }

  Future<List<ScheduledReminderEntry>> getScheduledReminders() {
    return notificationService.getPendingScheduledReminders();
  }

  Future<void> sendTestNotificationNow() {
    return notificationService.showTestNotificationNow();
  }

  Future<void> _syncStatusBarConfig() {
    return widgetBridgeService.updateStatusBarConfig(
      enabled: _statusBarRemainingEnabled,
      autoRestore: _statusBarRemainingEnabled,
    );
  }

  NextPrayerInfo? _findFirstUpcomingPrayer(DateTime now) {
    if (_yearRange.isEmpty) {
      return null;
    }
    final todayStart = DateTime(now.year, now.month, now.day);
    final orderedDays = _yearRange.where((item) {
      final day = DateTime(item.date.year, item.date.month, item.date.day);
      return !day.isBefore(todayStart);
    });

    for (final day in orderedDays) {
      final prayers = prayerMapForDay(day);
      for (final prayerName in prayerOrder) {
        final prayerTime = parsePrayerTime(day.date, prayers[prayerName] ?? '');
        if (prayerTime != null && prayerTime.isAfter(now)) {
          return NextPrayerInfo(
            name: prayerName,
            time: prayerTime,
            remaining: prayerTime.difference(now),
          );
        }
      }
    }

    // User requested fallback: if there is no upcoming prayer on this date,
    // treat the first available prayer as the next one.
    for (final day in _yearRange) {
      final prayers = prayerMapForDay(day);
      for (final prayerName in prayerOrder) {
        final prayerTime = parsePrayerTime(day.date, prayers[prayerName] ?? '');
        if (prayerTime != null) {
          return NextPrayerInfo(
            name: prayerName,
            time: prayerTime,
            remaining: prayerTime.difference(now),
          );
        }
      }
    }
    return null;
  }
}
