import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';


import '../calendar/hijri_utils.dart';
import '../calendar/models/calendar_reminder.dart';
import '../calendar/services/calendar_reminder_service.dart';
import '../kaza/models/kaza_tracker.dart';
import '../../l10n/app_localizations.dart';
import '../l10n/locale_options.dart';
import '../l10n/prayer_names.dart';
import '../models/calendar_week_start.dart';
import '../models/fasting_models.dart';
import '../models/prayer_models.dart';

import '../services/backup_export_service.dart';
import '../services/imsakiyem_api.dart';
import '../services/local_database.dart';
import '../services/location_resolver.dart';
import '../services/notification_service.dart';
import '../services/widget_bridge_service.dart';
import '../tesbihat/data/item_history_repository.dart';
import '../tesbihat/data/item_repository.dart';
import '../tesbihat/models/daily_item_stat.dart';
import '../tesbihat/models/item.dart';
import '../tesbihat/models/item_group.dart';
import '../utils/time_utils.dart';


class PrayerAppController extends ChangeNotifier {
  PrayerAppController({
    required this.api,
    required this.database,
    required this.locationResolver,
    required this.notificationService,
    required this.widgetBridgeService,
    required this.calendarReminderService,
    ItemRepository? itemRepo,
    ItemHistoryRepository? historyRepo,
  })  : _itemRepo = itemRepo,
        _historyRepo = historyRepo;

  final ImsakiyemApi api;
  final LocalDatabase database;
  final LocationResolver locationResolver;
  final NotificationService notificationService;
  final WidgetBridgeService widgetBridgeService;
  final CalendarReminderService calendarReminderService;
  final ItemRepository? _itemRepo;
  final ItemHistoryRepository? _historyRepo;

  int _tabIndex = 2;
  bool _isInitializing = true;
  bool _isBusy = false;
  String? _error;
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
  WidgetTextSize _widgetTextSize = WidgetTextSize.medium;
  int _widgetTextSizeValue = 14;
  WidgetTheme _widgetTheme = WidgetTheme.system;
  WidgetCalendarDisplay _widgetCalendarDisplay = WidgetCalendarDisplay.both;
  int _widgetMmssThresholdMinutes = 60;
  bool _remindersSilenced = false;
  bool _reminderVibrationEnabled = true;
  bool _reminderSoundEnabled = true;
  AppThemePreference _themePreference = AppThemePreference.system;
  AppLocalePreference _localePreference = AppLocalePreference.system;
  List<CalendarReminder> _calendarReminders = const <CalendarReminder>[];
  CalendarPrimaryDisplay _calendarPrimaryDisplay = CalendarPrimaryDisplay.hijri;
  bool _showSecondaryCalendarDate = true;
  CalendarWeekStart _calendarWeekStart = CalendarWeekStart.monday;
  int _hijriDateOffset = 0;
  bool _showIslamicHolidays = true;
  bool _showFastingBadges = true;
  CalendarPrimaryDisplay _defaultCalendarDisplay = CalendarPrimaryDisplay.hijri;
  bool _showCalendarReminderDots = true;
  bool _showCardMoonPhase = true;
  bool _showCardIftarSuhoor = true;
  bool _showCardDailyWisdom = true;
  bool _showCardUpcomingReminders = true;
  Map<String, List<String>> _prayerCompletions = <String, List<String>>{};
  KazaTracker _kazaTracker = const KazaTracker();
  Map<String, FastingLog> _fastingLogs = <String, FastingLog>{};
  Future<void> Function(Locale? locale)? onLocaleChanged;

  Map<String, FastingLog> get fastingLogs => _fastingLogs;



  bool get isInitializing => _isInitializing;
  bool get isBusy => _isBusy;
  String? get error => _error;
  int get tabIndex => _tabIndex;

  List<LocationNode> get countries => _countries;
  List<LocationNode> get states => _states;
  List<LocationNode> get districts => _districts;

  SelectedLocation? get selectedLocation => _selectedLocation;
  PrayerDay? get today {
    final now = DateTime.now();
    if (_today != null) {
      final t = _today!.date;
      if (t.year == now.year && t.month == now.month && t.day == now.day) {
        return _today;
      }
    }
    final currentDay = prayerDayFor(now);
    if (currentDay != null) {
      _today = currentDay;
    }
    return _today;
  }
  List<PrayerDay> get yearRange => _yearRange;

  PrayerDay? prayerDayFor(DateTime date) {
    for (final day in _yearRange) {
      final safeDay = DateTime(day.date.year, day.date.month, day.date.day);
      if (safeDay.year == date.year &&
          safeDay.month == date.month &&
          safeDay.day == date.day) {
        return day;
      }
    }
    return null;
  }


