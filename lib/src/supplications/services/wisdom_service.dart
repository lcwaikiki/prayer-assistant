import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/supplication_models.dart';

class WisdomService {
  WisdomService._();
  static final WisdomService instance = WisdomService._();

  static const String _favoritesKey = 'hisn_favorite_ids';

  List<DailyWisdom> _wisdomList = [];
  List<SupplicationItem> _supplicationList = [];
  final Set<String> _favoriteIds = {};
  bool _initialized = false;

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String id) => _favoriteIds.contains(id);

  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    await _saveFavorites();
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, _favoriteIds.toList());
    } catch (_) {}
  }

  void setFavoritesForTesting(Iterable<String> ids) {
    _favoriteIds
      ..clear()
      ..addAll(ids);
  }

  void setSupplicationsForTesting(List<SupplicationItem> items) {
    _supplicationList = List.from(items);
  }

  Future<void> init() async {
    if (_initialized) return;

    try {
      final wisdomRaw =
          await rootBundle.loadString('assets/data/daily_wisdom.json');
      final List<dynamic> wisdomJson = jsonDecode(wisdomRaw) as List<dynamic>;
      _wisdomList = wisdomJson
          .map((e) => DailyWisdom.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _wisdomList = [];
    }

    try {
      final suppRaw =
          await rootBundle.loadString('assets/data/supplications.json');
      final List<dynamic> suppJson = jsonDecode(suppRaw) as List<dynamic>;
      _supplicationList = suppJson
          .map((e) => SupplicationItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _supplicationList = [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList(_favoritesKey);
      if (favs != null) {
        _favoriteIds
          ..clear()
          ..addAll(favs);
      }
    } catch (_) {}

    _initialized = true;
  }

  DailyWisdom? getWisdomForDate(DateTime date) {
    if (_wisdomList.isEmpty) return null;
    final dayIndex =
        (date.year * 365 + date.month * 31 + date.day) % _wisdomList.length;
    return _wisdomList[dayIndex];
  }

  List<SupplicationItem> getSupplicationsByCategory(String category) {
    if (category == 'favorites') {
      return _supplicationList.where((s) => _favoriteIds.contains(s.id)).toList();
    }
    if (category.isEmpty || category == 'all') {
      return List.unmodifiable(_supplicationList);
    }
    return _supplicationList.where((s) => s.category == category).toList();
  }

  List<SupplicationItem> searchSupplications(String query, String lang) {
    if (query.trim().isEmpty) {
      return List.unmodifiable(_supplicationList);
    }
    final q = query.trim().toLowerCase();
    return _supplicationList.where((item) {
      final text = item.localizedText(lang).toLowerCase();
      final ar = item.textAr.toLowerCase();
      final ref = item.reference.toLowerCase();
      final trans = item.transliteration.toLowerCase();
      return text.contains(q) || ar.contains(q) || ref.contains(q) || trans.contains(q);
    }).toList();
  }
}
