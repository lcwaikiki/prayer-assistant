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
}
