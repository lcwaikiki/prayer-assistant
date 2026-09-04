// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Asisten Salat';

  @override
  String get tabLocation => 'Lokasi';

  @override
  String get tabToday => 'Hari ini';

  @override
  String get tabDates => 'Tanggal';

  @override
  String get tabTesbih => 'Tasbih';

  @override
  String get tooltipToggleLightDark => 'Ganti terang/gelap';

  @override
  String get tooltipRemindersOn => 'Nyalakan pengingat';

  @override
  String get tooltipRemindersOff => 'Matikan pengingat';

  @override
  String get tooltipPreferences => 'Preferensi';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes mnt';
  }

  @override
  String get remainingMinutesUnknown => '-- mnt';

  @override
  String get homeNoLocationTitle => 'Lokasi belum dipilih';

  @override
  String get homeNoLocationSubtitle =>
      'Buka tab Lokasi dan simpan distrik Anda terlebih dahulu.';

  @override
  String get homeNoPrayerTimesTitle => 'Waktu salat belum ada di cache';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Ketuk refresh untuk sinkronisasi data tahunan.';

  @override
  String get refresh => 'Refresh';

  @override
  String get qiblaTitle => 'Kiblat';

  @override
  String qiblaBearing(int degrees) {
    return 'Kiblat: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Tidak dapat menentukan lokasi Anda. Aktifkan GPS dan coba lagi.';

  @override
  String get qiblaHeadingUnavailable =>
      'Kompas tidak tersedia - menampilkan arah tetap.';

  @override
  String get qiblaPointDevice =>
      'Putar perangkat hingga jarum menunjuk ke atas.';

  @override
  String get qiblaKaabaShort => 'Kiblat';

  @override
  String get shareTodayTimes => 'Bagikan waktu hari ini';

  @override
  String get calendarPreviousDay => 'Hari sebelumnya';

  @override
  String get calendarNextDay => 'Hari berikutnya';

  @override
  String todayWithDate(Object date) {
    return 'Hari ini • $date';
  }

  @override
  String get hijriUnknown => 'Hijriah: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hijriah: $date';
  }

  @override
  String get reminderSettingsTitle => 'Pengaturan pengingat';

  @override
  String get reminderSettingsSubtitle =>
      'Ketuk waktu salat di atas untuk mengatur jenis pengingat dan menit sebelumnya.';

  @override
  String get tooltipScheduledDebug => 'Debug pengingat terjadwal';

  @override
  String get scheduledRemindersDebugTitle => 'Pengingat Terjadwal (Debug)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Notifikasi tertunda: $count';
  }

  @override
  String get sendTestNotificationNow => 'Kirim notifikasi tes sekarang';

  @override
  String get testNotificationSent => 'Notifikasi tes terkirim.';

  @override
  String get statusBarMinutesTitle => 'Menit di status bar';

  @override
  String get statusBarMinutesSubtitle =>
      'Tampilkan notifikasi berjalan menit tersisa di status bar.';

  @override
  String get statusAutoRestoreTitle => 'Pulihkan otomatis jika ditutup';

  @override
  String get statusAutoRestoreSubtitle =>
      'Buat ulang item status jika dihapus pengguna.';

  @override
  String get noPendingReminders => 'Tidak ada pengingat tertunda.';

  @override
  String get unknownFireTime => 'Waktu tidak diketahui';

  @override
  String get pastPrefix => '[LEWAT] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Aktif • Tepat waktu + $minutes mnt sebelum';
  }

  @override
  String get reminderOnTimeOnly => 'Aktif • Tepat waktu';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Aktif • $minutes mnt sebelum';
  }

  @override
  String get reminderOff => 'Pengingat nonaktif';

  @override
  String get nextPrayerTitle => 'Salat Berikutnya';

  @override
  String get homeUpcomingRemindersTitle => 'Pengingat mendatang';

  @override
  String startsIn(Object remaining) {
    return 'Mulai dalam $remaining';
  }

  @override
  String get selectYourLocation => 'Pilih lokasi Anda';

  @override
  String get locationHelp =>
      'Gunakan GPS untuk setup cepat atau pilih negara/kota secara manual.';

  @override
  String get useCurrentLocation => 'Gunakan lokasi saat ini';

  @override
  String get country => 'Negara';

  @override
  String get stateCity => 'Provinsi / Kota';

  @override
  String get district => 'Distrik';

  @override
  String get saveLocation => 'Simpan lokasi';

  @override
  String selectedLocation(Object location) {
    return 'Dipilih: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Pilih lokasi terlebih dahulu untuk melihat daftar salat 1 tahun.';

  @override
  String get historyTableTitle => 'Tabel Waktu Salat (Setahun Penuh)';

  @override
  String get todayShort => 'Hari ini';

  @override
  String get dateHeader => 'Tanggal';

  @override
  String get imsak => 'Subuh';

  @override
  String get gunes => 'Terbit';

  @override
  String get ogle => 'Dzuhur';

  @override
  String get ikindi => 'Ashar';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Isya';

  @override
  String get hijriHeader => 'Hijriah';

  @override
  String get preferencesTitle => 'Preferensi';

  @override
  String get languageTitle => 'Bahasa';

  @override
  String get languageSystem => 'Default sistem';

  @override
  String get themeModeTitle => 'Mode tema';

  @override
  String get themeSystem => 'Default sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get appBarRemainingTitle => 'Teks sisa waktu di app bar beranda';

  @override
  String get showInTitle => 'Tampilkan di judul';

  @override
  String get showAtRight => 'Tampilkan di kanan';

  @override
  String get showAsSubtitle => 'Tampilkan sebagai subjudul';

  @override
  String get hideRemainingText => 'Sembunyikan teks sisa';

  @override
  String get notificationMessageTitle => 'Pesan notifikasi';

  @override
  String get notificationMessageShown => 'Ditampilkan';

  @override
  String get notificationMessageHidden => 'Disembunyikan';

  @override
  String get widgetSettingsSectionTitle => 'Pengaturan Widget';

  @override
  String get widgetTextSizeTitle => 'Ukuran teks widget';

  @override
  String get widgetTextSizeSubtitle =>
      'Ukuran teks yang digunakan pada widget layar utama.';

  @override
  String get widgetTextSizeExtraSmall => 'Sangat kecil';

  @override
  String get widgetTextSizeSmall => 'Kecil';

  @override
  String get widgetTextSizeMedium => 'Sedang';

  @override
  String get widgetTextSizeLarge => 'Besar';

  @override
  String widgetTextSizePreview(Object size) {
    return 'Preview $size';
  }

  @override
  String get widgetMmssThresholdTitle => 'Ambang Hitung Mundur';

  @override
  String get widgetThemeTitle => 'Tema Latar Belakang';

  @override
  String get widgetThemeSystem => 'Default Sistem';

  @override
  String get widgetThemeLight => 'Terang';

  @override
  String get widgetThemeDark => 'Gelap';

  @override
  String get widgetThemeTransparent => 'Transparan';

  @override
  String get widgetCalendarDisplayTitle => 'Tampilan Tanggal Kalender';

  @override
  String get widgetCalendarDisplayBoth => 'Keduanya (Hijriah & Masehi)';

  @override
  String get widgetCalendarDisplayHijri => 'Hanya Hijriah';

  @override
  String get widgetCalendarDisplayGregorian => 'Hanya Masehi';

  @override
  String get widgetMmssThresholdNever => 'Selalu tampilkan HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS di bawah $minutes menit';
  }

  @override
  String get remindersOnOffTitle => 'Pengingat on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Nyalakan atau matikan notifikasi pengingat salat. Pengaturan per salat tetap tersimpan.';

  @override
  String get reminderVibrationTitle => 'Getar saat pengingat';

  @override
  String get reminderVibrationSubtitle =>
      'Getar berdenyut selama sekitar 10 detik saat pengingat muncul.';

  @override
  String get reminderSoundTitle => 'Putar suara saat pengingat';

  @override
  String get reminderSoundSubtitle =>
      'Putar suara notifikasi saat pengingat muncul.';

  @override
  String get remindersOn => 'On';

  @override
  String get remindersOff => 'Off';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'Pengingat $prayer';
  }

  @override
  String get reminderTypeTitle => 'Jenis pengingat (bisa pilih keduanya)';

  @override
  String get onTime => 'Tepat waktu';

  @override
  String get before => 'Sebelum';

  @override
  String get after => 'Setelah';

  @override
  String get reminderAlertTitle => 'Peringatan';

  @override
  String get reminderAlertSubtitle =>
      'Juga memerlukan sakelar yang sesuai aktif di Preferensi agar benar-benar memberi peringatan.';

  @override
  String get vibrateChip => 'Getar';

  @override
  String get soundChip => 'Suara';

  @override
  String get adhanChip => 'Azan';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total shalat selesai';
  }

  @override
  String get holiday_islamic_new_year => 'Tahun Baru Islam';

  @override
  String get holiday_ashura => 'Asyura';

  @override
  String get holiday_mawlid => 'Maulid Nabi';

  @override
  String get holiday_isra_miraj => 'Isra Miraj';

  @override
  String get holiday_laylat_barat => 'Nisfu Syaban';

  @override
  String get holiday_ramadan_first => 'Awal Ramadan';

  @override
  String get holiday_laylat_qadr => 'Lailatul Qadar';

  @override
  String get holiday_eid_fitr => 'Idul Fitri';

  @override
  String get holiday_arafah => 'Hari Arafah';

  @override
  String get holiday_eid_adha => 'Idul Adha';

  @override
  String get remindBeforePrayerTitle => 'Ingatkan saya sebelum salat';

  @override
  String get remindAfterPrayerTitle => 'Ingatkan saya setelah salat';

  @override
  String minutesValue(Object minutes) {
    return '$minutes mnt';
  }

  @override
  String get custom => 'Kustom';

  @override
  String get customMinutes => 'Menit kustom';

  @override
  String get customMinutesHint => 'mis. 12';

  @override
  String get save => 'Simpan';

  @override
  String get enableBeforeToSelectMinutes =>
      'Aktifkan \"Sebelum\" untuk memilih menit.';

  @override
  String get enableAfterToSelectMinutes =>
      'Aktifkan \"Setelah\" untuk memilih menit.';

  @override
  String get enterValidPositiveNumber => 'Masukkan angka positif yang valid.';

  @override
  String get useValueUpTo240 => 'Gunakan nilai hingga 240 menit.';

  @override
  String get customMinutesSaved => 'Menit kustom tersimpan.';

  @override
  String get cancel => 'Batal';

  @override
  String get calendarTabTooltip => 'Kalender Hijriah';

  @override
  String get calendarPreviousMonth => 'Bulan sebelumnya';

  @override
  String get calendarNextMonth => 'Bulan berikutnya';

  @override
  String get calendarSwapPrimary => 'Ganti Hijriah/Masehi';

  @override
  String get calendarShowSecondary => 'Tampilkan tanggal sekunder';

  @override
  String get calendarHideSecondary => 'Sembunyikan tanggal sekunder';

  @override
  String get calendarNoRemindersOnDay => 'Tidak ada pengingat pada hari ini';

  @override
  String get calendarAddReminder => 'Tambah pengingat';

  @override
  String get calendarEditReminder => 'Ubah';

  @override
  String get calendarDeleteReminder => 'Hapus';

  @override
  String get calendarReminderFormTitleNew => 'Pengingat baru';

  @override
  String get calendarReminderFormTitleEdit => 'Ubah pengingat';

  @override
  String get calendarReminderTitleLabel => 'Judul';

  @override
  String get calendarReminderTitleHint => 'mis. Awal Ramadan';

  @override
  String get calendarReminderNotesLabel => 'Catatan (opsional)';

  @override
  String get calendarReminderDateTimeLabel => 'Tanggal & waktu';

  @override
  String get calendarReminderRecurrenceLabel => 'Ulangi';

  @override
  String get calendarRecurrenceOnce => 'Sekali';

  @override
  String get calendarRecurrenceDaily => 'Harian';

  @override
  String get calendarRecurrenceWeekly => 'Mingguan';

  @override
  String get calendarRecurrenceMonthly => 'Bulanan';

  @override
  String get calendarRecurrenceYearly => 'Tahunan';

  @override
  String get calendarRepeatCountLabel => 'Jumlah pengulangan';

  @override
  String get calendarRepeatCountHelper =>
      'Berapa kali pengingat berbunyi sebelum berhenti (mati = berulang selamanya)';

  @override
  String get calendarRepeatCountError => 'Masukkan angka 2 hingga 100';

  @override
  String get calendarRepeatDaysLabel => 'Ulangi pada';

  @override
  String get calendarDayOfMonthLabel => 'Hari dalam bulan';

  @override
  String get calendarYearlyMonthLabel => 'Bulan';

  @override
  String get calendarYearlyDayLabel => 'Hari';

  @override
  String get calendarMonthlyBasisLabel => 'Dasar bulanan';

  @override
  String get calendarYearlyBasisLabel => 'Dasar tahunan';

  @override
  String get calendarYearlyBasisGregorian => 'Masehi';

  @override
  String get calendarYearlyBasisHijri => 'Hijriah';

  @override
  String get calendarReminderTitleRequired => 'Masukkan judul';

  @override
  String get calendarAnchorClockTime => 'Tanggal kalender';

  @override
  String get calendarAnchorPrayerTime => 'Waktu salat';

  @override
  String get calendarSelectPrayer => 'Pilih salat';

  @override
  String get calendarOffsetOnTime => 'Tepat waktu';

  @override
  String get calendarOffsetBefore => 'Sebelum';

  @override
  String get calendarOffsetAfter => 'Setelah';

  @override
  String get calendarPickAnchorDate => 'Pilih tanggal';

  @override
  String get datesPrayerTimesTab => 'Waktu Salat';

  @override
  String get datesCalendarTab => 'Kalender';

  @override
  String get undo => 'Batalkan';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" dihapus';
  }

  @override
  String get verseOfTheDay => 'Ayat Hari Ini';

  @override
  String get hadithOfTheDay => 'Hadits Hari Ini';

  @override
  String get hisnAlMuslimTitle => 'Hisnul Muslim';

  @override
  String get morningAdhkar => 'Dzikir Pagi';

  @override
  String get eveningAdhkar => 'Dzikir Petang';

  @override
  String get afterPrayerAdhkar => 'Dzikir Setelah Shalat';

  @override
  String get sleepingAdhkar => 'Dzikir Sebelum Tidur';

  @override
  String get dailyLifeDuas => 'Doa Sehari-hari';

  @override
  String get shareWisdom => 'Bagikan';

  @override
  String get copyText => 'Salin';

  @override
  String get copiedToClipboard => 'Disalin ke papan klip';

  @override
  String get searchSupplicationsHint => 'Cari doa...';

  @override
  String get noSupplicationsFound => 'Doa tidak ditemukan';

  @override
  String get completed => 'Selesai';

  @override
  String get tapToCount => 'Ketuk untuk menghitung';

  @override
  String get tabAll => 'Semua';

  @override
  String get kazaTitle => 'Qadha';

  @override
  String get kazaSubtitle => 'Lacak dan qadha shalat yang terlewat';

  @override
  String get kazaCalculatorWizard => 'Kalkulator';

  @override
  String get kazaBatchLogDay => '+1 Hari Penuh';

  @override
  String get kazaBatchLogDayTooltip => 'Tambah 1 hitungan untuk semua 6 shalat';

  @override
  String get kazaTotalRemaining => 'Total Tersisa';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target selesai';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Est. Selesai: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'Semua shalat qadha telah selesai! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Target Harian';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count shalat / hari';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Atur Target Harian';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'Berapa banyak shalat qadha yang Anda kerjakan setiap hari?';

  @override
  String get kazaCalculatorTitle => 'Kalkulator Shalat Qadha';

  @override
  String get kazaCalculateByYears => 'Berdasarkan Waktu';

  @override
  String get kazaCalculateManual => 'Target Manual';

  @override
  String get kazaYearsMissed => 'Jumlah Tahun';

  @override
  String get kazaMonthsMissed => 'Tambahan Bulan';

  @override
  String get kazaCalculateButton => 'Simpan Target';

  @override
  String get kazaWitrLabel => 'Witir';

  @override
  String kazaRemainingCount(Object count) {
    return 'Sisa $count';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'Jumlah Selesai $name';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days hari per shalat (Total $total shalat)';
  }

  @override
  String get backupExportTitle => 'Cadangkan & Ekspor';

  @override
  String get backupExportSubtitle =>
      'Cadangkan data aplikasi atau ekspor jadwal';

  @override
  String get exportBackupJson => 'Ekspor Data Cadangan (JSON)';

  @override
  String get restoreBackupJson => 'Pulihkan Data dari Cadangan';

  @override
  String get exportPrayerScheduleIcs => 'Ekspor Jadwal Shalat (.ics)';

  @override
  String get exportHolidaysIcs => 'Ekspor Hari Besar Islam (.ics)';

  @override
  String get restoreConfirmTitle => 'Pulihkan Data Aplikasi?';

  @override
  String get restoreConfirmBody =>
      'Ini akan memulihkan target Qadha, riwayat shalat, pengingat, dan data Tasbih Anda. Lanjutkan?';

  @override
  String get restoreSuccess => 'Data berhasil dipulihkan!';

  @override
  String get restoreError => 'Format berkas cadangan tidak valid';

  @override
  String get shareOrSave => 'Bagikan / Simpan';

  @override
  String get analyticsTab => 'Analistik';

  @override
  String get currentStreak => 'Beruntun Saat Ini';

  @override
  String get longestStreak => 'Beruntun Terpanjang';

  @override
  String get daysUnit => 'hari';

  @override
  String get monthlyHeatmapTitle => 'Penyelesaian Bulanan';

  @override
  String get completionBreakdownTitle => 'Rincian Shalat';

  @override
  String get overallConsistency => 'Konsistensi Keseluruhan';

  @override
  String get totalPrayersCompleted => 'Total Shalat Dicatat';

  @override
  String get last30Days => '30 Hari Terakhir';

  @override
  String get allTime => 'Semua Waktu';

  @override
  String get fastingTitle => 'Puasa';

  @override
  String get suhoorCountdownTitle => 'Menuju Sahur';

  @override
  String get iftarCountdownTitle => 'Menuju Buka Puasa';

  @override
  String get fastingTypeRamadan => 'Puasa Ramadhan';

  @override
  String get fastingTypeSunnah => 'Puasa Sunnah';

  @override
  String get fastingTypeQadaa => 'Puasa Qadha';

  @override
  String get whiteDaysTitle => 'Hari-hari Putih (Ayyamul Bidh)';

  @override
  String get mondayThursdayTitle => 'Sunnah Senin & Kamis';

  @override
  String get logFastAction => 'Catat Puasa';

  @override
  String get totalFastsLogged => 'Total Puasa Dicatat';

  @override
  String get suhoorEndsIn => 'Sahur berakhir dalam';

  @override
  String get iftarIn => 'Buka puasa dalam';

  @override
  String get fastingTab => 'Puasa';

  @override
  String get trackTabTitle => 'Lacak';

  @override
  String get prayerAnalyticsTitle => 'Analisis Shalat';

  @override
  String get prayerQadaaTitle => 'Qadha Shalat';

  @override
  String get iftarTimeLabel => 'Waktu Iftar';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% Berpuasa';
  }

  @override
  String get suhoorTickerTitle => 'Penghitung Sahur';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% berlalu';
  }

  @override
  String suhoorWithTime(String time) {
    return 'Sahur ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'Iftar ($time)';
  }

  @override
  String get upcomingSunnahDays => 'Hari Sunnah Mendatang';

  @override
  String get fastingCalendarLogger => 'Pencatat Kalender Puasa';

  @override
  String get removeFastLog => 'Hapus Log Puasa';

  @override
  String get calendarWeekStartTitle => 'Awal Minggu Kalender';

  @override
  String get calendarWeekStartSunday => 'Minggu';

  @override
  String get calendarWeekStartMonday => 'Senin';

  @override
  String get hijriDateOffsetTitle => 'Penyesuaian Tanggal Hijriah';

  @override
  String get hijriDateOffsetSubtitle =>
      'Sesuaikan tanggal Hijriah untuk rukyatul hilal lokal';

  @override
  String get showIslamicHolidaysTitle => 'Sorot Hari Besar Islam';

  @override
  String get showIslamicHolidaysSubtitle =>
      'Tampilkan lencana khusus untuk hari suci Islam';

  @override
  String get showFastingBadgesTitle => 'Tampilkan Catatan Puasa di Kalender';

  @override
  String get showFastingBadgesSubtitle =>
      'Tampilkan lencana pada tanggal dengan catatan puasa';

  @override
  String get defaultCalendarDisplayTitle => 'Tampilan Kalender Default';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'Basis awal saat membuka kalender';

  @override
  String get showCalendarReminderDotsTitle => 'Tampilkan Titik Pengingat';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'Tampilkan titik pada sel hari dengan pengingat terjadwal';

  @override
  String get calendarSettingsSectionTitle => 'Pengaturan Kalender';

  @override
  String get moonPhaseTitle => 'Fase Bulan';

  @override
  String moonIllumination(int percent) {
    return '$percent% Terang';
  }

  @override
  String moonAgeDays(String days) {
    return 'Hari ke-$days dari siklus';
  }

  @override
  String get moonPhaseNewMoon => 'Bulan Baru (Hilal)';

  @override
  String get moonPhaseWaxingCrescent => 'Sabit Muda';

  @override
  String get moonPhaseFirstQuarter => 'Kuartal Pertama';

  @override
  String get moonPhaseWaxingGibbous => 'Cembung Muda';

  @override
  String get moonPhaseFullMoon => 'Bulan Purnama (Badr)';

  @override
  String get moonPhaseWaningGibbous => 'Cembung Tua';

  @override
  String get moonPhaseLastQuarter => 'Kuartal Terakhir';

  @override
  String get moonPhaseWaningCrescent => 'Sabit Tua';

  @override
  String get whiteDaysSubtitle => 'Hari Puasa Sunnah (13, 14, 15 Hijriyah)';
}
