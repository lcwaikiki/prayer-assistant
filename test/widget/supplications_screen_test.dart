import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/supplications/models/supplication_models.dart';
import 'package:prayer_assistant/src/supplications/screens/supplications_screen.dart';
import 'package:prayer_assistant/src/supplications/services/wisdom_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const dummyItem1 = SupplicationItem(
    id: 'supp_1',
    category: 'morning',
    reference: 'Ref 1',
    targetCount: 3,
    textAr: 'سبحان الله',
    transliteration: 'Subhanallah',
    translations: {'en': 'Glory be to Allah'},
  );

  const dummyItem2 = SupplicationItem(
    id: 'supp_2',
    category: 'evening',
    reference: 'Ref 2',
    targetCount: 1,
    textAr: 'الحمد لله',
    transliteration: 'Alhamdulillah',
    translations: {'en': 'Praise be to Allah'},
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    WisdomService.instance.setSupplicationsForTesting([dummyItem1, dummyItem2]);
    WisdomService.instance.setFavoritesForTesting([]);
  });

  testWidgets('SupplicationsScreen displays Favorites tab at the beginning and handles toggling',
      (tester) async {
    await pumpLocalized(tester, const SupplicationsScreen());
    await tester.pumpAndSettle();

    // Verify Favorites chip exists
    expect(find.text('Favorites'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);

    // Initial state: 2 cards in "All" view
    expect(find.text('Glory be to Allah'), findsOneWidget);
    expect(find.text('Praise be to Allah'), findsOneWidget);

    // Toggle favorite on first card
    final favoriteButtons = find.byTooltip('Favorites');
    expect(favoriteButtons, findsWidgets);
    await tester.tap(favoriteButtons.first);
    await tester.pumpAndSettle();

    expect(WisdomService.instance.isFavorite('supp_1'), isTrue);

    // Switch to Favorites tab
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    // Only favorited item is shown
    expect(find.text('Glory be to Allah'), findsOneWidget);
    expect(find.text('Praise be to Allah'), findsNothing);

    // Unfavorite it
    await tester.tap(find.byTooltip('Favorites').first);
    await tester.pumpAndSettle();

    expect(WisdomService.instance.isFavorite('supp_1'), isFalse);
    expect(find.text('No favorite supplications yet'), findsOneWidget);
  });
}
