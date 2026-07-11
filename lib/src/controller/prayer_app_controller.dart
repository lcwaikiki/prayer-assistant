import 'package:flutter/foundation.dart';

import '../models/prayer_models.dart';
import '../services/imsakiyem_api.dart';
import '../services/local_database.dart';
import '../services/location_resolver.dart';
import '../utils/time_utils.dart';

class PrayerAppController extends ChangeNotifier {
  PrayerAppController({
    required this.api,
    required this.database,
    required this.locationResolver,
  });

  final ImsakiyemApi api;
  final LocalDatabase database;
  final LocationResolver locationResolver;

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
  Map<String, bool> _reminderSettings = <String, bool>{};

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
  Map<String, bool> get reminderSettings => _reminderSettings;

  Future<void> initialize() async {
    _setLoading(true);
    try {
      _selectedLocation = await database.loadSelectedLocation();
      _reminderSettings = await database.loadReminderSettings();
      _countries = await api.getCountries();
      if (_selectedLocation != null) {
        await _loadStates(_selectedLocation!.countryId);
        await _loadDistricts(_selectedLocation!.stateId);
        await refreshPrayerData(forceSync: false);
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

  Future<void> setReminderEnabled(String prayer, bool enabled) async {
    final updated = Map<String, bool>.from(_reminderSettings);
    updated[prayer] = enabled;
    _reminderSettings = updated;
    await database.saveReminderSettings(updated);
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
    _yearRange = await database.getRange(
      districtId: districtId,
      start: start,
      end: end,
    );
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isBusy = value;
    notifyListeners();
  }
}
