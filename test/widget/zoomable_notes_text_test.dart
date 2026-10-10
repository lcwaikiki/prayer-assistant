import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/widgets/zoomable_notes_text.dart';

void main() {
  Future<void> pumpNotes(WidgetTester tester, {required bool zoomable}) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 200,
            child: ZoomableNotesText(
              text: 'Read this note',
              style: const TextStyle(fontSize: 14),
              zoomable: zoomable,
            ),
          ),
        ),
      ),
    );
  }

  double fontSize(WidgetTester tester) =>
      tester.widget<SelectableText>(find.byType(SelectableText)).style!.fontSize!;

  Future<void> pinch(WidgetTester tester, double spread) async {
    final center = tester.getCenter(find.byType(ZoomableNotesText));
    final a = await tester.startGesture(center - const Offset(20, 0));
    final b = await tester.startGesture(center + const Offset(20, 0));
    await a.moveBy(Offset(-spread, 0));
    await b.moveBy(Offset(spread, 0));
    await tester.pump();
    await a.up();
    await b.up();
  }

  testWidgets('notes are selectable', (tester) async {
    await pumpNotes(tester, zoomable: true);
    expect(find.byType(SelectableText), findsOneWidget);
  });

  testWidgets('pinching out enlarges the text', (tester) async {
    await pumpNotes(tester, zoomable: true);
    await pinch(tester, 20);
    expect(fontSize(tester), closeTo(28, 0.01));
  });

  testWidgets('pinch is ignored when not zoomable', (tester) async {
    await pumpNotes(tester, zoomable: false);
    await pinch(tester, 20);
    expect(fontSize(tester), 14);
  });
}