  Map<String, ReminderSetting> get reminderSettings => _reminderSettings;
  AppBarRemainingPlacement get appBarRemainingPlacement =>
      _appBarRemainingPlacement;
  bool get statusBarRemainingEnabled => _statusBarRemainingEnabled;
  WidgetTextSize get widgetTextSize => _widgetTextSize;
  int get widgetTextSizeValue => _widgetTextSizeValue;
  WidgetTheme get widgetTheme => _widgetTheme;
  WidgetCalendarDisplay get widgetCalendarDisplay => _widgetCalendarDisplay;

  /// Minutes below which widgets count down in MM:SS instead of HH:MM.
  int get widgetMmssThresholdMinutes => _widgetMmssThresholdMinutes;
  bool get remindersSilenced => _remindersSilenced;
  bool get reminderVibrationEnabled => _reminderVibrationEnabled;
  bool get reminderSoundEnabled => _reminderSoundEnabled;
  AppThemePreference get themePreference => _themePreference;
  ThemeMode get themeMode => switch (_themePreference) {
    AppThemePreference.system => ThemeMode.system,
    AppThemePreference.light => ThemeMode.light,
    AppThemePreference.dark => ThemeMode.dark,
  };
  AppLocalePreference get localePreference => _localePreference;
  Locale? get appLocale => _localePreference.locale;
  Locale get resolvedLocale => appLocale ?? PlatformDispatcher.instance.locale;
  List<CalendarReminder> get calendarReminders => _calendarReminders;
  CalendarPrimaryDisplay get calendarPrimaryDisplay => _calendarPrimaryDisplay;
  bool get showSecondaryCalendarDate => _showSecondaryCalendarDate;
  CalendarWeekStart get calendarWeekStart => _calendarWeekStart;
  int get hijriDateOffset => _hijriDateOffset;
  bool get showIslamicHolidays => _showIslamicHolidays;
  bool get showFastingBadges => _showFastingBadges;
  CalendarPrimaryDisplay get defaultCalendarDisplay => _defaultCalendarDisplay;
  bool get showCalendarReminderDots => _showCalendarReminderDots;
  bool get showCardMoonPhase => _showCardMoonPhase;
  bool get showCardIftarSuhoor => _showCardIftarSuhoor;
  bool get showCardDailyWisdom => _showCardDailyWisdom;
  bool get showCardUpcomingReminders => _showCardUpcomingReminders;

  void updateCalendarWeekStart(CalendarWeekStart weekStart) {
    _calendarWeekStart = weekStart;
    database.saveCalendarWeekStart(weekStart);
    notifyListeners();
  }

  void updateHijriDateOffset(int offset) {
    _hijriDateOffset = offset;
    database.saveHijriDateOffset(offset);
    notifyListeners();
  }

  void updateShowIslamicHolidays(bool show) {
    _showIslamicHolidays = show;
    database.saveShowIslamicHolidays(show);
    notifyListeners();
  }

  void updateShowFastingBadges(bool show) {
    _showFastingBadges = show;
    database.saveShowFastingBadges(show);
    notifyListeners();
  }

  void updateDefaultCalendarDisplay(CalendarPrimaryDisplay display) {
    _defaultCalendarDisplay = display;
    database.saveDefaultCalendarDisplay(display);
    notifyListeners();
  }

  void updateShowCalendarReminderDots(bool show) {
    _showCalendarReminderDots = show;
    database.saveShowCalendarReminderDots(show);
    notifyListeners();
  }

  void updateShowCardMoonPhase(bool show) {
    _showCardMoonPhase = show;
    database.saveShowCardMoonPhase(show);
    notifyListeners();
  }

  void updateShowCardIftarSuhoor(bool show) {
    _showCardIftarSuhoor = show;
    database.saveShowCardIftarSuhoor(show);
    notifyListeners();
  }

  void updateShowCardDailyWisdom(bool show) {
    _showCardDailyWisdom = show;
    database.saveShowCardDailyWisdom(show);
    notifyListeners();
  }

  void updateShowCardUpcomingReminders(bool show) {
    _showCardUpcomingReminders = show;
    database.saveShowCardUpcomingReminders(show);
    notifyListeners();
  }

  Map<String, List<String>> get prayerCompletions => _prayerCompletions;
  KazaTracker get kazaTracker => _kazaTracker;

  void updateKazaTracker(KazaTracker tracker) {
    _kazaTracker = tracker;
    database.saveKazaTracker(tracker);
    notifyListeners();
  }

