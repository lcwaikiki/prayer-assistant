import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/widgets/truncated_title_tooltip.dart';

void main() {
  testWidgets('renders short title normally without triggering tooltip on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: TruncatedTitleTooltip(title: 'Short Title'),
          ),
        ),
      ),
    );

    expect(find.text('Short Title'), findsOneWidget);
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('shows tooltip on tap when title overflows constraints', (
    tester,
  ) async {
    const longTitle =
        'Very Long Bead Title That Definitively Exceeds Small Available Screen Width';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 100,
            child: TruncatedTitleTooltip(title: longTitle),
          ),
        ),
      ),
    );

    expect(find.byType(Tooltip), findsOneWidget);

    // Tap on the text
    await tester.tap(find.text(longTitle));
    await tester.pump();

    // Verify tooltip balloon appears
    expect(find.byType(Tooltip), findsOneWidget);
  });

  testWidgets('renders badge alongside title when provided', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: TruncatedTitleTooltip(
              title: 'Group Title',
              badge: Text('GROUP'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Group Title'), findsOneWidget);
    expect(find.text('GROUP'), findsOneWidget);
  });
}
