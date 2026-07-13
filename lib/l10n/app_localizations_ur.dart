// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'نماز اسسٹنٹ';

  @override
  String get tabLocation => 'مقام';

  @override
  String get tabToday => 'آج';

  @override
  String get tabDates => 'تاریخیں';

  @override
  String get tooltipToggleLightDark => 'لائٹ/ڈارک تبدیل کریں';

  @override
  String get tooltipRemindersOn => 'یاد دہانیاں آن کریں';

  @override
  String get tooltipRemindersOff => 'یاد دہانیاں آف کریں';

  @override
  String get tooltipPreferences => 'ترجیحات';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes منٹ';
  }

  @override
  String get remainingMinutesUnknown => '-- منٹ';

  @override
  String get homeNoLocationTitle => 'کوئی مقام منتخب نہیں';

  @override
  String get homeNoLocationSubtitle =>
      'مقام ٹیب میں جا کر پہلے اپنا ضلع محفوظ کریں۔';

  @override
  String get homeNoPrayerTimesTitle => 'کیش میں نماز اوقات نہیں';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'سالانہ ڈیٹا ہم آہنگ کرنے کے لیے ریفریش کریں۔';

  @override
  String get refresh => 'ریفریش';

  @override
  String todayWithDate(Object date) {
    return 'آج • $date';
  }

  @override
  String get hijriUnknown => 'ہجری: -';

  @override
  String hijriWithDate(Object date) {
    return 'ہجری: $date';
  }

  @override
  String get reminderSettingsTitle => 'یاد دہانی سیٹنگز';

  @override
  String get reminderSettingsSubtitle =>
      'یاد دہانی اور منٹس پہلے کے لیے اوپر وقت پر ٹیپ کریں۔';

  @override
  String get tooltipScheduledDebug => 'شیڈولڈ ریمائنڈر ڈیبگ';

  @override
  String get scheduledRemindersDebugTitle => 'شیڈولڈ ریمائنڈرز (ڈیبگ)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'زیر التواء نوٹیفکیشنز: $count';
  }

  @override
  String get sendTestNotificationNow => 'ٹیسٹ نوٹیفکیشن بھیجیں';

  @override
  String get testNotificationSent => 'ٹیسٹ نوٹیفکیشن بھیج دیا گیا۔';

  @override
  String get statusBarMinutesTitle => 'اسٹیٹس بار منٹس';

  @override
  String get statusBarMinutesSubtitle =>
      'اسٹیٹس بار میں باقی منٹس کی مسلسل اطلاع دکھائیں۔';

  @override
  String get statusAutoRestoreTitle => 'ہٹانے پر بحال کریں';

  @override
  String get statusAutoRestoreSubtitle =>
      'اگر صارف ہٹا دے تو اسٹیٹس آئٹم دوبارہ بنائیں۔';

  @override
  String get noPendingReminders => 'کوئی زیر التواء یاد دہانی نہیں۔';

  @override
  String get unknownFireTime => 'نامعلوم وقت';

  @override
  String get pastPrefix => '[گزر گیا] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'آن • وقت پر + $minutes منٹ پہلے';
  }

  @override
  String get reminderOnTimeOnly => 'آن • وقت پر';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'آن • $minutes منٹ پہلے';
  }

  @override
  String get reminderOff => 'یاد دہانی بند';

  @override
  String get nextPrayerTitle => 'اگلی نماز';

  @override
  String startsIn(Object remaining) {
    return '$remaining میں شروع ہوگی';
  }

  @override
  String get selectYourLocation => 'اپنا مقام منتخب کریں';

  @override
  String get locationHelp =>
      'فوری سیٹ اپ کے لیے GPS استعمال کریں یا ملک/شہر دستی طور پر منتخب کریں۔';

  @override
  String get useCurrentLocation => 'موجودہ مقام استعمال کریں';

  @override
  String get country => 'ملک';

  @override
  String get stateCity => 'صوبہ / شہر';

  @override
  String get district => 'ضلع';

  @override
  String get saveLocation => 'مقام محفوظ کریں';

  @override
  String selectedLocation(Object location) {
    return 'منتخب شدہ: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1 سالہ نماز فہرست دیکھنے کے لیے پہلے مقام منتخب کریں۔';

  @override
  String get historyTableTitle => 'نماز اوقات جدول (پورا سال)';

  @override
  String get todayShort => 'آج';

  @override
  String get dateHeader => 'تاریخ';

  @override
  String get imsak => 'امساک';

  @override
  String get gunes => 'طلوع';

  @override
  String get ogle => 'ظہر';

  @override
  String get ikindi => 'عصر';

  @override
  String get aksam => 'مغرب';

  @override
  String get yatsi => 'عشاء';

  @override
  String get hijriHeader => 'ہجری';

  @override
  String get preferencesTitle => 'ترجیحات';

  @override
  String get languageTitle => 'زبان';

  @override
  String get languageSystem => 'سسٹم ڈیفالٹ';

  @override
  String get themeModeTitle => 'تھیم موڈ';

  @override
  String get themeSystem => 'سسٹم ڈیفالٹ';

  @override
  String get themeLight => 'لائٹ';

  @override
  String get themeDark => 'ڈارک';

  @override
  String get appBarRemainingTitle => 'ہوم ایپ بار باقی وقت متن';

  @override
  String get showInTitle => 'عنوان میں دکھائیں';

  @override
  String get showAtRight => 'دائیں دکھائیں';

  @override
  String get showAsSubtitle => 'ذیلی عنوان کے طور پر دکھائیں';

  @override
  String get hideRemainingText => 'باقی متن چھپائیں';

  @override
  String get notificationMessageTitle => 'اطلاع کا پیغام';

  @override
  String get notificationMessageShown => 'دکھایا گیا';

  @override
  String get notificationMessageHidden => 'چھپا ہوا';

  @override
  String get remindersOnOffTitle => 'یاد دہانیاں آن/آف';

  @override
  String get remindersOnOffSubtitle =>
      'نماز کی یاد دہانی آن یا آف کریں۔ ہر نماز کی سیٹنگز محفوظ رہیں گی۔';

  @override
  String get remindersOn => 'آن';

  @override
  String get remindersOff => 'آف';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer یاد دہانی';
  }

  @override
  String get reminderTypeTitle => 'یاد دہانی کی قسم (دونوں منتخب ہو سکتے ہیں)';

  @override
  String get onTime => 'وقت پر';

  @override
  String get before => 'پہلے';

  @override
  String get remindBeforePrayerTitle => 'نماز سے پہلے یاد دلائیں';

  @override
  String minutesValue(Object minutes) {
    return '$minutes منٹ';
  }

  @override
  String get custom => 'کسٹم';

  @override
  String get customMinutes => 'کسٹم منٹس';

  @override
  String get customMinutesHint => 'مثلاً 12';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get enableBeforeToSelectMinutes =>
      'منٹس منتخب کرنے کے لیے \"پہلے\" فعال کریں۔';

  @override
  String get enterValidPositiveNumber => 'درست مثبت نمبر درج کریں۔';

  @override
  String get useValueUpTo240 => '240 منٹ تک کی قدر استعمال کریں۔';

  @override
  String get customMinutesSaved => 'کسٹم منٹس محفوظ ہو گئے۔';
}
