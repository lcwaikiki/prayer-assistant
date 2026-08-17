import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';

void main() {
  group('LocationNode.fromJson', () {
    test('maps _id, name and name_en', () {
      final node = LocationNode.fromJson(const {
        '_id': '42',
        'name': 'Ankara',
        'name_en': 'Ankara',
      });

      expect(node.id, '42');
      expect(node.name, 'Ankara');
      expect(node.englishName, 'Ankara');
    });

    test('falls back to empty strings for missing fields', () {
      final node = LocationNode.fromJson(const {});

      expect(node.id, '');
      expect(node.name, '');
      expect(node.englishName, '');
    });

    test('coerces non-string values to strings', () {
      final node = LocationNode.fromJson(const {'_id': 7});

      expect(node.id, '7');
    });
  });

  group('SelectedLocation', () {
    test('fullName joins district, state and country', () {
      final location = SelectedLocation(
        countryId: 'tr',
        countryName: 'Turkiye',
        stateId: '34',
        stateName: 'Istanbul',
        districtId: '541',
        districtName: 'Uskudar',
      );

      expect(location.fullName, 'Uskudar, Istanbul, Turkiye');
    });

    test('toJson/fromJson round-trips every field', () {
      final location = SelectedLocation(
        countryId: 'tr',
        countryName: 'Turkiye',
        stateId: '34',
        stateName: 'Istanbul',
        districtId: '541',
        districtName: 'Uskudar',
      );

      final restored = SelectedLocation.fromJson(location.toJson());

      expect(restored.countryId, location.countryId);
      expect(restored.countryName, location.countryName);
      expect(restored.stateId, location.stateId);
      expect(restored.stateName, location.stateName);
      expect(restored.districtId, location.districtId);
      expect(restored.districtName, location.districtName);
    });

    test('tryParse returns null for null/empty input', () {
      expect(SelectedLocation.tryParse(null), isNull);
      expect(SelectedLocation.tryParse(''), isNull);
    });

    test('tryParse returns null when districtId is missing', () {
      expect(
        SelectedLocation.tryParse('{"countryId":"tr"}'),
        isNull,
      );
    });

    test('tryParse returns null for malformed JSON', () {
      expect(SelectedLocation.tryParse('not json'), isNull);
    });

    test('tryParse parses a valid payload', () {
      final location = SelectedLocation.tryParse(
        '{"countryId":"tr","countryName":"Turkiye","stateId":"34",'
        '"stateName":"Istanbul","districtId":"541","districtName":"Uskudar"}',
      );

      expect(location, isNotNull);
      expect(location!.districtId, '541');
    });
  });

  group('PrayerDay', () {
    test('fromApi parses date, times and hijri date', () {
      final day = PrayerDay.fromApi(const {
        'date': '2026-08-17',
        'times': {'imsak': '05:10', 'gunes': '06:42'},
        'hijri_date': {'full_date': '3 Rabi I 1448'},
      });

      expect(day.date, DateTime(2026, 8, 17));
      expect(day.imsak, '05:10');
      expect(day.gunes, '06:42');
      expect(day.ogle, '--:--');
      expect(day.hijriDate, '3 Rabi I 1448');
    });

    test('fromApi defaults missing times to --:--', () {
      final day = PrayerDay.fromApi(const {
        'date': '2026-08-17',
      });

      expect(day.imsak, '--:--');
      expect(day.aksam, '--:--');
      expect(day.yatsi, '--:--');
    });

    test('dateKey formats as yyyy-MM-dd', () {
      final day = PrayerDay(
        date: DateTime(2026, 3, 5),
        hijriDate: '',
        imsak: '05:10',
        gunes: '06:42',
        ogle: '12:35',
        ikindi: '16:10',
        aksam: '18:20',
        yatsi: '19:45',
      );

      expect(day.dateKey, '2026-03-05');
    });

    test('toMap/fromMap round-trips through the stored shape', () {
      final day = PrayerDay(
        date: DateTime(2026, 8, 17),
        hijriDate: '3 Rabi I 1448',
        imsak: '05:10',
        gunes: '06:42',
        ogle: '12:35',
        ikindi: '16:10',
        aksam: '18:20',
        yatsi: '19:45',
      );

      final restored = PrayerDay.fromMap(day.toMap('541'));

      expect(restored.date, day.date);
      expect(restored.hijriDate, day.hijriDate);
      expect(restored.imsak, day.imsak);
      expect(restored.gunes, day.gunes);
      expect(restored.ogle, day.ogle);
      expect(restored.ikindi, day.ikindi);
      expect(restored.aksam, day.aksam);
      expect(restored.yatsi, day.yatsi);
    });

    test('toMap stamps the district id', () {
      final day = PrayerDay(
        date: DateTime(2026, 8, 17),
        hijriDate: '',
        imsak: '05:10',
        gunes: '06:42',
        ogle: '12:35',
        ikindi: '16:10',
        aksam: '18:20',
        yatsi: '19:45',
      );

      expect(day.toMap('541')['district_id'], '541');
    });
  });

  group('ReminderSetting', () {
    test('defaults() has sensible values and everything off', () {
      final setting = ReminderSetting.defaults();

      expect(setting.minutesBefore, 10);
      expect(setting.customMinutesBefore, 10);
      expect(setting.minutesAfter, 10);
      expect(setting.customMinutesAfter, 10);
      expect(setting.notifyOnTime, isFalse);
      expect(setting.notifyBefore, isFalse);
      expect(setting.notifyAfter, isFalse);
      expect(setting.vibrationEnabled, isTrue);
      expect(setting.soundEnabled, isTrue);
    });

    test('toJson/fromJson round-trips every field', () {
      final setting = ReminderSetting(
        minutesBefore: 15,
        customMinutesBefore: 20,
        minutesAfter: 30,
        customMinutesAfter: 25,
        notifyOnTime: true,
        notifyBefore: true,
        notifyAfter: true,
        vibrationEnabled: false,
        soundEnabled: true,
      );

      final restored = ReminderSetting.fromJson(setting.toJson());

      expect(restored.minutesBefore, 15);
      expect(restored.customMinutesBefore, 20);
      expect(restored.minutesAfter, 30);
      expect(restored.customMinutesAfter, 25);
      expect(restored.notifyOnTime, isTrue);
      expect(restored.notifyBefore, isTrue);
      expect(restored.notifyAfter, isTrue);
      expect(restored.vibrationEnabled, isFalse);
      expect(restored.soundEnabled, isTrue);
    });

    test('fromJson(bool) maps the legacy enabled flag to notifyBefore', () {
      final setting = ReminderSetting.fromJson(true);

      expect(setting.notifyBefore, isTrue);
      expect(setting.notifyOnTime, isFalse);
      expect(setting.notifyAfter, isFalse);
      expect(setting.minutesBefore, 10);
      expect(setting.vibrationEnabled, isTrue);
    });

    test('fromJson(bool false) maps to all-off', () {
      final setting = ReminderSetting.fromJson(false);

      expect(setting.notifyBefore, isFalse);
      expect(setting.notifyOnTime, isFalse);
      expect(setting.notifyAfter, isFalse);
    });

    test('fromJson map migrates legacy timing=onTime to notifyOnTime', () {
      final setting = ReminderSetting.fromJson(const {
        'enabled': true,
        'timing': 'onTime',
      });

      expect(setting.notifyOnTime, isTrue);
      expect(setting.notifyBefore, isFalse);
    });

    test('fromJson map migrates legacy timing=before to notifyBefore', () {
      final setting = ReminderSetting.fromJson(const {
        'enabled': true,
        'timing': 'before',
      });

      expect(setting.notifyBefore, isTrue);
      expect(setting.notifyOnTime, isFalse);
    });

    test('fromJson map with unknown values falls back to defaults', () {
      final setting = ReminderSetting.fromJson(const {
        'enabled': true,
        'timing': 'something-else',
      });

      expect(setting.notifyOnTime, isFalse);
      expect(setting.notifyBefore, isTrue);
    });

    test('fromJson map fills missing minute fields with defaults', () {
      final setting = ReminderSetting.fromJson(const {
        'notifyOnTime': true,
        'notifyBefore': true,
        'notifyAfter': true,
      });

      expect(setting.minutesBefore, 10);
      expect(setting.customMinutesBefore, 10);
      expect(setting.minutesAfter, 10);
      expect(setting.customMinutesAfter, 10);
    });

    test('fromJson on non-map/non-bool input returns defaults', () {
      expect(ReminderSetting.fromJson('garbage').notifyBefore, isFalse);
      expect(ReminderSetting.fromJson(42).minutesBefore, 10);
      expect(ReminderSetting.fromJson(null).notifyOnTime, isFalse);
    });

    test('copyWith overrides only the provided fields', () {
      final base = ReminderSetting.defaults();
      final updated = base.copyWith(minutesBefore: 25, notifyAfter: true);

      expect(updated.minutesBefore, 25);
      expect(updated.notifyAfter, isTrue);
      expect(updated.minutesAfter, 10);
      expect(updated.notifyOnTime, isFalse);
    });

    test('ensureCurrent preserves all current fields', () {
      final base = ReminderSetting(
        minutesBefore: 15,
        customMinutesBefore: 20,
        minutesAfter: 30,
        customMinutesAfter: 25,
        notifyOnTime: true,
        notifyBefore: true,
        notifyAfter: true,
        vibrationEnabled: false,
        soundEnabled: true,
      );

      final current = ReminderSetting.ensureCurrent(base);

      expect(current.customMinutesBefore, 20);
      expect(current.customMinutesAfter, 25);
      expect(current.notifyAfter, isTrue);
      expect(current.vibrationEnabled, isFalse);
      expect(current.soundEnabled, isTrue);
      expect(current.minutesBefore, 15);
    });
  });
}