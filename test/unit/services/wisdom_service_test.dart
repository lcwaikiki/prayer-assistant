import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/supplications/models/supplication_models.dart';
import 'package:prayer_assistant/src/supplications/services/wisdom_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('WisdomService Favorites Persistence', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'hisn_favorite_ids': ['supp_1'],
      });
      WisdomService.instance.setSupplicationsForTesting([dummyItem1, dummyItem2]);
      WisdomService.instance.setFavoritesForTesting(['supp_1']);
    });

    test('isFavorite checks whether item id is in favorites', () {
      expect(WisdomService.instance.isFavorite('supp_1'), isTrue);
      expect(WisdomService.instance.isFavorite('supp_2'), isFalse);
    });

    test('getSupplicationsByCategory(favorites) returns only favorited items', () {
      final favs = WisdomService.instance.getSupplicationsByCategory('favorites');
      expect(favs.length, 1);
      expect(favs.first.id, 'supp_1');
    });

    test('toggleFavorite updates favorite state and persists to SharedPreferences', () async {
      await WisdomService.instance.toggleFavorite('supp_2');
      expect(WisdomService.instance.isFavorite('supp_2'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('hisn_favorite_ids');
      expect(stored, containsAll(['supp_1', 'supp_2']));

      await WisdomService.instance.toggleFavorite('supp_1');
      expect(WisdomService.instance.isFavorite('supp_1'), isFalse);

      final storedAfterRemove = prefs.getStringList('hisn_favorite_ids');
      expect(storedAfterRemove, contains('supp_2'));
      expect(storedAfterRemove, isNot(contains('supp_1')));
    });
  });
}
