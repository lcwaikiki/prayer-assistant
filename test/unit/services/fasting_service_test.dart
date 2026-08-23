import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prayer_assistant/src/models/fasting_models.dart';

import '../../helpers/test_harness.dart';

void main() {
  group('FastingLog & SunnahDayInfo Unit Tests', () {
    test('FastingLog toMap and fromMap serialization', () {
      const log = FastingLog(
        dateKey: '2026-08-23',
        type: FastingType.ramadan,
        notes: 'First day of Ramadan',
      );

      final map = log.toMap();
      expect(map['dateKey'], '2026-08-23');
      expect(map['type'], 'ramadan');

      final restored = FastingLog.fromMap(map);
      expect(restored.dateKey, '2026-08-23');
      expect(restored.type, FastingType.ramadan);
      expect(restored.notes, 'First day of Ramadan');
    });

    test('SunnahDayInfo detects Monday and Thursday fasts', () {
      final mondayDate = DateTime(2026, 8, 24);
      final info = SunnahDayInfo.checkDate(mondayDate);
      expect(info, isNotNull);
      expect(info!.categories.contains(SunnahCategory.mondayThursday), isTrue);
    });

    test('PrayerAppController toggleFastingLog and removeFastingLog', () async {
      final harness = TestHarness.create();
      when(() => harness.database.loadFastingLogs())
          .thenAnswer((_) async => <String, FastingLog>{});
      when(() => harness.database.saveFastingLogs(any()))
          .thenAnswer((_) async {});

      await harness.initialize();

      final controller = harness.controller;
      final testDate = DateTime(2026, 8, 23);

      expect(controller.getFastingLog(testDate), isNull);

      // Log a Sunnah fast
      controller.toggleFastingLog(testDate, FastingType.sunnah);
      expect(controller.getFastingLog(testDate)?.type, FastingType.sunnah);
      expect(controller.fastingLogs.length, 1);

      // Toggle same type removes it
      controller.toggleFastingLog(testDate, FastingType.sunnah);
      expect(controller.getFastingLog(testDate), isNull);
      expect(controller.fastingLogs.length, 0);

      // Log a Qadaa fast
      controller.toggleFastingLog(testDate, FastingType.qadaa);
      expect(controller.getFastingLog(testDate)?.type, FastingType.qadaa);

      // Remove explicitly
      controller.removeFastingLog(testDate);
      expect(controller.getFastingLog(testDate), isNull);
    });
  });
}
