// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'தொழுகை உதவியாளர்';

  @override
  String get tabLocation => 'இடம்';

  @override
  String get tabToday => 'இன்று';

  @override
  String get tabDates => 'தேதிகள்';

  @override
  String get tabTesbih => 'மணிகள்';

  @override
  String get tooltipToggleLightDark => 'லைட்/டார்க் மாற்றுக';

  @override
  String get tooltipRemindersOn => 'நினைவூட்டல்களை இயக்கு';

  @override
  String get tooltipRemindersOff => 'நினைவூட்டல்களை அணை';

  @override
  String get tooltipPreferences => 'விருப்பத்தேர்வுகள்';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes நிமி';
  }

  @override
  String get remainingMinutesUnknown => '-- நிமி';

  @override
  String get homeNoLocationTitle => 'இடம் தேர்ந்தெடுக்கப்படவில்லை';

  @override
  String get homeNoLocationSubtitle =>
      'இடம் பகுதிக்குச் சென்று முதலில் உங்கள் மாவட்டத்தைச் சேமிக்கவும்.';

  @override
  String get homeNoPrayerTimesTitle => 'தொழுகை நேரங்கள் இல்லை';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'வருடாந்திர தரவை ஒத்திசைக்க புதுப்பிக்கவும்.';

  @override
  String get refresh => 'புதுப்பி';

  @override
  String get qiblaTitle => 'கிப்லா';

  @override
  String qiblaBearing(int degrees) {
    return 'கிப்லா: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'உங்கள் இருப்பிடத்தைக் கண்டறிய முடியவில்லை. GPS-ஐ இயக்கி மீண்டும் முயற்சிக்கவும்.';

  @override
  String get qiblaHeadingUnavailable =>
      'திசைகாட்டி கிடைக்கவில்லை - நிலையான திசை காட்டப்படுகிறது.';

  @override
  String get qiblaPointDevice =>
      'முள் மேலே சுட்டிக்காட்டும் வரை சாதனத்தைச் சுழற்றுங்கள்.';

  @override
  String get qiblaKaabaShort => 'கிப்லா';

  @override
  String get shareTodayTimes => 'இன்றைய தொழுகை நேரங்களைப் பகிர்க';

  @override
  String get calendarPreviousDay => 'முந்தைய நாள்';

  @override
  String get calendarNextDay => 'அடுத்த நாள்';

  @override
  String todayWithDate(Object date) {
    return 'இன்று • $date';
  }

  @override
  String get hijriUnknown => 'ஹிஜ்ரி: -';

  @override
  String hijriWithDate(Object date) {
    return 'ஹிஜ்ரி: $date';
  }

  @override
  String get reminderSettingsTitle => 'நினைவூட்டல் அமைப்புகள்';

  @override
  String get reminderSettingsSubtitle =>
      'நினைவூட்டல் மற்றும் எத்தனை நிமிடங்களுக்கு முன் என்பதை உள்ளமைக்க மேலே உள்ள தொழுகை நேரத்தைத் தட்டவும்.';

  @override
  String get tooltipScheduledDebug =>
      'திட்டமிடப்பட்ட நினைவூட்டல்கள் பிழைத்திருத்தம்';

  @override
  String get scheduledRemindersDebugTitle =>
      'திட்டமிடப்பட்ட நினைவூட்டல்கள் (பிழைத்திருத்தம்)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'நிலுவையிலுள்ள அறிவிப்புகள்: $count';
  }

  @override
  String get sendTestNotificationNow => 'சோதனை அறிவிப்பை இப்போது அனுப்புக';

  @override
  String get testNotificationSent => 'சோதனை அறிவிப்பு அனுப்பப்பட்டது.';

  @override
  String get statusBarMinutesTitle => 'ஸ்டேட்டஸ் பார் நிமிடங்கள்';

  @override
  String get statusBarMinutesSubtitle =>
      'ஸ்டேட்டஸ் பாரில் மீதமுள்ள நிமிடங்களின் அறிவிப்பைக் காட்டவும்.';

  @override
  String get statusAutoRestoreTitle => 'நீக்கப்பட்டால் தானியங்கி மீட்பு';

  @override
  String get statusAutoRestoreSubtitle =>
      'பயனர் அறிவிப்பை ஸ்வைப் செய்தால் அதை மீண்டும் உருவாக்கவும்.';

  @override
  String get noPendingReminders =>
      'நிலுவையில் உள்ள நினைவூட்டல் அறிவிப்புகள் இல்லை.';

  @override
  String get unknownFireTime => 'தெரியாத நேரம்';

  @override
  String get pastPrefix => '[கடந்த] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'ஆன் • சரியான நேரத்தில் + $minutes நிமி முன்பு';
  }

  @override
  String get reminderOnTimeOnly => 'ஆன் • சரியான நேரத்தில்';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'ஆன் • $minutes நிமி முன்பு';
  }

  @override
  String get reminderOff => 'நினைவூட்டல் ஆஃப்';

  @override
  String get nextPrayerTitle => 'அடுத்த தொழுகை';

  @override
  String get homeUpcomingRemindersTitle => 'வரவிருக்கும் நினைவூட்டல்கள்';

  @override
  String startsIn(Object remaining) {
    return '$remaining-ல் தொடங்குகிறது';
  }

  @override
  String get selectYourLocation => 'உங்கள் இருப்பிடத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get locationHelp =>
      'விரைவான அமைப்பிற்கு GPS ஐப் பயன்படுத்தவும் அல்லது நாடு/நகரத்தை கைமுறையாகத் தேர்ந்தெடுக்கவும்.';

  @override
  String get useCurrentLocation => 'தற்போதைய இருப்பிடத்தைப் பயன்படுத்து';

  @override
  String get country => 'நாடு';

  @override
  String get stateCity => 'மாநிலம் / நகரம்';

  @override
  String get district => 'மாவட்டம்';

  @override
  String get search => 'தேடு';

  @override
  String get noResults => 'முடிவுகள் இல்லை';

  @override
  String get noInternetTitle => 'இணைய இணைப்பு இல்லை';

  @override
  String get noInternetMessage =>
      'சர்வரை அடைய முடியவில்லை. உங்கள் இணைப்பைச் சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get saveLocation => 'இருப்பிடத்தைச் சேமி';

  @override
  String selectedLocation(Object location) {
    return 'தேர்ந்தெடுக்கப்பட்டது: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1 வருட தொழுகைப் பட்டியலைக் காண முதலில் ஒரு இடத்தைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get historyTableTitle => 'தொழுகை நேர அட்டவணை (முழு ஆண்டு)';

  @override
  String get todayShort => 'இன்று';

  @override
  String get dateHeader => 'தேதி';

  @override
  String get imsak => 'ஃபஜ்ர்';

  @override
  String get gunes => 'சூரியோதயம்';

  @override
  String get ogle => 'ளுஹர்';

  @override
  String get ikindi => 'அஸ்ர்';

  @override
  String get aksam => 'மஃக்ரிப்';

  @override
  String get yatsi => 'இஷா';

  @override
  String get hijriHeader => 'ஹிஜ்ரி';

  @override
  String get preferencesTitle => 'விருப்பத்தேர்வுகள்';

  @override
  String get languageTitle => 'மொழி';

  @override
  String get languageSystem => 'கணினி இயல்புநிலை';

  @override
  String get themeModeTitle => 'தீம் முறை';

  @override
  String get themeSystem => 'கணினி இயல்புநிலை';

  @override
  String get themeLight => 'லைட்';

  @override
  String get themeDark => 'டார்க்';

  @override
  String get homeScreenSettingsSectionTitle => 'முகப்புத் திரை அமைப்புகள்';

  @override
  String get appBarRemainingTitle => 'முகப்பு ஆப் பார் மீதமுள்ள நேரம்';

  @override
  String get showInTitle => 'தலைப்பில் காட்டு';

  @override
  String get showAtRight => 'வலதுபுறத்தில் காட்டு';

  @override
  String get showAsSubtitle => 'துணைத்தலைப்பாகக் காட்டு';

  @override
  String get hideRemainingText => 'மீதமுள்ள உரையை மறை';

  @override
  String get notificationMessageTitle => 'அறிவிப்பு செய்தி';

  @override
  String get notificationMessageShown => 'காட்டப்பட்டது';

  @override
  String get notificationMessageHidden => 'மறைக்கப்பட்டது';

  @override
  String get widgetSettingsSectionTitle => 'விட்ஜெட் அமைப்புகள்';

  @override
  String get widgetTextSizeTitle => 'எழுத்துரு அளவு';

  @override
  String get widgetTextSizeSubtitle =>
      'முகப்புத் திரை விட்ஜெட்களில் பயன்படுத்தப்படும் எழுத்து அளவு.';

  @override
  String get widgetTextSizeExtraSmall => 'மிகச் சிறியது';

  @override
  String get widgetTextSizeSmall => 'சிறியது';

  @override
  String get widgetTextSizeMedium => 'நடுத்தர';

  @override
  String get widgetTextSizeLarge => 'பெரியது';

  @override
  String widgetTextSizePreview(Object size) {
    return 'முன்னோட்டம் $size';
  }

  @override
  String get widgetMmssThresholdTitle => 'வினாடிகள் கவுண்டவுன்';

  @override
  String get widgetThemeTitle => 'பின்னணி தீம்';

  @override
  String get widgetThemeSystem => 'கணினி';

  @override
  String get widgetThemeLight => 'லைட்';

  @override
  String get widgetThemeDark => 'டார்க்';

  @override
  String get widgetThemeTransparent => 'வெளிப்படையானது';

  @override
  String get widgetCalendarDisplayTitle => 'நாட்காட்டி தேதி காட்சி';

  @override
  String get widgetCalendarDisplayBoth =>
      'இரண்டும் (ஹிஜ்ரி மற்றும் கிரிகோரியன்)';

  @override
  String get widgetCalendarDisplayHijri => 'ஹிஜ்ரி மட்டும்';

  @override
  String get widgetCalendarDisplayGregorian => 'கிரிகோரியன் மட்டும்';

  @override
  String get widgetMmssThresholdNever => 'எப்போதும் HH:MM காட்டு';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes நிமிடத்திற்கு கீழ் MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'நினைவூட்டல்கள் ஆன்/ஆஃப்';

  @override
  String get remindersOnOffSubtitle =>
      'தொழுகை நினைவூட்டல் அறிவிப்புகளை இயக்கவும் அல்லது அணைக்கவும். தனிப்பட்ட அமைப்புகள் பாதுகாக்கப்படும்.';

  @override
  String get reminderVibrationTitle => 'நினைவூட்டலில் அதிர்வு';

  @override
  String get reminderVibrationSubtitle =>
      'நினைவூட்டல் ஒலிக்கும்போது சுமார் 10 விநாடிகள் அதிரும்.';

  @override
  String get reminderSoundTitle => 'நினைவூட்டலில் ஒலி எழுப்பு';

  @override
  String get reminderSoundSubtitle =>
      'நினைவூட்டல் ஒலிக்கும்போது அறிவிப்பு ஒலியை இயக்கவும்.';

  @override
  String get remindersOn => 'ஆன்';

  @override
  String get remindersOff => 'ஆஃப்';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer நினைவூட்டல்';
  }

  @override
  String get reminderTypeTitle =>
      'நினைவூட்டல் வகை (இரண்டையும் தேர்ந்தெடுக்கலாம்)';

  @override
  String get onTime => 'சரியான நேரத்தில்';

  @override
  String get before => 'முன்பு';

  @override
  String get after => 'பின்பு';

  @override
  String get reminderAlertTitle => 'எச்சரிக்கை';

  @override
  String get reminderAlertSubtitle =>
      'எச்சரிக்கையை செயல்படுத்த விருப்பத்தேர்வுகளில் தொடர்புடைய சுவிட்ச் ஆன் செய்யப்பட வேண்டும்.';

  @override
  String get vibrateChip => 'அதிர்வு';

  @override
  String get soundChip => 'ஒலி';

  @override
  String get adhanChip => 'பாங்கு';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total தொழுகைகள் முடிந்தன';
  }

  @override
  String get holiday_islamic_new_year => 'இஸ்லாமிய புத்தாண்டு';

  @override
  String get holiday_ashura => 'ஆஷூரா';

  @override
  String get holiday_mawlid => 'மீலாதுன் நபி';

  @override
  String get holiday_isra_miraj => 'இஸ்ரா மற்றும் மிஃராஜ்';

  @override
  String get holiday_laylat_barat => 'ஷபே பராத்';

  @override
  String get holiday_ramadan_first => 'ரமலான் முதல் நாள்';

  @override
  String get holiday_laylat_qadr => 'லைலத்துல் கத்ர்';

  @override
  String get holiday_eid_fitr => 'ஈகைத் திருநாள் (ஈதுல் ஃபித்ர்)';

  @override
  String get holiday_arafah => 'அரஃபா நாள்';

  @override
  String get holiday_eid_adha => 'ஹஜ்ஜுப் பெருநாள் (ஈதுல் அழ்ஹா)';

  @override
  String get remindBeforePrayerTitle => 'தொழுகைக்கு முன் நினைவூட்டு';

  @override
  String get remindAfterPrayerTitle => 'தொழுகைக்கு பின் நினைவூட்டு';

  @override
  String minutesValue(Object minutes) {
    return '$minutes நிமி';
  }

  @override
  String get custom => 'விருப்பப்படி';

  @override
  String get customMinutes => 'தனிப்பயன் நிமிடங்கள்';

  @override
  String get customMinutesHint => 'எ.கா. 12';

  @override
  String get save => 'சேமி';

  @override
  String get enableBeforeToSelectMinutes =>
      'நிமிடங்களைத் தேர்ந்தெடுக்க \"முன்பு\" என்பதை இயக்கவும்.';

  @override
  String get enableAfterToSelectMinutes =>
      'நிமிடங்களைத் தேர்ந்தெடுக்க \"பின்பு\" என்பதை இயக்கவும்.';

  @override
  String get enterValidPositiveNumber =>
      'செல்லுபடியாகும் நேர்மறை எண்ணை உள்ளிடவும்.';

  @override
  String get useValueUpTo240 => '240 நிமிடங்கள் வரை மதிப்பை உள்ளிடவும்.';

  @override
  String get customMinutesSaved => 'தனிப்பயன் நிமிடங்கள் சேமிக்கப்பட்டன.';

  @override
  String get cancel => 'ரத்து';

  @override
  String get calendarTabTooltip => 'ஹிஜ்ரி நாட்காட்டி';

  @override
  String get calendarPreviousMonth => 'முந்தைய மாதம்';

  @override
  String get calendarNextMonth => 'அடுத்த மாதம்';

  @override
  String get calendarSwapPrimary => 'ஹிஜ்ரி/கிரிகோரியன் மாற்றுக';

  @override
  String get calendarShowSecondary => 'இரண்டாம் நிலை தேதியைக் காட்டு';

  @override
  String get calendarHideSecondary => 'இரண்டாம் நிலை தேதியை மறை';

  @override
  String get calendarNoRemindersOnDay => 'இந்த நாளில் நினைவூட்டல்கள் இல்லை';

  @override
  String get calendarAddReminder => 'நினைவூட்டலைச் சேர்';

  @override
  String get calendarEditReminder => 'திருத்து';

  @override
  String get calendarDeleteReminder => 'நீக்கு';

  @override
  String get calendarDeleteOccurrence => 'இந்த நிகழ்வை நீக்கு';

  @override
  String get calendarDeleteOccurrenceConfirm =>
      'தொடரிலிருந்து இந்த நாளை மட்டும் நீக்கவா?';

  @override
  String get calendarOccurrenceDeleted => 'நிகழ்வு நீக்கப்பட்டது';

  @override
  String get calendarExcludedOccurrencesLabel => 'நீக்கப்பட்ட நிகழ்வுகள்';

  @override
  String get calendarRestoreOccurrence => 'மீட்டமை';

  @override
  String get calendarRestoreAllOccurrences => 'அனைத்தையும் மீட்டமை';

  @override
  String get calendarReminderFormTitleNew => 'புதிய நினைவூட்டல்';

  @override
  String get calendarReminderFormTitleEdit => 'நினைவூட்டலைத் திருத்து';

  @override
  String get calendarReminderTitleLabel => 'தலைப்பு';

  @override
  String get calendarReminderTitleHint => 'எ.கா. ரமலான் தொடங்குகிறது';

  @override
  String get calendarReminderNotesLabel => 'குறிப்புகள் (விருப்பத்தேர்வு)';

  @override
  String get calendarReminderDateTimeLabel => 'தேதி & நேரம்';

  @override
  String get calendarReminderRecurrenceLabel => 'மீண்டும் செய்';

  @override
  String get calendarRecurrenceOnce => 'ஒரு முறை';

  @override
  String get calendarRecurrenceDaily => 'தினசரி';

  @override
  String get calendarRecurrenceWeekly => 'வாராந்திர';

  @override
  String get calendarRecurrenceMonthly => 'மாதாந்திர';

  @override
  String get calendarRecurrenceYearly => 'வருடாந்திர';

  @override
  String get calendarRepeatCountLabel => 'மீண்டும் நிகழும் எண்ணிக்கை';

  @override
  String get calendarRepeatCountHelper =>
      'நினைவூட்டல் நிறுத்தப்படுவதற்கு முன் ஒலிக்கும் முறைகளின் எண்ணிக்கை (ஆஃப் = எப்போதும் மீண்டும் நிகழும்)';

  @override
  String get calendarRepeatCountError =>
      '2 முதல் 100 வரையிலான எண்ணை உள்ளிடவும்';

  @override
  String get calendarRepeatDaysLabel => 'மீண்டும் நிகழும் நாட்கள்';

  @override
  String get calendarDayOfMonthLabel => 'மாதத்தின் நாள்';

  @override
  String get calendarYearlyMonthLabel => 'மாதம்';

  @override
  String get calendarYearlyDayLabel => 'நாள்';

  @override
  String get calendarMonthlyBasisLabel => 'மாதாந்திர அடிப்படை';

  @override
  String get calendarYearlyBasisLabel => 'வருடாந்திர அடிப்படை';

  @override
  String get calendarYearlyBasisGregorian => 'கிரிகோரியன்';

  @override
  String get calendarYearlyBasisHijri => 'ஹிஜ்ரி';

  @override
  String get calendarReminderTitleRequired => 'ஒரு தலைப்பை உள்ளிடவும்';

  @override
  String get calendarAnchorClockTime => 'நாட்காட்டி தேதி';

  @override
  String get calendarAnchorPrayerTime => 'தொழுகை நேரம்';

  @override
  String get calendarSelectPrayer => 'தொழுகையைத் தேர்ந்தெடுக்கவும்';

  @override
  String get calendarOffsetOnTime => 'சரியான நேரத்தில்';

  @override
  String get calendarOffsetBefore => 'முன்பு';

  @override
  String get calendarOffsetAfter => 'பின்பு';

  @override
  String get calendarPickAnchorDate => 'தேதியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get datesPrayerTimesTab => 'தொழுகை நேரங்கள்';

  @override
  String get datesCalendarTab => 'நாட்காட்டி';

  @override
  String get datesMoonPhaseTab => 'சந்திர நிலை';

  @override
  String get undo => 'செயல்தவிர்';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" நீக்கப்பட்டது';
  }

  @override
  String get verseOfTheDay => 'இன்றைய வசனம்';

  @override
  String get hadithOfTheDay => 'இன்றைய ஹதீஸ்';

  @override
  String get hisnAlMuslimTitle => 'ஹிஸ்னுல் முஸ்லிம்';

  @override
  String get morningAdhkar => 'காலை திக்ருகள்';

  @override
  String get eveningAdhkar => 'மாலை திக்ருகள்';

  @override
  String get afterPrayerAdhkar => 'தொழுகைக்குப் பின்';

  @override
  String get sleepingAdhkar => 'தூங்குவதற்கு முன்';

  @override
  String get dailyLifeDuas => 'தினசரி துஆக்கள்';

  @override
  String get shareWisdom => 'பகிர்';

  @override
  String get copyText => 'நகலெடு';

  @override
  String get copiedToClipboard => 'கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String get searchSupplicationsHint => 'துஆக்களைத் தேடுங்கள்...';

  @override
  String get noSupplicationsFound => 'துஆக்கள் எதுவும் கிடைக்கவில்லை';

  @override
  String get completed => 'முடிந்தது';

  @override
  String get tapToCount => 'எண்ணத் தட்டவும்';

  @override
  String get tabAll => 'அனைத்தும்';

  @override
  String get kazaTitle => 'களா';

  @override
  String get kazaSubtitle =>
      'விடுபட்ட முந்தைய தொழுகைகளைக் கண்காணித்து நிறைவேற்றுங்கள்';

  @override
  String get kazaCalculatorWizard => 'கால்குலேட்டர்';

  @override
  String get kazaBatchLogDay => '+1 முழு நாள்';

  @override
  String get kazaBatchLogDayTooltip =>
      'அனைத்து 6 தொழுகைகளுக்கும் தலா 1 எண்ணிக்கையை அதிகரிக்கவும்';

  @override
  String get kazaTotalRemaining => 'மொத்தம் மீதமுள்ளது';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target முடிந்தது';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'மதிப்பிடப்பட்ட முடிவு: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'விடுபட்ட அனைத்து தொழுகைகளும் நிறைவேற்றப்பட்டன! 🎉';

  @override
  String get kazaDailyPaceLabel => 'தினசரி வேகம்';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count தொழுகைகள் / நாள்';
  }

  @override
  String get kazaSetPaceDialogTitle => 'தினசரி வேகத்தை அமைக்கவும்';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'ஒவ்வொரு நாளும் எத்தனை களா தொழுகைகளை நிறைவேற்றுகிறீர்கள்?';

  @override
  String get kazaCalculatorTitle => 'விடுபட்ட தொழுகைகள் கால்குலேட்டர்';

  @override
  String get kazaCalculateByYears => 'விடுபட்ட காலம்';

  @override
  String get kazaCalculateManual => 'கைமுறை இலக்குகள்';

  @override
  String get kazaYearsMissed => 'விடுபட்ட ஆண்டுகள்';

  @override
  String get kazaMonthsMissed => 'கூடுதல் மாதங்கள்';

  @override
  String get kazaCalculateButton => 'இலக்குகளை அமை';

  @override
  String get kazaWitrLabel => 'வித்ர்';

  @override
  String kazaRemainingCount(Object count) {
    return '$count மீதமுள்ளது';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name முடிந்த எண்ணிக்கை';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= ஒரு தொழுகைக்கு $days நாட்கள் (மொத்தம் $total தொழுகைகள்)';
  }

  @override
  String get backupExportTitle => 'காப்புப்பிரதி & ஏற்றுமதி';

  @override
  String get backupExportSubtitle =>
      'ஆப் தரவை காப்புப் பிரதி எடுக்கவும் அல்லது ஏற்றுமதி செய்யவும்';

  @override
  String get exportBackupJson => 'காப்புப் பிரதி தரவை ஏற்றுமதி செய் (JSON)';

  @override
  String get restoreBackupJson => 'காப்புப் பிரதியிலிருந்து மீட்டமை';

  @override
  String get exportPrayerScheduleIcs => 'தொழுகை அட்டவணையை ஏற்றுமதி செய் (.ics)';

  @override
  String get exportHolidaysIcs =>
      'இஸ்லாமிய விடுமுறை நாட்களை ஏற்றுமதி செய் (.ics)';

  @override
  String get restoreConfirmTitle => 'ஆப் தரவை மீட்டமைக்கவா?';

  @override
  String get restoreConfirmBody =>
      'இது உங்கள் களா இலக்குகள், தொழுகை வரலாறு, நினைவூட்டல்கள் மற்றும் தஸ்பீஹ் தரவை மீட்டமைக்கும். தொடரவா?';

  @override
  String get restoreSuccess => 'தரவு வெற்றிகரமாக மீட்டமைக்கப்பட்டது!';

  @override
  String get restoreNewerVersionError =>
      'இந்த காப்புப்பிரதி புதிய ஆப் பதிப்பால் உருவாக்கப்பட்டது. பயன்பாட்டைப் புதுப்பித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get restoreError => 'தவறான காப்புப்பிரதி கோப்பு வடிவம்';

  @override
  String get shareOrSave => 'பகிர் / சேமி';

  @override
  String get googleDriveSignIn => 'Google Drive-ல் உள்நுழைக';

  @override
  String get googleDriveSignOut => 'Google Drive-லிருந்து வெளியேறு';

  @override
  String get googleDriveBackup => 'காப்புப்பிரதியை Google Drive-ல் சேமி';

  @override
  String get googleDriveRestore => 'Google Drive-லிருந்து மீட்டமை';

  @override
  String get googleDriveBackupSuccess =>
      'காப்புப்பிரதி Google Drive-ல் சேமிக்கப்பட்டது';

  @override
  String get googleDriveBackupError => 'Google Drive-ல் சேமிக்க முடியவில்லை';

  @override
  String get googleDriveWorking => 'செயல்பாட்டில் உள்ளது...';

  @override
  String get googleDriveRestoreConfirm =>
      'இது உங்கள் Google Drive காப்புப்பிரதியிலிருந்து தரவை மீட்டமைக்கும். தொடரவா?';

  @override
  String googleDriveLastBackup(String date) {
    return 'கடைசி காப்புப்பிரதி: $date';
  }

  @override
  String get googleDriveNotSignedIn =>
      'Google Drive காப்புப்பிரதியைப் பயன்படுத்த உள்நுழையவும்';

  @override
  String get googleDriveSignInError => 'Google Drive-ல் உள்நுழைய முடியவில்லை';

  @override
  String get googleDriveConfigError =>
      'Google Drive உள்நுழைவு உள்ளமைக்கப்படவில்லை.';

  @override
  String get googleDriveSignOutConfirmTitle =>
      'Google Drive-லிருந்து வெளியேறவா?';

  @override
  String googleDriveSignOutConfirmBody(String email) {
    return '$email கணக்கிலிருந்து வெளியேறவா? பிறகு மீண்டும் உள்நுழையலாம்.';
  }

  @override
  String get googleDriveRestoreEmpty =>
      'Google Drive-ல் காப்புப்பிரதிகள் எதுவும் கிடைக்கவில்லை.';

  @override
  String get driveRestorePromptBody =>
      'இந்த சாதனத்தில் தரவு எதுவும் இல்லை. Google Drive-லிருந்து மீட்டெடுக்க விரும்புகிறீர்களா?';

  @override
  String get offlineFolderChoose => 'காப்புப்பிரதி கோப்புறையைத் தேர்வுசெய்க';

  @override
  String get offlineFolderChange => 'கோப்புறையை மாற்றுக';

  @override
  String get offlineFolderNone =>
      'கோப்புறை தேர்வு செய்யப்படவில்லை. காப்புப்பிரதிகள் ஆஃப்லைனில் சேமிக்கப்படாது.';

  @override
  String get offlineFolderSaved =>
      'காப்புப்பிரதி கோப்புறையில் சேமிக்கப்பட்டது.';

  @override
  String get offlineFolderRestore => 'கோப்புறையிலிருந்து மீட்டமை';

  @override
  String get offlineFolderRestoreEmpty =>
      'தேர்ந்தெடுக்கப்பட்ட கோப்புறையில் காப்புப்பிரதி கோப்பு எதுவும் இல்லை.';

  @override
  String get offlineFolderRemove => 'காப்புப்பிரதி கோப்புறையை நீக்கு';

  @override
  String get restoreOptionsTitle => 'எதை மீட்டமைக்க வேண்டும்?';

  @override
  String get restoreOptionsData => 'ஆப் தரவு';

  @override
  String get restoreOptionsPreferences => 'விருப்பத்தேர்வுகள்';

  @override
  String googleDriveBackupItemCount(int count) {
    return '$count உருப்படிகள்';
  }

  @override
  String get googleDriveHistoryLimitTitle => 'காப்புப்பிரதி வரலாற்று நீளம்';

  @override
  String get googleDriveHistoryLimitAll => 'அனைத்தும்';

  @override
  String get analyticsTab => 'பகுப்பாய்வு';

  @override
  String get currentStreak => 'தற்போதைய தொடர்ச்சி';

  @override
  String get longestStreak => 'நீண்ட தொடர்ச்சி';

  @override
  String get daysUnit => 'நாட்கள்';

  @override
  String get monthlyHeatmapTitle => 'மாதாந்திர நிறைவு';

  @override
  String get completionBreakdownTitle => 'தொழுகை விவரம்';

  @override
  String get overallConsistency => 'ஒட்டுமொத்த நிலைத்தன்மை';

  @override
  String get totalPrayersCompleted => 'பதிவு செய்யப்பட்ட மொத்த தொழுகைகள்';

  @override
  String get last30Days => 'கடந்த 30 நாட்கள்';

  @override
  String get allTime => 'எல்லாக் காலமும்';

  @override
  String get fastingTitle => 'நோன்பு';

  @override
  String get suhoorCountdownTitle => 'சஹருக்கான நேரம்';

  @override
  String get iftarCountdownTitle => 'இஃப்தாருக்கான நேரம்';

  @override
  String get fastingTypeRamadan => 'ரமலான் நோன்பு';

  @override
  String get fastingTypeSunnah => 'சுன்னத் நோன்பு';

  @override
  String get fastingTypeQadaa => 'களா நோன்பு';

  @override
  String get whiteDaysTitle => 'அய்யாமுல் பீள் (13, 14, 15)';

  @override
  String get mondayThursdayTitle => 'திங்கள் & வியாழன் சுன்னத்';

  @override
  String get logFastAction => 'நோன்பைப் பதிவு செய்';

  @override
  String get totalFastsLogged => 'பதிவு செய்யப்பட்ட மொத்த நோன்புகள்';

  @override
  String get suhoorEndsIn => 'சஹர் முடிவடைய இன்னும்';

  @override
  String get iftarIn => 'இஃப்தாருக்கு இன்னும்';

  @override
  String get fastingTab => 'நோன்பு';

  @override
  String get trackTabTitle => 'கண்காணிப்பு';

  @override
  String get prayerAnalyticsTitle => 'தொழுகை பகுப்பாய்வு';

  @override
  String get prayerQadaaTitle => 'தொழுகை களா';

  @override
  String get iftarTimeLabel => 'இஃப்தார் நேரம்';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% நோன்பு முடிந்தது';
  }

  @override
  String get suhoorTickerTitle => 'சஹர் தகவல்';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% கழிந்தது';
  }

  @override
  String suhoorWithTime(String time) {
    return 'சஹர் ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'இஃப்தார் ($time)';
  }

  @override
  String get upcomingSunnahDays => 'வரவிருக்கும் சுன்னத் நாட்கள்';

  @override
  String get fastingCalendarLogger => 'நோன்பு நாட்காட்டி பதிவேடு';

  @override
  String get removeFastLog => 'நோன்பு பதிவை நீக்கு';

  @override
  String get calendarWeekStartTitle => 'நாட்காட்டி வாரம் தொடங்கும் நாள்';

  @override
  String get calendarWeekStartSunday => 'ஞாயிறு';

  @override
  String get calendarWeekStartMonday => 'திங்கள்';

  @override
  String get hijriDateOffsetTitle => 'ஹிஜ்ரி தேதி சரிசெய்தல்';

  @override
  String get hijriDateOffsetSubtitle =>
      'பிறை தெரிவதை அடிப்படையாகக் கொண்டு ஹிஜ்ரி தேதியை சரிசெய்யவும்';

  @override
  String get showIslamicHolidaysTitle =>
      'இஸ்லாமிய விடுமுறை நாட்களை முன்னிலைப்படுத்துக';

  @override
  String get showIslamicHolidaysSubtitle =>
      'புனித நாட்களுக்கான சிறப்பு பேட்ஜ்களைக் காட்டு';

  @override
  String get showFastingBadgesTitle =>
      'நாட்காட்டியில் நோன்புப் பதிவுகளைக் காட்டு';

  @override
  String get showFastingBadgesSubtitle =>
      'நோன்பு நோற்ற தேதிகளில் பேட்ஜ்களைக் காட்டு';

  @override
  String get defaultCalendarDisplayTitle => 'இயல்புநிலை நாட்காட்டி பார்வை';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'நாட்காட்டியைத் திறக்கும்போது தொடக்கக் காட்சி';

  @override
  String get showCalendarReminderDotsTitle => 'நினைவூட்டல் புள்ளிகளைக் காட்டு';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'திட்டமிடப்பட்ட நினைவூட்டல்கள் உள்ள நாட்களில் புள்ளிகளைக் காட்டு';

  @override
  String get calendarSettingsSectionTitle => 'நாட்காட்டி அமைப்புகள்';

  @override
  String get moonPhaseTitle => 'சந்திர நிலை';

  @override
  String moonIllumination(int percent) {
    return '$percent% ஒளிர்கிறது';
  }

  @override
  String moonAgeDays(String days) {
    return 'சுழற்சியின் நாள் $days';
  }

  @override
  String get moonPhaseNewMoon => 'அமாவாசை (ஹிலால்)';

  @override
  String get moonPhaseWaxingCrescent => 'வளர்பிறை';

  @override
  String get moonPhaseFirstQuarter => 'முதல் கால் பகுதி';

  @override
  String get moonPhaseWaxingGibbous => 'வளரும் கிப்பஸ்';

  @override
  String get moonPhaseFullMoon => 'பௌர்ணமி (பத்ர்)';

  @override
  String get moonPhaseWaningGibbous => 'தேயும் கிப்பஸ்';

  @override
  String get moonPhaseLastQuarter => 'கடைசி கால் பகுதி';

  @override
  String get moonPhaseWaningCrescent => 'தேய்பிறை';

  @override
  String get whiteDaysSubtitle => 'சுன்னத் நோன்பு நாட்கள் (13, 14, 15 ஹிஜ்ரி)';

  @override
  String get homeDashboardCardsSectionTitle => 'முகப்பு பலகை அட்டைகள்';

  @override
  String get showCardMoonPhaseTitle => 'சந்திர நிலை அட்டையைக் காட்டு';

  @override
  String get showCardMoonPhaseSubtitle =>
      'சந்திர நிலை மற்றும் அய்யாமுல் பீள் அட்டையைக் காட்டு';

  @override
  String get showCardIftarSuhoorTitle => 'சஹர் & இஃப்தார் அட்டையைக் காட்டு';

  @override
  String get showCardIftarSuhoorSubtitle =>
      'நேரலை சஹர் மற்றும் இஃப்தார் கவுண்டவுன் அட்டையைக் காட்டு';

  @override
  String get showCardDailyWisdomTitle => 'தினசரி ஞான அட்டையைக் காட்டு';

  @override
  String get showCardDailyWisdomSubtitle =>
      'தினசரி உத்வேகம் தரும் ஹதீஸ் அல்லது வசன அட்டையைக் காட்டு';

  @override
  String get showCardUpcomingRemindersTitle =>
      'வரவிருக்கும் நினைவூட்டல்கள் அட்டையைக் காட்டு';

  @override
  String get showCardUpcomingRemindersSubtitle =>
      'அடுத்த 3 நினைவூட்டல்களின் அட்டையைக் காட்டு';

  @override
  String get moonCalendarTitle => 'சந்திர நாட்காட்டி';

  @override
  String get calendarGoToDate => 'குறிப்பிட்ட தேதிக்குச் செல்';

  @override
  String get whiteDaysBannerPrefix => 'அய்யாமுல் பீள் (13, 14, 15)';
}