  void incrementKaza(String prayerKey, [int amount = 1]) {
    final key = prayerKey.toLowerCase();
    KazaTracker updated;
    switch (key) {
      case 'fajr':
      case 'imsak':
        updated = _kazaTracker.copyWith(
          fajrCompleted: _kazaTracker.fajrCompleted + amount,
        );
        break;
      case 'dhuhr':
      case 'ogle':
        updated = _kazaTracker.copyWith(
          dhuhrCompleted: _kazaTracker.dhuhrCompleted + amount,
        );
        break;
      case 'asr':
      case 'ikindi':
        updated = _kazaTracker.copyWith(
          asrCompleted: _kazaTracker.asrCompleted + amount,
        );
        break;
      case 'maghrib':
      case 'aksam':
        updated = _kazaTracker.copyWith(
          maghribCompleted: _kazaTracker.maghribCompleted + amount,
        );
        break;
      case 'isha':
      case 'yatsi':
        updated = _kazaTracker.copyWith(
          ishaCompleted: _kazaTracker.ishaCompleted + amount,
        );
        break;
      case 'witr':
        updated = _kazaTracker.copyWith(
          witrCompleted: _kazaTracker.witrCompleted + amount,
        );
        break;
      default:
        return;
    }
    updateKazaTracker(updated);
  }

  void decrementKaza(String prayerKey, [int amount = 1]) {
    final key = prayerKey.toLowerCase();
    KazaTracker updated;
    switch (key) {
      case 'fajr':
      case 'imsak':
        updated = _kazaTracker.copyWith(
          fajrCompleted: (_kazaTracker.fajrCompleted - amount).clamp(0, 999999),
        );
        break;
      case 'dhuhr':
      case 'ogle':
        updated = _kazaTracker.copyWith(
          dhuhrCompleted: (_kazaTracker.dhuhrCompleted - amount).clamp(0, 999999),
        );
        break;
      case 'asr':
      case 'ikindi':
        updated = _kazaTracker.copyWith(
          asrCompleted: (_kazaTracker.asrCompleted - amount).clamp(0, 999999),
        );
        break;
      case 'maghrib':
      case 'aksam':
        updated = _kazaTracker.copyWith(
          maghribCompleted: (_kazaTracker.maghribCompleted - amount).clamp(0, 999999),
        );
        break;
      case 'isha':
      case 'yatsi':
        updated = _kazaTracker.copyWith(
          ishaCompleted: (_kazaTracker.ishaCompleted - amount).clamp(0, 999999),
        );
        break;
      case 'witr':
        updated = _kazaTracker.copyWith(
          witrCompleted: (_kazaTracker.witrCompleted - amount).clamp(0, 999999),
        );
        break;
      default:
        return;
    }
    updateKazaTracker(updated);
  }

  void logFullDayKaza() {
    final updated = _kazaTracker.copyWith(
      fajrCompleted: _kazaTracker.fajrCompleted + 1,
      dhuhrCompleted: _kazaTracker.dhuhrCompleted + 1,
      asrCompleted: _kazaTracker.asrCompleted + 1,
      maghribCompleted: _kazaTracker.maghribCompleted + 1,
      ishaCompleted: _kazaTracker.ishaCompleted + 1,
      witrCompleted: _kazaTracker.witrCompleted + 1,
    );
    updateKazaTracker(updated);
  }

  bool isPrayerCompleted(String prayerName, DateTime date) {
    final key = _toDateKey(date);
    final list = _prayerCompletions[key];
    if (list == null) {
      return false;
    }
    final lowerName = prayerName.toLowerCase();
    return list.any((item) => item.toLowerCase() == lowerName);
  }

  int completedCountForDate(DateTime date) {
    final key = _toDateKey(date);
    return _prayerCompletions[key]?.length ?? 0;
  }

  void togglePrayerCompletion(String prayerName) {
    final targetDate = today?.date ?? DateTime.now();
    togglePrayerCompletionForDate(prayerName, targetDate);
  }

  void togglePrayerCompletionForDate(String prayerName, DateTime date) {
    final key = _toDateKey(date);
    final next = Map<String, List<String>>.from(_prayerCompletions);
    final current = List<String>.from(next[key] ?? []);
    final lowerName = prayerName.toLowerCase();
    final existingIndex =
        current.indexWhere((item) => item.toLowerCase() == lowerName);
    if (existingIndex != -1) {
      current.removeAt(existingIndex);
    } else {
      current.add(prayerName);
    }
    next[key] = current;
    _prayerCompletions = next;
    database.savePrayerCompletions(next);
    notifyListeners();
  }


