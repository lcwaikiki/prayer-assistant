import 'dart:convert';

import 'package:intl/intl.dart';

class LocationNode {
  LocationNode({
    required this.id,
    required this.name,
    required this.englishName,
  });

  final String id;
  final String name;
  final String englishName;

  factory LocationNode.fromJson(Map<String, dynamic> json) {
    return LocationNode(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      englishName: (json['name_en'] ?? '').toString(),
    );
  }
}

class SelectedLocation {
  SelectedLocation({
    required this.countryId,
    required this.countryName,
    required this.stateId,
    required this.stateName,
    required this.districtId,
    required this.districtName,
  });

  final String countryId;
  final String countryName;
  final String stateId;
  final String stateName;
  final String districtId;
  final String districtName;

  String get fullName => '$districtName, $stateName, $countryName';

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'countryName': countryName,
      'stateId': stateId,
      'stateName': stateName,
      'districtId': districtId,
      'districtName': districtName,
    };
  }

  factory SelectedLocation.fromJson(Map<String, dynamic> json) {
    return SelectedLocation(
      countryId: (json['countryId'] ?? '').toString(),
      countryName: (json['countryName'] ?? '').toString(),
      stateId: (json['stateId'] ?? '').toString(),
      stateName: (json['stateName'] ?? '').toString(),
      districtId: (json['districtId'] ?? '').toString(),
      districtName: (json['districtName'] ?? '').toString(),
    );
  }

  static SelectedLocation? tryParse(String? rawJson) {
    if (rawJson == null || rawJson.isEmpty) {
      return null;
    }
    try {
      final map = jsonDecode(rawJson) as Map<String, dynamic>;
      final location = SelectedLocation.fromJson(map);
      if (location.districtId.isEmpty) {
        return null;
      }
      return location;
    } catch (_) {
      return null;
    }
  }
}

class PrayerDay {
  PrayerDay({
    required this.date,
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  final DateTime date;
  final String imsak;
  final String gunes;
  final String ogle;
  final String ikindi;
  final String aksam;
  final String yatsi;

  String get dateKey => DateFormat('yyyy-MM-dd').format(date);

  factory PrayerDay.fromApi(Map<String, dynamic> json) {
    final times =
        (json['times'] as Map<String, dynamic>? ?? <String, dynamic>{});
    return PrayerDay(
      date: DateTime.parse((json['date'] ?? '').toString()).toLocal(),
      imsak: (times['imsak'] ?? '--:--').toString(),
      gunes: (times['gunes'] ?? '--:--').toString(),
      ogle: (times['ogle'] ?? '--:--').toString(),
      ikindi: (times['ikindi'] ?? '--:--').toString(),
      aksam: (times['aksam'] ?? '--:--').toString(),
      yatsi: (times['yatsi'] ?? '--:--').toString(),
    );
  }

  Map<String, Object?> toMap(String districtId) {
    return {
      'district_id': districtId,
      'date': dateKey,
      'imsak': imsak,
      'gunes': gunes,
      'ogle': ogle,
      'ikindi': ikindi,
      'aksam': aksam,
      'yatsi': yatsi,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory PrayerDay.fromMap(Map<String, Object?> map) {
    return PrayerDay(
      date: DateTime.parse((map['date'] ?? '').toString()),
      imsak: (map['imsak'] ?? '--:--').toString(),
      gunes: (map['gunes'] ?? '--:--').toString(),
      ogle: (map['ogle'] ?? '--:--').toString(),
      ikindi: (map['ikindi'] ?? '--:--').toString(),
      aksam: (map['aksam'] ?? '--:--').toString(),
      yatsi: (map['yatsi'] ?? '--:--').toString(),
    );
  }
}

class NextPrayerInfo {
  NextPrayerInfo({
    required this.name,
    required this.time,
    required this.remaining,
  });

  final String name;
  final DateTime time;
  final Duration remaining;
}
