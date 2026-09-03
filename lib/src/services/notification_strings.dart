import 'dart:ui';

/// Localized string templates for prayer reminder notifications and beads
/// (tasbih/dhikr) reminder notifications across all 12 supported app languages.
class NotificationStrings {
  const NotificationStrings({
    required this.onTimeTitle,
    required this.onTimeBody,
    required this.beforeTitle,
    required this.beforeBody,
    required this.soonTitle,
    required this.soonBody,
    required this.afterTitle,
    required this.afterBody,
    required this.testTitle,
    required this.testBody,
    required this.dhikrBody,
  });

  final String Function(String prayer) onTimeTitle;
  final String Function(String location, String prayer) onTimeBody;
  final String Function(String prayer, int minutes) beforeTitle;
  final String Function(String location, String prayer, String time) beforeBody;
  final String Function(String prayer) soonTitle;
  final String Function(String location, String prayer, String time) soonBody;
  final String Function(String prayer, int minutes) afterTitle;
  final String Function(String location, String prayer, int minutes) afterBody;
  final String testTitle;
  final String testBody;
  final String Function(String title) dhikrBody;

  static const Map<String, NotificationStrings> _byLang = {
    'tr': NotificationStrings(
      onTimeTitle: _trOnTimeTitle,
      onTimeBody: _trOnTimeBody,
      beforeTitle: _trBeforeTitle,
      beforeBody: _trBeforeBody,
      soonTitle: _trSoonTitle,
      soonBody: _trSoonBody,
      afterTitle: _trAfterTitle,
      afterBody: _trAfterBody,
      testTitle: 'Prayer Assist testi',
      testBody: 'Bildirim sistemi bu cihazda çalışıyor.',
      dhikrBody: _trDhikrBody,
    ),
    'en': NotificationStrings(
      onTimeTitle: _enOnTimeTitle,
      onTimeBody: _enOnTimeBody,
      beforeTitle: _enBeforeTitle,
      beforeBody: _enBeforeBody,
      soonTitle: _enSoonTitle,
      soonBody: _enSoonBody,
      afterTitle: _enAfterTitle,
      afterBody: _enAfterBody,
      testTitle: 'Prayer Assist test',
      testBody: 'Notification pipeline is working on this device.',
      dhikrBody: _enDhikrBody,
    ),
    'ar': NotificationStrings(
      onTimeTitle: _arOnTimeTitle,
      onTimeBody: _arOnTimeBody,
      beforeTitle: _arBeforeTitle,
      beforeBody: _arBeforeBody,
      soonTitle: _arSoonTitle,
      soonBody: _arSoonBody,
      afterTitle: _arAfterTitle,
      afterBody: _arAfterBody,
      testTitle: 'اختبار مساعد الصلاة',
      testBody: 'نظام الإشعارات يعمل بنجاح على هذا الجهاز.',
      dhikrBody: _arDhikrBody,
    ),
    'de': NotificationStrings(
      onTimeTitle: _deOnTimeTitle,
      onTimeBody: _deOnTimeBody,
      beforeTitle: _deBeforeTitle,
      beforeBody: _deBeforeBody,
      soonTitle: _deSoonTitle,
      soonBody: _deSoonBody,
      afterTitle: _deAfterTitle,
      afterBody: _deAfterBody,
      testTitle: 'Prayer Assist Test',
      testBody: 'Das Benachrichtigungssystem funktioniert auf diesem Gerät.',
      dhikrBody: _deDhikrBody,
    ),
    'es': NotificationStrings(
      onTimeTitle: _esOnTimeTitle,
      onTimeBody: _esOnTimeBody,
      beforeTitle: _esBeforeTitle,
      beforeBody: _esBeforeBody,
      soonTitle: _esSoonTitle,
      soonBody: _esSoonBody,
      afterTitle: _esAfterTitle,
      afterBody: _esAfterBody,
      testTitle: 'Prueba de Prayer Assist',
      testBody: 'El sistema de notificaciones funciona en este dispositivo.',
      dhikrBody: _esDhikrBody,
    ),
    'fr': NotificationStrings(
      onTimeTitle: _frOnTimeTitle,
      onTimeBody: _frOnTimeBody,
      beforeTitle: _frBeforeTitle,
      beforeBody: _frBeforeBody,
      soonTitle: _frSoonTitle,
      soonBody: _frSoonBody,
      afterTitle: _frAfterTitle,
      afterBody: _frAfterBody,
      testTitle: 'Test Prayer Assist',
      testBody: 'Le système de notifications fonctionne sur cet appareil.',
      dhikrBody: _frDhikrBody,
    ),
    'ru': NotificationStrings(
      onTimeTitle: _ruOnTimeTitle,
      onTimeBody: _ruOnTimeBody,
      beforeTitle: _ruBeforeTitle,
      beforeBody: _ruBeforeBody,
      soonTitle: _ruSoonTitle,
      soonBody: _ruSoonBody,
      afterTitle: _ruAfterTitle,
      afterBody: _ruAfterBody,
      testTitle: 'Тест Prayer Assist',
      testBody: 'Система уведомлений работает на этом устройстве.',
      dhikrBody: _ruDhikrBody,
    ),
    'fa': NotificationStrings(
      onTimeTitle: _faOnTimeTitle,
      onTimeBody: _faOnTimeBody,
      beforeTitle: _faBeforeTitle,
      beforeBody: _faBeforeBody,
      soonTitle: _faSoonTitle,
      soonBody: _faSoonBody,
      afterTitle: _faAfterTitle,
      afterBody: _faAfterBody,
      testTitle: 'آزمایش دستیار نماز',
      testBody: 'سیستم اعلان‌ها در این دستگاه به درستی کار می‌کند.',
      dhikrBody: _faDhikrBody,
    ),
    'ur': NotificationStrings(
      onTimeTitle: _urOnTimeTitle,
      onTimeBody: _urOnTimeBody,
      beforeTitle: _urBeforeTitle,
      beforeBody: _urBeforeBody,
      soonTitle: _urSoonTitle,
      soonBody: _urSoonBody,
      afterTitle: _urAfterTitle,
      afterBody: _urAfterBody,
      testTitle: 'نماز اسسٹ ٹیسٹ',
      testBody: 'اس ڈیوائس پر نوٹیفکیشن سسٹم کام کر رہا ہے۔',
      dhikrBody: _urDhikrBody,
    ),
    'id': NotificationStrings(
      onTimeTitle: _idOnTimeTitle,
      onTimeBody: _idOnTimeBody,
      beforeTitle: _idBeforeTitle,
      beforeBody: _idBeforeBody,
      soonTitle: _idSoonTitle,
      soonBody: _idSoonBody,
      afterTitle: _idAfterTitle,
      afterBody: _idAfterBody,
      testTitle: 'Uji coba Prayer Assist',
      testBody: 'Sistem notifikasi berfungsi di perangkat ini.',
      dhikrBody: _idDhikrBody,
    ),
    'zh': NotificationStrings(
      onTimeTitle: _zhOnTimeTitle,
      onTimeBody: _zhOnTimeBody,
      beforeTitle: _zhBeforeTitle,
      beforeBody: _zhBeforeBody,
      soonTitle: _zhSoonTitle,
      soonBody: _zhSoonBody,
      afterTitle: _zhAfterTitle,
      afterBody: _zhAfterBody,
      testTitle: 'Prayer Assist 测试',
      testBody: '该设备上的通知系统正常运行。',
      dhikrBody: _zhDhikrBody,
    ),
    'ja': NotificationStrings(
      onTimeTitle: _jaOnTimeTitle,
      onTimeBody: _jaOnTimeBody,
      beforeTitle: _jaBeforeTitle,
      beforeBody: _jaBeforeBody,
      soonTitle: _jaSoonTitle,
      soonBody: _jaSoonBody,
      afterTitle: _jaAfterTitle,
      afterBody: _jaAfterBody,
      testTitle: 'Prayer Assist テスト',
      testBody: 'この端末で通知システムが正常に動作しています。',
      dhikrBody: _jaDhikrBody,
    ),
  };

