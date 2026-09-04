import 'package:flutter/material.dart';

class _DiscardDialogStrings {
  const _DiscardDialogStrings({
    required this.title,
    required this.content,
    required this.cancel,
    required this.discard,
  });

  final String title;
  final String content;
  final String cancel;
  final String discard;

  static const Map<String, _DiscardDialogStrings> _byLang = {
    'tr': _DiscardDialogStrings(
      title: 'Değişiklikler iptal edilsin mi?',
      content:
          'Kaydedilmemiş değişiklikleriniz var. İptal etmek istediğinizden emin misiniz?',
      cancel: 'Düzenlemeye Devam Et',
      discard: 'İptal Et',
    ),
    'en': _DiscardDialogStrings(
      title: 'Discard changes?',
      content:
          'You have unsaved changes. Are you sure you want to discard them?',
      cancel: 'Keep Editing',
      discard: 'Discard',
    ),
    'ar': _DiscardDialogStrings(
      title: 'تجاهل التغييرات؟',
      content:
          'لديك تغييرات غير محفوظة. هل أنت تأكد من أنك تريد تجاهلها؟',
      cancel: 'متابعة التعديل',
      discard: 'تجاهل',
    ),
    'de': _DiscardDialogStrings(
      title: 'Änderungen verwerfen?',
      content:
          'Sie haben ungespeicherte Änderungen. Möchten Sie diese wirklich verwerfen?',
      cancel: 'Weiter bearbeiten',
      discard: 'Verwerfen',
    ),
    'es': _DiscardDialogStrings(
      title: '¿Descartar cambios?',
      content:
          'Tienes cambios sin guardar. ¿Estás seguro de que quieres descartarlos?',
      cancel: 'Seguir editando',
      discard: 'Descartar',
    ),
    'fa': _DiscardDialogStrings(
      title: 'لغو تغییرات؟',
      content:
          'تغییرات ذخیره‌نشده دارید. آیا مطمئن هستید که می‌خواهید آنها را لغو کنید؟',
      cancel: 'ادامه ویرایش',
      discard: 'لغو تغییرات',
    ),
    'fr': _DiscardDialogStrings(
      title: 'Abandonner les modifications ?',
      content:
          'Vous avez des modifications non enregistrées. Voulez-vous vraiment les abandonner ?',
      cancel: 'Continuer l\'édition',
      discard: 'Abandonner',
    ),
    'id': _DiscardDialogStrings(
      title: 'Buang perubahan?',
      content:
          'Anda memiliki perubahan yang belum disimpan. Yakin ingin membuangnya?',
      cancel: 'Lanjutkan Mengedit',
      discard: 'Buang',
    ),
    'ja': _DiscardDialogStrings(
      title: '変更を破棄しますか？',
      content: '保存されていない変更があります。破棄してもよろしいですか？',
      cancel: '編集を続ける',
      discard: '破棄',
    ),
    'ru': _DiscardDialogStrings(
      title: 'Сбросить изменения?',
      content:
          'У вас есть несохраненные изменения. Вы уверены, что хотите сбросить их?',
      cancel: 'Продолжить',
      discard: 'Сбросить',
    ),
    'ur': _DiscardDialogStrings(
      title: 'تبدیلیاں منسوخ کریں؟',
      content:
          'آپ کی غیر محفوظ شدہ تبدیلیاں ہیں۔ کیا آپ واقعی انہیں منسوخ کرنا چاہتے ہیں؟',
      cancel: 'ترمیم جاری رکھیں',
      discard: 'منسوخ کریں',
    ),
    'zh': _DiscardDialogStrings(
      title: '放弃更改？',
      content: '您有未保存的更改。确定要放弃吗？',
      cancel: '继续编辑',
      discard: '放弃',
    ),
  };

  static _DiscardDialogStrings of(String languageCode) {
    return _byLang[languageCode.toLowerCase()] ?? _byLang['en']!;
  }
}

/// Displays a confirmation dialog asking the user if they want to discard unsaved changes.
/// Returns `true` if the user confirmed discarding changes, or `false`/`null` if cancelled.
Future<bool?> showDiscardConfirmationDialog(BuildContext context) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final strings = _DiscardDialogStrings.of(languageCode);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(strings.title),
      content: Text(strings.content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(strings.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(strings.discard),
        ),
      ],
    ),
  );
}
