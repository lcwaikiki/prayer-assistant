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
  String get qiblaTitle => 'قبله';

  @override
  String qiblaBearing(int degrees) {
    return 'قبله: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'مکان شما مشخص نشد. GPS را فعال و دوباره تلاش کنید.';

  @override
  String get qiblaHeadingUnavailable =>
      'قطب‌نما در دسترس نیست - جهت ثابت نمایش داده می‌شود.';

  @override
  String get qiblaPointDevice =>
      'دستگاه را بچرخانید تا عقربه رو به بالا قرار گیرد.';

  @override
  String get qiblaKaabaShort => 'قبله';

  @override
  String get shareTodayTimes => 'اشتراک اوقات امروز';

  @override
  String get calendarPreviousDay => 'روز قبل';

  @override
  String get calendarNextDay => 'روز بعد';

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
  String get homeUpcomingRemindersTitle => 'یادآورهای پیش رو';

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
  String get widgetSettingsSectionTitle => 'تنظیمات ابزارک';

  @override
  String get widgetTextSizeTitle => 'اندازه متن ابزارک';

  @override
  String get widgetTextSizeSubtitle =>
      'اندازه متن استفاده‌شده در ابزارک‌های صفحه اصلی.';

  @override
  String get widgetTextSizeExtraSmall => 'خیلی کوچک';

  @override
  String get widgetTextSizeSmall => 'کوچک';

  @override
  String get widgetTextSizeMedium => 'متوسط';

  @override
  String get widgetTextSizeLarge => 'بزرگ';

  @override
  String widgetTextSizePreview(Object size) {
    return 'Preview $size';
  }

  @override
  String get widgetMmssThresholdTitle => 'آستانه شمارش معکوس';

  @override
  String get widgetThemeTitle => 'تم پس‌زمینه';

  @override
  String get widgetThemeSystem => 'پیش‌فرض سیستم';

  @override
  String get widgetThemeLight => 'روشن';

  @override
  String get widgetThemeDark => 'تاریک';

  @override
  String get widgetThemeTransparent => 'شفاف';

  @override
  String get widgetCalendarDisplayTitle => 'نمایش تاریخ تقویم';

  @override
  String get widgetCalendarDisplayBoth => 'هر دو (هجری و میلادی)';

  @override
  String get widgetCalendarDisplayHijri => 'فقط هجری';

  @override
  String get widgetCalendarDisplayGregorian => 'فقط میلادی';

  @override
  String get widgetMmssThresholdNever => 'همیشه نمایش HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS زیر $minutes دقیقه';
  }

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
  String get after => 'بعد';

  @override
  String get reminderAlertTitle => 'هشدار';

  @override
  String get reminderAlertSubtitle =>
      'برای هشدار واقعی، کلید مربوطه در تنظیمات هم باید روشن باشد.';

  @override
  String get vibrateChip => 'لرزش';

  @override
  String get soundChip => 'صدا';

  @override
  String get adhanChip => 'اذان';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total نماز تکمیل شد';
  }

  @override
  String get holiday_islamic_new_year => 'سال نو هجری';

  @override
  String get holiday_ashura => 'عاشورا';

  @override
  String get holiday_mawlid => 'میلاد پیامبر';

  @override
  String get holiday_isra_miraj => 'اسراء و معراج';

  @override
  String get holiday_laylat_barat => 'شب برات';

  @override
  String get holiday_ramadan_first => 'اول رمضان';

  @override
  String get holiday_laylat_qadr => 'شب قدر';

  @override
  String get holiday_eid_fitr => 'عید فطر';

  @override
  String get holiday_arafah => 'روز عرفه';

  @override
  String get holiday_eid_adha => 'عید قربان';

  @override
  String get remindBeforePrayerTitle => 'قبل از نماز یادآوری کن';

  @override
  String get remindAfterPrayerTitle => 'بعد از نماز یادآوری کن';

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
  String get enableAfterToSelectMinutes =>
      'برای انتخاب دقیقه، \"بعد\" را فعال کنید.';

  @override
  String get enterValidPositiveNumber => 'یک عدد مثبت معتبر وارد کنید.';

  @override
  String get useValueUpTo240 => 'از مقدار تا 240 دقیقه استفاده کنید.';

  @override
  String get customMinutesSaved => 'دقیقه سفارشی ذخیره شد.';

  @override
  String get cancel => 'انصراف';

  @override
  String get calendarTabTooltip => 'تقویم هجری';

  @override
  String get calendarPreviousMonth => 'ماه قبل';

  @override
  String get calendarNextMonth => 'ماه بعد';

  @override
  String get calendarSwapPrimary => 'تعویض هجری/میلادی';

  @override
  String get calendarShowSecondary => 'نمایش تاریخ ثانویه';

  @override
  String get calendarHideSecondary => 'پنهان کردن تاریخ ثانویه';

  @override
  String get calendarNoRemindersOnDay => 'یادآوری در این روز وجود ندارد';

  @override
  String get calendarAddReminder => 'افزودن یادآور';

  @override
  String get calendarEditReminder => 'ویرایش';

  @override
  String get calendarDeleteReminder => 'حذف';

  @override
  String get calendarReminderFormTitleNew => 'یادآور جدید';

  @override
  String get calendarReminderFormTitleEdit => 'ویرایش یادآور';

  @override
  String get calendarReminderTitleLabel => 'عنوان';

  @override
  String get calendarReminderTitleHint => 'مثلاً شروع ماه رمضان';

  @override
  String get calendarReminderNotesLabel => 'یادداشت (اختیاری)';

  @override
  String get calendarReminderDateTimeLabel => 'تاریخ و ساعت';

  @override
  String get calendarReminderRecurrenceLabel => 'تکرار';

  @override
  String get calendarRecurrenceOnce => 'یک‌بار';

  @override
  String get calendarRecurrenceDaily => 'روزانه';

  @override
  String get calendarRecurrenceWeekly => 'هفتگی';

  @override
  String get calendarRecurrenceMonthly => 'ماهانه';

  @override
  String get calendarRecurrenceYearly => 'سالانه';

  @override
  String get calendarRepeatCountLabel => 'تعداد تکرار';

  @override
  String get calendarRepeatCountHelper =>
      'تعداد دفعاتی که یادآوری قبل از توقف اجرا می‌شود (خاموش = همیشه تکرار می‌شود)';

  @override
  String get calendarRepeatCountError => 'عددی از ۲ تا ۱۰۰ وارد کنید';

  @override
  String get calendarRepeatDaysLabel => 'تکرار در';

  @override
  String get calendarDayOfMonthLabel => 'روز ماه';

  @override
  String get calendarYearlyMonthLabel => 'ماه';

  @override
  String get calendarYearlyDayLabel => 'روز';

  @override
  String get calendarMonthlyBasisLabel => 'مبنای ماهانه';

  @override
  String get calendarYearlyBasisLabel => 'مبنای سالانه';

  @override
  String get calendarYearlyBasisGregorian => 'میلادی';

  @override
  String get calendarYearlyBasisHijri => 'هجری';

  @override
  String get calendarReminderTitleRequired => 'یک عنوان وارد کنید';

  @override
  String get calendarAnchorClockTime => 'تاریخ تقویم';

  @override
  String get calendarAnchorPrayerTime => 'وقت نماز';

  @override
  String get calendarSelectPrayer => 'انتخاب نماز';

  @override
  String get calendarOffsetOnTime => 'به‌موقع';

  @override
  String get calendarOffsetBefore => 'قبل';

  @override
  String get calendarOffsetAfter => 'بعد';

  @override
  String get calendarPickAnchorDate => 'انتخاب تاریخ';

  @override
  String get datesPrayerTimesTab => 'اوقات نماز';

  @override
  String get datesCalendarTab => 'تقویم';

  @override
  String get undo => 'بازگردانی';

  @override
  String calendarReminderDeleted(Object title) {
    return '«$title» حذف شد';
  }

  @override
  String get verseOfTheDay => 'آیه روز';

  @override
  String get hadithOfTheDay => 'حدیث روز';

  @override
  String get hisnAlMuslimTitle => 'حصن المسلم';

  @override
  String get morningAdhkar => 'اذکار صبح';

  @override
  String get eveningAdhkar => 'اذکار شب';

  @override
  String get afterPrayerAdhkar => 'اذکار بعد از نماز';

  @override
  String get sleepingAdhkar => 'اذکار قبل از خواب';

  @override
  String get dailyLifeDuas => 'دعاهای زندگی روزمره';

  @override
  String get shareWisdom => 'اشتراک‌گذاری';

  @override
  String get copyText => 'کپی';

  @override
  String get copiedToClipboard => 'در حافظه کپی شد';

  @override
  String get searchSupplicationsHint => 'جستجوی ادعیه...';

  @override
  String get noSupplicationsFound => 'دعا یافت نشد';

  @override
  String get completed => 'تکمیل شده';

  @override
  String get tapToCount => 'برای شمارش ضربه بزنید';

  @override
  String get tabAll => 'همه';

  @override
  String get kazaTitle => 'قضا';

  @override
  String get kazaSubtitle => 'محاسبه و پیگیری نمازهای قضای گذشته';

  @override
  String get kazaCalculatorWizard => 'محاسبه‌گر';

  @override
  String get kazaBatchLogDay => '+۱ روز کامل';

  @override
  String get kazaBatchLogDayTooltip => 'افزایش ۱ عدد برای هر ۶ نماز';

  @override
  String get kazaTotalRemaining => 'مجموع باقیمانده';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed از $target انجام شد';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'تخمین اتمام: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished => 'تمام نمازهای قضا ادا شدند! 🎉';

  @override
  String get kazaDailyPaceLabel => 'سرعت روزانه';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count نماز / روز';
  }

  @override
  String get kazaSetPaceDialogTitle => 'تنظیم سرعت روزانه';

  @override
  String get kazaSetPaceDialogSubtitle => 'روزانه چند نماز قضا می‌خوانید؟';

  @override
  String get kazaCalculatorTitle => 'محاسبه‌گر نمازهای قضا';

  @override
  String get kazaCalculateByYears => 'بر اساس زمان';

  @override
  String get kazaCalculateManual => 'مقادیر دستی';

  @override
  String get kazaYearsMissed => 'سال‌های قضا شده';

  @override
  String get kazaMonthsMissed => 'ماه‌های اضافی';

  @override
  String get kazaCalculateButton => 'ثبت اهداف';

  @override
  String get kazaWitrLabel => 'واتر';

  @override
  String kazaRemainingCount(Object count) {
    return '$count باقیمانده';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'تعداد انجام شده $name';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days روز برای هر نماز (مجموعاً $total نماز)';
  }

  @override
  String get backupExportTitle => 'پشتیبان‌گیری و خروجی';

  @override
  String get backupExportSubtitle => 'پشتیبان‌گیری از داده‌ها یا خروجی تقویم';

  @override
  String get exportBackupJson => 'خروجی پشتیبان (JSON)';

  @override
  String get restoreBackupJson => 'بازیابی داده‌ها از پشتیبان';

  @override
  String get exportPrayerScheduleIcs => 'خروجی اوقات نماز (.ics)';

  @override
  String get exportHolidaysIcs => 'خروجی مناسبت‌های اسلامی (.ics)';

  @override
  String get restoreConfirmTitle => 'بازیابی داده‌های برنامه؟';

  @override
  String get restoreConfirmBody =>
      'اهداف قضا، تاریخچه نماز، یادآورها و تسبیحات بازیابی خواهند شد. ادامه می‌دهید؟';

  @override
  String get restoreSuccess => 'داده‌ها با موفقیت بازیابی شدند!';

  @override
  String get restoreError => 'فرمت فایل پشتیبان نامعتبر است';

  @override
  String get shareOrSave => 'اشتراک‌گذاری / ذخیره';

  @override
  String get analyticsTab => 'تحلیل و آمار';

  @override
  String get currentStreak => 'زنجیره فعلی';

  @override
  String get longestStreak => 'طولانی‌ترین زنجیره';

  @override
  String get daysUnit => 'روز';

  @override
  String get monthlyHeatmapTitle => 'تکمیل ماهانه';

  @override
  String get completionBreakdownTitle => 'تفکیک نمازها';

  @override
  String get overallConsistency => 'ثبات کلی';

  @override
  String get totalPrayersCompleted => 'مجموع نمازهای ثبت شده';

  @override
  String get last30Days => '۳۰ روز گذشته';

  @override
  String get allTime => 'همه زمان‌ها';

  @override
  String get fastingTitle => 'روزه';

  @override
  String get suhoorCountdownTitle => 'تا سحر';

  @override
  String get iftarCountdownTitle => 'تا افطار';

  @override
  String get fastingTypeRamadan => 'روزه رمضان';

  @override
  String get fastingTypeSunnah => 'روزه مستحبی';

  @override
  String get fastingTypeQadaa => 'روزه قضا';

  @override
  String get whiteDaysTitle => 'ایام البیض';

  @override
  String get mondayThursdayTitle => 'سنت دوشنبه و پنج‌شنبه';

  @override
  String get logFastAction => 'ثبت روزه';

  @override
  String get totalFastsLogged => 'مجموع روزه‌های گرفته‌شده';

  @override
  String get suhoorEndsIn => 'پایان سحر در';

  @override
  String get iftarIn => 'مانده تا افطار';

  @override
  String get fastingTab => 'روزه';

  @override
  String get trackTabTitle => 'پیگیری';

  @override
  String get prayerAnalyticsTitle => 'تحلیل‌های نماز';

  @override
  String get prayerQadaaTitle => 'قضای نماز';

  @override
  String get iftarTimeLabel => 'زمان افطار';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent٪ روزه گذشته';
  }

  @override
  String get suhoorTickerTitle => 'شمارش سحر';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent٪ سپری شده';
  }

  @override
  String suhoorWithTime(String time) {
    return 'سحر ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'افطار ($time)';
  }

  @override
  String get upcomingSunnahDays => 'روزهای سنت در پیش رو';

  @override
  String get fastingCalendarLogger => 'ثبت تقویم روزه‌داری';

  @override
  String get removeFastLog => 'حذف ثبت روزه‌داری';

  @override
  String get calendarWeekStartTitle => 'شروع هفته تقویم';

  @override
  String get calendarWeekStartSunday => 'یکشنبه';

  @override
  String get calendarWeekStartMonday => 'دوشنبه';

  @override
  String get hijriDateOffsetTitle => 'تنظیم تاریخ هجری';

  @override
  String get hijriDateOffsetSubtitle =>
      'تنظیم تاریخ هجری بر اساس رؤیت ماه محلی';

  @override
  String get showIslamicHolidaysTitle => 'برجسته‌سازی مناسبت‌های اسلامی';

  @override
  String get showIslamicHolidaysSubtitle =>
      'نمایش نشان‌های ویژه برای روزهای مبارک اسلامی';

  @override
  String get showFastingBadgesTitle => 'نمایش ثبت روزه‌ها در تقویم';

  @override
  String get showFastingBadgesSubtitle =>
      'نمایش نشان در روزهایی که روزه ثبت شده است';

  @override
  String get defaultCalendarDisplayTitle => 'نمای پیش‌فرض تقویم';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'حالت اولیه هنگام باز کردن تقویم';

  @override
  String get showCalendarReminderDotsTitle => 'نمایش نقاط یادآوری';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'نمایش نقطه در روزهای دارای یادآوری';

  @override
  String get calendarSettingsSectionTitle => 'تنظیمات تقویم';

  @override
  String get moonPhaseTitle => 'حالت‌های ماه';

  @override
  String moonIllumination(int percent) {
    return '$percent٪ روشن';
  }

  @override
  String moonAgeDays(String days) {
    return 'روز $days از چرخه';
  }

  @override
  String get moonPhaseNewMoon => 'ماه نو (هلال)';

  @override
  String get moonPhaseWaxingCrescent => 'هلال فزون‌يابی';

  @override
  String get moonPhaseFirstQuarter => 'تربیع اول';

  @override
  String get moonPhaseWaxingGibbous => 'تثلیث فزون‌يابی';

  @override
  String get moonPhaseFullMoon => 'ماه کامل (بدر)';

  @override
  String get moonPhaseWaningGibbous => 'تثلیث کاست‌يابی';

  @override
  String get moonPhaseLastQuarter => 'تربیع آخر';

  @override
  String get moonPhaseWaningCrescent => 'هلال کاست‌يابی';

  @override
  String get whiteDaysSubtitle => 'روزهای روزه سنت (۱۳، ۱۴، ۱۵ هجری)';
}
