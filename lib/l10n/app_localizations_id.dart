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
  String get widgetTextSizeTitle => 'Widget text size';

  @override
  String get widgetTextSizeSubtitle =>
      'Text size used in the home screen widgets.';

  @override
  String get widgetTextSizeExtraSmall => 'Extra small';

  @override
  String get widgetTextSizeSmall => 'Small';

  @override
  String get widgetTextSizeMedium => 'Medium';

  @override
  String get widgetTextSizeLarge => 'Large';

  @override
  String get remindersOnOffTitle => 'Pengingat on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Nyalakan atau matikan notifikasi pengingat salat. Pengaturan per salat tetap tersimpan.';

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
  String get remindBeforePrayerTitle => 'Ingatkan saya sebelum salat';

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
  String get enterValidPositiveNumber => 'Masukkan angka positif yang valid.';

  @override
  String get useValueUpTo240 => 'Gunakan nilai hingga 240 menit.';

  @override
  String get customMinutesSaved => 'Menit kustom tersimpan.';
}