  static NotificationStrings of(Locale? locale) {
    final lang = locale?.languageCode.toLowerCase() ?? 'en';
    return _byLang[lang] ?? _byLang['en']!;
  }

  // --- TR ---
  static String _trOnTimeTitle(String prayer) => '$prayer vakti';
  static String _trOnTimeBody(String location, String prayer) =>
      '$location - $prayer namazı vakti geldi.';
  static String _trBeforeTitle(String prayer, int minutes) =>
      '$prayer vaktine $minutes dk';
  static String _trBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer vakti: $time.';
  static String _trSoonTitle(String prayer) => '$prayer yakında';
  static String _trSoonBody(String location, String prayer, String time) =>
      '$location - $prayer vakti: $time.';
  static String _trAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes dk';
  static String _trAfterBody(String location, String prayer, int minutes) =>
      '$location - $prayer vaktinden bu yana $minutes dk geçti.';
  static String _trDhikrBody(String title) => '$title zikri vakti geldi.';

  // --- EN ---
  static String _enOnTimeTitle(String prayer) => '$prayer time';
  static String _enOnTimeBody(String location, String prayer) =>
      '$location - It is time for $prayer prayer.';
  static String _enBeforeTitle(String prayer, int minutes) =>
      '$prayer in $minutes min';
  static String _enBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer is at $time.';
  static String _enSoonTitle(String prayer) => '$prayer soon';
  static String _enSoonBody(String location, String prayer, String time) =>
      '$location - $prayer is at $time.';
  static String _enAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes min';
  static String _enAfterBody(String location, String prayer, int minutes) =>
      '$location - It has been $minutes min since $prayer.';
  static String _enDhikrBody(String title) => 'Time for your $title dhikr.';

