// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'دستیار نماز';

  @override
  String get tabLocation => 'مکان';

  @override
  String get tabToday => 'امروز';

  @override
  String get tabDates => 'تاریخ‌ها';

  @override
  String get tabTesbih => 'تسبیح';

  @override
  String get tooltipToggleLightDark => 'تغییر روشن/تیره';

  @override
  String get tooltipRemindersOn => 'یادآورها را روشن کنید';

  @override
  String get tooltipRemindersOff => 'یادآورها را خاموش کنید';

  @override
  String get tooltipPreferences => 'تنظیمات';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get remainingMinutesUnknown => '-- دقیقه';

  @override
  String get homeNoLocationTitle => 'مکانی انتخاب نشده است';

  @override
  String get homeNoLocationSubtitle =>
      'به تب مکان بروید و ابتدا ناحیه خود را ذخیره کنید.';

  @override
  String get homeNoPrayerTimesTitle => 'اوقات نماز در کش موجود نیست';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'برای همگام‌سازی داده سالانه، نوسازی کنید.';

  @override
  String get refresh => 'نوسازی';

  @override
  String todayWithDate(Object date) {
    return 'امروز • $date';
  }

  @override
  String get hijriUnknown => 'هجری: -';

  @override
  String hijriWithDate(Object date) {
    return 'هجری: $date';
  }

  @override
  String get reminderSettingsTitle => 'تنظیمات یادآور';

  @override
  String get reminderSettingsSubtitle =>
      'برای تنظیم یادآور و دقیقه‌های قبل، روی یکی از اوقات نماز بزنید.';

  @override
  String get tooltipScheduledDebug => 'اشکال‌زدایی یادآورهای زمان‌بندی‌شده';

  @override
  String get scheduledRemindersDebugTitle =>
      'یادآورهای زمان‌بندی‌شده (اشکال‌زدایی)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'اعلان‌های در انتظار: $count';
  }

  @override
  String get sendTestNotificationNow => 'ارسال اعلان آزمایشی';

  @override
  String get testNotificationSent => 'اعلان آزمایشی ارسال شد.';

  @override
  String get statusBarMinutesTitle => 'دقایق نوار وضعیت';

  @override
  String get statusBarMinutesSubtitle =>
      'نمایش اعلان دائمی دقایق باقی‌مانده در نوار وضعیت.';

  @override
  String get statusAutoRestoreTitle => 'بازیابی خودکار در صورت حذف';

  @override
  String get statusAutoRestoreSubtitle =>
      'اگر کاربر اعلان را ببندد، دوباره ایجاد شود.';

  @override
  String get noPendingReminders => 'یادآور در انتظاری وجود ندارد.';

  @override
  String get unknownFireTime => 'زمان نامشخص';

  @override
  String get pastPrefix => '[گذشته] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'روشن • به‌موقع + $minutes دقیقه قبل';
  }

  @override
  String get reminderOnTimeOnly => 'روشن • به‌موقع';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'روشن • $minutes دقیقه قبل';
  }

  @override
  String get reminderOff => 'یادآور خاموش';

  @override
  String get nextPrayerTitle => 'نماز بعدی';

  @override
  String startsIn(Object remaining) {
    return 'شروع در $remaining';
  }

  @override
  String get selectYourLocation => 'مکان خود را انتخاب کنید';

  @override
  String get locationHelp =>
      'برای تنظیم سریع از GPS استفاده کنید یا کشور/شهر را دستی انتخاب کنید.';

  @override
  String get useCurrentLocation => 'استفاده از مکان فعلی';

  @override
  String get country => 'کشور';

  @override
  String get stateCity => 'استان / شهر';

  @override
  String get district => 'ناحیه';

  @override
  String get saveLocation => 'ذخیره مکان';

  @override
  String selectedLocation(Object location) {
    return 'انتخاب‌شده: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'برای دیدن فهرست یک‌ساله نماز ابتدا یک مکان انتخاب کنید.';

  @override
  String get historyTableTitle => 'جدول اوقات نماز (کل سال)';

  @override
  String get todayShort => 'امروز';

  @override
  String get dateHeader => 'تاریخ';

  @override
  String get imsak => 'فجر';

  @override
  String get gunes => 'طلوع';

  @override
  String get ogle => 'ظهر';

  @override
  String get ikindi => 'عصر';

  @override
  String get aksam => 'مغرب';

  @override
  String get yatsi => 'عشاء';

  @override
  String get hijriHeader => 'هجری';

  @override
  String get preferencesTitle => 'تنظیمات';

  @override
  String get languageTitle => 'زبان';

  @override
  String get languageSystem => 'پیش‌فرض سیستم';

  @override
  String get themeModeTitle => 'حالت پوسته';

  @override
  String get themeSystem => 'پیش‌فرض سیستم';

  @override
  String get themeLight => 'روشن';

  @override
  String get themeDark => 'تیره';

  @override
  String get appBarRemainingTitle => 'متن زمان باقی‌مانده نوار بالا';

  @override
  String get showInTitle => 'نمایش در عنوان';

  @override
  String get showAtRight => 'نمایش در راست';

  @override
  String get showAsSubtitle => 'نمایش به‌عنوان زیرعنوان';

  @override
  String get hideRemainingText => 'مخفی کردن متن باقی‌مانده';

  @override
  String get notificationMessageTitle => 'پیام اعلان';

  @override
  String get notificationMessageShown => 'نمایش داده می‌شود';

  @override
  String get notificationMessageHidden => 'پنهان';

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
  String get remindersOnOffTitle => 'یادآورها روشن/خاموش';

  @override
  String get remindersOnOffSubtitle =>
      'اعلان‌های یادآور نماز را روشن یا خاموش کنید. تنظیمات هر نماز حفظ می‌شود.';

  @override
  String get reminderVibrationTitle => 'لرزش هنگام یادآوری';

  @override
  String get reminderVibrationSubtitle =>
      'لرزش ضربانی به مدت حدود ۱۰ ثانیه هنگام فعال شدن یادآور.';

  @override
  String get reminderSoundTitle => 'پخش صدا هنگام یادآوری';

  @override
  String get reminderSoundSubtitle => 'پخش صدای اعلان هنگام فعال شدن یادآور.';

  @override
  String get remindersOn => 'روشن';

  @override
  String get remindersOff => 'خاموش';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'یادآور $prayer';
  }

  @override
  String get reminderTypeTitle => 'نوع یادآور (می‌توانید هر دو را انتخاب کنید)';

  @override
  String get onTime => 'به‌موقع';

  @override
  String get before => 'قبل';

  @override
  String get remindBeforePrayerTitle => 'قبل از نماز یادآوری کن';

  @override
  String minutesValue(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get custom => 'سفارشی';

  @override
  String get customMinutes => 'دقیقه سفارشی';

  @override
  String get customMinutesHint => 'مثلاً 12';

  @override
  String get save => 'ذخیره';

  @override
  String get enableBeforeToSelectMinutes =>
      'برای انتخاب دقیقه، \"قبل\" را فعال کنید.';

  @override
  String get enterValidPositiveNumber => 'یک عدد مثبت معتبر وارد کنید.';

  @override
  String get useValueUpTo240 => 'از مقدار تا 240 دقیقه استفاده کنید.';

  @override
  String get customMinutesSaved => 'دقیقه سفارشی ذخیره شد.';
}
