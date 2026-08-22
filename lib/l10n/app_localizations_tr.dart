// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Namaz AsistanÄ±';

  @override
  String get tabLocation => 'Konum';

  @override
  String get tabToday => 'BugÃ¼n';

  @override
  String get tabDates => 'Tarih';

  @override
  String get tabTesbih => 'Tesbih';

  @override
  String get tooltipToggleLightDark => 'AÃ§Ä±k/Koyu deÄŸiÅŸtir';

  @override
  String get tooltipRemindersOn => 'HatÄ±rlatÄ±cÄ±larÄ± aÃ§';

  @override
  String get tooltipRemindersOff => 'HatÄ±rlatÄ±cÄ±larÄ± kapat';

  @override
  String get tooltipPreferences => 'Tercihler';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes dk';
  }

  @override
  String get remainingMinutesUnknown => '-- dk';

  @override
  String get homeNoLocationTitle => 'Konum seÃ§ilmedi';

  @override
  String get homeNoLocationSubtitle =>
      'Konum sekmesine gidip Ã¶nce ilÃ§enizi kaydedin.';

  @override
  String get homeNoPrayerTimesTitle => 'Ã–nbellekte namaz vakti yok';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'YÄ±llÄ±k veriyi eÅŸitlemek iÃ§in yenileyin.';

  @override
  String get refresh => 'Yenile';

  @override
  String get qiblaTitle => 'KÄ±ble';

  @override
  String qiblaBearing(int degrees) {
    return 'KÄ±ble: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Konumunuz belirlenemedi. GPS\'i aÃ§Ä±p tekrar deneyin.';

  @override
  String get qiblaHeadingUnavailable =>
      'Pusula yok - sabit yÃ¶n gÃ¶steriliyor.';

  @override
  String get qiblaPointDevice =>
      'Ä°bre yukarÄ±yÄ± gÃ¶sterene kadar cihazÄ±nÄ±zÄ± Ã§evirin.';

  @override
  String get qiblaKaabaShort => 'KÄ±ble';

  @override
  String get shareTodayTimes => 'BugÃ¼nÃ¼n vakitlerini paylaÅŸ';

  @override
  String get calendarPreviousDay => 'Ã–nceki gÃ¼n';

  @override
  String get calendarNextDay => 'Sonraki gÃ¼n';

  @override
  String todayWithDate(Object date) {
    return 'BugÃ¼n â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Hicri: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hicri: $date';
  }

  @override
  String get reminderSettingsTitle => 'HatÄ±rlatÄ±cÄ± ayarlarÄ±';

  @override
  String get reminderSettingsSubtitle =>
      'HatÄ±rlatÄ±cÄ± ve dakika ayarlarÄ± iÃ§in yukarÄ±daki vakitlerden birine dokunun.';

  @override
  String get tooltipScheduledDebug =>
      'ZamanlanmÄ±ÅŸ hatÄ±rlatÄ±cÄ± hata ayÄ±klama';

  @override
  String get scheduledRemindersDebugTitle =>
      'ZamanlanmÄ±ÅŸ HatÄ±rlatÄ±cÄ±lar (Debug)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Bekleyen bildirim: $count';
  }

  @override
  String get sendTestNotificationNow => 'Test bildirimi gÃ¶nder';

  @override
  String get testNotificationSent => 'Test bildirimi gÃ¶nderildi.';

  @override
  String get statusBarMinutesTitle => 'Durum Ã§ubuÄŸu dakikalarÄ±';

  @override
  String get statusBarMinutesSubtitle =>
      'Durum Ã§ubuÄŸunda kalan dakika bildirimini gÃ¶ster.';

  @override
  String get statusAutoRestoreTitle => 'Silinince geri yÃ¼kle';

  @override
  String get statusAutoRestoreSubtitle =>
      'KullanÄ±cÄ± kapatÄ±rsa durum Ã¶ÄŸesini yeniden oluÅŸtur.';

  @override
  String get noPendingReminders => 'Bekleyen hatÄ±rlatÄ±cÄ± yok.';

  @override
  String get unknownFireTime => 'Bilinmeyen zaman';

  @override
  String get pastPrefix => '[GEÃ‡MÄ°Åž] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'AÃ§Ä±k â€¢ Vaktinde + $minutes dk Ã¶nce';
  }

  @override
  String get reminderOnTimeOnly => 'AÃ§Ä±k â€¢ Vaktinde';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'AÃ§Ä±k â€¢ $minutes dk Ã¶nce';
  }

  @override
  String get reminderOff => 'HatÄ±rlatÄ±cÄ± kapalÄ±';

  @override
  String get nextPrayerTitle => 'SÄ±radaki Vakit';

  @override
  String get homeUpcomingRemindersTitle => 'YaklaÅŸan hatÄ±rlatÄ±cÄ±lar';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total namaz tamamlandı';
  }

  @override
  String startsIn(Object remaining) {
    return '$remaining sonra baÅŸlar';
  }

  @override
  String get selectYourLocation => 'Konumunuzu seÃ§in';

  @override
  String get locationHelp =>
      'HÄ±zlÄ± kurulum iÃ§in GPS kullanÄ±n veya Ã¼lke/ÅŸehir seÃ§imini manuel yapÄ±n.';

  @override
  String get useCurrentLocation => 'Mevcut konumu kullan';

  @override
  String get country => 'Ãœlke';

  @override
  String get stateCity => 'Ä°l / Åžehir';

  @override
  String get district => 'Ä°lÃ§e';

  @override
  String get saveLocation => 'Konumu kaydet';

  @override
  String selectedLocation(Object location) {
    return 'SeÃ§ilen: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1 yÄ±llÄ±k namaz listesini gÃ¶rmek iÃ§in Ã¶nce konum seÃ§in.';

  @override
  String get historyTableTitle => 'Namaz Vakitleri Tablosu (Tam YÄ±l)';

  @override
  String get todayShort => 'BugÃ¼n';

  @override
  String get dateHeader => 'Tarih';

  @override
  String get imsak => 'Ä°msak';

  @override
  String get gunes => 'GÃ¼neÅŸ';

  @override
  String get ogle => 'Ã–ÄŸle';

  @override
  String get ikindi => 'Ä°kindi';

  @override
  String get aksam => 'AkÅŸam';

  @override
  String get yatsi => 'YatsÄ±';

  @override
  String get hijriHeader => 'Hicri';

  @override
  String get preferencesTitle => 'Tercihler';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageSystem => 'Sistem varsayÄ±lanÄ±';

  @override
  String get themeModeTitle => 'Tema modu';

  @override
  String get themeSystem => 'Sistem varsayÄ±lanÄ±';

  @override
  String get themeLight => 'AÃ§Ä±k';

  @override
  String get themeDark => 'Koyu';

  @override
  String get appBarRemainingTitle => 'Ana sayfa Ã¼st Ã§ubuk kalan sÃ¼re';

  @override
  String get showInTitle => 'BaÅŸlÄ±kta gÃ¶ster';

  @override
  String get showAtRight => 'SaÄŸda gÃ¶ster';

  @override
  String get showAsSubtitle => 'Alt baÅŸlÄ±kta gÃ¶ster';

  @override
  String get hideRemainingText => 'Kalan metni gizle';

  @override
  String get notificationMessageTitle => 'Bildirim mesajÄ±';

  @override
  String get notificationMessageShown => 'GÃ¶steriliyor';

  @override
  String get notificationMessageHidden => 'Gizli';

  @override
  String get widgetTextSizeTitle => 'Widget yazÄ± boyutu';

  @override
  String get widgetTextSizeSubtitle =>
      'Ana ekran widget\'larÄ±nda kullanÄ±lan yazÄ± boyutu.';

  @override
  String get widgetTextSizeExtraSmall => 'Ã‡ok kÃ¼Ã§Ã¼k';

  @override
  String get widgetTextSizeSmall => 'KÃ¼Ã§Ã¼k';

  @override
  String get widgetTextSizeMedium => 'Orta';

  @override
  String get widgetTextSizeLarge => 'BÃ¼yÃ¼k';

  @override
  String get widgetMmssThresholdTitle => 'Widget saniye geri sayÄ±mÄ±';

  @override
  String get widgetMmssThresholdNever => 'Her zaman HH:MM gÃ¶ster';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes dk altÄ±nda MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'HatÄ±rlatÄ±cÄ±lar aÃ§Ä±k/kapalÄ±';

  @override
  String get remindersOnOffSubtitle =>
      'Namaz hatÄ±rlatÄ±cÄ± bildirimlerini aÃ§ veya kapat. Vakit ayarlarÄ±n korunur.';

  @override
  String get reminderVibrationTitle => 'HatÄ±rlatmada titreÅŸim';

  @override
  String get reminderVibrationSubtitle =>
      'HatÄ±rlatma geldiÄŸinde yaklaÅŸÄ±k 10 saniye aralÄ±klÄ± titreÅŸim.';

  @override
  String get reminderSoundTitle => 'HatÄ±rlatmada ses';

  @override
  String get reminderSoundSubtitle =>
      'HatÄ±rlatma geldiÄŸinde bildirim sesi Ã§alsÄ±n.';

  @override
  String get remindersOn => 'AÃ§Ä±k';

  @override
  String get remindersOff => 'KapalÄ±';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer HatÄ±rlatÄ±cÄ±sÄ±';
  }

  @override
  String get reminderTypeTitle =>
      'HatÄ±rlatÄ±cÄ± tÃ¼rÃ¼ (ikisi de seÃ§ilebilir)';

  @override
  String get onTime => 'Vaktinde';

  @override
  String get before => 'Ã–nce';

  @override
  String get after => 'Sonra';

  @override
  String get reminderAlertTitle => 'UyarÄ±';

  @override
  String get reminderAlertSubtitle =>
      'GerÃ§ekten uyarmasÄ± iÃ§in Tercihler\'deki ilgili anahtarÄ±n da aÃ§Ä±k olmasÄ± gerekir.';

  @override
  String get vibrateChip => 'TitreÅŸim';

  @override
  String get soundChip => 'Ses';

  @override
  String get adhanChip => 'Ezan';

  @override
  String get remindBeforePrayerTitle => 'Namazdan Ã¶nce hatÄ±rlat';

  @override
  String get remindAfterPrayerTitle => 'Namazdan sonra hatÄ±rlat';

  @override
  String minutesValue(Object minutes) {
    return '$minutes dk';
  }

  @override
  String get custom => 'Ã–zel';

  @override
  String get customMinutes => 'Ã–zel dakika';

  @override
  String get customMinutesHint => 'Ã¶rn. 12';

  @override
  String get save => 'Kaydet';

  @override
  String get enableBeforeToSelectMinutes =>
      'Dakika seÃ§mek iÃ§in \"Ã–nce\"yi aÃ§Ä±n.';

  @override
  String get enableAfterToSelectMinutes =>
      'Dakika seÃ§mek iÃ§in \"Sonra\"yÄ± aÃ§Ä±n.';

  @override
  String get enterValidPositiveNumber => 'GeÃ§erli pozitif sayÄ± girin.';

  @override
  String get useValueUpTo240 => 'En fazla 240 dakika girin.';

  @override
  String get customMinutesSaved => 'Ã–zel dakika kaydedildi.';

  @override
  String get cancel => 'Ä°ptal';

  @override
  String get calendarTabTooltip => 'Hicri takvim';

  @override
  String get calendarPreviousMonth => 'Ã–nceki ay';

  @override
  String get calendarNextMonth => 'Sonraki ay';

  @override
  String get calendarSwapPrimary => 'Hicri/Miladi deÄŸiÅŸtir';

  @override
  String get calendarShowSecondary => 'Ä°kincil tarihi gÃ¶ster';

  @override
  String get calendarHideSecondary => 'Ä°kincil tarihi gizle';

  @override
  String get calendarNoRemindersOnDay => 'Bu gÃ¼nde hatÄ±rlatÄ±cÄ± yok';

  @override
  String get calendarAddReminder => 'HatÄ±rlatÄ±cÄ± ekle';

  @override
  String get calendarEditReminder => 'DÃ¼zenle';

  @override
  String get calendarDeleteReminder => 'Sil';

  @override
  String get calendarReminderFormTitleNew => 'Yeni hatÄ±rlatÄ±cÄ±';

  @override
  String get calendarReminderFormTitleEdit => 'HatÄ±rlatÄ±cÄ±yÄ± dÃ¼zenle';

  @override
  String get calendarReminderTitleLabel => 'BaÅŸlÄ±k';

  @override
  String get calendarReminderTitleHint => 'Ã¶rn. Ramazan baÅŸlangÄ±cÄ±';

  @override
  String get calendarReminderNotesLabel => 'Notlar (isteÄŸe baÄŸlÄ±)';

  @override
  String get calendarReminderDateTimeLabel => 'Tarih ve saat';

  @override
  String get calendarReminderRecurrenceLabel => 'Tekrar';

  @override
  String get calendarRecurrenceOnce => 'Bir kez';

  @override
  String get calendarRecurrenceDaily => 'Her gÃ¼n';

  @override
  String get calendarRecurrenceWeekly => 'Her hafta';

  @override
  String get calendarRecurrenceMonthly => 'Her ay';

  @override
  String get calendarRecurrenceYearly => 'Her yÄ±l';

  @override
  String get calendarRepeatCountLabel => 'Tekrar sayÄ±sÄ±';

  @override
  String get calendarRepeatCountHelper =>
      'HatÄ±rlatmanÄ±n durmadan Ã¶nce kaÃ§ kez Ã§alacaÄŸÄ± (kapalÄ± = her zaman tekrarlanÄ±r)';

  @override
  String get calendarRepeatCountError => '2 ile 100 arasÄ±nda bir sayÄ± girin';

  @override
  String get calendarRepeatDaysLabel => 'Tekrarla';

  @override
  String get calendarDayOfMonthLabel => 'AyÄ±n gÃ¼nÃ¼';

  @override
  String get calendarYearlyMonthLabel => 'Ay';

  @override
  String get calendarYearlyDayLabel => 'GÃ¼n';

  @override
  String get calendarMonthlyBasisLabel => 'AylÄ±k esas';

  @override
  String get calendarYearlyBasisLabel => 'YÄ±llÄ±k esas';

  @override
  String get calendarYearlyBasisGregorian => 'Miladi';

  @override
  String get calendarYearlyBasisHijri => 'Hicri';

  @override
  String get calendarReminderTitleRequired => 'Bir baÅŸlÄ±k girin';

  @override
  String get calendarAnchorClockTime => 'Takvim tarihi';

  @override
  String get calendarAnchorPrayerTime => 'Namaz vakti';

  @override
  String get calendarSelectPrayer => 'Vakit seÃ§in';

  @override
  String get calendarOffsetOnTime => 'Vaktinde';

  @override
  String get calendarOffsetBefore => 'Ã–nce';

  @override
  String get calendarOffsetAfter => 'Sonra';

  @override
  String get calendarPickAnchorDate => 'Tarih seÃ§';

  @override
  String get datesPrayerTimesTab => 'Namaz Vakitleri';

  @override
  String get datesCalendarTab => 'Takvim';

  @override
  String get undo => 'Geri Al';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" silindi';
  }
}