  // --- AR ---
  static String _arOnTimeTitle(String prayer) => 'وقت صلاة $prayer';
  static String _arOnTimeBody(String location, String prayer) =>
      '$location - حان الآن موعد صلاة $prayer.';
  static String _arBeforeTitle(String prayer, int minutes) =>
      'صلاة $prayer خلال $minutes دقيقة';
  static String _arBeforeBody(String location, String prayer, String time) =>
      '$location - موعد صلاة $prayer في $time.';
  static String _arSoonTitle(String prayer) => 'اقتربت صلاة $prayer';
  static String _arSoonBody(String location, String prayer, String time) =>
      '$location - موعد صلاة $prayer في $time.';
  static String _arAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes دقيقة';
  static String _arAfterBody(String location, String prayer, int minutes) =>
      '$location - مضت $minutes دقيقة منذ صلاة $prayer.';
  static String _arDhikrBody(String title) => 'حان وقت ذكر $title.';

  // --- DE ---
  static String _deOnTimeTitle(String prayer) => '$prayer-Zeit';
  static String _deOnTimeBody(String location, String prayer) =>
      '$location - Es ist Zeit für das $prayer-Gebet.';
  static String _deBeforeTitle(String prayer, int minutes) =>
      '$prayer in $minutes Min.';
  static String _deBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer ist um $time.';
  static String _deSoonTitle(String prayer) => '$prayer bald';
  static String _deSoonBody(String location, String prayer, String time) =>
      '$location - $prayer ist um $time.';
  static String _deAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes Min.';
  static String _deAfterBody(String location, String prayer, int minutes) =>
      '$location - Seit $prayer sind $minutes Min. vergangen.';
  static String _deDhikrBody(String title) => 'Zeit für dein $title-Dhikr.';

  // --- ES ---
  static String _esOnTimeTitle(String prayer) => 'Hora de $prayer';
  static String _esOnTimeBody(String location, String prayer) =>
      '$location - Es hora de la oración de $prayer.';
  static String _esBeforeTitle(String prayer, int minutes) =>
      '$prayer en $minutes min';
  static String _esBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer es a las $time.';
  static String _esSoonTitle(String prayer) => '$prayer pronto';
  static String _esSoonBody(String location, String prayer, String time) =>
      '$location - $prayer es a las $time.';
  static String _esAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes min';
  static String _esAfterBody(String location, String prayer, int minutes) =>
      '$location - Han pasado $minutes min desde $prayer.';
  static String _esDhikrBody(String title) => 'Es hora de tu dhikr de $title.';

  // --- FR ---
  static String _frOnTimeTitle(String prayer) => 'Heure de $prayer';
  static String _frOnTimeBody(String location, String prayer) =>
      '$location - C\'est l\'heure de la prière de $prayer.';
  static String _frBeforeTitle(String prayer, int minutes) =>
      '$prayer dans $minutes min';
  static String _frBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer est à $time.';
  static String _frSoonTitle(String prayer) => '$prayer bientôt';
  static String _frSoonBody(String location, String prayer, String time) =>
      '$location - $prayer est à $time.';
  static String _frAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes min';
  static String _frAfterBody(String location, String prayer, int minutes) =>
      '$location - $minutes min se sont écoulées depuis $prayer.';
  static String _frDhikrBody(String title) => 'C\'est l\'heure de votre dhikr de $title.';

  // --- RU ---
  static String _ruOnTimeTitle(String prayer) => 'Время намаза $prayer';
  static String _ruOnTimeBody(String location, String prayer) =>
      '$location — Настало время намаза $prayer.';
  static String _ruBeforeTitle(String prayer, int minutes) =>
      '$prayer через $minutes мин';
  static String _ruBeforeBody(String location, String prayer, String time) =>
      '$location — $prayer в $time.';
  static String _ruSoonTitle(String prayer) => '$prayer скоро';
  static String _ruSoonBody(String location, String prayer, String time) =>
      '$location — $prayer в $time.';
  static String _ruAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes мин';
  static String _ruAfterBody(String location, String prayer, int minutes) =>
      '$location — Прошло $minutes мин с начала намаза $prayer.';
  static String _ruDhikrBody(String title) => 'Время для зикра «$title».';

