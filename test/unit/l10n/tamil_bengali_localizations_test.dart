import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/l10n/app_localizations.dart';
import 'package:prayer_assistant/src/calendar/hijri_utils.dart';
import 'package:prayer_assistant/src/l10n/country_names.dart';
import 'package:prayer_assistant/src/l10n/locale_options.dart';
import 'package:prayer_assistant/src/l10n/prayer_names.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/services/notification_strings.dart';
import 'package:prayer_assistant/src/tesbihat/l10n/tesbihat_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tamil and Bengali localization support', () {
    test('AppLocalePreference contains bn and ta with correct labels', () {
      expect(AppLocalePreference.bn.name, 'bn');
      expect(AppLocalePreference.ta.name, 'ta');
      expect(AppLocalePreference.bn.nativeLabel('System'), 'বাংলা');
      expect(AppLocalePreference.ta.nativeLabel('System'), 'தமிழ்');
      expect(AppLocalePreference.bn.locale, const Locale('bn'));
      expect(AppLocalePreference.ta.locale, const Locale('ta'));
    });

    test('supportedAppLocales contains bn and ta', () {
      expect(supportedAppLocales.contains(const Locale('bn')), isTrue);
      expect(supportedAppLocales.contains(const Locale('ta')), isTrue);
    });

    test('AppLocalizations supports bn', () {
      final l10n = lookupAppLocalizations(const Locale('bn'));
      expect(l10n.appTitle, 'নামাজ সহায়ক');
      expect(l10n.tabLocation, 'অবস্থান');
      expect(l10n.tabToday, 'আজ');
      expect(l10n.tabDates, 'তারিখ');
      expect(l10n.tabTesbih, 'তসবীহ');
      expect(l10n.imsak, 'ফজর');
      expect(l10n.ogle, 'যোহর');
      expect(l10n.ikindi, 'আসর');
      expect(l10n.aksam, 'মাগরিব');
      expect(l10n.yatsi, 'ইশা');
      expect(l10n.remainingMinutesValue('15'), '15 মিনিট');
    });

    test('AppLocalizations supports ta', () {
      final l10n = lookupAppLocalizations(const Locale('ta'));
      expect(l10n.appTitle, 'தொழுகை உதவியாளர்');
      expect(l10n.tabLocation, 'இடம்');
      expect(l10n.tabToday, 'இன்று');
      expect(l10n.tabDates, 'தேதிகள்');
      expect(l10n.tabTesbih, 'மணிகள்');
      expect(l10n.imsak, 'ஃபஜ்ர்');
      expect(l10n.ogle, 'ளுஹர்');
      expect(l10n.ikindi, 'அஸ்ர்');
      expect(l10n.aksam, 'மஃக்ரிப்');
      expect(l10n.yatsi, 'இஷா');
      expect(l10n.remainingMinutesValue('15'), '15 நிமி');
    });

    test('TesbihatLocalizations supports bn and ta', () {
      final l10nBn = TesbihatLocalizations(const Locale('bn'));
      expect(l10nBn.appTitle, 'তসবীহ গণক');
      expect(l10nBn.milestones, 'তসবীহ');
      expect(l10nBn.tap, 'ট্যাপ');
      expect(l10nBn.save, 'সংরক্ষণ');

      final l10nTa = TesbihatLocalizations(const Locale('ta'));
      expect(l10nTa.appTitle, 'தஸ்பீஹ் கவுண்டர்');
      expect(l10nTa.milestones, 'மணிகள்');
      expect(l10nTa.tap, 'தட்டு');
      expect(l10nTa.save, 'சேமி');
    });

    test('NotificationStrings supports bn and ta', () {
      final bn = NotificationStrings.of(const Locale('bn'));
      expect(bn.onTimeTitle('ফজর'), 'ফজর-এর সময়');
      expect(bn.testTitle, 'Prayer Assist পরীক্ষা');

      final ta = NotificationStrings.of(const Locale('ta'));
      expect(ta.onTimeTitle('ஃபஜ்ர்'), 'ஃபஜ்ர் நேரம்');
      expect(ta.testTitle, 'Prayer Assist சோதனை');
    });

    test('Hijri calendar month names format in bn and ta', () {
      // 2026-08-17 is 4 Rabi' Al-Awwal 1448
      final date = DateTime(2026, 8, 17);
      final bnFormatted = formatHijriDate(date, 'bn');
      expect(bnFormatted, contains('রবিউল আউয়াল'));

      final taFormatted = formatHijriDate(date, 'ta');
      expect(taFormatted, contains('ரபீஉல் அவ்வல்'));
    });

    test('iconForPrayer matches Bengali and Tamil prayer names', () {
      expect(iconForPrayer('ফজর'), Icons.wb_twilight);
      expect(iconForPrayer('সূর্যোদয়'), Icons.wb_sunny_outlined);
      expect(iconForPrayer('যোহর'), Icons.wb_sunny);
      expect(iconForPrayer('আসর'), Icons.wb_twilight_outlined);
      expect(iconForPrayer('মাগরিব'), Icons.nights_stay_outlined);
      expect(iconForPrayer('ইশা'), Icons.nights_stay);
      expect(iconForPrayer('বিতর'), Icons.star_outline);

      expect(iconForPrayer('ஃபஜ்ர்'), Icons.wb_twilight);
      expect(iconForPrayer('சூரியோதயம்'), Icons.wb_sunny_outlined);
      expect(iconForPrayer('ளுஹர்'), Icons.wb_sunny);
      expect(iconForPrayer('அஸ்ர்'), Icons.wb_twilight_outlined);
      expect(iconForPrayer('மஃக்ரிப்'), Icons.nights_stay_outlined);
      expect(iconForPrayer('இஷா'), Icons.nights_stay);
      expect(iconForPrayer('வித்ர்'), Icons.star_outline);
    });

    test('daily_wisdom.json contains bn and ta for all items', () async {
      final raw = await rootBundle.loadString('assets/data/daily_wisdom.json');
      final list = jsonDecode(raw) as List<dynamic>;
      expect(list.length, 300);
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final trans = map['translations'] as Map<String, dynamic>;
        expect(trans['bn'], isNotNull, reason: 'Missing bn in ${map['id']}');
        expect(trans['bn'], isNotEmpty, reason: 'Empty bn in ${map['id']}');
        expect(trans['ta'], isNotNull, reason: 'Missing ta in ${map['id']}');
        expect(trans['ta'], isNotEmpty, reason: 'Empty ta in ${map['id']}');
      }
    });

    test('supplications.json contains bn and ta for all items', () async {
      final raw = await rootBundle.loadString('assets/data/supplications.json');
      final list = jsonDecode(raw) as List<dynamic>;
      expect(list.length, 300);
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        final trans = map['translations'] as Map<String, dynamic>;
        expect(trans['bn'], isNotNull, reason: 'Missing bn in ${map['id']}');
        expect(trans['bn'], isNotEmpty, reason: 'Empty bn in ${map['id']}');
        expect(trans['ta'], isNotNull, reason: 'Missing ta in ${map['id']}');
        expect(trans['ta'], isNotEmpty, reason: 'Empty ta in ${map['id']}');
      }
    });

    test('localizedCountryName supports bn and ta', () {
      expect(localizedCountryName('TURKIYE', 'bn'), 'তুরস্ক');
      expect(localizedCountryName('BANGLADES', 'bn'), 'বাংলাদেশ');
      expect(localizedCountryName('TURKIYE', 'ta'), 'துருக்கியே');
      expect(localizedCountryName('HINDISTAN', 'ta'), 'இந்தியா');
    });
  });
}
