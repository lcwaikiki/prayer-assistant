import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/supplication_models.dart';

class WisdomService {
  WisdomService._();
  static final WisdomService instance = WisdomService._();

  List<DailyWisdom> _wisdomList = [];
  List<SupplicationItem> _supplicationList = [];
  bool _initialized = false;

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

    _initialized = true;
  }

  DailyWisdom? getWisdomForDate(DateTime date) {
    if (_wisdomList.isEmpty) return null;
    final dayIndex =
        (date.year * 365 + date.month * 31 + date.day) % _wisdomList.length;
    return _wisdomList[dayIndex];
  }

  List<SupplicationItem> getSupplicationsByCategory(String category) {
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