  // --- FA ---
  static String _faOnTimeTitle(String prayer) => 'وقت نماز $prayer';
  static String _faOnTimeBody(String location, String prayer) =>
      '$location - زمان نماز $prayer فرا رسیده است.';
  static String _faBeforeTitle(String prayer, int minutes) =>
      '$prayer تا $minutes دقیقه دیگر';
  static String _faBeforeBody(String location, String prayer, String time) =>
      '$location - زمان $prayer در $time است.';
  static String _faSoonTitle(String prayer) => '$prayer به زودی';
  static String _faSoonBody(String location, String prayer, String time) =>
      '$location - زمان $prayer در $time است.';
  static String _faAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes دقیقه';
  static String _faAfterBody(String location, String prayer, int minutes) =>
      '$location - $minutes دقیقه از $prayer گذشته است.';
  static String _faDhikrBody(String title) => 'زمان ذکر $title فرا رسیده است.';

  // --- UR ---
  static String _urOnTimeTitle(String prayer) => '$prayer کا وقت';
  static String _urOnTimeBody(String location, String prayer) =>
      '$location - $prayer کی نماز کا وقت ہو گیا ہے۔';
  static String _urBeforeTitle(String prayer, int minutes) =>
      '$prayer $minutes منٹ میں';
  static String _urBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer کا وقت $time ہے۔';
  static String _urSoonTitle(String prayer) => '$prayer جلد ہی';
  static String _urSoonBody(String location, String prayer, String time) =>
      '$location - $prayer کا وقت $time ہے۔';
  static String _urAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes منٹ';
  static String _urAfterBody(String location, String prayer, int minutes) =>
      '$location - $prayer کو $minutes منٹ گزر چکے ہیں۔';
  static String _urDhikrBody(String title) => '$title کے ذکر کا وقت ہو گیا ہے۔';

  // --- ID ---
  static String _idOnTimeTitle(String prayer) => 'Waktu shalat $prayer';
  static String _idOnTimeBody(String location, String prayer) =>
      '$location - Waktunya shalat $prayer.';
  static String _idBeforeTitle(String prayer, int minutes) =>
      '$prayer dalam $minutes mnt';
  static String _idBeforeBody(String location, String prayer, String time) =>
      '$location - Waktu $prayer pukul $time.';
  static String _idSoonTitle(String prayer) => '$prayer sebentar lagi';
  static String _idSoonBody(String location, String prayer, String time) =>
      '$location - Waktu $prayer pukul $time.';
  static String _idAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes mnt';
  static String _idAfterBody(String location, String prayer, int minutes) =>
      '$location - Sudah $minutes mnt sejak $prayer.';
  static String _idDhikrBody(String title) => 'Waktunya dzikir $title Anda.';

  // --- ZH ---
  static String _zhOnTimeTitle(String prayer) => '$prayer时间';
  static String _zhOnTimeBody(String location, String prayer) =>
      '$location - $prayer时间到了。';
  static String _zhBeforeTitle(String prayer, int minutes) =>
      '$minutes分钟后$prayer';
  static String _zhBeforeBody(String location, String prayer, String time) =>
      '$location - $prayer时间为 $time。';
  static String _zhSoonTitle(String prayer) => '$prayer即将到来';
  static String _zhSoonBody(String location, String prayer, String time) =>
      '$location - $prayer时间为 $time。';
  static String _zhAfterTitle(String prayer, int minutes) =>
      '$prayer +$minutes分钟';
  static String _zhAfterBody(String location, String prayer, int minutes) =>
      '$location - 距离$prayer已过去 $minutes 分钟。';
  static String _zhDhikrBody(String title) => '该进行您的 $title 记念了。';

  // --- JA ---
  static String _jaOnTimeTitle(String prayer) => '${prayer}の時間';
  static String _jaOnTimeBody(String location, String prayer) =>
      '$location - ${prayer}の礼拝の時間です。';
  static String _jaBeforeTitle(String prayer, int minutes) =>
      '${minutes}分後に$prayer';
  static String _jaBeforeBody(String location, String prayer, String time) =>
      '$location - ${prayer}は$timeです。';
  static String _jaSoonTitle(String prayer) => '${prayer}まもなく';
  static String _jaSoonBody(String location, String prayer, String time) =>
      '$location - ${prayer}は$timeです。';
  static String _jaAfterTitle(String prayer, int minutes) =>
      '$prayer +${minutes}分';
  static String _jaAfterBody(String location, String prayer, int minutes) =>
      '$location - ${prayer}から${minutes}分が経過しました。';
  static String _jaDhikrBody(String title) => '$titleのズィクルの時間です。';
}
