// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Namaz Asistanı';

  @override
  String get tabLocation => 'Konum';

  @override
  String get tabToday => 'Bugün';

  @override
  String get tabDates => 'Tarih';

  @override
  String get tooltipToggleLightDark => 'Açık/Koyu değiştir';

  @override
  String get tooltipRemindersOn => 'Hatırlatıcıları aç';

  @override
  String get tooltipRemindersOff => 'Hatırlatıcıları kapat';

  @override
  String get tooltipPreferences => 'Tercihler';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes dk';
  }

  @override
  String get remainingMinutesUnknown => '-- dk';

  @override
  String get homeNoLocationTitle => 'Konum seçilmedi';

  @override
  String get homeNoLocationSubtitle =>
      'Konum sekmesine gidip önce ilçenizi kaydedin.';

  @override
  String get homeNoPrayerTimesTitle => 'Önbellekte namaz vakti yok';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Yıllık veriyi eşitlemek için yenileyin.';

  @override
  String get refresh => 'Yenile';

  @override
  String todayWithDate(Object date) {
    return 'Bugün • $date';
  }

  @override
  String get hijriUnknown => 'Hicri: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hicri: $date';
  }

  @override
  String get reminderSettingsTitle => 'Hatırlatıcı ayarları';

  @override
  String get reminderSettingsSubtitle =>
      'Hatırlatıcı ve dakika ayarları için yukarıdaki vakitlerden birine dokunun.';

  @override
  String get tooltipScheduledDebug => 'Zamanlanmış hatırlatıcı hata ayıklama';

  @override
  String get scheduledRemindersDebugTitle =>
      'Zamanlanmış Hatırlatıcılar (Debug)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Bekleyen bildirim: $count';
  }

  @override
  String get sendTestNotificationNow => 'Test bildirimi gönder';

  @override
  String get testNotificationSent => 'Test bildirimi gönderildi.';

  @override
  String get statusBarMinutesTitle => 'Durum çubuğu dakikaları';

  @override
  String get statusBarMinutesSubtitle =>
      'Durum çubuğunda kalan dakika bildirimini göster.';

  @override
  String get statusAutoRestoreTitle => 'Silinince geri yükle';

  @override
  String get statusAutoRestoreSubtitle =>
      'Kullanıcı kapatırsa durum öğesini yeniden oluştur.';

  @override
  String get noPendingReminders => 'Bekleyen hatırlatıcı yok.';

  @override
  String get unknownFireTime => 'Bilinmeyen zaman';

  @override
  String get pastPrefix => '[GEÇMİŞ] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Açık • Vaktinde + $minutes dk önce';
  }

  @override
  String get reminderOnTimeOnly => 'Açık • Vaktinde';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Açık • $minutes dk önce';
  }

  @override
  String get reminderOff => 'Hatırlatıcı kapalı';

  @override
  String get nextPrayerTitle => 'Sıradaki Vakit';

  @override
  String startsIn(Object remaining) {
    return '$remaining sonra başlar';
  }

  @override
  String get selectYourLocation => 'Konumunuzu seçin';

  @override
  String get locationHelp =>
      'Hızlı kurulum için GPS kullanın veya ülke/şehir seçimini manuel yapın.';

  @override
  String get useCurrentLocation => 'Mevcut konumu kullan';

  @override
  String get country => 'Ülke';

  @override
  String get stateCity => 'İl / Şehir';

  @override
  String get district => 'İlçe';

  @override
  String get saveLocation => 'Konumu kaydet';

  @override
  String selectedLocation(Object location) {
    return 'Seçilen: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1 yıllık namaz listesini görmek için önce konum seçin.';

  @override
  String get historyTableTitle => 'Namaz Vakitleri Tablosu (Tam Yıl)';

  @override
  String get todayShort => 'Bugün';

  @override
  String get dateHeader => 'Tarih';

  @override
  String get imsak => 'İmsak';

  @override
  String get gunes => 'Güneş';

  @override
  String get ogle => 'Öğle';

  @override
  String get ikindi => 'İkindi';

  @override
  String get aksam => 'Akşam';

  @override
  String get yatsi => 'Yatsı';

  @override
  String get hijriHeader => 'Hicri';

  @override
  String get preferencesTitle => 'Tercihler';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayılanı';

  @override
  String get themeModeTitle => 'Tema modu';

  @override
  String get themeSystem => 'Sistem varsayılanı';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get appBarRemainingTitle => 'Ana sayfa üst çubuk kalan süre';

  @override
  String get showInTitle => 'Başlıkta göster';

  @override
  String get showAtRight => 'Sağda göster';

  @override
  String get showAsSubtitle => 'Alt başlıkta göster';

  @override
  String get hideRemainingText => 'Kalan metni gizle';

  @override
  String get notificationMessageTitle => 'Bildirim mesajı';

  @override
  String get notificationMessageShown => 'Gösteriliyor';

  @override
  String get notificationMessageHidden => 'Gizli';

  @override
  String get widgetTextSizeTitle => 'Widget yazı boyutu';

  @override
  String get widgetTextSizeSubtitle =>
      'Ana ekran widget\'larında kullanılan yazı boyutu.';

  @override
  String get widgetTextSizeSmall => 'Küçük';

  @override
  String get widgetTextSizeMedium => 'Orta';

  @override
  String get widgetTextSizeLarge => 'Büyük';

  @override
  String get remindersOnOffTitle => 'Hatırlatıcılar açık/kapalı';

  @override
  String get remindersOnOffSubtitle =>
      'Namaz hatırlatıcı bildirimlerini aç veya kapat. Vakit ayarların korunur.';

  @override
  String get remindersOn => 'Açık';

  @override
  String get remindersOff => 'Kapalı';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer Hatırlatıcısı';
  }

  @override
  String get reminderTypeTitle => 'Hatırlatıcı türü (ikisi de seçilebilir)';

  @override
  String get onTime => 'Vaktinde';

  @override
  String get before => 'Önce';

  @override
  String get remindBeforePrayerTitle => 'Namazdan önce hatırlat';

  @override
  String minutesValue(Object minutes) {
    return '$minutes dk';
  }

  @override
  String get custom => 'Özel';

  @override
  String get customMinutes => 'Özel dakika';

  @override
  String get customMinutesHint => 'örn. 12';

  @override
  String get save => 'Kaydet';

  @override
  String get enableBeforeToSelectMinutes =>
      'Dakika seçmek için \"Önce\"yi açın.';

  @override
  String get enterValidPositiveNumber => 'Geçerli pozitif sayı girin.';

  @override
  String get useValueUpTo240 => 'En fazla 240 dakika girin.';

  @override
  String get customMinutesSaved => 'Özel dakika kaydedildi.';
}
