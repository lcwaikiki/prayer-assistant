import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/services/notification_strings.dart';

void main() {
  group('NotificationStrings localization', () {
    test('provides Turkish strings when locale is tr', () {
      final strings = NotificationStrings.of(const Locale('tr'));
      expect(strings.onTimeTitle('İmsak'), 'İmsak vakti');
      expect(
        strings.onTimeBody('İstanbul', 'İmsak'),
        'İstanbul - İmsak namazı vakti geldi.',
      );
      expect(strings.beforeTitle('Öğle', 15), 'Öğle vaktine 15 dk');
      expect(
        strings.beforeBody('İstanbul', 'Öğle', '13:12'),
        'İstanbul - Öğle vakti: 13:12.',
      );
      expect(strings.soonTitle('İkindi'), 'İkindi yakında');
      expect(
        strings.soonBody('İstanbul', 'İkindi', '16:45'),
        'İstanbul - İkindi vakti: 16:45.',
      );
      expect(strings.afterTitle('Akşam', 20), 'Akşam +20 dk');
      expect(strings.afterBody('İstanbul', 'Akşam', 20),
          'İstanbul - Akşam vaktinden bu yana 20 dk geçti.');
      expect(strings.testTitle, 'Prayer Assist testi');
      expect(strings.dhikrBody('Sübhanallah'), 'Sübhanallah zikri vakti geldi.');
    });

    test('provides English strings when locale is en or unknown', () {
      final strings = NotificationStrings.of(const Locale('en'));
      expect(strings.onTimeTitle('Fajr'), 'Fajr time');
      expect(
        strings.onTimeBody('London', 'Fajr'),
        'London - It is time for Fajr prayer.',
      );
      expect(strings.beforeTitle('Dhuhr', 10), 'Dhuhr in 10 min');
      expect(
        strings.beforeBody('London', 'Dhuhr', '13:00'),
        'London - Dhuhr is at 13:00.',
      );
      expect(strings.soonTitle('Asr'), 'Asr soon');
      expect(strings.afterTitle('Maghrib', 15), 'Maghrib +15 min');
      expect(
        strings.afterBody('London', 'Maghrib', 15),
        'London - It has been 15 min since Maghrib.',
      );
      expect(strings.testTitle, 'Prayer Assist test');
      expect(strings.dhikrBody('SubhanAllah'), 'Time for your SubhanAllah dhikr.');

      final unknownStrings = NotificationStrings.of(const Locale('xx'));
      expect(unknownStrings.onTimeTitle('Fajr'), 'Fajr time');
      expect(unknownStrings.dhikrBody('SubhanAllah'), 'Time for your SubhanAllah dhikr.');
    });

    test('provides Arabic strings when locale is ar', () {
      final strings = NotificationStrings.of(const Locale('ar'));
      expect(strings.onTimeTitle('الفجر'), 'وقت صلاة الفجر');
      expect(
        strings.onTimeBody('مكة', 'الفجر'),
        'مكة - حان الآن موعد صلاة الفجر.',
      );
      expect(strings.beforeTitle('الظهر', 15), 'صلاة الظهر خلال 15 دقيقة');
      expect(strings.testTitle, 'اختبار مساعد الصلاة');
      expect(strings.dhikrBody('سبحان الله'), 'حان وقت ذكر سبحان الله.');
    });

    test('supports all 12 languages without throwing', () {
      const languages = [
        'tr',
        'en',
        'ar',
        'es',
        'fr',
        'de',
        'ru',
        'fa',
        'ur',
        'id',
        'zh',
        'ja',
      ];
      for (final lang in languages) {
        final strings = NotificationStrings.of(Locale(lang));
        expect(strings.onTimeTitle('Prayer'), isNotEmpty);
        expect(strings.onTimeBody('City', 'Prayer'), isNotEmpty);
        expect(strings.beforeTitle('Prayer', 10), isNotEmpty);
        expect(strings.beforeBody('City', 'Prayer', '12:00'), isNotEmpty);
        expect(strings.soonTitle('Prayer'), isNotEmpty);
        expect(strings.soonBody('City', 'Prayer', '12:00'), isNotEmpty);
        expect(strings.afterTitle('Prayer', 10), isNotEmpty);
        expect(strings.afterBody('City', 'Prayer', 10), isNotEmpty);
        expect(strings.testTitle, isNotEmpty);
        expect(strings.testBody, isNotEmpty);
        expect(strings.dhikrBody('Tasbih'), isNotEmpty);
      }
    });
  });
}
