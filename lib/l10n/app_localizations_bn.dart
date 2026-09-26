// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appTitle => 'নামাজ সহায়ক';

  @override
  String get tabLocation => 'অবস্থান';

  @override
  String get tabToday => 'আজ';

  @override
  String get tabDates => 'তারিখ';

  @override
  String get tabTesbih => 'তসবীহ';

  @override
  String get tooltipToggleLightDark => 'লাইট/ডার্ক পরিবর্তন করুন';

  @override
  String get tooltipRemindersOn => 'অনুস্মারক চালু করুন';

  @override
  String get tooltipRemindersOff => 'অনুস্মারক বন্ধ করুন';

  @override
  String get tooltipPreferences => 'পছন্দসমূহ';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get remainingMinutesUnknown => '-- মিনিট';

  @override
  String get homeNoLocationTitle => 'কোন অবস্থান নির্বাচিত হয়নি';

  @override
  String get homeNoLocationSubtitle =>
      'অবস্থান ট্যাবে যান এবং প্রথমে আপনার জেলা সংরক্ষণ করুন।';

  @override
  String get homeNoPrayerTimesTitle => 'ক্যাশে নামাজের সময় নেই';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'বার্ষিক ডেটা সিঙ্ক করতে রিফ্রেশ চাপুন।';

  @override
  String get refresh => 'রিফ্রেশ';

  @override
  String get qiblaTitle => 'কিবলা';

  @override
  String qiblaBearing(int degrees) {
    return 'কিবলা: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'আপনার অবস্থান নির্ধারণ করা যায়নি। GPS চালু করে আবার চেষ্টা করুন।';

  @override
  String get qiblaHeadingUnavailable =>
      'কম্পাস অনুপলব্ধ - নির্দিষ্ট দিক দেখানো হচ্ছে।';

  @override
  String get qiblaPointDevice =>
      'তীরটি উপরের দিকে নির্দেশ না করা পর্যন্ত আপনার ডিভাইসটি ঘোরান।';

  @override
  String get qiblaKaabaShort => 'কিবলা';

  @override
  String get shareTodayTimes => 'আজকের নামাজের সময় শেয়ার করুন';

  @override
  String get calendarPreviousDay => 'আগের দিন';

  @override
  String get calendarNextDay => 'পরের দিন';

  @override
  String todayWithDate(Object date) {
    return 'আজ • $date';
  }

  @override
  String get hijriUnknown => 'হিজরি: -';

  @override
  String hijriWithDate(Object date) {
    return 'হিজরি: $date';
  }

  @override
  String get reminderSettingsTitle => 'অনুস্মারক সেটিংস';

  @override
  String get reminderSettingsSubtitle =>
      'অনুস্মারক এবং কত মিনিট পূর্বে তা কনফিগার করতে উপরে যেকোনো নামাজের সময়ে ট্যাপ করুন।';

  @override
  String get tooltipScheduledDebug => 'নির্ধারিত অনুস্মারক ডিবাগ';

  @override
  String get scheduledRemindersDebugTitle => 'নির্ধারিত অনুস্মারক (ডিবাগ)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'মুলতবি বিজ্ঞপ্তি: $count';
  }

  @override
  String get sendTestNotificationNow => 'এখনই পরীক্ষামূলক বিজ্ঞপ্তি পাঠান';

  @override
  String get testNotificationSent => 'পরীক্ষামূলক বিজ্ঞপ্তি পাঠানো হয়েছে।';

  @override
  String get statusBarMinutesTitle => 'স্ট্যাটাস বার মিনিট';

  @override
  String get statusBarMinutesSubtitle =>
      'স্ট্যাটাস বারে চলমান অবশিষ্ট মিনিটের বিজ্ঞপ্তি দেখান।';

  @override
  String get statusAutoRestoreTitle => 'মুছে ফেলা হলে স্বয়ংক্রিয় পুনরুদ্ধার';

  @override
  String get statusAutoRestoreSubtitle =>
      'ব্যবহারকারী সোয়াইপ করে সরিয়ে দিলে স্ট্যাটাস আইটেমটি পুনরায় তৈরি করুন।';

  @override
  String get noPendingReminders => 'কোন মুলতবি অনুস্মারক বিজ্ঞপ্তি নেই।';

  @override
  String get unknownFireTime => 'অজানা সময়';

  @override
  String get pastPrefix => '[অতীত] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'চালু • সঠিক সময়ে + $minutes মিনিট আগে';
  }

  @override
  String get reminderOnTimeOnly => 'চালু • সঠিক সময়ে';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'চালু • $minutes মিনিট আগে';
  }

  @override
  String get reminderOff => 'অনুস্মারক বন্ধ';

  @override
  String get nextPrayerTitle => 'পরবর্তী নামাজ';

  @override
  String get homeUpcomingRemindersTitle => 'আসন্ন অনুস্মারক';

  @override
  String startsIn(Object remaining) {
    return '$remaining-এ শুরু হবে';
  }

  @override
  String get selectYourLocation => 'আপনার অবস্থান নির্বাচন করুন';

  @override
  String get locationHelp =>
      'দ্রুত সেটআপের জন্য GPS ব্যবহার করুন অথবা দেশ/শহর নির্বাচন করুন।';

  @override
  String get useCurrentLocation => 'বর্তমান অবস্থান ব্যবহার করুন';

  @override
  String get country => 'দেশ';

  @override
  String get stateCity => 'বিভাগ / শহর';

  @override
  String get district => 'জেলা';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get noResults => 'কোন ফলাফল পাওয়া যায়নি';

  @override
  String get noInternetTitle => 'ইন্টারনেট সংযোগ নেই';

  @override
  String get noInternetMessage =>
      'সার্ভারে পৌঁছানো সম্ভব হয়নি। আপনার ইন্টারনেট পরীক্ষা করে আবার চেষ্টা করুন।';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get saveLocation => 'অবস্থান সংরক্ষণ করুন';

  @override
  String selectedLocation(Object location) {
    return 'নির্বাচিত: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '১ বছরের নামাজের তালিকা দেখতে প্রথমে একটি অবস্থান নির্বাচন করুন।';

  @override
  String get historyTableTitle => 'নামাজের সময় সারণী (সম্পূর্ণ বছর)';

  @override
  String get todayShort => 'আজ';

  @override
  String get dateHeader => 'তারিখ';

  @override
  String get imsak => 'ফজর';

  @override
  String get gunes => 'সূর্যোদয়';

  @override
  String get ogle => 'যোহর';

  @override
  String get ikindi => 'আসর';

  @override
  String get aksam => 'মাগরিব';

  @override
  String get yatsi => 'ইশা';

  @override
  String get hijriHeader => 'হিজরি';

  @override
  String get preferencesTitle => 'পছন্দসমূহ';

  @override
  String get languageTitle => 'ভাষা';

  @override
  String get languageSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get themeModeTitle => 'থিম মোড';

  @override
  String get themeSystem => 'সিস্টেম ডিফল্ট';

  @override
  String get themeLight => 'লাইট';

  @override
  String get themeDark => 'ডার্ক';

  @override
  String get homeScreenSettingsSectionTitle => 'হোম স্ক্রিন সেটিংস';

  @override
  String get appBarRemainingTitle => 'হোম অ্যাপ বার অবশিষ্ট সময়';

  @override
  String get showInTitle => 'শিরোনামে দেখান';

  @override
  String get showAtRight => 'ডানপাশে দেখান';

  @override
  String get showAsSubtitle => 'উপশিরোনাম হিসেবে দেখান';

  @override
  String get hideRemainingText => 'অবশিষ্ট সময় লুকান';

  @override
  String get notificationMessageTitle => 'বিজ্ঞপ্তি বার্তা';

  @override
  String get notificationMessageShown => 'দৃশ্যমান';

  @override
  String get notificationMessageHidden => 'লুকানো';

  @override
  String get widgetSettingsSectionTitle => 'উইজেট সেটিংস';

  @override
  String get widgetTextSizeTitle => 'ফন্ট সাইজ';

  @override
  String get widgetTextSizeSubtitle => 'হোম স্ক্রিন উইজেটে ব্যবহৃত লেখার আকার।';

  @override
  String get widgetTextSizeExtraSmall => 'অতিরিক্ত ছোট';

  @override
  String get widgetTextSizeSmall => 'ছোট';

  @override
  String get widgetTextSizeMedium => 'মাঝারি';

  @override
  String get widgetTextSizeLarge => 'বড়';

  @override
  String widgetTextSizePreview(Object size) {
    return 'প্রিভিউ $size';
  }

  @override
  String get widgetMmssThresholdTitle => 'সেকেন্ড কাউন্টডাউন';

  @override
  String get widgetThemeTitle => 'পটভূমি থিম';

  @override
  String get widgetThemeSystem => 'সিস্টেম';

  @override
  String get widgetThemeLight => 'লাইট';

  @override
  String get widgetThemeDark => 'ডার্ক';

  @override
  String get widgetThemeTransparent => 'স্বচ্ছ';

  @override
  String get widgetCalendarDisplayTitle => 'ক্যালেন্ডার তারিখ প্রদর্শন';

  @override
  String get widgetCalendarDisplayBoth => 'উভয় (হিজরি ও গ্রেগরিয়ান)';

  @override
  String get widgetCalendarDisplayHijri => 'শুধুমাত্র হিজরি';

  @override
  String get widgetCalendarDisplayGregorian => 'শুধুমাত্র গ্রেগরিয়ান';

  @override
  String get widgetMmssThresholdNever => 'সবসময় HH:MM দেখান';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes মিনিটের নিচে MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'অনুস্মারক চালু/বন্ধ';

  @override
  String get remindersOnOffSubtitle =>
      'নামাজের অনুস্মারক বিজ্ঞপ্তি চালু বা বন্ধ করুন। প্রতিটি নামাজের সেটিংস সংরক্ষিত থাকবে।';

  @override
  String get reminderVibrationTitle => 'অনুস্মারকে কম্পন';

  @override
  String get reminderVibrationSubtitle =>
      'অনুস্মারক সক্রিয় হলে প্রায় ১০ সেকেন্ড স্পন্দিত হবে।';

  @override
  String get reminderSoundTitle => 'অনুস্মারকে শব্দ বাজান';

  @override
  String get reminderSoundSubtitle =>
      'অনুস্মারক সক্রিয় হলে বিজ্ঞপ্তি শব্দ বাজান।';

  @override
  String get remindersOn => 'চালু';

  @override
  String get remindersOff => 'বন্ধ';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer অনুস্মারক';
  }

  @override
  String get reminderTypeTitle =>
      'অনুস্মারকের ধরন (উভয়টি নির্বাচন করা যেতে পারে)';

  @override
  String get onTime => 'সঠিক সময়ে';

  @override
  String get before => 'আগে';

  @override
  String get after => 'পরে';

  @override
  String get reminderAlertTitle => 'সতর্কতা';

  @override
  String get reminderAlertSubtitle =>
      'সতর্কতা কার্যকর হতে পছন্দসমূহে সংশ্লিষ্ট সুইচ চালু থাকতে হবে।';

  @override
  String get vibrateChip => 'কম্পন';

  @override
  String get soundChip => 'শব্দ';

  @override
  String get adhanChip => 'আজান';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total নামাজ সম্পন্ন';
  }

  @override
  String get holiday_islamic_new_year => 'ইসলামি নববর্ষ';

  @override
  String get holiday_ashura => 'আশুরা';

  @override
  String get holiday_mawlid => 'ঈদে মিলাদুন্নবী';

  @override
  String get holiday_isra_miraj => 'শবে মেরাজ';

  @override
  String get holiday_laylat_barat => 'শবে বরাত';

  @override
  String get holiday_ramadan_first => 'পহেলা রমজান';

  @override
  String get holiday_laylat_qadr => 'শবে কদর';

  @override
  String get holiday_eid_fitr => 'ঈদুল ফিতর';

  @override
  String get holiday_arafah => 'আরাফার দিন';

  @override
  String get holiday_eid_adha => 'ঈদুল আজহা';

  @override
  String get remindBeforePrayerTitle => 'নামাজের আগে মনে করিয়ে দিন';

  @override
  String get remindAfterPrayerTitle => 'নামাজের পরে মনে করিয়ে দিন';

  @override
  String minutesValue(Object minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get custom => 'কাস্টম';

  @override
  String get customMinutes => 'কাস্টম মিনিট';

  @override
  String get customMinutesHint => 'যেমন: ১২';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get enableBeforeToSelectMinutes =>
      'মিনিট নির্বাচন করতে \"আগে\" সক্রিয় করুন।';

  @override
  String get enableAfterToSelectMinutes =>
      'মিনিট নির্বাচন করতে \"পরে\" সক্রিয় করুন।';

  @override
  String get enterValidPositiveNumber => 'একটি বৈধ ধনাত্মক সংখ্যা লিখুন।';

  @override
  String get useValueUpTo240 => '২৪০ মিনিট পর্যন্ত মান ব্যবহার করুন।';

  @override
  String get customMinutesSaved => 'কাস্টম মিনিট সংরক্ষিত হয়েছে।';

  @override
  String get cancel => 'বাতিল';

  @override
  String get calendarTabTooltip => 'হিজরি ক্যালেন্ডার';

  @override
  String get calendarPreviousMonth => 'আগের মাস';

  @override
  String get calendarNextMonth => 'পরের মাস';

  @override
  String get calendarSwapPrimary => 'হিজরি/গ্রেগরিয়ান পরিবর্তন করুন';

  @override
  String get calendarShowSecondary => 'গৌণ তারিখ দেখান';

  @override
  String get calendarHideSecondary => 'গৌণ তারিখ লুকান';

  @override
  String get calendarNoRemindersOnDay => 'এই দিনে কোন অনুস্মারক নেই';

  @override
  String get calendarAddReminder => 'অনুস্মারক যোগ করুন';

  @override
  String get calendarEditReminder => 'সম্পাদনা';

  @override
  String get calendarDeleteReminder => 'মুছুন';

  @override
  String get calendarDeleteOccurrence => 'এই পুনরাবৃত্তি মুছুন';

  @override
  String get calendarDeleteOccurrenceConfirm =>
      'সিরিজ থেকে শুধু এই দিনটি বাদ দেবেন?';

  @override
  String get calendarOccurrenceDeleted => 'পুনরাবৃত্তি মুছে ফেলা হয়েছে';

  @override
  String get calendarExcludedOccurrencesLabel => 'মুছে ফেলা পুনরাবৃত্তিসমূহ';

  @override
  String get calendarRestoreOccurrence => 'পুনরুদ্ধার';

  @override
  String get calendarRestoreAllOccurrences => 'সব পুনরুদ্ধার করুন';

  @override
  String get calendarReminderFormTitleNew => 'নতুন অনুস্মারক';

  @override
  String get calendarReminderFormTitleEdit => 'অনুস্মারক সম্পাদনা';

  @override
  String get calendarReminderTitleLabel => 'শিরোনাম';

  @override
  String get calendarReminderTitleHint => 'যেমন: রমজান শুরু';

  @override
  String get calendarReminderNotesLabel => 'নোট (ঐচ্ছিক)';

  @override
  String get calendarReminderDateTimeLabel => 'তারিখ ও সময়';

  @override
  String get calendarReminderRecurrenceLabel => 'পুনরাবৃত্তি';

  @override
  String get calendarRecurrenceOnce => 'একবার';

  @override
  String get calendarRecurrenceDaily => 'প্রতিদিন';

  @override
  String get calendarRecurrenceWeekly => 'সাপ্তাহিক';

  @override
  String get calendarRecurrenceMonthly => 'মাসিক';

  @override
  String get calendarRecurrenceYearly => 'বার্ষিক';

  @override
  String get calendarRepeatCountLabel => 'পুনরাবৃত্তির সংখ্যা';

  @override
  String get calendarRepeatCountHelper =>
      'থামার আগে অনুস্মারক যতবার বাজবে (বন্ধ = চিরতরে পুনরাবৃত্তি)';

  @override
  String get calendarRepeatCountError =>
      '২ থেকে ১০০ এর মধ্যে একটি সংখ্যা লিখুন';

  @override
  String get calendarRepeatDaysLabel => 'পুনরাবৃত্তির দিন';

  @override
  String get calendarDayOfMonthLabel => 'মাসের দিন';

  @override
  String get calendarYearlyMonthLabel => 'মাস';

  @override
  String get calendarYearlyDayLabel => 'দিন';

  @override
  String get calendarMonthlyBasisLabel => 'মাসিক ভিত্তি';

  @override
  String get calendarYearlyBasisLabel => 'বার্ষিক ভিত্তি';

  @override
  String get calendarYearlyBasisGregorian => 'গ্রেগরিয়ান';

  @override
  String get calendarYearlyBasisHijri => 'হিজরি';

  @override
  String get calendarReminderTitleRequired => 'একটি শিরোনাম লিখুন';

  @override
  String get calendarAnchorClockTime => 'ক্যালেন্ডার তারিখ';

  @override
  String get calendarAnchorPrayerTime => 'নামাজের সময়';

  @override
  String get calendarSelectPrayer => 'নামাজ নির্বাচন করুন';

  @override
  String get calendarOffsetOnTime => 'সঠিক সময়ে';

  @override
  String get calendarOffsetBefore => 'আগে';

  @override
  String get calendarOffsetAfter => 'পরে';

  @override
  String get calendarPickAnchorDate => 'তারিখ নির্বাচন করুন';

  @override
  String get datesPrayerTimesTab => 'নামাজের সময়';

  @override
  String get datesCalendarTab => 'ক্যালেন্ডার';

  @override
  String get datesMoonPhaseTab => 'চাঁদের দশা';

  @override
  String get undo => 'পূর্বাবস্থায় ফেরান';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" মুছে ফেলা হয়েছে';
  }

  @override
  String get verseOfTheDay => 'আজকের আয়াত';

  @override
  String get hadithOfTheDay => 'আজকের হাদিস';

  @override
  String get hisnAlMuslimTitle => 'হিসনুল মুসলিম';

  @override
  String get morningAdhkar => 'সকালের আজকার';

  @override
  String get eveningAdhkar => 'সন্ধ্যার আজকার';

  @override
  String get afterPrayerAdhkar => 'নামাজের পরের আজকার';

  @override
  String get sleepingAdhkar => 'ঘুমানোর আগের আজকার';

  @override
  String get dailyLifeDuas => 'দৈনন্দিন জীবনের দোয়া';

  @override
  String get shareWisdom => 'শেয়ার করুন';

  @override
  String get copyText => 'কপি করুন';

  @override
  String get copiedToClipboard => 'ক্লিপবোর্ডে কপি করা হয়েছে';

  @override
  String get searchSupplicationsHint => 'দোয়া অনুসন্ধান করুন...';

  @override
  String get noSupplicationsFound => 'কোন দোয়া পাওয়া যায়নি';

  @override
  String get completed => 'সম্পন্ন';

  @override
  String get tapToCount => 'গণনা করতে ট্যাপ করুন';

  @override
  String get tabAll => 'সব';

  @override
  String get kazaTitle => 'কাজা';

  @override
  String get kazaSubtitle => 'ছুটে যাওয়া অতীতের নামাজ ট্র্যাক ও আদায় করুন';

  @override
  String get kazaCalculatorWizard => 'ক্যালকুলেটর';

  @override
  String get kazaBatchLogDay => '+১ পূর্ণ দিন';

  @override
  String get kazaBatchLogDayTooltip =>
      'সব ৬টি নামাজের জন্য ১টি করে সম্পন্ন গণনা বৃদ্ধি করুন';

  @override
  String get kazaTotalRemaining => 'মোট অবশিষ্ট';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target সম্পন্ন';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'আনুমানিক সমাপ্তি: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'সমস্ত কাজা নামাজ সম্পন্ন হয়েছে! 🎉';

  @override
  String get kazaDailyPaceLabel => 'দৈনিক গতি';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count নামাজ / দিন';
  }

  @override
  String get kazaSetPaceDialogTitle => 'দৈনিক গতি নির্ধারণ করুন';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'আপনি প্রতিদিন কতটি কাজা নামাজ আদায় করেন?';

  @override
  String get kazaCalculatorTitle => 'কাজা নামাজ ক্যালকুলেটর';

  @override
  String get kazaCalculateByYears => 'ছুটে যাওয়া সময়';

  @override
  String get kazaCalculateManual => 'ম্যানুয়াল লক্ষ্য';

  @override
  String get kazaYearsMissed => 'ছুটে যাওয়া বছর';

  @override
  String get kazaMonthsMissed => 'অতিরিক্ত মাস';

  @override
  String get kazaCalculateButton => 'লক্ষ্য সেট করুন';

  @override
  String get kazaWitrLabel => 'বিতর';

  @override
  String kazaRemainingCount(Object count) {
    return '$countটি অবশিষ্ট';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name সম্পন্ন গণনা';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= প্রতি নামাজে $days দিন (মোট $totalটি নামাজ)';
  }

  @override
  String get backupExportTitle => 'ব্যাকআপ ও এক্সপোর্ট';

  @override
  String get backupExportSubtitle =>
      'অ্যাপ ডেটা ব্যাকআপ করুন বা সময়সূচী এক্সপোর্ট করুন';

  @override
  String get exportBackupJson => 'ব্যাকআপ ডেটা এক্সপোর্ট করুন (JSON)';

  @override
  String get restoreBackupJson => 'ব্যাকআপ থেকে ডেটা পুনরুদ্ধার করুন';

  @override
  String get exportPrayerScheduleIcs =>
      'নামাজের সময়সূচী এক্সপোর্ট করুন (.ics)';

  @override
  String get exportHolidaysIcs => 'ইসলামিক ছুটির দিন এক্সপোর্ট করুন (.ics)';

  @override
  String get restoreConfirmTitle => 'অ্যাপ ডেটা পুনরুদ্ধার করবেন?';

  @override
  String get restoreConfirmBody =>
      'এটি আপনার কাজা লক্ষ্য, নামাজের ইতিহাস, অনুস্মারক এবং তসবীহ ডেটা পুনরুদ্ধার করবে। চালিয়ে যাবেন?';

  @override
  String get restoreSuccess => 'ডেটা সফলভাবে পুনরুদ্ধার করা হয়েছে!';

  @override
  String get restoreNewerVersionError =>
      'এই ব্যাকআপটি একটি নতুন অ্যাপ সংস্করণ দ্বারা তৈরি করা হয়েছে। অনুগ্রহ করে অ্যাপ আপডেট করুন এবং পুনরায় চেষ্টা করুন।';

  @override
  String get restoreError => 'অবৈধ ব্যাকআপ ফাইল ফরম্যাট';

  @override
  String get shareOrSave => 'শেয়ার / সংরক্ষণ';

  @override
  String get googleDriveSignIn => 'Google Drive-এ সাইন ইন করুন';

  @override
  String get googleDriveSignOut => 'Google Drive থেকে সাইন আউট করুন';

  @override
  String get googleDriveBackup => 'Google Drive-এ ব্যাকআপ সংরক্ষণ করুন';

  @override
  String get googleDriveRestore => 'Google Drive থেকে পুনরুদ্ধার করুন';

  @override
  String get googleDriveBackupSuccess =>
      'ব্যাকআপ Google Drive-এ সংরক্ষিত হয়েছে';

  @override
  String get googleDriveBackupError =>
      'Google Drive-এ ব্যাকআপ সংরক্ষণ করতে ব্যর্থ হয়েছে';

  @override
  String get googleDriveWorking => 'কাজ চলছে...';

  @override
  String get googleDriveRestoreConfirm =>
      'এটি আপনার Google Drive ব্যাকআপ থেকে ডেটা পুনরুদ্ধার করবে। চালিয়ে যাবেন?';

  @override
  String googleDriveLastBackup(String date) {
    return 'সর্বশেষ ব্যাকআপ: $date';
  }

  @override
  String get googleDriveNotSignedIn =>
      'Google Drive ব্যাকআপ ব্যবহার করতে সাইন ইন করুন';

  @override
  String get googleDriveSignInError =>
      'Google Drive-এ সাইন ইন করতে ব্যর্থ হয়েছে';

  @override
  String get googleDriveConfigError =>
      'Google Drive সাইন-ইন কনফিগার করা হয়নি।';

  @override
  String get googleDriveSignOutConfirmTitle =>
      'Google Drive থেকে সাইন আউট করবেন?';

  @override
  String googleDriveSignOutConfirmBody(String email) {
    return '$email দিয়ে সাইন আউট করবেন? আপনি পরে আবার সাইন ইন করতে পারেন।';
  }

  @override
  String get googleDriveRestoreEmpty =>
      'Google Drive-এ কোন ব্যাকআপ পাওয়া যায়নি।';

  @override
  String get driveRestorePromptBody =>
      'এই ডিভাইসে কোন ডেটা পাওয়া যায়নি। Google Drive থেকে ডেটা পুনরুদ্ধার করবেন?';

  @override
  String get offlineFolderChoose => 'ব্যাকআপ ফোল্ডার চয়ন করুন';

  @override
  String get offlineFolderChange => 'ব্যাকআপ ফোল্ডার পরিবর্তন করুন';

  @override
  String get offlineFolderNone =>
      'কোন ফোল্ডার চয়ন করা হয়নি। ব্যাকআপ অফলাইনে সংরক্ষিত হবে না।';

  @override
  String get offlineFolderSaved => 'ব্যাকআপ ফোল্ডারে সংরক্ষিত হয়েছে।';

  @override
  String get offlineFolderRestore => 'ব্যাকআপ ফোল্ডার থেকে পুনরুদ্ধার করুন';

  @override
  String get offlineFolderRestoreEmpty =>
      'নির্বাচিত ফোল্ডারে কোন ব্যাকআপ ফাইল পাওয়া যায়নি।';

  @override
  String get offlineFolderRemove => 'ব্যাকআপ ফোল্ডার সরান';

  @override
  String get restoreOptionsTitle => 'কী পুনরুদ্ধার করবেন?';

  @override
  String get restoreOptionsData => 'অ্যাপ ডেটা';

  @override
  String get restoreOptionsPreferences => 'পছন্দসমূহ';

  @override
  String googleDriveBackupItemCount(int count) {
    return '$countটি আইটেম';
  }

  @override
  String get googleDriveHistoryLimitTitle => 'ব্যাকআপ ইতিহাসের দৈর্ঘ্য';

  @override
  String get googleDriveHistoryLimitAll => 'সব';

  @override
  String get analyticsTab => 'অ্যানালিটিক্স';

  @override
  String get currentStreak => 'বর্তমান ধারাবাহিকতা';

  @override
  String get longestStreak => 'দীর্ঘতম ধারাবাহিকতা';

  @override
  String get daysUnit => 'দিন';

  @override
  String get monthlyHeatmapTitle => 'মাসিক সমাপ্তি';

  @override
  String get completionBreakdownTitle => 'নামাজের বিশ্লেষণ';

  @override
  String get overallConsistency => 'সামগ্রিক ধারাবাহিকতা';

  @override
  String get totalPrayersCompleted => 'মোট সংরক্ষিত নামাজ';

  @override
  String get last30Days => 'গত ৩০ দিন';

  @override
  String get allTime => 'সর্বকাল';

  @override
  String get fastingTitle => 'রোজা';

  @override
  String get suhoorCountdownTitle => 'সাহরির বাকি সময়';

  @override
  String get iftarCountdownTitle => 'ইফতারের বাকি সময়';

  @override
  String get fastingTypeRamadan => 'রমজানের রোজা';

  @override
  String get fastingTypeSunnah => 'সুন্নত রোজা';

  @override
  String get fastingTypeQadaa => 'কাজা রোজা';

  @override
  String get whiteDaysTitle => 'আইয়ামে বিজ (১৩, ১৪, ১৫)';

  @override
  String get mondayThursdayTitle => 'সোম ও বৃহস্পতিবারের সুন্নত';

  @override
  String get logFastAction => 'রোজা সংরক্ষণ করুন';

  @override
  String get totalFastsLogged => 'মোট সংরক্ষিত রোজা';

  @override
  String get suhoorEndsIn => 'সাহরি শেষ হতে বাকি';

  @override
  String get iftarIn => 'ইফতারের বাকি';

  @override
  String get fastingTab => 'রোজা';

  @override
  String get trackTabTitle => 'ট্র্যাক';

  @override
  String get prayerAnalyticsTitle => 'নামাজ অ্যানালিটিক্স';

  @override
  String get prayerQadaaTitle => 'নামাজ কাজা';

  @override
  String get iftarTimeLabel => 'ইফতারের সময়';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% রোজা সম্পন্ন';
  }

  @override
  String get suhoorTickerTitle => 'সাহরি সারণী';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% অতিবাহিত';
  }

  @override
  String suhoorWithTime(String time) {
    return 'সাহরি ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'ইফতার ($time)';
  }

  @override
  String get upcomingSunnahDays => 'আসন্ন সুন্নত দিনসমূহ';

  @override
  String get fastingCalendarLogger => 'রোজা ক্যালেন্ডার লগার';

  @override
  String get removeFastLog => 'রোজার লগ মুছুন';

  @override
  String get calendarWeekStartTitle => 'সপ্তাহ শুরু হয়';

  @override
  String get calendarWeekStartSunday => 'রবিবার';

  @override
  String get calendarWeekStartMonday => 'সোমবার';

  @override
  String get hijriDateOffsetTitle => 'হিজরি তারিখ সমন্বয়';

  @override
  String get hijriDateOffsetSubtitle =>
      'স্থানীয় চাঁদ দেখার ভিত্তিতে হিজরি তারিখ সমন্বয় করুন';

  @override
  String get showIslamicHolidaysTitle => 'ইসলামিক ছুটির দিনসমূহ হাইলাইট করুন';

  @override
  String get showIslamicHolidaysSubtitle =>
      'বিশেষ ইসলামিক দিনগুলির জন্য ব্যাজ দেখান';

  @override
  String get showFastingBadgesTitle => 'ক্যালেন্ডারে রোজার ব্যাজ দেখান';

  @override
  String get showFastingBadgesSubtitle => 'রোজা রাখা তারিখগুলিতে ব্যাজ দেখান';

  @override
  String get defaultCalendarDisplayTitle => 'ডিফল্ট ক্যালেন্ডার ভিউ';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'ক্যালেন্ডার খোলার সময় প্রাথমিক দৃশ্য';

  @override
  String get showCalendarReminderDotsTitle => 'অনুস্মারক ডট দেখান';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'নির্ধারিত অনুস্মারক থাকা দিনে ডট প্রদর্শন করুন';

  @override
  String get calendarSettingsSectionTitle => 'ক্যালেন্ডার সেটিংস';

  @override
  String get moonPhaseTitle => 'চাঁদের দশা';

  @override
  String moonIllumination(int percent) {
    return '$percent% আলোকিত';
  }

  @override
  String moonAgeDays(String days) {
    return 'চক্রের $daysতম দিন';
  }

  @override
  String get moonPhaseNewMoon => 'নতুন চাঁদ (হেলাল)';

  @override
  String get moonPhaseWaxingCrescent => 'বর্ধমান অর্ধচন্দ্র';

  @override
  String get moonPhaseFirstQuarter => 'প্রথম চতুর্থাংশ';

  @override
  String get moonPhaseWaxingGibbous => 'বর্ধমান গিব্বাস';

  @override
  String get moonPhaseFullMoon => 'পূর্ণিমা (বদর)';

  @override
  String get moonPhaseWaningGibbous => 'ক্ষীয়মাণ গিব্বাস';

  @override
  String get moonPhaseLastQuarter => 'শেষ চতুর্থাংশ';

  @override
  String get moonPhaseWaningCrescent => 'ক্ষীয়মাণ অর্ধচন্দ্র';

  @override
  String get whiteDaysSubtitle => 'সুন্নত রোজার দিন (১৩, ১৪, ১৫ হিজরি)';

  @override
  String get homeDashboardCardsSectionTitle => 'হোম ড্যাশবোর্ড কার্ড';

  @override
  String get showCardMoonPhaseTitle => 'চাঁদের দশা কার্ড দেখান';

  @override
  String get showCardMoonPhaseSubtitle =>
      'চাঁদের দশা এবং আইয়ামে বিজের কার্ড প্রদর্শন করুন';

  @override
  String get showCardIftarSuhoorTitle => 'সাহরি ও ইফতার কার্ড দেখান';

  @override
  String get showCardIftarSuhoorSubtitle =>
      'সরাসরি সাহরি এবং ইফতারের কাউন্টডাউন কার্ড প্রদর্শন করুন';

  @override
  String get showCardDailyWisdomTitle => 'দৈনিক প্রজ্ঞা কার্ড দেখান';

  @override
  String get showCardDailyWisdomSubtitle =>
      'দৈনিক অনুপ্রেরণামূলক হাদিস বা আয়াত কার্ড প্রদর্শন করুন';

  @override
  String get showCardUpcomingRemindersTitle => 'আসন্ন অনুস্মারক কার্ড দেখান';

  @override
  String get showCardUpcomingRemindersSubtitle =>
      'আপনার পরবর্তী ৩টি আসন্ন অনুস্মারকের কার্ড প্রদর্শন করুন';

  @override
  String get moonCalendarTitle => 'চন্দ্রকলা ক্যালেন্ডার';

  @override
  String get calendarGoToDate => 'নির্দিষ্ট তারিখে যান';

  @override
  String get whiteDaysBannerPrefix => 'আইয়ামে বিজ (১৩, ১৪, ১৫)';

  @override
  String get beadsAppTitle => 'তসবীহ গণক';

  @override
  String get beadsMilestones => 'তসবীহ';

  @override
  String get beadsSwitchToLight => 'লাইট মোডে যান';

  @override
  String get beadsSwitchToDark => 'ডার্ক মোডে যান';

  @override
  String get beadsLanguage => 'ভাষা';

  @override
  String get beadsChooseLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get beadsNoMilestones => 'কোন তসবীহ নেই। যোগ করতে + চাপুন।';

  @override
  String get beadsStatsTitle => 'ইতিহাস';

  @override
  String get beadsStatsToday => 'আজ';

  @override
  String get beadsStatsLast7Days => '৭ দিন';

  @override
  String get beadsStatsTotal => 'মোট';

  @override
  String get beadsDeleted => 'মুছে ফেলা হয়েছে';

  @override
  String get beadsUndo => 'পূর্বাবস্থায় ফেরান';

  @override
  String get beadsEdit => 'সম্পাদনা';

  @override
  String get beadsDuplicate => 'অনুলিপি';

  @override
  String get beadsClear => 'সাফ করুন';

  @override
  String get beadsDelete => 'মুছুন';

  @override
  String get beadsCount => 'গণনা';

  @override
  String get beadsCheck => 'চেক';

  @override
  String get beadsSet => 'সেট';

  @override
  String get beadsProgress => 'অগ্রগতি';

  @override
  String get beadsCreateMilestone => 'তসবীহ তৈরি করুন';

  @override
  String get beadsEditMilestone => 'তসবীহ সম্পাদনা করুন';

  @override
  String get beadsTitle => 'শিরোনাম';

  @override
  String get beadsNotes => 'নোট';

  @override
  String get beadsNotesHint => 'এই তসবীহের জন্য নোট যোগ করুন...';

  @override
  String get beadsCountField => 'গণনা';

  @override
  String get beadsCheckInterval => 'চেক ব্যবধান';

  @override
  String get beadsCheckHelper =>
      'মোট গণনার অর্ধেকের সমান বা কম। চেকপয়েন্ট না চাইলে খালি রাখুন বা ০ দিন।';

  @override
  String get beadsSetCount => 'সেট সংখ্যা';

  @override
  String get beadsSetCountHelper => 'সেট সংখ্যা মোট গণনার সমান বা কম হতে হবে।';

  @override
  String get beadsSetCountReadonlyHelper =>
      'সেট সংখ্যা কেবল অগ্রগতি স্ক্রিন থেকে পরিবর্তন করা যাবে।';

  @override
  String get beadsVibrationIntensity => 'কম্পনের মাত্রা';

  @override
  String get beadsReminderTitle => 'অনুস্মারক';

  @override
  String get beadsReminderEnable => 'অনুস্মারক চালু করুন';

  @override
  String get beadsReminderRepeatOnce => 'একবার';

  @override
  String get beadsReminderRepeatDaily => 'প্রতিদিন';

  @override
  String get beadsReminderRepeatWeekly => 'সাপ্তাহিক';

  @override
  String get beadsReminderRepeatMonthly => 'মাসিক';

  @override
  String get beadsReminderRepeatYearly => 'বার্ষিক';

  @override
  String get beadsReminderRepeatCountLabel => 'পুনরাবৃত্তির সংখ্যা';

  @override
  String get beadsReminderRepeatCountHelper =>
      'থামার আগে অনুস্মারকটি যতবার বাজবে (বন্ধ = চিরতরে পুনরাবৃত্তি)';

  @override
  String get beadsReminderRepeatCountRangeError =>
      '২ থেকে ১০০ এর মধ্যে একটি সংখ্যা লিখুন';

  @override
  String get beadsReminderRepeatDaysLabel => 'পুনরাবৃত্তির দিন';

  @override
  String get beadsReminderDayOfMonthLabel => 'মাসের দিন';

  @override
  String get beadsReminderYearlyMonthLabel => 'মাস';

  @override
  String get beadsReminderYearlyDayLabel => 'দিন';

  @override
  String get beadsReminderRecurrenceLabel => 'পুনরাবৃত্তি';

  @override
  String get beadsReminderMonthlyBasisLabel => 'মাসিক ভিত্তি';

  @override
  String get beadsReminderYearlyBasisLabel => 'বার্ষিক ভিত্তি';

  @override
  String get beadsReminderBasisGregorian => 'গ্রেগরিয়ান';

  @override
  String get beadsReminderBasisHijri => 'হিজরি';

  @override
  String get beadsReminderPickDateTime => 'তারিখ ও সময় নির্বাচন করুন';

  @override
  String get beadsReminderPickDate => 'তারিখ নির্বাচন করুন';

  @override
  String get beadsReminderPickTime => 'সময় নির্বাচন করুন';

  @override
  String get beadsReminderNotSet => 'সেট করা হয়নি';

  @override
  String get beadsReminderAnchorTime => 'সময়';

  @override
  String get beadsReminderAnchorPrayer => 'নামাজের সময়';

  @override
  String get beadsReminderOffsetOnTime => 'সঠিক সময়ে';

  @override
  String get beadsReminderOffsetBefore => 'আগে';

  @override
  String get beadsReminderOffsetAfter => 'পরে';

  @override
  String get beadsReminderMinutesLabel => 'মিনিট';

  @override
  String get beadsReminderSelectPrayer => 'নামাজ নির্বাচন করুন';

  @override
  String get beadsSave => 'সংরক্ষণ';

  @override
  String get beadsUpdate => 'আপডেট';

  @override
  String get beadsRequiredSuffix => 'প্রয়োজন';

  @override
  String get beadsMustBeInteger => 'একটি পূর্ণসংখ্যা হতে হবে';

  @override
  String get beadsCountPositive => 'গণনা একটি ধনাত্মক পূর্ণসংখ্যা হতে হবে';

  @override
  String get beadsCheckGreaterThanZero => 'চেক ০ এর বেশি হতে হবে';

  @override
  String get beadsCheckHalfError => 'চেক গণনার অর্ধেকের বেশি হতে পারে না';

  @override
  String get beadsEnterValidCountFirst => 'প্রথমে একটি বৈধ গণনা লিখুন';

  @override
  String get beadsSetCountNegative => 'সেট সংখ্যা ঋণাত্মক হতে পারে না';

  @override
  String get beadsSetCountGreaterCount =>
      'সেট সংখ্যা গণনার চেয়ে বেশি হতে পারে না';

  @override
  String get beadsSetCountValueRequired => 'সেট সংখ্যা আবশ্যক';

  @override
  String get beadsItemNotFound => 'আইটেম পাওয়া যায়নি';

  @override
  String get beadsResetProgressTitle => 'অগ্রগতি রিসেট করবেন?';

  @override
  String get beadsResetProgressBody => 'এটি বর্তমান অগ্রগতি ০-তে ফিরিয়ে দেবে।';

  @override
  String get beadsCancel => 'বাতিল';

  @override
  String get beadsReset => 'রিসেট';

  @override
  String get beadsEditProgressAndSetCount =>
      'অগ্রগতি ও সেট সংখ্যা সম্পাদনা করুন';

  @override
  String get beadsProgressCount => 'অগ্রগতি গণনা';

  @override
  String get beadsSetCountCannotNegative => 'সেট সংখ্যা ঋণাত্মক হতে পারে না';

  @override
  String get beadsValidProgressNumber => 'একটি বৈধ অগ্রগতি সংখ্যা লিখুন';

  @override
  String beadsProgressBetween(int max) {
    return 'অগ্রগতি ০ এবং $max-এর মধ্যে হতে হবে';
  }

  @override
  String get beadsMaxMinusCount => 'অবশিষ্ট গণনা';

  @override
  String get beadsTap => 'ট্যাপ';

  @override
  String get beadsGroups => 'গ্রুপসমূহ';

  @override
  String get beadsNewGroup => 'নতুন গ্রুপ';

  @override
  String get beadsEditGroup => 'গ্রুপ সম্পাদনা';

  @override
  String get beadsGroupName => 'গ্রুপের নাম';

  @override
  String get beadsGroupMembers => 'সদস্যগণ';

  @override
  String get beadsNoBeadsInGroup => 'এই গ্রুপে এখনও কোনও তসবীহ নেই।';

  @override
  String get beadsAddBead => 'তসবীহ যোগ করুন';

  @override
  String get beadsAddBeads => 'তসবীহসমূহ যোগ করুন';

  @override
  String get beadsNewBead => 'নতুন তসবীহ';

  @override
  String get beadsDeleteGroup => 'গ্রুপ মুছুন';

  @override
  String get beadsDeleteGroupConfirm =>
      'এই গ্রুপটি মুছবেন? এর তসবীহগুলি সংরক্ষিত থাকবে।';

  @override
  String get beadsRemoveFromGroup => 'গ্রুপ থেকে সরান';

  @override
  String get beadsNoNotesAdded => 'কোন নোট যোগ করা হয়নি।';

  @override
  String get beadsSelect => 'নির্বাচন করুন';

  @override
  String get beadsSelectAll => 'সব নির্বাচন করুন';

  @override
  String beadsSelectedCount(int count) {
    return '$countটি নির্বাচিত';
  }

  @override
  String beadsDeleteSelectedConfirm(int count) {
    return '$countটি নির্বাচিত আইটেম মুছবেন?';
  }

  @override
  String beadsDeletedSelected(int count) {
    return '$countটি মুছে ফেলা হয়েছে';
  }

  @override
  String get notificationActionSnooze => 'স্নুজ';

  @override
  String get notificationActionDismiss => 'খারিজ';

  @override
  String get notificationActionDone => 'সম্পন্ন';

  @override
  String get snoozeDurationTitle => 'স্নুজ সময়কাল';

  @override
  String get snoozeDurationSubtitle => 'আবার মনে করিয়ে দেওয়ার আগের সময়';

  @override
  String snoozeMinutesOption(int minutes) {
    return '$minutes মিনিট';
  }
}
