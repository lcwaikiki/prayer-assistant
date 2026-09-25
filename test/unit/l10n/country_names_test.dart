import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/l10n/country_names.dart';

void main() {
  group('localizedCountryName', () {
    test('translates Turkish API names into English', () {
      expect(localizedCountryName('ALMANYA', 'en'), 'Germany');
      expect(localizedCountryName('MISIR', 'en'), 'Egypt');
      expect(localizedCountryName('FRANSA', 'en'), 'France');
    });

    test('translates into the app languages', () {
      // Spot-check a locale from each script family.
      expect(localizedCountryName('ALMANYA', 'tr'), 'Almanya');
      expect(localizedCountryName('ALMANYA', 'id'), 'Jerman');
      expect(localizedCountryName('ALMANYA', 'ru'), 'Германия');
      expect(localizedCountryName('MISIR', 'ar'), 'مصر');
      expect(localizedCountryName('ALMANYA', 'zh'), '德国');
      expect(localizedCountryName('ALMANYA', 'ja'), 'ドイツ');
      expect(localizedCountryName('ALMANYA', 'fa'), 'آلمان');
      expect(localizedCountryName('ALMANYA', 'bn'), 'জার্মানি');
      expect(localizedCountryName('TURKIYE', 'bn'), 'তুরস্ক');
      expect(localizedCountryName('ALMANYA', 'ta'), 'ஜெர்மனி');
      expect(localizedCountryName('TURKIYE', 'ta'), 'துருக்கியே');
    });

    test('is case-insensitive on the API name', () {
      expect(localizedCountryName('almanya', 'en'), 'Germany');
    });

    test('falls back to the original name when unknown', () {
      expect(localizedCountryName('ATLANTIK OKYANUSU', 'en'), 'ATLANTIK OKYANUSU');
    });

    test('falls back to English for an unsupported locale code', () {
      expect(localizedCountryName('ALMANYA', 'xx'), 'Germany');
    });
  });
}
