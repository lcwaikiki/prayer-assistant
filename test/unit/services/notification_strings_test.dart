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

    test('provides Bengali strings when locale is bn', () {
      final strings = NotificationStrings.of(const Locale('bn'));
      expect(strings.onTimeTitle('ফজর'), 'ফজর-এর সময়');
      expect(
        strings.onTimeBody('ঢাকা', 'ফজর'),
        'ঢাকা - ফজর নামাজের সময় হয়েছে।',
      );
      expect(strings.beforeTitle('যোহর', 15), '15 মিনিট পর যোহর');
      expect(
        strings.beforeBody('ঢাকা', 'যোহর', '12:30'),
        'ঢাকা - যোহর ওয়াক্ত শুরু হবে 12:30-এ।',
      );
      expect(strings.testTitle, 'Prayer Assist পরীক্ষা');
      expect(strings.dhikrBody('সুবহানাল্লাহ'), 'আপনার সুবহানাল্লাহ জিকিরের সময় হয়েছে।');
    });

    test('provides Tamil strings when locale is ta', () {
      final strings = NotificationStrings.of(const Locale('ta'));
      expect(strings.onTimeTitle('ஃபஜ்ர்'), 'ஃபஜ்ர் நேரம்');
      expect(
        strings.onTimeBody('சென்னை', 'ஃபஜ்ர்'),
        'சென்னை - ஃபஜ்ர் தொழுகைக்கான நேரம் வந்துவிட்டது.',
      );
      expect(strings.beforeTitle('ளுஹர்', 15), '15 நிமிடத்தில் ளுஹர்');
      expect(
        strings.beforeBody('சென்னை', 'ளுஹர்', '12:30'),
        'சென்னை - ளுஹர் நேரம்: 12:30.',
      );
      expect(strings.testTitle, 'Prayer Assist சோதனை');
      expect(strings.dhikrBody('சுப்ஹானல்லாஹ்'), 'உங்கள் சுப்ஹானல்லாஹ் திக்ருக்கான நேரம்.');
    });

    test('supports all 14 languages without throwing', () {
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
        'bn',
        'ta',
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
