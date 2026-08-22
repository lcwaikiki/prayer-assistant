class DailyWisdom {
  const DailyWisdom({
    required this.id,
    required this.type,
    required this.reference,
    required this.textAr,
    required this.transliteration,
    required this.translations,
  });

  final String id;
  final String type; // 'ayah' or 'hadith'
  final String reference;
  final String textAr;
  final String transliteration;
  final Map<String, String> translations;

  String localizedText(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? textAr;
  }

  factory DailyWisdom.fromJson(Map<String, dynamic> json) {
    final trans = <String, String>{};
    if (json['translations'] is Map) {
      (json['translations'] as Map).forEach((k, v) {
        if (v is String) {
          trans[k.toString()] = v;
        }
      });
    }
    return DailyWisdom(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'ayah',
      reference: json['reference'] as String? ?? '',
      textAr: json['text_ar'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translations: trans,
    );
  }
}

class SupplicationItem {
  const SupplicationItem({
    required this.id,
    required this.category,
    required this.reference,
    required this.targetCount,
    required this.textAr,
    required this.transliteration,
    required this.translations,
  });

  final String id;
  final String category; // 'morning', 'evening', 'after_prayer', 'sleeping', 'daily_life'
  final String reference;
  final int targetCount;
  final String textAr;
  final String transliteration;
  final Map<String, String> translations;

  String localizedText(String languageCode) {
    return translations[languageCode] ?? translations['en'] ?? textAr;
  }

  factory SupplicationItem.fromJson(Map<String, dynamic> json) {
    final trans = <String, String>{};
    if (json['translations'] is Map) {
      (json['translations'] as Map).forEach((k, v) {
        if (v is String) {
          trans[k.toString()] = v;
        }
      });
    }
    return SupplicationItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'daily_life',
      reference: json['reference'] as String? ?? '',
      targetCount: (json['target_count'] as num?)?.toInt() ?? 1,
      textAr: json['text_ar'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      translations: trans,
    );
  }
}
