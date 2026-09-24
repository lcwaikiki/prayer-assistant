import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/supplications/models/supplication_models.dart';
import 'package:prayer_assistant/src/supplications/widgets/daily_wisdom_card.dart';

import '../helpers/test_app.dart';

void main() {
  const wisdom = DailyWisdom(
    id: 'w1',
    type: 'hadith',
    reference: 'Sahih Bukhari 1:1',
    textAr: 'Actions are by intentions.',
    transliteration: 'Innamal amalu bin niyyat',
    translations: {'en': 'Actions are judged by intentions.'},
  );

  List<MethodCall> captureClipboard(WidgetTester tester) {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        calls.add(call);
        return null;
      },
    );
    return calls;
  }

  testWidgets('copying includes the transliteration', (tester) async {
    final calls = captureClipboard(tester);
    await pumpLocalized(
      tester,
      const Scaffold(body: DailyWisdomCard(wisdom: wisdom)),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    final setData = calls.firstWhere((c) => c.method == 'Clipboard.setData');
    final text = (setData.arguments as Map)['text'] as String;

    expect(
      text,
      'Actions are by intentions.\n\nInnamal amalu bin niyyat\n\n'
      'Actions are judged by intentions.\n— Sahih Bukhari 1:1',
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('copying omits an empty transliteration', (tester) async {
    final calls = captureClipboard(tester);
    await pumpLocalized(
      tester,
      const Scaffold(
        body: DailyWisdomCard(
          wisdom: DailyWisdom(
            id: 'w2',
            type: 'ayah',
            reference: 'Surah Al-Baqarah 2:255',
            textAr: 'Allahu la ilaha illa huwa',
            transliteration: '',
            translations: {'en': 'Allah, there is no deity except Him.'},
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.copy_rounded));
    await tester.pump();

    final setData = calls.firstWhere((c) => c.method == 'Clipboard.setData');
    final text = (setData.arguments as Map)['text'] as String;

    expect(
      text,
      'Allahu la ilaha illa huwa\n\n'
      'Allah, there is no deity except Him.\n— Surah Al-Baqarah 2:255',
    );

    await tester.pumpWidget(const SizedBox());
  });
}
