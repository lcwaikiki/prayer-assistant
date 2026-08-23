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
  String get tabTesbih => 'تسبیح';

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
  String get qiblaTitle => 'قبلہ';

  @override
  String qiblaBearing(int degrees) {
    return 'قبلہ: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'آپ کا مقام معلوم نہیں ہو سکا۔ GPS آن کر کے دوبارہ کوشش کریں۔';

  @override
  String get qiblaHeadingUnavailable =>
      'قطب نما دستیاب نہیں - مقررہ سمت دکھائی جا رہی ہے۔';

  @override
  String get qiblaPointDevice =>
      'جب تک سوئی اوپر کی طرف نہ اشارہ کرے اپنا آلہ گھمائیں۔';

  @override
  String get qiblaKaabaShort => 'قبلہ';

  @override
  String get shareTodayTimes => 'آج کے اوقات شیئر کریں';

  @override
  String get calendarPreviousDay => 'پچھلا دن';

  @override
  String get calendarNextDay => 'اگلا دن';

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
  String get homeUpcomingRemindersTitle => 'آنے والی یاد دہانیاں';

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
  String get imsak => 'فجر';

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
  String get widgetTextSizeTitle => 'ویجٹ متن کا سائز';

  @override
  String get widgetTextSizeSubtitle =>
      'ہوم اسکرین ویجٹس میں استعمال ہونے والے متن کا سائز۔';

  @override
  String get widgetTextSizeExtraSmall => 'بہت چھوٹا';

  @override
  String get widgetTextSizeSmall => 'چھوٹا';

  @override
  String get widgetTextSizeMedium => 'درمیانہ';

  @override
  String get widgetTextSizeLarge => 'بڑا';

  @override
  String get widgetMmssThresholdTitle => 'ویجٹ میں سیکنڈ کاؤنٹ ڈاؤن';

  @override
  String get widgetMmssThresholdNever => 'ہمیشہ HH:MM دکھائیں';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes منٹ سے کم پر MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'یاد دہانیاں آن/آف';

  @override
  String get remindersOnOffSubtitle =>
      'نماز کی یاد دہانی آن یا آف کریں۔ ہر نماز کی سیٹنگز محفوظ رہیں گی۔';

  @override
  String get reminderVibrationTitle => 'یاد دہانی پر وائبریشن';

  @override
  String get reminderVibrationSubtitle =>
      'یاد دہانی پر تقریباً 10 سیکنڈ تک وقفے وقفے سے وائبریشن ہو۔';

  @override
  String get reminderSoundTitle => 'یاد دہانی پر آواز چلائیں';

  @override
  String get reminderSoundSubtitle => 'یاد دہانی پر نوٹیفکیشن کی آواز چلائیں۔';

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
  String get after => 'بعد میں';

  @override
  String get reminderAlertTitle => 'الرٹ';

  @override
  String get reminderAlertSubtitle =>
      'دراصل الرٹ کرنے کے لیے ترجیحات میں متعلقہ سوئچ کا آن ہونا بھی ضروری ہے۔';

  @override
  String get vibrateChip => 'وائبریشن';

  @override
  String get soundChip => 'آواز';

  @override
  String get adhanChip => 'اذان';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total نمازیں مکمل';
  }

  @override
  String get holiday_islamic_new_year => 'اسلامی نیا سال';

  @override
  String get holiday_ashura => 'عاشورہ';

  @override
  String get holiday_mawlid => 'میلاد النبی';

  @override
  String get holiday_isra_miraj => 'اسراء اور معراج';

  @override
  String get holiday_laylat_barat => 'شب برات';

  @override
  String get holiday_ramadan_first => 'پہلا رمضان';

  @override
  String get holiday_laylat_qadr => 'شب قدر';

  @override
  String get holiday_eid_fitr => 'عید الفطر';

  @override
  String get holiday_arafah => 'یوم عرفہ';

  @override
  String get holiday_eid_adha => 'عید الاضحی';

  @override
  String get remindBeforePrayerTitle => 'نماز سے پہلے یاد دلائیں';

  @override
  String get remindAfterPrayerTitle => 'نماز کے بعد یاد دلائیں';

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
  String get enableAfterToSelectMinutes =>
      'منٹس منتخب کرنے کے لیے \"بعد میں\" فعال کریں۔';

  @override
  String get enterValidPositiveNumber => 'درست مثبت نمبر درج کریں۔';

  @override
  String get useValueUpTo240 => '240 منٹ تک کی قدر استعمال کریں۔';

  @override
  String get customMinutesSaved => 'کسٹم منٹس محفوظ ہو گئے۔';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get calendarTabTooltip => 'ہجری کیلنڈر';

  @override
  String get calendarPreviousMonth => 'پچھلا مہینہ';

  @override
  String get calendarNextMonth => 'اگلا مہینہ';

  @override
  String get calendarSwapPrimary => 'ہجری/عیسوی تبدیل کریں';

  @override
  String get calendarShowSecondary => 'ثانوی تاریخ دکھائیں';

  @override
  String get calendarHideSecondary => 'ثانوی تاریخ چھپائیں';

  @override
  String get calendarNoRemindersOnDay => 'اس دن کوئی یاد دہانی نہیں';

  @override
  String get calendarAddReminder => 'یاد دہانی شامل کریں';

  @override
  String get calendarEditReminder => 'ترمیم کریں';

  @override
  String get calendarDeleteReminder => 'حذف کریں';

  @override
  String get calendarReminderFormTitleNew => 'نئی یاد دہانی';

  @override
  String get calendarReminderFormTitleEdit => 'یاد دہانی میں ترمیم کریں';

  @override
  String get calendarReminderTitleLabel => 'عنوان';

  @override
  String get calendarReminderTitleHint => 'مثلاً رمضان کا آغاز';

  @override
  String get calendarReminderNotesLabel => 'نوٹس (اختیاری)';

  @override
  String get calendarReminderDateTimeLabel => 'تاریخ اور وقت';

  @override
  String get calendarReminderRecurrenceLabel => 'تکرار';

  @override
  String get calendarRecurrenceOnce => 'ایک بار';

  @override
  String get calendarRecurrenceDaily => 'روزانہ';

  @override
  String get calendarRecurrenceWeekly => 'ہفتہ وار';

  @override
  String get calendarRecurrenceMonthly => 'ماہانہ';

  @override
  String get calendarRecurrenceYearly => 'سالانہ';

  @override
  String get calendarRepeatCountLabel => 'تکرار کی تعداد';

  @override
  String get calendarRepeatCountHelper =>
      'یاد دہانی رکنے سے پہلے کتنی بار چلے گی (بند = ہمیشہ دہرائی جائے)';

  @override
  String get calendarRepeatCountError => '2 سے 100 تک نمبر درج کریں';

  @override
  String get calendarRepeatDaysLabel => 'دہرائیں';

  @override
  String get calendarDayOfMonthLabel => 'مہینے کا دن';

  @override
  String get calendarYearlyMonthLabel => 'مہینہ';

  @override
  String get calendarYearlyDayLabel => 'دن';

  @override
  String get calendarMonthlyBasisLabel => 'ماہانہ بنیاد';

  @override
  String get calendarYearlyBasisLabel => 'سالانہ بنیاد';

  @override
  String get calendarYearlyBasisGregorian => 'عیسوی';

  @override
  String get calendarYearlyBasisHijri => 'ہجری';

  @override
  String get calendarReminderTitleRequired => 'ایک عنوان درج کریں';

  @override
  String get calendarAnchorClockTime => 'کیلنڈر تاریخ';

  @override
  String get calendarAnchorPrayerTime => 'نماز کا وقت';

  @override
  String get calendarSelectPrayer => 'نماز منتخب کریں';

  @override
  String get calendarOffsetOnTime => 'وقت پر';

  @override
  String get calendarOffsetBefore => 'پہلے';

  @override
  String get calendarOffsetAfter => 'بعد میں';

  @override
  String get calendarPickAnchorDate => 'تاریخ منتخب کریں';

  @override
  String get datesPrayerTimesTab => 'نماز کے اوقات';

  @override
  String get datesCalendarTab => 'کیلنڈر';

  @override
  String get undo => 'واپس لائیں';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" حذف ہوگیا';
  }

  @override
  String get verseOfTheDay => 'آج کی آیت';

  @override
  String get hadithOfTheDay => 'آج کی حدیث';

  @override
  String get hisnAlMuslimTitle => 'حصن المسلم';

  @override
  String get morningAdhkar => 'صبح کے اذکار';

  @override
  String get eveningAdhkar => 'شام کے اذکار';

  @override
  String get afterPrayerAdhkar => 'نماز کے بعد کے اذکار';

  @override
  String get sleepingAdhkar => 'سوتے وقت کے اذکار';

  @override
  String get dailyLifeDuas => 'روزمرہ کی دعائیں';

  @override
  String get shareWisdom => 'شیئر کریں';

  @override
  String get copyText => 'کاپی کریں';

  @override
  String get copiedToClipboard => 'کلپ بورڈ پر کاپی ہو گیا';

  @override
  String get searchSupplicationsHint => 'دعاؤں میں تلاش کریں...';

  @override
  String get noSupplicationsFound => 'کوئی دعا نہیں ملی';

  @override
  String get completed => 'مکمل';

  @override
  String get tapToCount => 'گننے کے لیے ٹیپ کریں';

  @override
  String get tabAll => 'تمام';

  @override
  String get kazaTitle => 'قضاء';

  @override
  String get kazaSubtitle => 'قضاء نمازوں کا حساب اور اندراج کریں';

  @override
  String get kazaCalculatorWizard => 'حساب کار';

  @override
  String get kazaBatchLogDay => '+1 مکمل دن';

  @override
  String get kazaBatchLogDayTooltip => 'تمام 6 نمازوں میں 1 کا اضافہ کریں';

  @override
  String get kazaTotalRemaining => 'کل باقی';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target مکمل';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'تخمینی تکمیل: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'تمام قضاء نمازیں مکمل ہو گئیں! 🎉';

  @override
  String get kazaDailyPaceLabel => 'روزانہ کی رفتار';

  @override
  String kazaDailyPaceValue(Object count) {
    return 'روزانہ $count نمازیں';
  }

  @override
  String get kazaSetPaceDialogTitle => 'روزانہ کی رفتار مقرر کریں';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'آپ روزانہ کتنی قضاء نمازیں پڑھتے ہیں؟';

  @override
  String get kazaCalculatorTitle => 'قضاء نمازوں کا حساب کار';

  @override
  String get kazaCalculateByYears => 'وقت کے حساب سے';

  @override
  String get kazaCalculateManual => 'دستی اندراج';

  @override
  String get kazaYearsMissed => 'چھوٹے ہوئے سال';

  @override
  String get kazaMonthsMissed => 'مزید مہینے';

  @override
  String get kazaCalculateButton => 'محفوظ کریں';

  @override
  String get kazaWitrLabel => 'وتر';

  @override
  String kazaRemainingCount(Object count) {
    return '$count باقی';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name مکمل شدہ تعداد';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= ہر نماز کے $days دن (کل $total نمازیں)';
  }

  @override
  String get backupExportTitle => 'بیک اپ اور ایکسپورٹ';

  @override
  String get backupExportSubtitle =>
      'ایپ کا ڈیٹا بیک اپ کریں یا کیلنڈر ایکسپورٹ کریں';

  @override
  String get exportBackupJson => 'بیک اپ ڈیٹا ایکسپورٹ کریں (JSON)';

  @override
  String get restoreBackupJson => 'بیک اپ سے ڈیٹا ری اسٹور کریں';

  @override
  String get exportPrayerScheduleIcs => 'اوقاتِ نماز ایکسپورٹ کریں (.ics)';

  @override
  String get exportHolidaysIcs => 'اسلامی ایام ایکسپورٹ کریں (.ics)';

  @override
  String get restoreConfirmTitle => 'ڈیٹا ری اسٹور کریں؟';

  @override
  String get restoreConfirmBody =>
      'آپ کے قضا کے اہداف، نماز کی ہسٹری، ریمائنڈرز اور تسبیحات کا ڈیٹا ری اسٹور ہو جائے گا۔ جاری رکھیں؟';

  @override
  String get restoreSuccess => 'ڈیٹا کامیابی کے ساتھ ری اسٹور ہو گیا!';

  @override
  String get restoreError => 'بیک اپ فائل کا فارمیٹ غلط ہے';

  @override
  String get shareOrSave => 'شیئر / محفوظ کریں';

  @override
  String get analyticsTab => 'تجزیہ';

  @override
  String get currentStreak => 'موجودہ تسلسل';

  @override
  String get longestStreak => 'طویل ترین تسلسل';

  @override
  String get daysUnit => 'دن';

  @override
  String get monthlyHeatmapTitle => 'ماہانہ تکمیل';

  @override
  String get completionBreakdownTitle => 'نماز کی تقسیم';

  @override
  String get overallConsistency => 'مجموعی تسلسل';

  @override
  String get totalPrayersCompleted => 'کل ادا کردہ نمازیں';

  @override
  String get last30Days => 'آخری 30 دن';

  @override
  String get allTime => 'تمام وقت';

  @override
  String get fastingTitle => 'روزہ';

  @override
  String get suhoorCountdownTitle => 'سحری کا بقایا وقت (امساک)';

  @override
  String get iftarCountdownTitle => 'افطار کا بقایا وقت (مغرب)';

  @override
  String get fastingTypeRamadan => 'رمضان کا روزہ';

  @override
  String get fastingTypeSunnah => 'سنت روزہ';

  @override
  String get fastingTypeQadaa => 'قضا روزہ';

  @override
  String get whiteDaysTitle => 'ایام بیض (13، 14، 15)';

  @override
  String get mondayThursdayTitle => 'پیر اور جمعرات کی سنت';

  @override
  String get logFastAction => 'روزہ درج کریں';

  @override
  String get totalFastsLogged => 'کل رکھے گئے روزے';

  @override
  String get suhoorEndsIn => 'سحری کا وقت ختم ہونے میں';

  @override
  String get iftarIn => 'افطار میں باقی';

  @override
  String get fastingTab => 'روزہ';

  @override
  String get trackTabTitle => 'ٹریک';

  @override
  String get prayerAnalyticsTitle => 'نماز تجزیات';

  @override
  String get prayerQadaaTitle => 'قضا نمازیں';

  @override
  String get iftarTimeLabel => 'افطار کا وقت';
}
