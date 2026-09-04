// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مساعد الصلاة';

  @override
  String get tabLocation => 'الموقع';

  @override
  String get tabToday => 'اليوم';

  @override
  String get tabDates => 'التواريخ';

  @override
  String get tabTesbih => 'مِسْبَحَة';

  @override
  String get tooltipToggleLightDark => 'تبديل فاتح/داكن';

  @override
  String get tooltipRemindersOn => 'تشغيل التذكيرات';

  @override
  String get tooltipRemindersOff => 'إيقاف التذكيرات';

  @override
  String get tooltipPreferences => 'التفضيلات';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes د';
  }

  @override
  String get remainingMinutesUnknown => '-- د';

  @override
  String get homeNoLocationTitle => 'لم يتم اختيار موقع';

  @override
  String get homeNoLocationSubtitle =>
      'اذهب إلى تبويب الموقع واحفظ منطقتك أولاً.';

  @override
  String get homeNoPrayerTimesTitle => 'لا توجد أوقات صلاة مخزنة';

  @override
  String get homeNoPrayerTimesSubtitle => 'اضغط تحديث لمزامنة بيانات السنة.';

  @override
  String get refresh => 'تحديث';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String qiblaBearing(int degrees) {
    return 'القبلة: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'تعذر تحديد موقعك. فعّل نظام تحديد المواقع وحاول مرة أخرى.';

  @override
  String get qiblaHeadingUnavailable =>
      'البوصلة غير متاحة - يتم عرض الاتجاه الثابت.';

  @override
  String get qiblaPointDevice => 'أدر جهازك حتى يشير السهم إلى الأعلى.';

  @override
  String get qiblaKaabaShort => 'القبلة';

  @override
  String get shareTodayTimes => 'مشاركة أوقات اليوم';

  @override
  String get calendarPreviousDay => 'اليوم السابق';

  @override
  String get calendarNextDay => 'اليوم التالي';

  @override
  String todayWithDate(Object date) {
    return 'اليوم • $date';
  }

  @override
  String get hijriUnknown => 'هجري: -';

  @override
  String hijriWithDate(Object date) {
    return 'هجري: $date';
  }

  @override
  String get reminderSettingsTitle => 'إعدادات التذكير';

  @override
  String get reminderSettingsSubtitle =>
      'اضغط على أي وقت صلاة بالأعلى لضبط التذكير وعدد الدقائق قبلها.';

  @override
  String get tooltipScheduledDebug => 'تصحيح التذكيرات المجدولة';

  @override
  String get scheduledRemindersDebugTitle => 'التذكيرات المجدولة (تصحيح)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'الإشعارات المعلقة: $count';
  }

  @override
  String get sendTestNotificationNow => 'إرسال إشعار تجريبي';

  @override
  String get testNotificationSent => 'تم إرسال الإشعار التجريبي.';

  @override
  String get statusBarMinutesTitle => 'دقائق شريط الحالة';

  @override
  String get statusBarMinutesSubtitle =>
      'إظهار إشعار مستمر للدقائق المتبقية في شريط الحالة.';

  @override
  String get statusAutoRestoreTitle => 'إعادة تلقائية عند الإزالة';

  @override
  String get statusAutoRestoreSubtitle =>
      'إعادة إنشاء عنصر الحالة إذا قام المستخدم بإزالته.';

  @override
  String get noPendingReminders => 'لا توجد تذكيرات معلقة.';

  @override
  String get unknownFireTime => 'وقت غير معروف';

  @override
  String get pastPrefix => '[مضى] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'مفعل • في الوقت + قبل $minutes د';
  }

  @override
  String get reminderOnTimeOnly => 'مفعل • في الوقت';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'مفعل • قبل $minutes د';
  }

  @override
  String get reminderOff => 'التذكير متوقف';

  @override
  String get nextPrayerTitle => 'الصلاة التالية';

  @override
  String get homeUpcomingRemindersTitle => 'التذكيرات القادمة';

  @override
  String startsIn(Object remaining) {
    return 'تبدأ بعد $remaining';
  }

  @override
  String get selectYourLocation => 'اختر موقعك';

  @override
  String get locationHelp =>
      'استخدم GPS للإعداد السريع أو اختر الدولة/المدينة يدويًا.';

  @override
  String get useCurrentLocation => 'استخدم الموقع الحالي';

  @override
  String get country => 'الدولة';

  @override
  String get stateCity => 'الولاية / المدينة';

  @override
  String get district => 'المنطقة';

  @override
  String get saveLocation => 'حفظ الموقع';

  @override
  String selectedLocation(Object location) {
    return 'المحدد: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'اختر موقعًا أولًا لعرض قائمة الصلاة لسنة كاملة.';

  @override
  String get historyTableTitle => 'جدول أوقات الصلاة (سنة كاملة)';

  @override
  String get todayShort => 'اليوم';

  @override
  String get dateHeader => 'التاريخ';

  @override
  String get imsak => 'فجر';

  @override
  String get gunes => 'شروق';

  @override
  String get ogle => 'ظهر';

  @override
  String get ikindi => 'عصر';

  @override
  String get aksam => 'مغرب';

  @override
  String get yatsi => 'عشاء';

  @override
  String get hijriHeader => 'هجري';

  @override
  String get preferencesTitle => 'التفضيلات';

  @override
  String get languageTitle => 'اللغة';

  @override
  String get languageSystem => 'افتراضي النظام';

  @override
  String get themeModeTitle => 'وضع المظهر';

  @override
  String get themeSystem => 'افتراضي النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get appBarRemainingTitle => 'نص الوقت المتبقي في شريط التطبيق';

  @override
  String get showInTitle => 'إظهار في العنوان';

  @override
  String get showAtRight => 'إظهار في اليمين';

  @override
  String get showAsSubtitle => 'إظهار كعنوان فرعي';

  @override
  String get hideRemainingText => 'إخفاء النص المتبقي';

  @override
  String get notificationMessageTitle => 'رسالة الإشعار';

  @override
  String get notificationMessageShown => 'ظاهرة';

  @override
  String get notificationMessageHidden => 'مخفية';

  @override
  String get widgetTextSizeTitle => 'حجم خط الودجت';

  @override
  String get widgetTextSizeSubtitle =>
      'حجم الخط المستخدم في ودجتات الشاشة الرئيسية.';

  @override
  String get widgetTextSizeExtraSmall => 'صغير جدًا';

  @override
  String get widgetTextSizeSmall => 'صغير';

  @override
  String get widgetTextSizeMedium => 'متوسط';

  @override
  String get widgetTextSizeLarge => 'كبير';

  @override
  String get widgetMmssThresholdTitle => 'عد تنازلي بالثواني في الودجت';

  @override
  String get widgetMmssThresholdNever => 'عرض HH:MM دائمًا';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS أقل من $minutes دقيقة';
  }

  @override
  String get remindersOnOffTitle => 'التذكيرات تشغيل/إيقاف';

  @override
  String get remindersOnOffSubtitle =>
      'تشغيل أو إيقاف إشعارات تذكير الصلاة مع الاحتفاظ بإعدادات كل صلاة.';

  @override
  String get reminderVibrationTitle => 'الاهتزاز عند التذكير';

  @override
  String get reminderVibrationSubtitle =>
      'اهتزاز نابض لمدة 10 ثوانٍ تقريبًا عند تفعيل التذكير.';

  @override
  String get reminderSoundTitle => 'تشغيل الصوت عند التذكير';

  @override
  String get reminderSoundSubtitle => 'تشغيل صوت الإشعار عند تفعيل التذكير.';

  @override
  String get remindersOn => 'تشغيل';

  @override
  String get remindersOff => 'إيقاف';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'تذكير $prayer';
  }

  @override
  String get reminderTypeTitle => 'نوع التذكير (يمكن اختيار الاثنين)';

  @override
  String get onTime => 'في الوقت';

  @override
  String get before => 'قبل';

  @override
  String get after => 'بعد';

  @override
  String get reminderAlertTitle => 'التنبيه';

  @override
  String get reminderAlertSubtitle =>
      'يتطلب أيضًا تفعيل المفتاح المطابق في التفضيلات ليعمل التنبيه فعليًا.';

  @override
  String get vibrateChip => 'اهتزاز';

  @override
  String get soundChip => 'صوت';

  @override
  String get adhanChip => 'أذان';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total صلاة مكتملة';
  }

  @override
  String get holiday_islamic_new_year => 'رأس السنة الهجرية';

  @override
  String get holiday_ashura => 'عاشوراء';

  @override
  String get holiday_mawlid => 'المولد النبوي';

  @override
  String get holiday_isra_miraj => 'الإسراء والمعراج';

  @override
  String get holiday_laylat_barat => 'ليلة البراءة';

  @override
  String get holiday_ramadan_first => 'أول يوم رمضان';

  @override
  String get holiday_laylat_qadr => 'ليلة القدر';

  @override
  String get holiday_eid_fitr => 'عيد الفطر';

  @override
  String get holiday_arafah => 'يوم عرفة';

  @override
  String get holiday_eid_adha => 'عيد الأضحى';

  @override
  String get remindBeforePrayerTitle => 'ذكّرني قبل الصلاة';

  @override
  String get remindAfterPrayerTitle => 'ذكّرني بعد الصلاة';

  @override
  String minutesValue(Object minutes) {
    return '$minutes د';
  }

  @override
  String get custom => 'مخصص';

  @override
  String get customMinutes => 'دقائق مخصصة';

  @override
  String get customMinutesHint => 'مثال: 12';

  @override
  String get save => 'حفظ';

  @override
  String get enableBeforeToSelectMinutes => 'فعّل \"قبل\" لاختيار الدقائق.';

  @override
  String get enableAfterToSelectMinutes => 'فعّل \"بعد\" لاختيار الدقائق.';

  @override
  String get enterValidPositiveNumber => 'أدخل رقمًا موجبًا صحيحًا.';

  @override
  String get useValueUpTo240 => 'استخدم قيمة حتى 240 دقيقة.';

  @override
  String get customMinutesSaved => 'تم حفظ الدقائق المخصصة.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get calendarTabTooltip => 'التقويم الهجري';

  @override
  String get calendarPreviousMonth => 'الشهر السابق';

  @override
  String get calendarNextMonth => 'الشهر التالي';

  @override
  String get calendarSwapPrimary => 'تبديل الهجري/الميلادي';

  @override
  String get calendarShowSecondary => 'إظهار التاريخ الثانوي';

  @override
  String get calendarHideSecondary => 'إخفاء التاريخ الثانوي';

  @override
  String get calendarNoRemindersOnDay => 'لا توجد تذكيرات في هذا اليوم';

  @override
  String get calendarAddReminder => 'إضافة تذكير';

  @override
  String get calendarEditReminder => 'تعديل';

  @override
  String get calendarDeleteReminder => 'حذف';

  @override
  String get calendarReminderFormTitleNew => 'تذكير جديد';

  @override
  String get calendarReminderFormTitleEdit => 'تعديل التذكير';

  @override
  String get calendarReminderTitleLabel => 'العنوان';

  @override
  String get calendarReminderTitleHint => 'مثال: بداية رمضان';

  @override
  String get calendarReminderNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get calendarReminderDateTimeLabel => 'التاريخ والوقت';

  @override
  String get calendarReminderRecurrenceLabel => 'التكرار';

  @override
  String get calendarRecurrenceOnce => 'مرة واحدة';

  @override
  String get calendarRecurrenceDaily => 'يوميًا';

  @override
  String get calendarRecurrenceWeekly => 'أسبوعيًا';

  @override
  String get calendarRecurrenceMonthly => 'شهريًا';

  @override
  String get calendarRecurrenceYearly => 'سنويًا';

  @override
  String get calendarRepeatCountLabel => 'عدد التكرار';

  @override
  String get calendarRepeatCountHelper =>
      'عدد مرات تشغيل التذكير قبل التوقف (إيقاف = يتكرر دائمًا)';

  @override
  String get calendarRepeatCountError => 'أدخل رقمًا من 2 إلى 100';

  @override
  String get calendarRepeatDaysLabel => 'التكرار في';

  @override
  String get calendarDayOfMonthLabel => 'يوم من الشهر';

  @override
  String get calendarYearlyMonthLabel => 'الشهر';

  @override
  String get calendarYearlyDayLabel => 'اليوم';

  @override
  String get calendarMonthlyBasisLabel => 'الأساس الشهري';

  @override
  String get calendarYearlyBasisLabel => 'الأساس السنوي';

  @override
  String get calendarYearlyBasisGregorian => 'ميلادي';

  @override
  String get calendarYearlyBasisHijri => 'هجري';

  @override
  String get calendarReminderTitleRequired => 'أدخل عنوانًا';

  @override
  String get calendarAnchorClockTime => 'تاريخ التقويم';

  @override
  String get calendarAnchorPrayerTime => 'وقت الصلاة';

  @override
  String get calendarSelectPrayer => 'اختر الصلاة';

  @override
  String get calendarOffsetOnTime => 'في الوقت';

  @override
  String get calendarOffsetBefore => 'قبل';

  @override
  String get calendarOffsetAfter => 'بعد';

  @override
  String get calendarPickAnchorDate => 'اختر التاريخ';

  @override
  String get datesPrayerTimesTab => 'أوقات الصلاة';

  @override
  String get datesCalendarTab => 'التقويم';

  @override
  String get undo => 'تراجع';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" تم الحذف';
  }

  @override
  String get verseOfTheDay => 'آية اليوم';

  @override
  String get hadithOfTheDay => 'حديث اليوم';

  @override
  String get hisnAlMuslimTitle => 'حصن المسلم';

  @override
  String get morningAdhkar => 'أذكار الصباح';

  @override
  String get eveningAdhkar => 'أذكار المساء';

  @override
  String get afterPrayerAdhkar => 'أذكار بعد الصلاة';

  @override
  String get sleepingAdhkar => 'أذكار النوم';

  @override
  String get dailyLifeDuas => 'أدعية الحياة اليومية';

  @override
  String get shareWisdom => 'مشاركة';

  @override
  String get copyText => 'نسخ';

  @override
  String get copiedToClipboard => 'تم النسخ إلى الحافظة';

  @override
  String get searchSupplicationsHint => 'البحث في الأدعية واللوائح...';

  @override
  String get noSupplicationsFound => 'لم يتم العثور على أدعية';

  @override
  String get completed => 'مكتمل';

  @override
  String get tapToCount => 'اضغط للعد';

  @override
  String get tabAll => 'الكل';

  @override
  String get kazaTitle => 'القضاء';

  @override
  String get kazaSubtitle => 'حساب ومتابعة قضاء الصلوات الفائتة';

  @override
  String get kazaCalculatorWizard => 'الحاسبة';

  @override
  String get kazaBatchLogDay => '+١ يوم كامل';

  @override
  String get kazaBatchLogDayTooltip => 'زيادة صلاة واحدة لكل الصلوات الست';

  @override
  String get kazaTotalRemaining => 'إجمالي المتبقي';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return 'تم قضاء $completed من $target';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'تاريخ الإتمام المتوقع: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'تم قضاء جميع الصلوات الفائتة! 🎉';

  @override
  String get kazaDailyPaceLabel => 'المعدل اليومي';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count صلاة / يوم';
  }

  @override
  String get kazaSetPaceDialogTitle => 'تحديد المعدل اليومي';

  @override
  String get kazaSetPaceDialogSubtitle => 'كم صلاة فائتة تقضيها كل يوم؟';

  @override
  String get kazaCalculatorTitle => 'حاسبة الصلوات الفائتة';

  @override
  String get kazaCalculateByYears => 'حسب المدة';

  @override
  String get kazaCalculateManual => 'إدخال يدوي';

  @override
  String get kazaYearsMissed => 'عدد السنوات الفائتة';

  @override
  String get kazaMonthsMissed => 'أشهر إضافية';

  @override
  String get kazaCalculateButton => 'حفظ الأهداف';

  @override
  String get kazaWitrLabel => 'الوتر';

  @override
  String kazaRemainingCount(Object count) {
    return '$count متبقٍ';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'عدد صلاة $name المقضية';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days يوم لكل صلاة ($total صلاة إجمالاً)';
  }

  @override
  String get backupExportTitle => 'النسخ الاحتياطي والتصدير';

  @override
  String get backupExportSubtitle =>
      'نسخ بيانات التطبيق احتياطياً أو تصدير التقويم';

  @override
  String get exportBackupJson => 'تصدير النسخة الاحتياطية (JSON)';

  @override
  String get restoreBackupJson => 'استعادة البيانات من النسخة الاحتياطية';

  @override
  String get exportPrayerScheduleIcs => 'تصدير مواقيت الصلاة (.ics)';

  @override
  String get exportHolidaysIcs => 'تصدير المناسبات الإسلامية (.ics)';

  @override
  String get restoreConfirmTitle => 'استعادة بيانات التطبيق؟';

  @override
  String get restoreConfirmBody =>
      'سيتم استعادة أهداف القضاء وسجل الصلاة والتذكيرات والتسبيحات. هل تريد الاستمرار؟';

  @override
  String get restoreSuccess => 'تمت استعادة البيانات بنجاح!';

  @override
  String get restoreError => 'تنسيق ملف النسخة الاحتياطية غير صالح';

  @override
  String get shareOrSave => 'مشاركة / حفظ';

  @override
  String get analyticsTab => 'التحليلات';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get longestStreak => 'أطول سلسلة';

  @override
  String get daysUnit => 'أيام';

  @override
  String get monthlyHeatmapTitle => 'الإكمال الشهري';

  @override
  String get completionBreakdownTitle => 'توزيع الصلوات';

  @override
  String get overallConsistency => 'الاستمرارية العامة';

  @override
  String get totalPrayersCompleted => 'إجمالي الصلوات المسجلة';

  @override
  String get last30Days => 'آخر 30 يومًا';

  @override
  String get allTime => 'كل الأوقات';

  @override
  String get fastingTitle => 'الصيام';

  @override
  String get suhoorCountdownTitle => 'حتى السحور';

  @override
  String get iftarCountdownTitle => 'حتى الإفطار';

  @override
  String get fastingTypeRamadan => 'صيام رمضان';

  @override
  String get fastingTypeSunnah => 'صيام سنة';

  @override
  String get fastingTypeQadaa => 'صيام قضاء';

  @override
  String get whiteDaysTitle => 'الأيام البيض (13، 14، 15)';

  @override
  String get mondayThursdayTitle => 'سنة الإثنين والخميس';

  @override
  String get logFastAction => 'تسجيل الصوم';

  @override
  String get totalFastsLogged => 'إجمالي الأيام المصومة';

  @override
  String get suhoorEndsIn => 'ينتهي السحور خلال';

  @override
  String get iftarIn => 'الإفطار خلال';

  @override
  String get fastingTab => 'الصيام';

  @override
  String get trackTabTitle => 'تتبع';

  @override
  String get prayerAnalyticsTitle => 'تحليلات الصلاة';

  @override
  String get prayerQadaaTitle => 'قضاء الصلاة';

  @override
  String get iftarTimeLabel => 'وقت الإفطار';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent٪ صيام';
  }

  @override
  String get suhoorTickerTitle => 'مؤقت السحور';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent٪ مضى';
  }

  @override
  String suhoorWithTime(String time) {
    return 'السحور ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'الإفطار ($time)';
  }

  @override
  String get upcomingSunnahDays => 'أيام السنة القادمة';

  @override
  String get fastingCalendarLogger => 'سجل تقويم الصيام';

  @override
  String get removeFastLog => 'إزالة سجل الصيام';

  @override
  String get calendarWeekStartTitle => 'بداية الأسبوع في التقويم';

  @override
  String get calendarWeekStartSunday => 'الأحد';

  @override
  String get calendarWeekStartMonday => 'الإثنين';

  @override
  String get hijriDateOffsetTitle => 'تعديل التاريخ الهجري';

  @override
  String get hijriDateOffsetSubtitle =>
      'تعديل التاريخ الهجري حسب رؤية الهلال المحلية';

  @override
  String get showIslamicHolidaysTitle => 'تمييز المناسبات الإسلامية';

  @override
  String get showIslamicHolidaysSubtitle =>
      'إظهار شارات خاصة للأيام المباركة والمناسبات';

  @override
  String get showFastingBadgesTitle => 'إظهار سجلات الصيام على التقويم';

  @override
  String get showFastingBadgesSubtitle =>
      'إظهار شارات في الأيام المسجلة للصيام';

  @override
  String get defaultCalendarDisplayTitle => 'عرض التقويم الافتراضي';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'النوع الافتراضي عند فتح التقويم';

  @override
  String get showCalendarReminderDotsTitle => 'إظهار نقاط التذكير';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'إظهار نقاط في الأيام التي تحتوي على تذكيرات';

  @override
  String get calendarSettingsSectionTitle => 'إعدادات التقويم';
}
