import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_assistant/src/tesbihat/l10n/tesbihat_localizations.dart';

void main() {
  group('TesbihatLocalizations refactor tests', () {
    test('resolves English correctly', () {
      final l10n = TesbihatLocalizations(const Locale('en'));
      expect(l10n.appTitle, 'Beads Counter');
      expect(l10n.milestones, 'Beads');
      expect(l10n.tap, 'TAP');
      expect(l10n.save, 'Save');
      expect(l10n.cancel, 'Cancel');
      expect(l10n.selectedCount(5), '5 selected');
      expect(l10n.progressBetween(33), 'Progress must be between 0 and 33');
      expect(l10n.deleteSelectedConfirm(3), 'Delete 3 selected items?');
      expect(l10n.deletedSelected(3), '3 deleted');
      expect(l10n.deletedItem('Subhanallah'), '"Subhanallah" deleted');
      expect(l10n.requiredField('Title'), 'Title is required');
      expect(l10n.fieldMustBeInteger('Count'), 'Count must be an integer');
    });

    test('resolves Turkish correctly', () {
      final l10n = TesbihatLocalizations(const Locale('tr'));
      expect(l10n.appTitle, 'Tesbih Sayacı');
      expect(l10n.milestones, 'Tesbih');
      expect(l10n.tap, 'DOKUN');
      expect(l10n.save, 'Kaydet');
      expect(l10n.cancel, 'İptal');
      expect(l10n.selectedCount(4), '4 seçili');
      expect(l10n.deletedItem('Sübhanallah'), '"Sübhanallah" silindi');
    });

    test('resolves Arabic correctly', () {
      final l10n = TesbihatLocalizations(const Locale('ar'));
      expect(l10n.appTitle, 'عداد المسبحة');
      expect(l10n.save, 'حفظ');
    });

    test('resolves Indonesian correctly', () {
      final l10n = TesbihatLocalizations(const Locale('id'));
      expect(l10n.appTitle, 'Penghitung Tasbih');
      expect(l10n.milestones, 'Tasbih');
      expect(l10n.save, 'Simpan');
      expect(l10n.selectedCount(2), '2 dipilih');
    });

    test('falls back gracefully on unknown locale', () {
      final l10n = TesbihatLocalizations(const Locale('xx'));
      expect(l10n.appTitle, 'Beads Counter');
      expect(l10n.save, 'Save');
    });
  });
}
