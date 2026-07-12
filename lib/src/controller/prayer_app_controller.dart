import 'package:flutter/foundation.dart';

import '../models/prayer_models.dart';
import '../services/imsakiyem_api.dart';
import '../services/local_database.dart';
import '../services/location_resolver.dart';
import '../services/notification_service.dart';
import '../utils/time_utils.dart';

class PrayerAppController extends ChangeNotifier {
  PrayerAppController({
    required this.api,
    required this.database,
    required this.locationResolver,
    required this.notificationService,
  });

  final ImsakiyemApi api;
  final LocalDatabase database;
  final LocationResolver locationResolver;
  final NotificationService notificationService;

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

  Future<void> initialize() async {
    _setLoading(true);
    try {
      await notificationService.initialize();
      _selectedLocation = await database.loadSelectedLocation();
      _reminderSettings = await database.loadReminderSettings();
      _countries = await api.getCountries();
      if (_selectedLocation != null) {
        await _loadStates(_selectedLocation!.countryId);
        await _loadDistricts(_selectedLocation!.stateId);
        await refreshPrayerData(forceSync: false);
      } else {
        await notificationService.cancelAllPrayerNotifications();
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
    final today = _today;
    if (today == null) {
      return null;
    }
    final prayers = prayerMapForDay(today);
    for (final prayerName in prayerOrder) {
      final time = parsePrayerTime(today.date, prayers[prayerName] ?? '');
      if (time != null && time.isAfter(now)) {
        return NextPrayerInfo(
          name: prayerName,
          time: time,
          remaining: time.difference(now),
        );
      }
    }
    if (_yearRange.length > 1) {
      final tomorrow = _yearRange.firstWhere(
        (item) => item.date.isAfter(today.date),
        orElse: () => today,
      );
      final imsak = parsePrayerTime(tomorrow.date, tomorrow.imsak);
      if (imsak != null) {
        return NextPrayerInfo(
          name: 'Imsak',
          time: imsak,
          remaining: imsak.difference(now),
        );
      }
    }
    return null;
  }

  ReminderSetting reminderFor(String prayer) {
    return _reminderSettings[prayer] ?? ReminderSetting.defaults();
  }

  Future<void> updateReminderSetting({
    required String prayer,
    int? minutesBefore,
    bool? notifyOnTime,
    bool? notifyBefore,
  }) async {
    final updated = Map<String, ReminderSetting>.from(_reminderSettings);
    final current = reminderFor(prayer);
    final next = current.copyWith(
      minutesBefore: minutesBefore,
      notifyOnTime: notifyOnTime,
      notifyBefore: notifyBefore,
    );
    updated[prayer] = next;
    _reminderSettings = updated;
    await database.saveReminderSettings(updated);
    await _syncNotifications();
    notifyListeners();
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

print('306 today: ${_today?.date}');

    _yearRange = await database.getRange(
      districtId: districtId,
      start: start,
      end: end,
    );

    print('310 yearRange: ${_yearRange.length}');
    
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isBusy = value;
    notifyListeners();
  }

  Future<void> _syncNotifications() async {
    final selected = _selectedLocation;
    if (selected == null) {
      await notificationService.cancelAllPrayerNotifications();
      return;
    }
    await notificationService.reschedulePrayerNotifications(
      days: _yearRange,
      reminderSettings: _reminderSettings,
      locationName: selected.fullName,
    );
  }

  Future<List<ScheduledReminderEntry>> getScheduledReminders() {
    return notificationService.getPendingScheduledReminders();
  }

  Future<void> sendTestNotificationNow() {
    return notificationService.showTestNotificationNow();
  }
}