  String _toDateKey(DateTime date) {
    final safe = DateTime(date.year, date.month, date.day);
    return '${safe.year.toString().padLeft(4, '0')}-'
        '${safe.month.toString().padLeft(2, '0')}-'
        '${safe.day.toString().padLeft(2, '0')}';
  }

  FastingLog? getFastingLog(DateTime date) {
    final key = _toDateKey(date);
    return _fastingLogs[key];
  }

  void toggleFastingLog(DateTime date, FastingType type) {
    final key = _toDateKey(date);
    final next = Map<String, FastingLog>.from(_fastingLogs);
    final existing = next[key];
    if (existing != null && existing.type == type) {
      next.remove(key);
    } else {
      next[key] = FastingLog(dateKey: key, type: type);
    }
    _fastingLogs = next;
    database.saveFastingLogs(next);
    notifyListeners();
  }

  void removeFastingLog(DateTime date) {
    final key = _toDateKey(date);
    if (!_fastingLogs.containsKey(key)) return;
    final next = Map<String, FastingLog>.from(_fastingLogs)..remove(key);
    _fastingLogs = next;
    database.saveFastingLogs(next);
    notifyListeners();
  }

  Future<void> initialize() async {
    _setLoading(true);
    try {
      widgetBridgeService.registerOpenHomeHandler(() => setTab(2));
      await notificationService.initialize();
      _selectedLocation = await database.loadSelectedLocation();
      _reminderSettings = await database.loadReminderSettings();
      _prayerCompletions = await database.loadPrayerCompletions();
      _kazaTracker = await database.loadKazaTracker();
      _fastingLogs = await database.loadFastingLogs();


      _reminderSettings = {
        for (final entry in _reminderSettings.entries)
          entry.key: ReminderSetting.ensureCurrent(entry.value),
      };
      _statusBarRemainingEnabled =
          await database.loadStatusBarRemainingEnabled() ?? true;
      _remindersSilenced = await database.loadRemindersSilenced() ?? false;
      _reminderVibrationEnabled =
          await database.loadReminderVibrationEnabled() ?? true;
      _reminderSoundEnabled = await database.loadReminderSoundEnabled() ?? true;
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
      final rawWidgetTextSize = await database.loadWidgetTextSize();
      var widgetTextSize = WidgetTextSize.medium;
      var widgetTextSizeVal = 14;
      final parsedInt = int.tryParse(rawWidgetTextSize ?? '');
      if (parsedInt != null) {
        widgetTextSizeVal = parsedInt.clamp(10, 18);
        if (widgetTextSizeVal <= 10) {
          widgetTextSize = WidgetTextSize.extraSmall;
        } else if (widgetTextSizeVal <= 12) {
          widgetTextSize = WidgetTextSize.small;
        } else if (widgetTextSizeVal <= 15) {
          widgetTextSize = WidgetTextSize.medium;
        } else {
          widgetTextSize = WidgetTextSize.large;
        }
      } else {
        for (final item in WidgetTextSize.values) {
          if (item.name == rawWidgetTextSize) {
            widgetTextSize = item;
            break;
          }
        }
        switch (widgetTextSize) {
          case WidgetTextSize.extraSmall:
            widgetTextSizeVal = 10;
            break;
          case WidgetTextSize.small:
            widgetTextSizeVal = 12;
            break;
          case WidgetTextSize.medium:
            widgetTextSizeVal = 14;
            break;
          case WidgetTextSize.large:
            widgetTextSizeVal = 16;
            break;
        }
      }
      _widgetTextSize = widgetTextSize;
      _widgetTextSizeValue = widgetTextSizeVal;
      final rawWidgetTheme = await database.loadWidgetTheme();
      var widgetTheme = WidgetTheme.system;
      for (final item in WidgetTheme.values) {
        if (item.name == rawWidgetTheme) {
          widgetTheme = item;
          break;
        }
      }
      _widgetTheme = widgetTheme;

      final rawWidgetCalDisplay = await database.loadWidgetCalendarDisplay();
      var widgetCalDisplay = WidgetCalendarDisplay.both;
      for (final item in WidgetCalendarDisplay.values) {
        if (item.name == rawWidgetCalDisplay) {
          widgetCalDisplay = item;
          break;
        }
      }
      _widgetCalendarDisplay = widgetCalDisplay;

      _widgetMmssThresholdMinutes = (await database
              .loadWidgetMmssThreshold())
          .clamp(0, 60);
      await _syncStatusBarConfig();
      await widgetBridgeService.updateWidgetTextSize(_widgetTextSize.name);
      await widgetBridgeService.updateWidgetTheme(_widgetTheme.name);
      await widgetBridgeService.updateWidgetCalendarDisplay(_widgetCalendarDisplay.name);
      await widgetBridgeService.updateWidgetMmssThreshold(
        _widgetMmssThresholdMinutes,
      );
      try {
        await widgetBridgeService.updateWidgetLocale(resolvedLocale.languageCode);
      } catch (_) {}
      final rawCalendarPrimaryDisplay = await database
          .loadCalendarPrimaryDisplay();
      var calendarPrimaryDisplay = CalendarPrimaryDisplay.hijri;
      for (final item in CalendarPrimaryDisplay.values) {
        if (item.name == rawCalendarPrimaryDisplay) {
          calendarPrimaryDisplay = item;
          break;
        }
      }
      _calendarPrimaryDisplay = calendarPrimaryDisplay;
      _showSecondaryCalendarDate =
          await database.loadShowSecondaryCalendarDate() ?? true;
      _calendarWeekStart =
          await database.loadCalendarWeekStart() ?? CalendarWeekStart.monday;
      _hijriDateOffset = await database.loadHijriDateOffset() ?? 0;
      _showIslamicHolidays =
          await database.loadShowIslamicHolidays() ?? true;
      _showFastingBadges = await database.loadShowFastingBadges() ?? true;
      _defaultCalendarDisplay =
          await database.loadDefaultCalendarDisplay() ??
          CalendarPrimaryDisplay.hijri;
      _showCalendarReminderDots =
          await database.loadShowCalendarReminderDots() ?? true;
      _showCardMoonPhase = await database.loadShowCardMoonPhase() ?? true;
      _showCardIftarSuhoor = await database.loadShowCardIftarSuhoor() ?? true;
      _showCardDailyWisdom = await database.loadShowCardDailyWisdom() ?? true;
      _showCardUpcomingReminders =
          await database.loadShowCardUpcomingReminders() ?? true;
      _calendarReminders = await database.loadCalendarReminders();
      for (final reminder in _calendarReminders) {
        if (reminder.enabled) {
          // Re-arms already-fired occurrences without re-firing them: the
          // catch-up only applies when the user saves/enables a reminder.
          await calendarReminderService.scheduleReminder(
            reminder,
            catchUp: false,
          );
        }
      }
      await _syncCalendarRemindersWidget();
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

  /// Retries loading the location option lists after a failed startup fetch
  /// (a network hiccup during [initialize] left the lists empty and no
  /// subsequent retry existed). Also reloads the saved location's
  /// states/districts when they are missing, and clears the stale error.
  Future<void> reloadLocationOptions() async {
    if (_countries.isNotEmpty) {
      return;
    }
    try {
      _countries = await api.getCountries();
      final selected = _selectedLocation;
      if (selected != null) {
        await _loadStates(selected.countryId);
        await _loadDistricts(selected.stateId);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
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
      // Persist first so a failed write never leaves an unsaved location
      // in memory (which also blocked closing the location screen).
      await database.saveSelectedLocation(selected);
      _selectedLocation = selected;
      await refreshPrayerData(forceSync: true);
      _tabIndex = 2;
      _error = null;

    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Resolves the device location and matches it against the API location
  /// lists; returns the matched nodes for the screen to fill its dropdowns.
  /// Does not persist anything and does not leave the current tab — saving
  /// stays the user's explicit Save action. On failure records the error and
  /// returns null.
  Future<
    ({LocationNode country, LocationNode state, LocationNode district})?
  >
  autoPickFromGps() async {
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
        guess.district,
        guess.city,
        guess.state,
      ]);
      if (district == null) {
        throw Exception(
          'Could not match district from GPS. Please choose manually.',
        );
      }
      return (country: country, state: state, district: district);
    } catch (e) {
      _error = e.toString();
      return null;
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
    final setting = _reminderSettings[prayer];
    if (setting == null) {
      return ReminderSetting.defaults();
    }
    final current = ReminderSetting.ensureCurrent(setting);
    if (!identical(current, setting)) {
      _reminderSettings = Map<String, ReminderSetting>.from(_reminderSettings)
        ..[prayer] = current;
    }
    return current;
  }

  Future<void> updateReminderSetting({
    required String prayer,
    int? minutesBefore,
    int? customMinutesBefore,
    int? minutesAfter,
    int? customMinutesAfter,
    bool? notifyOnTime,
    bool? notifyBefore,
    bool? notifyAfter,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? adhanEnabled,
  }) async {
    final updated = Map<String, ReminderSetting>.from(_reminderSettings);
    final current = reminderFor(prayer);
    final next = current.copyWith(
      minutesBefore: minutesBefore,
      customMinutesBefore: customMinutesBefore,
      minutesAfter: minutesAfter,
      customMinutesAfter: customMinutesAfter,
      notifyOnTime: notifyOnTime,
      notifyBefore: notifyBefore,
      notifyAfter: notifyAfter,
      vibrationEnabled: vibrationEnabled,
      soundEnabled: soundEnabled,
      adhanEnabled: adhanEnabled,
    );
    updated[prayer] = next;
    _reminderSettings = updated;
    await database.saveReminderSettings(updated);
    notifyListeners();
    final shouldSyncNotifications =
        minutesBefore != null ||
        minutesAfter != null ||
        notifyOnTime != null ||
        notifyBefore != null ||
        notifyAfter != null ||
        vibrationEnabled != null ||
        soundEnabled != null ||
        adhanEnabled != null;
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

  Future<void> updateWidgetTextSize(WidgetTextSize size) async {
    if (_widgetTextSize == size) {
      return;
    }
    _widgetTextSize = size;
    switch (size) {
      case WidgetTextSize.extraSmall:
        _widgetTextSizeValue = 10;
        break;
      case WidgetTextSize.small:
        _widgetTextSizeValue = 12;
        break;
      case WidgetTextSize.medium:
        _widgetTextSizeValue = 14;
        break;
      case WidgetTextSize.large:
        _widgetTextSizeValue = 16;
        break;
    }
    await database.saveWidgetTextSize(size.name);
    await widgetBridgeService.updateWidgetTextSize(size.name);
    notifyListeners();
  }

  Future<void> updateWidgetTextSizeValue(int size) async {
    final clamped = size.clamp(10, 18);
    if (_widgetTextSizeValue == clamped) {
      return;
    }
    _widgetTextSizeValue = clamped;
    if (clamped <= 10) {
      _widgetTextSize = WidgetTextSize.extraSmall;
    } else if (clamped <= 12) {
      _widgetTextSize = WidgetTextSize.small;
    } else if (clamped <= 15) {
      _widgetTextSize = WidgetTextSize.medium;
    } else {
      _widgetTextSize = WidgetTextSize.large;
    }
    final strVal = clamped.toString();
    await database.saveWidgetTextSize(strVal);
    await widgetBridgeService.updateWidgetTextSize(strVal);
    notifyListeners();
  }

  Future<void> updateWidgetMmssThreshold(int minutes) async {
    final clamped = minutes.clamp(0, 60);
    if (_widgetMmssThresholdMinutes == clamped) {
      return;
    }
    _widgetMmssThresholdMinutes = clamped;
    await database.saveWidgetMmssThreshold(clamped);
    await widgetBridgeService.updateWidgetMmssThreshold(clamped);
    notifyListeners();
  }

  Future<void> updateWidgetTheme(WidgetTheme theme) async {
    if (_widgetTheme == theme) {
      return;
    }
    _widgetTheme = theme;
    await database.saveWidgetTheme(theme.name);
    await widgetBridgeService.updateWidgetTheme(theme.name);
    notifyListeners();
  }

  Future<void> updateWidgetCalendarDisplay(
    WidgetCalendarDisplay display,
  ) async {
    if (_widgetCalendarDisplay == display) {
      return;
    }
    _widgetCalendarDisplay = display;
    await database.saveWidgetCalendarDisplay(display.name);
    await widgetBridgeService.updateWidgetCalendarDisplay(display.name);
    await _updateWidgetBridgeData();
    notifyListeners();
  }

  Future<void> _updateWidgetBridgeData() async {
    final now = DateTime.now();
    final lang = resolvedLocale.languageCode;
    final hijriStr = formatHijriDate(now, lang, offset: _hijriDateOffset);
    String gregorianStr;
    try {
      gregorianStr = DateFormat.yMMMMd(lang).format(now);
    } catch (_) {
      try {
        gregorianStr = DateFormat('dd MMMM yyyy').format(now);
      } catch (_) {
        gregorianStr = '${now.day}.${now.month}.${now.year}';
      }
    }
    await widgetBridgeService.updateFromPrayerDays(
      days: _yearRange,
      now: now,
      locale: resolvedLocale,
      locationLabel: _selectedLocation?.fullName ?? '',
      dateHeaderHijri: hijriStr,
      dateHeaderGregorian: gregorianStr,
      calendarDisplay: _widgetCalendarDisplay.name,
    );
  }

  Future<void> updateCalendarPrimaryDisplay(
    CalendarPrimaryDisplay display,
  ) async {
    if (_calendarPrimaryDisplay == display) {
      return;
    }
    _calendarPrimaryDisplay = display;
    await database.saveCalendarPrimaryDisplay(display.name);
    notifyListeners();
  }

  Future<void> updateShowSecondaryCalendarDate(bool show) async {
    if (_showSecondaryCalendarDate == show) {
      return;
    }
    _showSecondaryCalendarDate = show;
    await database.saveShowSecondaryCalendarDate(show);
    notifyListeners();
  }

  Future<void> addCalendarReminder(CalendarReminder reminder) async {
    _calendarReminders = [..._calendarReminders, reminder];
    notifyListeners();
    _syncCalendarRemindersWidget();
    await database.saveCalendarReminder(reminder);
    await calendarReminderService.scheduleReminder(reminder);
  }

  Future<void> updateCalendarReminder(CalendarReminder reminder) async {
    _calendarReminders = [
      for (final existing in _calendarReminders)
        if (existing.id == reminder.id) reminder else existing,
    ];
    notifyListeners();
    _syncCalendarRemindersWidget();
    await database.saveCalendarReminder(reminder);
    await calendarReminderService.scheduleReminder(reminder);
  }

  Future<void> deleteCalendarReminder(String id) async {
    _calendarReminders = _calendarReminders
        .where((reminder) => reminder.id != id)
        .toList(growable: false);
    notifyListeners();
    _syncCalendarRemindersWidget();
    await database.deleteCalendarReminder(id);
    await calendarReminderService.cancelReminder(id);
  }

  Future<void> restoreCalendarReminder(
    CalendarReminder reminder, {
    required int index,
  }) async {
    if (_calendarReminders.any((existing) => existing.id == reminder.id)) {
      return;
    }
    final safeIndex = index.clamp(0, _calendarReminders.length);
    final nextReminders = [..._calendarReminders];
    nextReminders.insert(safeIndex, reminder);
    _calendarReminders = nextReminders;
    notifyListeners();
    _syncCalendarRemindersWidget();
    await database.saveCalendarReminder(reminder);
    await calendarReminderService.scheduleReminder(reminder);
  }

  /// Pushes the next few upcoming enabled calendar reminders to the Android
  /// home-screen widget. Fire-and-forget: display-only, not the scheduling
  /// authority (CalendarReminderService/CalendarMidnightScheduler are).
  Future<void> _syncCalendarRemindersWidget() async {
    final now = DateTime.now();
    final upcoming = <({CalendarReminder reminder, DateTime next})>[
      for (final reminder in _calendarReminders)
        if (reminder.enabled)
          if (reminder.nextOccurrenceFrom(now) case final next?)
            (reminder: reminder, next: next),
    ]..sort((a, b) => a.next.compareTo(b.next));
    final dateFormat = DateFormat(
      'EEE, d MMM · HH:mm',
      resolvedLocale.toString(),
    );
    final payload = [
      for (final entry in upcoming.take(3))
        {
          'title': entry.reminder.title,
          'when': dateFormat.format(entry.next),
          'epochMs': entry.next.millisecondsSinceEpoch,
        },
    ];
    await widgetBridgeService.updateCalendarReminders(
      headerText: lookupAppLocalizations(
        resolvedLocale,
      ).homeUpcomingRemindersTitle,
      reminders: payload,
    );
  }

  Future<void> toggleCalendarReminderEnabled(String id) async {
    final index = _calendarReminders.indexWhere(
      (reminder) => reminder.id == id,
    );
    if (index == -1) {
      return;
    }
    final updated = _calendarReminders[index].copyWith(
      enabled: !_calendarReminders[index].enabled,
    );
    await updateCalendarReminder(updated);
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

  Future<void> updateReminderVibrationEnabled(bool enabled) async {
    if (_reminderVibrationEnabled == enabled) {
      return;
    }
    _reminderVibrationEnabled = enabled;
    await database.saveReminderVibrationEnabled(enabled);
    try {
      await _syncNotifications();
    } catch (_) {
      // Preference is saved; notification sync can fail without blocking UI.
    }
    notifyListeners();
  }

  Future<void> updateReminderSoundEnabled(bool enabled) async {
    if (_reminderSoundEnabled == enabled) {
      return;
    }
    _reminderSoundEnabled = enabled;
    await database.saveReminderSoundEnabled(enabled);
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
    try {
      await widgetBridgeService.updateWidgetLocale(resolvedLocale.languageCode);
    } catch (_) {}
    if (_selectedLocation != null && _yearRange.isNotEmpty) {
      await _updateWidgetBridgeData();
      await _syncCalendarRemindersWidget();
      try {
        await _syncNotifications();
      } catch (_) {}
    }
    try {
      await onLocaleChanged?.call(resolvedLocale);
    } catch (_) {}
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
    await _updateWidgetBridgeData();
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
      vibrationEnabled: _reminderVibrationEnabled,
      soundEnabled: _reminderSoundEnabled,
      locale: resolvedLocale,
    );
  }

  Future<List<ScheduledReminderEntry>> getScheduledReminders() {
    return notificationService.getPendingScheduledReminders();
  }

  Future<void> sendTestNotificationNow() {
    return notificationService.showTestNotificationNow(locale: resolvedLocale);
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

  ItemRepository get _defaultItemRepo {
    if (Hive.isBoxOpen('items_box')) {
      return ItemRepository.hive(Hive.box<dynamic>('items_box'));
    }
    return ItemRepository.memory();
  }

  ItemHistoryRepository get _defaultHistoryRepo {
    if (Hive.isBoxOpen('item_history_box')) {
      return ItemHistoryRepository.hive(Hive.box<dynamic>('item_history_box'));
    }
    return ItemHistoryRepository.memory();
  }

  /// Exports a comprehensive JSON backup string of all app data.
  Future<String> exportBackupJson({
    ItemRepository? itemRepo,
    ItemHistoryRepository? historyRepo,
  }) async {
    const service = BackupExportService();
    final repo = itemRepo ?? _defaultItemRepo;
    final hRepo = historyRepo ?? _defaultHistoryRepo;
    final items = repo.loadItems();
    final groups = repo.loadGroups();
    final stats = hRepo.loadStats();

    final prefs = <String, dynamic>{
      'remindersSilenced': _remindersSilenced,
      'themePreference': _themePreference.name,
      'localePreference': _localePreference.name,
      'appBarRemainingPlacement': _appBarRemainingPlacement.name,
      'widgetTextSize': _widgetTextSize.name,
      'statusBarRemainingEnabled': _statusBarRemainingEnabled,

      'reminderVibrationEnabled': _reminderVibrationEnabled,
      'reminderSoundEnabled': _reminderSoundEnabled,
      'calendarPrimaryDisplay': _calendarPrimaryDisplay.name,
      'showSecondaryCalendarDate': _showSecondaryCalendarDate,
    };

    return service.generateJsonBackup(
      kazaTracker: _kazaTracker,
      prayerCompletions: _prayerCompletions,
      calendarReminders: _calendarReminders,
      tesbihItems: items,
      tesbihGroups: groups,
      tesbihStats: stats,
      preferences: prefs,
      fastingLogs: _fastingLogs,
    );
  }

  /// Restores all app data from a valid JSON backup string.
  Future<void> restoreBackupJson(
    String jsonString, {
    ItemRepository? itemRepo,
    ItemHistoryRepository? historyRepo,
  }) async {
    const service = BackupExportService();
    final repo = itemRepo ?? _defaultItemRepo;
    final hRepo = historyRepo ?? _defaultHistoryRepo;
    final parsed = service.parseAndValidateBackup(jsonString);

    final restoredKaza = parsed['kazaTracker'] as KazaTracker;
    final restoredCompletions =
        parsed['prayerCompletions'] as Map<String, List<String>>;
    final restoredReminders =
        parsed['calendarReminders'] as List<CalendarReminder>;
    final restoredItems = parsed['tesbihItems'] as List<Item>;
    final restoredGroups = parsed['tesbihGroups'] as List<ItemGroup>;
    final restoredStats = parsed['tesbihStats'] as List<DailyItemStat>;
    final restoredFastingLogs =
        parsed['fastingLogs'] as Map<String, FastingLog>? ?? {};

    await database.saveKazaTracker(restoredKaza);
    _kazaTracker = restoredKaza;

    await database.savePrayerCompletions(restoredCompletions);
    _prayerCompletions = restoredCompletions;

    await database.saveFastingLogs(restoredFastingLogs);
    _fastingLogs = restoredFastingLogs;

    for (final r in restoredReminders) {
      await database.saveCalendarReminder(r);
    }
    _calendarReminders = await database.loadCalendarReminders();

    if (restoredItems.isNotEmpty) {
      repo.saveItems(restoredItems);
    }
    if (restoredGroups.isNotEmpty) {
      repo.saveGroups(restoredGroups);
    }
    if (restoredStats.isNotEmpty) {
      hRepo.saveStats(restoredStats);
    }

    notifyListeners();
  }





  /// Exports the 10 Islamic holidays for the current year to iCalendar (.ics) format.
  String exportIslamicHolidaysIcs({
    required String Function(String key) holidayLabel,
  }) {
    const service = BackupExportService();
    return service.generateIslamicHolidaysIcs(
      days: _yearRange,
      holidayLabel: holidayLabel,
    );
  }
}

