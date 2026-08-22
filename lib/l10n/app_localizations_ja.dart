// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ç¤¼æ‹ã‚¢ã‚·ã‚¹ã‚¿ãƒ³ãƒˆ';

  @override
  String get tabLocation => 'å ´æ‰€';

  @override
  String get tabToday => 'ä»Šæ—¥';

  @override
  String get tabDates => 'æ—¥ä»˜';

  @override
  String get tabTesbih => 'ãƒ“ãƒ¼ã‚º';

  @override
  String get tooltipToggleLightDark => 'ãƒ©ã‚¤ãƒˆ/ãƒ€ãƒ¼ã‚¯åˆ‡æ›¿';

  @override
  String get tooltipRemindersOn => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã‚’ã‚ªãƒ³';

  @override
  String get tooltipRemindersOff => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã‚’ã‚ªãƒ•';

  @override
  String get tooltipPreferences => 'è¨­å®š';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes åˆ†';
  }

  @override
  String get remainingMinutesUnknown => '-- åˆ†';

  @override
  String get homeNoLocationTitle => 'å ´æ‰€ãŒæœªé¸æŠžã§ã™';

  @override
  String get homeNoLocationSubtitle =>
      'ã¾ãšã€Œå ´æ‰€ã€ã‚¿ãƒ–ã§åœ°åŒºã‚’ä¿å­˜ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get homeNoPrayerTimesTitle =>
      'ç¤¼æ‹æ™‚é–“ã®ã‚­ãƒ£ãƒƒã‚·ãƒ¥ãŒã‚ã‚Šã¾ã›ã‚“';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'æ›´æ–°ã—ã¦å¹´é–“ãƒ‡ãƒ¼ã‚¿ã‚’åŒæœŸã—ã¦ãã ã•ã„ã€‚';

  @override
  String get refresh => 'æ›´æ–°';

  @override
  String get qiblaTitle => 'ã‚­ãƒ–ãƒ©';

  @override
  String qiblaBearing(int degrees) {
    return 'ã‚­ãƒ–ãƒ©: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'ç¾åœ¨åœ°ã‚’ç‰¹å®šã§ãã¾ã›ã‚“ã§ã—ãŸã€‚GPSã‚’æœ‰åŠ¹ã«ã—ã¦å†è©¦è¡Œã—ã¦ãã ã•ã„ã€‚';

  @override
  String get qiblaHeadingUnavailable =>
      'ã‚³ãƒ³ãƒ‘ã‚¹ãŒåˆ©ç”¨ã§ãã¾ã›ã‚“ - å›ºå®šæ–¹å‘ã‚’è¡¨ç¤ºä¸­ã€‚';

  @override
  String get qiblaPointDevice =>
      'é‡ãŒä¸Šã‚’å‘ãã¾ã§ãƒ‡ãƒã‚¤ã‚¹ã‚’å›žã—ã¦ãã ã•ã„ã€‚';

  @override
  String get qiblaKaabaShort => 'ã‚­ãƒ–ãƒ©';

  @override
  String get shareTodayTimes => 'ä»Šæ—¥ã®æ™‚åˆ»ã‚’å…±æœ‰';

  @override
  String get calendarPreviousDay => 'å‰ã®æ—¥';

  @override
  String get calendarNextDay => 'æ¬¡ã®æ—¥';

  @override
  String todayWithDate(Object date) {
    return 'ä»Šæ—¥ â€¢ $date';
  }

  @override
  String get hijriUnknown => 'ãƒ’ã‚¸ãƒ¥ãƒ©æš¦: -';

  @override
  String hijriWithDate(Object date) {
    return 'ãƒ’ã‚¸ãƒ¥ãƒ©æš¦: $date';
  }

  @override
  String get reminderSettingsTitle => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼è¨­å®š';

  @override
  String get reminderSettingsSubtitle =>
      'ä¸Šã®ç¤¼æ‹æ™‚é–“ã‚’ã‚¿ãƒƒãƒ—ã—ã¦é€šçŸ¥ã‚¿ã‚¤ãƒ—ã¨äº‹å‰åˆ†æ•°ã‚’è¨­å®šã—ã¾ã™ã€‚';

  @override
  String get tooltipScheduledDebug => 'äºˆç´„é€šçŸ¥ãƒ‡ãƒãƒƒã‚°';

  @override
  String get scheduledRemindersDebugTitle => 'äºˆç´„é€šçŸ¥ï¼ˆãƒ‡ãƒãƒƒã‚°ï¼‰';

  @override
  String pendingNotificationsCount(Object count) {
    return 'ä¿ç•™ä¸­ã®é€šçŸ¥: $count';
  }

  @override
  String get sendTestNotificationNow => 'ãƒ†ã‚¹ãƒˆé€šçŸ¥ã‚’é€ä¿¡';

  @override
  String get testNotificationSent => 'ãƒ†ã‚¹ãƒˆé€šçŸ¥ã‚’é€ä¿¡ã—ã¾ã—ãŸã€‚';

  @override
  String get statusBarMinutesTitle => 'ã‚¹ãƒ†ãƒ¼ã‚¿ã‚¹ãƒãƒ¼åˆ†è¡¨ç¤º';

  @override
  String get statusBarMinutesSubtitle =>
      'ã‚¹ãƒ†ãƒ¼ã‚¿ã‚¹ãƒãƒ¼ã«æ®‹ã‚Šåˆ†ã®ç¶™ç¶šé€šçŸ¥ã‚’è¡¨ç¤ºã—ã¾ã™ã€‚';

  @override
  String get statusAutoRestoreTitle => 'å‰Šé™¤æ™‚ã«è‡ªå‹•å¾©å…ƒ';

  @override
  String get statusAutoRestoreSubtitle =>
      'ãƒ¦ãƒ¼ã‚¶ãƒ¼ãŒæ¶ˆã—ãŸã‚‰å†ä½œæˆã—ã¾ã™ã€‚';

  @override
  String get noPendingReminders => 'ä¿ç•™ä¸­ã®é€šçŸ¥ã¯ã‚ã‚Šã¾ã›ã‚“ã€‚';

  @override
  String get unknownFireTime => 'ä¸æ˜Žãªæ™‚åˆ»';

  @override
  String get pastPrefix => '[éŽåŽ»] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'ã‚ªãƒ³ â€¢ å®šåˆ» + $minutes åˆ†å‰';
  }

  @override
  String get reminderOnTimeOnly => 'ã‚ªãƒ³ â€¢ å®šåˆ»';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'ã‚ªãƒ³ â€¢ $minutes åˆ†å‰';
  }

  @override
  String get reminderOff => 'é€šçŸ¥ã‚ªãƒ•';

  @override
  String get nextPrayerTitle => 'æ¬¡ã®ç¤¼æ‹';

  @override
  String get homeUpcomingRemindersTitle => 'è¿‘æ—¥ã®ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total 礼拝完了';
  }

  @override
  String startsIn(Object remaining) {
    return '$remaining å¾Œã«é–‹å§‹';
  }

  @override
  String get selectYourLocation => 'å ´æ‰€ã‚’é¸æŠž';

  @override
  String get locationHelp =>
      'GPSã§ç°¡å˜è¨­å®šã€ã¾ãŸã¯å›½/éƒ½å¸‚ã‚’æ‰‹å‹•é¸æŠžã§ãã¾ã™ã€‚';

  @override
  String get useCurrentLocation => 'ç¾åœ¨åœ°ã‚’ä½¿ç”¨';

  @override
  String get country => 'å›½';

  @override
  String get stateCity => 'å·ž / å¸‚';

  @override
  String get district => 'åœ°åŒº';

  @override
  String get saveLocation => 'å ´æ‰€ã‚’ä¿å­˜';

  @override
  String selectedLocation(Object location) {
    return 'é¸æŠžä¸­: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1å¹´åˆ†ã®ç¤¼æ‹ä¸€è¦§ã‚’è¦‹ã‚‹ã«ã¯å…ˆã«å ´æ‰€ã‚’é¸æŠžã—ã¦ãã ã•ã„ã€‚';

  @override
  String get historyTableTitle => 'ç¤¼æ‹æ™‚é–“è¡¨ï¼ˆå¹´é–“ï¼‰';

  @override
  String get todayShort => 'ä»Šæ—¥';

  @override
  String get dateHeader => 'æ—¥ä»˜';

  @override
  String get imsak => 'ãƒ•ã‚¡ã‚¸ãƒ¥ãƒ«';

  @override
  String get gunes => 'æ—¥å‡º';

  @override
  String get ogle => 'ã‚ºãƒ•ãƒ«';

  @override
  String get ikindi => 'ã‚¢ã‚¹ãƒ«';

  @override
  String get aksam => 'ãƒžã‚°ãƒªãƒ–';

  @override
  String get yatsi => 'ã‚¤ã‚·ãƒ£';

  @override
  String get hijriHeader => 'ãƒ’ã‚¸ãƒ¥ãƒ©';

  @override
  String get preferencesTitle => 'è¨­å®š';

  @override
  String get languageTitle => 'è¨€èªž';

  @override
  String get languageSystem => 'ã‚·ã‚¹ãƒ†ãƒ è¨­å®š';

  @override
  String get themeModeTitle => 'ãƒ†ãƒ¼ãƒžãƒ¢ãƒ¼ãƒ‰';

  @override
  String get themeSystem => 'ã‚·ã‚¹ãƒ†ãƒ è¨­å®š';

  @override
  String get themeLight => 'ãƒ©ã‚¤ãƒˆ';

  @override
  String get themeDark => 'ãƒ€ãƒ¼ã‚¯';

  @override
  String get appBarRemainingTitle =>
      'ãƒ›ãƒ¼ãƒ ä¸Šéƒ¨ãƒãƒ¼ã®æ®‹ã‚Šæ™‚é–“è¡¨ç¤º';

  @override
  String get showInTitle => 'ã‚¿ã‚¤ãƒˆãƒ«ã«è¡¨ç¤º';

  @override
  String get showAtRight => 'å³å´ã«è¡¨ç¤º';

  @override
  String get showAsSubtitle => 'ã‚µãƒ–ã‚¿ã‚¤ãƒˆãƒ«ã«è¡¨ç¤º';

  @override
  String get hideRemainingText => 'æ®‹ã‚Šãƒ†ã‚­ã‚¹ãƒˆã‚’éžè¡¨ç¤º';

  @override
  String get notificationMessageTitle => 'é€šçŸ¥ãƒ¡ãƒƒã‚»ãƒ¼ã‚¸';

  @override
  String get notificationMessageShown => 'è¡¨ç¤º';

  @override
  String get notificationMessageHidden => 'éžè¡¨ç¤º';

  @override
  String get widgetTextSizeTitle => 'ã‚¦ã‚£ã‚¸ã‚§ãƒƒãƒˆã®æ–‡å­—ã‚µã‚¤ã‚º';

  @override
  String get widgetTextSizeSubtitle =>
      'ãƒ›ãƒ¼ãƒ ç”»é¢ã‚¦ã‚£ã‚¸ã‚§ãƒƒãƒˆã§ä½¿ç”¨ã™ã‚‹æ–‡å­—ã‚µã‚¤ã‚ºã€‚';

  @override
  String get widgetTextSizeExtraSmall => 'æ¥µå°';

  @override
  String get widgetTextSizeSmall => 'å°';

  @override
  String get widgetTextSizeMedium => 'ä¸­';

  @override
  String get widgetTextSizeLarge => 'å¤§';

  @override
  String get widgetMmssThresholdTitle =>
      'ã‚¦ã‚£ã‚¸ã‚§ãƒƒãƒˆã®ç§’ã‚«ã‚¦ãƒ³ãƒˆãƒ€ã‚¦ãƒ³';

  @override
  String get widgetMmssThresholdNever => 'å¸¸ã«HH:MMã‚’è¡¨ç¤º';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutesåˆ†æœªæº€ã¯MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ on/off';

  @override
  String get remindersOnOffSubtitle =>
      'ç¤¼æ‹ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼é€šçŸ¥ã®ã‚ªãƒ³/ã‚ªãƒ•ã€‚ç¤¼æ‹ã”ã¨ã®è¨­å®šã¯ä¿æŒã•ã‚Œã¾ã™ã€‚';

  @override
  String get reminderVibrationTitle => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã§æŒ¯å‹•';

  @override
  String get reminderVibrationSubtitle =>
      'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ç™ºç”Ÿæ™‚ã«ç´„10ç§’é–“ã€æ–­ç¶šçš„ã«æŒ¯å‹•ã—ã¾ã™ã€‚';

  @override
  String get reminderSoundTitle => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã§éŸ³ã‚’å†ç”Ÿ';

  @override
  String get reminderSoundSubtitle =>
      'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ç™ºç”Ÿæ™‚ã«é€šçŸ¥éŸ³ã‚’å†ç”Ÿã—ã¾ã™ã€‚';

  @override
  String get remindersOn => 'ã‚ªãƒ³';

  @override
  String get remindersOff => 'ã‚ªãƒ•';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼';
  }

  @override
  String get reminderTypeTitle => 'é€šçŸ¥ã‚¿ã‚¤ãƒ—ï¼ˆä¸¡æ–¹é¸æŠžå¯ï¼‰';

  @override
  String get onTime => 'å®šåˆ»';

  @override
  String get before => 'å‰';

  @override
  String get after => 'å¾Œ';

  @override
  String get reminderAlertTitle => 'ã‚¢ãƒ©ãƒ¼ãƒˆ';

  @override
  String get reminderAlertSubtitle =>
      'å®Ÿéš›ã«ã‚¢ãƒ©ãƒ¼ãƒˆã™ã‚‹ã«ã¯ç’°å¢ƒè¨­å®šå†…ã®å¯¾å¿œã™ã‚‹ã‚¹ã‚¤ãƒƒãƒã‚‚ã‚ªãƒ³ã§ã‚ã‚‹å¿…è¦ãŒã‚ã‚Šã¾ã™ã€‚';

  @override
  String get vibrateChip => 'æŒ¯å‹•';

  @override
  String get soundChip => 'éŸ³';

  @override
  String get adhanChip => 'ã‚¢ã‚¶ãƒ¼ãƒ³';

  @override
  String get remindBeforePrayerTitle => 'ç¤¼æ‹å‰ã«é€šçŸ¥';

  @override
  String get remindAfterPrayerTitle => 'ç¤¼æ‹å¾Œã«é€šçŸ¥';

  @override
  String minutesValue(Object minutes) {
    return '$minutes åˆ†';
  }

  @override
  String get custom => 'ã‚«ã‚¹ã‚¿ãƒ ';

  @override
  String get customMinutes => 'ã‚«ã‚¹ã‚¿ãƒ åˆ†';

  @override
  String get customMinutesHint => 'ä¾‹: 12';

  @override
  String get save => 'ä¿å­˜';

  @override
  String get enableBeforeToSelectMinutes =>
      'åˆ†ã‚’é¸ã¶ã«ã¯ã€Œå‰ã€ã‚’æœ‰åŠ¹ã«ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get enableAfterToSelectMinutes =>
      'åˆ†ã‚’é¸ã¶ã«ã¯ã€Œå¾Œã€ã‚’æœ‰åŠ¹ã«ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get enterValidPositiveNumber =>
      'æœ‰åŠ¹ãªæ­£ã®æ•°ã‚’å…¥åŠ›ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get useValueUpTo240 =>
      '240åˆ†ä»¥ä¸‹ã®å€¤ã‚’å…¥åŠ›ã—ã¦ãã ã•ã„ã€‚';

  @override
  String get customMinutesSaved => 'ã‚«ã‚¹ã‚¿ãƒ åˆ†ã‚’ä¿å­˜ã—ã¾ã—ãŸã€‚';

  @override
  String get cancel => 'ã‚­ãƒ£ãƒ³ã‚»ãƒ«';

  @override
  String get calendarTabTooltip => 'ãƒ’ã‚¸ãƒ¥ãƒ©æš¦ã‚«ãƒ¬ãƒ³ãƒ€ãƒ¼';

  @override
  String get calendarPreviousMonth => 'å‰ã®æœˆ';

  @override
  String get calendarNextMonth => 'æ¬¡ã®æœˆ';

  @override
  String get calendarSwapPrimary => 'ãƒ’ã‚¸ãƒ¥ãƒ©æš¦/è¥¿æš¦ã‚’åˆ‡æ›¿';

  @override
  String get calendarShowSecondary => 'å‰¯æš¦æ—¥ã‚’è¡¨ç¤º';

  @override
  String get calendarHideSecondary => 'å‰¯æš¦æ—¥ã‚’éžè¡¨ç¤º';

  @override
  String get calendarNoRemindersOnDay =>
      'ã“ã®æ—¥ã®ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã¯ã‚ã‚Šã¾ã›ã‚“';

  @override
  String get calendarAddReminder => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã‚’è¿½åŠ ';

  @override
  String get calendarEditReminder => 'ç·¨é›†';

  @override
  String get calendarDeleteReminder => 'å‰Šé™¤';

  @override
  String get calendarReminderFormTitleNew => 'æ–°ã—ã„ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼';

  @override
  String get calendarReminderFormTitleEdit => 'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ã‚’ç·¨é›†';

  @override
  String get calendarReminderTitleLabel => 'ã‚¿ã‚¤ãƒˆãƒ«';

  @override
  String get calendarReminderTitleHint => 'ä¾‹ï¼šãƒ©ãƒžãƒ€ãƒ³é–‹å§‹';

  @override
  String get calendarReminderNotesLabel => 'ãƒ¡ãƒ¢ï¼ˆä»»æ„ï¼‰';

  @override
  String get calendarReminderDateTimeLabel => 'æ—¥ä»˜ã¨æ™‚åˆ»';

  @override
  String get calendarReminderRecurrenceLabel => 'ç¹°ã‚Šè¿”ã—';

  @override
  String get calendarRecurrenceOnce => '1å›žã®ã¿';

  @override
  String get calendarRecurrenceDaily => 'æ¯Žæ—¥';

  @override
  String get calendarRecurrenceWeekly => 'æ¯Žé€±';

  @override
  String get calendarRecurrenceMonthly => 'æ¯Žæœˆ';

  @override
  String get calendarRecurrenceYearly => 'æ¯Žå¹´';

  @override
  String get calendarRepeatCountLabel => 'ç¹°ã‚Šè¿”ã—å›žæ•°';

  @override
  String get calendarRepeatCountHelper =>
      'ãƒªãƒžã‚¤ãƒ³ãƒ€ãƒ¼ãŒåœæ­¢ã™ã‚‹ã¾ã§ã®ç™ºç«å›žæ•°ï¼ˆã‚ªãƒ• = æ°¸ä¹…ã«ç¹°ã‚Šè¿”ã™ï¼‰';

  @override
  String get calendarRepeatCountError =>
      '2ã€œ100ã®æ•°å­—ã‚’å…¥åŠ›ã—ã¦ãã ã•ã„';

  @override
  String get calendarRepeatDaysLabel => 'ç¹°ã‚Šè¿”ã™æ›œæ—¥';

  @override
  String get calendarDayOfMonthLabel => 'æœˆã®æ—¥';

  @override
  String get calendarYearlyMonthLabel => 'æœˆ';

  @override
  String get calendarYearlyDayLabel => 'æ—¥';

  @override
  String get calendarMonthlyBasisLabel => 'æœˆæ¬¡åŸºæº–';

  @override
  String get calendarYearlyBasisLabel => 'å¹´æ¬¡åŸºæº–';

  @override
  String get calendarYearlyBasisGregorian => 'è¥¿æš¦';

  @override
  String get calendarYearlyBasisHijri => 'ãƒ’ã‚¸ãƒ¥ãƒ©æš¦';

  @override
  String get calendarReminderTitleRequired =>
      'ã‚¿ã‚¤ãƒˆãƒ«ã‚’å…¥åŠ›ã—ã¦ãã ã•ã„';

  @override
  String get calendarAnchorClockTime => 'ã‚«ãƒ¬ãƒ³ãƒ€ãƒ¼ã®æ—¥ä»˜';

  @override
  String get calendarAnchorPrayerTime => 'ç¤¼æ‹æ™‚é–“';

  @override
  String get calendarSelectPrayer => 'ç¤¼æ‹ã‚’é¸æŠž';

  @override
  String get calendarOffsetOnTime => 'å®šåˆ»';

  @override
  String get calendarOffsetBefore => 'å‰';

  @override
  String get calendarOffsetAfter => 'å¾Œ';

  @override
  String get calendarPickAnchorDate => 'æ—¥ä»˜ã‚’é¸æŠž';

  @override
  String get datesPrayerTimesTab => 'ç¤¼æ‹æ™‚é–“';

  @override
  String get datesCalendarTab => 'ã‚«ãƒ¬ãƒ³ãƒ€ãƒ¼';

  @override
  String get undo => 'å…ƒã«æˆ»ã™';

  @override
  String calendarReminderDeleted(Object title) {
    return 'ã€Œ$titleã€ã‚’å‰Šé™¤ã—ã¾ã—ãŸ';
  }
}
