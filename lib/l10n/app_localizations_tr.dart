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
  String get tabTesbih => 'Tesbih';

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
  String get qiblaTitle => 'Kıble';

  @override
  String qiblaBearing(int degrees) {
    return 'Kıble: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Konumunuz belirlenemedi. GPS\'i açıp tekrar deneyin.';

  @override
  String get qiblaHeadingUnavailable => 'Pusula yok - sabit yön gösteriliyor.';

  @override
  String get qiblaPointDevice =>
      'İbre yukarıyı gösterene kadar cihazınızı çevirin.';

  @override
  String get qiblaKaabaShort => 'Kıble';

  @override
  String get shareTodayTimes => 'Bugünün vakitlerini paylaş';

  @override
  String get calendarPreviousDay => 'Önceki gün';

  @override
  String get calendarNextDay => 'Sonraki gün';

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
  String get homeUpcomingRemindersTitle => 'Yaklaşan hatırlatıcılar';

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
  String get widgetTextSizeExtraSmall => 'Çok küçük';

  @override
  String get widgetTextSizeSmall => 'Küçük';

  @override
  String get widgetTextSizeMedium => 'Orta';

  @override
  String get widgetTextSizeLarge => 'Büyük';

  @override
  String get widgetMmssThresholdTitle => 'Widget saniye geri sayımı';

  @override
  String get widgetMmssThresholdNever => 'Her zaman HH:MM göster';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes dk altında MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'Hatırlatıcılar açık/kapalı';

  @override
  String get remindersOnOffSubtitle =>
      'Namaz hatırlatıcı bildirimlerini aç veya kapat. Vakit ayarların korunur.';

  @override
  String get reminderVibrationTitle => 'Hatırlatmada titreşim';

  @override
  String get reminderVibrationSubtitle =>
      'Hatırlatma geldiğinde yaklaşık 10 saniye aralıklı titreşim.';

  @override
  String get reminderSoundTitle => 'Hatırlatmada ses';

  @override
  String get reminderSoundSubtitle =>
      'Hatırlatma geldiğinde bildirim sesi çalsın.';

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
  String get after => 'Sonra';

  @override
  String get reminderAlertTitle => 'Uyarı';

  @override
  String get reminderAlertSubtitle =>
      'Gerçekten uyarması için Tercihler\'deki ilgili anahtarın da açık olması gerekir.';

  @override
  String get vibrateChip => 'Titreşim';

  @override
  String get soundChip => 'Ses';

  @override
  String get adhanChip => 'Ezan';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total namaz tamamlandı';
  }

  @override
  String get holiday_islamic_new_year => 'Hicri Yılbaşı';

  @override
  String get holiday_ashura => 'Aşure Günü';

  @override
  String get holiday_mawlid => 'Mevlid Kandili';

  @override
  String get holiday_isra_miraj => 'Miraç Kandili';

  @override
  String get holiday_laylat_barat => 'Berat Kandili';

  @override
  String get holiday_ramadan_first => 'Ramazan Başlangıcı';

  @override
  String get holiday_laylat_qadr => 'Kadir Gecesi';

  @override
  String get holiday_eid_fitr => 'Ramazan Bayramı';

  @override
  String get holiday_arafah => 'Arefe Günü';

  @override
  String get holiday_eid_adha => 'Kurban Bayramı';

  @override
  String get remindBeforePrayerTitle => 'Namazdan önce hatırlat';

  @override
  String get remindAfterPrayerTitle => 'Namazdan sonra hatırlat';

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
  String get enableAfterToSelectMinutes =>
      'Dakika seçmek için \"Sonra\"yı açın.';

  @override
  String get enterValidPositiveNumber => 'Geçerli pozitif sayı girin.';

  @override
  String get useValueUpTo240 => 'En fazla 240 dakika girin.';

  @override
  String get customMinutesSaved => 'Özel dakika kaydedildi.';

  @override
  String get cancel => 'İptal';

  @override
  String get calendarTabTooltip => 'Hicri takvim';

  @override
  String get calendarPreviousMonth => 'Önceki ay';

  @override
  String get calendarNextMonth => 'Sonraki ay';

  @override
  String get calendarSwapPrimary => 'Hicri/Miladi değiştir';

  @override
  String get calendarShowSecondary => 'İkincil tarihi göster';

  @override
  String get calendarHideSecondary => 'İkincil tarihi gizle';

  @override
  String get calendarNoRemindersOnDay => 'Bu günde hatırlatıcı yok';

  @override
  String get calendarAddReminder => 'Hatırlatıcı ekle';

  @override
  String get calendarEditReminder => 'Düzenle';

  @override
  String get calendarDeleteReminder => 'Sil';

  @override
  String get calendarReminderFormTitleNew => 'Yeni hatırlatıcı';

  @override
  String get calendarReminderFormTitleEdit => 'Hatırlatıcıyı düzenle';

  @override
  String get calendarReminderTitleLabel => 'Başlık';

  @override
  String get calendarReminderTitleHint => 'örn. Ramazan başlangıcı';

  @override
  String get calendarReminderNotesLabel => 'Notlar (isteğe bağlı)';

  @override
  String get calendarReminderDateTimeLabel => 'Tarih ve saat';

  @override
  String get calendarReminderRecurrenceLabel => 'Tekrar';

  @override
  String get calendarRecurrenceOnce => 'Bir kez';

  @override
  String get calendarRecurrenceDaily => 'Her gün';

  @override
  String get calendarRecurrenceWeekly => 'Her hafta';

  @override
  String get calendarRecurrenceMonthly => 'Her ay';

  @override
  String get calendarRecurrenceYearly => 'Her yıl';

  @override
  String get calendarRepeatCountLabel => 'Tekrar sayısı';

  @override
  String get calendarRepeatCountHelper =>
      'Hatırlatmanın durmadan önce kaç kez çalacağı (kapalı = her zaman tekrarlanır)';

  @override
  String get calendarRepeatCountError => '2 ile 100 arasında bir sayı girin';

  @override
  String get calendarRepeatDaysLabel => 'Tekrarla';

  @override
  String get calendarDayOfMonthLabel => 'Ayın günü';

  @override
  String get calendarYearlyMonthLabel => 'Ay';

  @override
  String get calendarYearlyDayLabel => 'Gün';

  @override
  String get calendarMonthlyBasisLabel => 'Aylık esas';

  @override
  String get calendarYearlyBasisLabel => 'Yıllık esas';

  @override
  String get calendarYearlyBasisGregorian => 'Miladi';

  @override
  String get calendarYearlyBasisHijri => 'Hicri';

  @override
  String get calendarReminderTitleRequired => 'Bir başlık girin';

  @override
  String get calendarAnchorClockTime => 'Takvim tarihi';

  @override
  String get calendarAnchorPrayerTime => 'Namaz vakti';

  @override
  String get calendarSelectPrayer => 'Vakit seçin';

  @override
  String get calendarOffsetOnTime => 'Vaktinde';

  @override
  String get calendarOffsetBefore => 'Önce';

  @override
  String get calendarOffsetAfter => 'Sonra';

  @override
  String get calendarPickAnchorDate => 'Tarih seç';

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

  @override
  String get verseOfTheDay => 'Günün Ayeti';

  @override
  String get hadithOfTheDay => 'Günün Hadisi';

  @override
  String get hisnAlMuslimTitle => 'Hısnü\'l-Müslim';

  @override
  String get morningAdhkar => 'Sabah Zikirleri';

  @override
  String get eveningAdhkar => 'Akşam Zikirleri';

  @override
  String get afterPrayerAdhkar => 'Namaz Sonrası';

  @override
  String get sleepingAdhkar => 'Uyku Öncesi Zikirler';

  @override
  String get dailyLifeDuas => 'Günlük Dualar';

  @override
  String get shareWisdom => 'Paylaş';

  @override
  String get copyText => 'Kopyala';

  @override
  String get copiedToClipboard => 'Panoya kopyalandı';

  @override
  String get searchSupplicationsHint => 'Dua ve zikirlerde ara...';

  @override
  String get noSupplicationsFound => 'Dua bulunamadı';

  @override
  String get completed => 'Tamamlandı';

  @override
  String get tapToCount => 'Saymak için dokunun';

  @override
  String get tabAll => 'Tümü';

  @override
  String get kazaTitle => 'Kaza';

  @override
  String get kazaSubtitle => 'Kaza namazlarınızı hesaplayın ve takip edin';

  @override
  String get kazaCalculatorWizard => 'Hesaplayıcı';

  @override
  String get kazaBatchLogDay => '+1 Gün Tamamla';

  @override
  String get kazaBatchLogDayTooltip =>
      '6 namazın tümü için tamamlanan sayısını 1 artırır';

  @override
  String get kazaTotalRemaining => 'Toplam Kalan';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target tamamlandı';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Tahmini Bitiş: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'Tüm kaza namazları tamamlandı! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Günlük Hedef';

  @override
  String kazaDailyPaceValue(Object count) {
    return 'Günde $count vakit';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Günlük Hedef Belirle';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'Günde kaç vakit kaza namazı kılıyorsunuz?';

  @override
  String get kazaCalculatorTitle => 'Kaza Hesaplama Sihirbazı';

  @override
  String get kazaCalculateByYears => 'Süreye Göre';

  @override
  String get kazaCalculateManual => 'Manuel Hedefler';

  @override
  String get kazaYearsMissed => 'Kılınmayan Yıl Sayısı';

  @override
  String get kazaMonthsMissed => 'İlave Ay Sayısı';

  @override
  String get kazaCalculateButton => 'Hedefleri Kaydet';

  @override
  String get kazaWitrLabel => 'Vitir';

  @override
  String kazaRemainingCount(Object count) {
    return '$count kalan';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name Tamamlanan Sayısı';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= Her vakit için $days gün (Toplam $total namaz)';
  }

  @override
  String get backupExportTitle => 'Yedekle ve Dışa Aktar';

  @override
  String get backupExportSubtitle =>
      'Uygulama verilerini yedekleyin veya takvimi dışa aktarın';

  @override
  String get exportBackupJson => 'Yedek Verisini Dışa Aktar (JSON)';

  @override
  String get restoreBackupJson => 'Yedekten Veri Geri Yükle';

  @override
  String get exportPrayerScheduleIcs => 'Namaz Vakitlerini Dışa Aktar (.ics)';

  @override
  String get exportHolidaysIcs => 'Dini Günleri Dışa Aktar (.ics)';

  @override
  String get restoreConfirmTitle => 'Veriler Geri Yüklensin mi?';

  @override
  String get restoreConfirmBody =>
      'Kaza hedefleri, namaz geçmişi, hatırlatıcılar ve Tesbihat verileriniz geri yüklenecektir. Devam edilsin mi?';

  @override
  String get restoreSuccess => 'Veriler başarıyla geri yüklendi!';

  @override
  String get restoreError => 'Geçersiz yedek dosyası biçimi';

  @override
  String get shareOrSave => 'Paylaş / Kaydet';

  @override
  String get analyticsTab => 'Analiz';

  @override
  String get currentStreak => 'Mevcut Seri';

  @override
  String get longestStreak => 'En Uzun Seri';

  @override
  String get daysUnit => 'gün';

  @override
  String get monthlyHeatmapTitle => 'Aylık Tamamlama';

  @override
  String get completionBreakdownTitle => 'Namaz Dağılımı';

  @override
  String get overallConsistency => 'Genel İstikrar';

  @override
  String get totalPrayersCompleted => 'Toplam Kılınan Namaz';

  @override
  String get last30Days => 'Son 30 Gün';

  @override
  String get allTime => 'Tüm Zamanlar';

  @override
  String get fastingTitle => 'Oruç';

  @override
  String get suhoorCountdownTitle => 'Sahura Kalan';

  @override
  String get iftarCountdownTitle => 'İftara Kalan';

  @override
  String get fastingTypeRamadan => 'Ramazan Orucu';

  @override
  String get fastingTypeSunnah => 'Sünnet Orucu';

  @override
  String get fastingTypeQadaa => 'Kaza Orucu';

  @override
  String get whiteDaysTitle => 'Eyyam-ı Biyd (13, 14, 15)';

  @override
  String get mondayThursdayTitle => 'Pazartesi ve Perşembe Sünneti';

  @override
  String get logFastAction => 'Oruç Kaydet';

  @override
  String get totalFastsLogged => 'Toplam Tutulan Oruç';

  @override
  String get suhoorEndsIn => 'Sahur bitimine';

  @override
  String get iftarIn => 'İftara kalan';

  @override
  String get fastingTab => 'Oruç';

  @override
  String get trackTabTitle => 'Takip';

  @override
  String get prayerAnalyticsTitle => 'Namaz Analizi';

  @override
  String get prayerQadaaTitle => 'Kaza Namazları';

  @override
  String get iftarTimeLabel => 'İftar Vakti';

  @override
  String fastingProgressFasted(int percent) {
    return '%$percent Tamamlandı';
  }

  @override
  String get suhoorTickerTitle => 'Sahur Sayacı';

  @override
  String fastingProgressElapsed(String percent) {
    return '%$percent geçti';
  }

  @override
  String suhoorWithTime(String time) {
    return 'Sahur ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'İftar ($time)';
  }
}
