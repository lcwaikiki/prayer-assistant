// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'ç¤¼æ‹œåŠ©æ‰‹';

  @override
  String get tabLocation => 'ä½ç½®';

  @override
  String get tabToday => 'ä»Šå¤©';

  @override
  String get tabDates => 'æ—¥æœŸ';

  @override
  String get tabTesbih => 'å¿µç ';

  @override
  String get tooltipToggleLightDark => 'åˆ‡æ¢æ˜Žæš—æ¨¡å¼';

  @override
  String get tooltipRemindersOn => 'å¼€å¯æé†’';

  @override
  String get tooltipRemindersOff => 'å…³é—­æé†’';

  @override
  String get tooltipPreferences => 'åå¥½è®¾ç½®';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes åˆ†é’Ÿ';
  }

  @override
  String get remainingMinutesUnknown => '-- åˆ†é’Ÿ';

  @override
  String get homeNoLocationTitle => 'æœªé€‰æ‹©ä½ç½®';

  @override
  String get homeNoLocationSubtitle =>
      'è¯·å…ˆåˆ°â€œä½ç½®â€é¡µä¿å­˜ä½ çš„åœ°åŒºã€‚';

  @override
  String get homeNoPrayerTimesTitle => 'æš‚æ— ç¼“å­˜ç¤¼æ‹œæ—¶é—´';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'ç‚¹å‡»åˆ·æ–°ä»¥åŒæ­¥å…¨å¹´æ•°æ®ã€‚';

  @override
  String get refresh => 'åˆ·æ–°';

  @override
  String get qiblaTitle => 'æœæ‹œæ–¹å‘';

  @override
  String qiblaBearing(int degrees) {
    return 'æœæ‹œæ–¹å‘: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'æ— æ³•ç¡®å®šæ‚¨çš„ä½ç½®ã€‚è¯·å¯ç”¨GPSåŽé‡è¯•ã€‚';

  @override
  String get qiblaHeadingUnavailable =>
      'æŒ‡å—é’ˆä¸å¯ç”¨ - æ˜¾ç¤ºå›ºå®šæ–¹å‘ã€‚';

  @override
  String get qiblaPointDevice => 'æ—‹è½¬è®¾å¤‡ç›´åˆ°æŒ‡é’ˆæœä¸Šã€‚';

  @override
  String get qiblaKaabaShort => 'æœæ‹œ';

  @override
  String get shareTodayTimes => 'åˆ†äº«ä»Šæ—¥æ—¶é—´';

  @override
  String get calendarPreviousDay => 'å‰ä¸€å¤©';

  @override
  String get calendarNextDay => 'ç¬¬äºŒå¤©';

  @override
  String todayWithDate(Object date) {
    return 'ä»Šå¤© â€¢ $date';
  }

  @override
  String get hijriUnknown => 'å›žåŽ†: -';

  @override
  String hijriWithDate(Object date) {
    return 'å›žåŽ†: $date';
  }

  @override
  String get reminderSettingsTitle => 'æé†’è®¾ç½®';

  @override
  String get reminderSettingsSubtitle =>
      'ç‚¹å‡»ä¸Šæ–¹ä»»ä¸€ç¤¼æ‹œæ—¶é—´ä»¥è®¾ç½®æé†’åŠæå‰åˆ†é’Ÿæ•°ã€‚';

  @override
  String get tooltipScheduledDebug => 'è®¡åˆ’æé†’è°ƒè¯•';

  @override
  String get scheduledRemindersDebugTitle => 'è®¡åˆ’æé†’ï¼ˆè°ƒè¯•ï¼‰';

  @override
  String pendingNotificationsCount(Object count) {
    return 'å¾…å¤„ç†é€šçŸ¥ï¼š$count';
  }

  @override
  String get sendTestNotificationNow => 'ç«‹å³å‘é€æµ‹è¯•é€šçŸ¥';

  @override
  String get testNotificationSent => 'æµ‹è¯•é€šçŸ¥å·²å‘é€ã€‚';

  @override
  String get statusBarMinutesTitle => 'çŠ¶æ€æ åˆ†é’Ÿæ•°';

  @override
  String get statusBarMinutesSubtitle =>
      'åœ¨çŠ¶æ€æ æ˜¾ç¤ºæŒç»­çš„å‰©ä½™åˆ†é’Ÿé€šçŸ¥ã€‚';

  @override
  String get statusAutoRestoreTitle => 'è¢«åˆ’æŽ‰åŽè‡ªåŠ¨æ¢å¤';

  @override
  String get statusAutoRestoreSubtitle =>
      'ç”¨æˆ·åˆ’æŽ‰åŽè‡ªåŠ¨é‡æ–°åˆ›å»ºçŠ¶æ€é¡¹ã€‚';

  @override
  String get noPendingReminders => 'æ²¡æœ‰å¾…å¤„ç†æé†’é€šçŸ¥ã€‚';

  @override
  String get unknownFireTime => 'æœªçŸ¥è§¦å‘æ—¶é—´';

  @override
  String get pastPrefix => '[å·²è¿‡] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'å¼€å¯ â€¢ å‡†ç‚¹ + æå‰ $minutes åˆ†é’Ÿ';
  }

  @override
  String get reminderOnTimeOnly => 'å¼€å¯ â€¢ å‡†ç‚¹';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'å¼€å¯ â€¢ æå‰ $minutes åˆ†é’Ÿ';
  }

  @override
  String get reminderOff => 'æé†’å·²å…³é—­';

  @override
  String get nextPrayerTitle => 'ä¸‹ä¸€æ¬¡ç¤¼æ‹œ';

  @override
  String get homeUpcomingRemindersTitle => 'å³å°†åˆ°æ¥çš„æé†’';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total 礼拜已完成';
  }

  @override
  String startsIn(Object remaining) {
    return '$remaining åŽå¼€å§‹';
  }

  @override
  String get selectYourLocation => 'é€‰æ‹©ä½ çš„ä½ç½®';

  @override
  String get locationHelp =>
      'å¯ä½¿ç”¨ GPS å¿«é€Ÿè®¾ç½®ï¼Œæˆ–æ‰‹åŠ¨é€‰æ‹©å›½å®¶/åŸŽå¸‚ã€‚';

  @override
  String get useCurrentLocation => 'ä½¿ç”¨å½“å‰ä½ç½®';

  @override
  String get country => 'å›½å®¶';

  @override
  String get stateCity => 'çœ/å·ž / åŸŽå¸‚';

  @override
  String get district => 'åœ°åŒº';

  @override
  String get saveLocation => 'ä¿å­˜ä½ç½®';

  @override
  String selectedLocation(Object location) {
    return 'å·²é€‰æ‹©ï¼š$location';
  }

  @override
  String get historySelectLocationFirst =>
      'è¯·å…ˆé€‰æ‹©ä½ç½®ä»¥æŸ¥çœ‹ 1 å¹´ç¤¼æ‹œæ—¶é—´åˆ—è¡¨ã€‚';

  @override
  String get historyTableTitle => 'ç¤¼æ‹œæ—¶é—´è¡¨ï¼ˆå…¨å¹´ï¼‰';

  @override
  String get todayShort => 'ä»Šå¤©';

  @override
  String get dateHeader => 'æ—¥æœŸ';

  @override
  String get imsak => 'æ™¨ç¤¼';

  @override
  String get gunes => 'æ—¥å‡º';

  @override
  String get ogle => 'æ™Œç¤¼';

  @override
  String get ikindi => 'æ™¡ç¤¼';

  @override
  String get aksam => 'æ˜ç¤¼';

  @override
  String get yatsi => 'å®µç¤¼';

  @override
  String get hijriHeader => 'å›žåŽ†';

  @override
  String get preferencesTitle => 'åå¥½è®¾ç½®';

  @override
  String get languageTitle => 'è¯­è¨€';

  @override
  String get languageSystem => 'è·Ÿéšç³»ç»Ÿ';

  @override
  String get themeModeTitle => 'ä¸»é¢˜æ¨¡å¼';

  @override
  String get themeSystem => 'è·Ÿéšç³»ç»Ÿ';

  @override
  String get themeLight => 'æµ…è‰²';

  @override
  String get themeDark => 'æ·±è‰²';

  @override
  String get appBarRemainingTitle => 'é¦–é¡µé¡¶æ å‰©ä½™æ—¶é—´æ˜¾ç¤º';

  @override
  String get showInTitle => 'æ˜¾ç¤ºåœ¨æ ‡é¢˜';

  @override
  String get showAtRight => 'æ˜¾ç¤ºåœ¨å³ä¾§';

  @override
  String get showAsSubtitle => 'æ˜¾ç¤ºä¸ºå‰¯æ ‡é¢˜';

  @override
  String get hideRemainingText => 'éšè—å‰©ä½™æ–‡å­—';

  @override
  String get notificationMessageTitle => 'é€šçŸ¥æ¶ˆæ¯';

  @override
  String get notificationMessageShown => 'æ˜¾ç¤º';

  @override
  String get notificationMessageHidden => 'éšè—';

  @override
  String get widgetTextSizeTitle => 'å°ç»„ä»¶æ–‡å­—å¤§å°';

  @override
  String get widgetTextSizeSubtitle =>
      'ä¸»å±å¹•å°ç»„ä»¶ä½¿ç”¨çš„æ–‡å­—å¤§å°ã€‚';

  @override
  String get widgetTextSizeExtraSmall => 'æžå°';

  @override
  String get widgetTextSizeSmall => 'å°';

  @override
  String get widgetTextSizeMedium => 'ä¸­';

  @override
  String get widgetTextSizeLarge => 'å¤§';

  @override
  String get widgetMmssThresholdTitle => 'å°ç»„ä»¶ç§’å€’è®¡æ—¶';

  @override
  String get widgetMmssThresholdNever => 'å§‹ç»ˆæ˜¾ç¤ºHH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes åˆ†é’Ÿä»¥ä¸‹æ˜¾ç¤º MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'æé†’å¼€/å…³';

  @override
  String get remindersOnOffSubtitle =>
      'å¼€å¯æˆ–å…³é—­ç¤¼æ‹œæé†’é€šçŸ¥ï¼Œå„ç¤¼æ‹œçš„è®¾ç½®ä¼šä¿ç•™ã€‚';

  @override
  String get reminderVibrationTitle => 'æé†’æ—¶æŒ¯åŠ¨';

  @override
  String get reminderVibrationSubtitle =>
      'æé†’è§¦å‘æ—¶è„‰å†²å¼æŒ¯åŠ¨çº¦10ç§’ã€‚';

  @override
  String get reminderSoundTitle => 'æé†’æ—¶æ’­æ”¾å£°éŸ³';

  @override
  String get reminderSoundSubtitle => 'æé†’è§¦å‘æ—¶æ’­æ”¾é€šçŸ¥å£°éŸ³ã€‚';

  @override
  String get remindersOn => 'å¼€';

  @override
  String get remindersOff => 'å…³';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer æé†’';
  }

  @override
  String get reminderTypeTitle => 'æé†’ç±»åž‹ï¼ˆå¯åŒæ—¶é€‰æ‹©ï¼‰';

  @override
  String get onTime => 'å‡†ç‚¹';

  @override
  String get before => 'æå‰';

  @override
  String get after => 'å»¶åŽ';

  @override
  String get reminderAlertTitle => 'æé†’æ–¹å¼';

  @override
  String get reminderAlertSubtitle =>
      'è¿˜éœ€è¦åœ¨åå¥½è®¾ç½®ä¸­æ‰“å¼€å¯¹åº”å¼€å…³æ‰ä¼šçœŸæ­£æé†’ã€‚';

  @override
  String get vibrateChip => 'æŒ¯åŠ¨';

  @override
  String get soundChip => 'å£°éŸ³';

  @override
  String get adhanChip => 'å®£ç¤¼';

  @override
  String get remindBeforePrayerTitle => 'åœ¨ç¤¼æ‹œå‰æé†’æˆ‘';

  @override
  String get remindAfterPrayerTitle => 'åœ¨ç¤¼æ‹œåŽæé†’æˆ‘';

  @override
  String minutesValue(Object minutes) {
    return '$minutes åˆ†é’Ÿ';
  }

  @override
  String get custom => 'è‡ªå®šä¹‰';

  @override
  String get customMinutes => 'è‡ªå®šä¹‰åˆ†é’Ÿ';

  @override
  String get customMinutesHint => 'ä¾‹å¦‚ 12';

  @override
  String get save => 'ä¿å­˜';

  @override
  String get enableBeforeToSelectMinutes =>
      'å¯ç”¨â€œæå‰â€åŽå¯é€‰æ‹©åˆ†é’Ÿã€‚';

  @override
  String get enableAfterToSelectMinutes =>
      'å¯ç”¨â€œå»¶åŽâ€åŽå¯é€‰æ‹©åˆ†é’Ÿã€‚';

  @override
  String get enterValidPositiveNumber => 'è¯·è¾“å…¥æœ‰æ•ˆçš„æ­£æ•°ã€‚';

  @override
  String get useValueUpTo240 => 'è¯·è¾“å…¥ä¸è¶…è¿‡ 240 çš„åˆ†é’Ÿå€¼ã€‚';

  @override
  String get customMinutesSaved => 'è‡ªå®šä¹‰åˆ†é’Ÿå·²ä¿å­˜ã€‚';

  @override
  String get cancel => 'å–æ¶ˆ';

  @override
  String get calendarTabTooltip => 'å›žåŽ†æ—¥åŽ†';

  @override
  String get calendarPreviousMonth => 'ä¸Šä¸ªæœˆ';

  @override
  String get calendarNextMonth => 'ä¸‹ä¸ªæœˆ';

  @override
  String get calendarSwapPrimary => 'åˆ‡æ¢å›žåŽ†/å…¬åŽ†';

  @override
  String get calendarShowSecondary => 'æ˜¾ç¤ºå‰¯åŽ†æ—¥æœŸ';

  @override
  String get calendarHideSecondary => 'éšè—å‰¯åŽ†æ—¥æœŸ';

  @override
  String get calendarNoRemindersOnDay => 'è¿™ä¸€å¤©æ²¡æœ‰æé†’';

  @override
  String get calendarAddReminder => 'æ·»åŠ æé†’';

  @override
  String get calendarEditReminder => 'ç¼–è¾‘';

  @override
  String get calendarDeleteReminder => 'åˆ é™¤';

  @override
  String get calendarReminderFormTitleNew => 'æ–°å»ºæé†’';

  @override
  String get calendarReminderFormTitleEdit => 'ç¼–è¾‘æé†’';

  @override
  String get calendarReminderTitleLabel => 'æ ‡é¢˜';

  @override
  String get calendarReminderTitleHint => 'ä¾‹å¦‚ï¼šæ–‹æœˆå¼€å§‹';

  @override
  String get calendarReminderNotesLabel => 'å¤‡æ³¨ï¼ˆå¯é€‰ï¼‰';

  @override
  String get calendarReminderDateTimeLabel => 'æ—¥æœŸå’Œæ—¶é—´';

  @override
  String get calendarReminderRecurrenceLabel => 'é‡å¤';

  @override
  String get calendarRecurrenceOnce => 'ä»…ä¸€æ¬¡';

  @override
  String get calendarRecurrenceDaily => 'æ¯å¤©';

  @override
  String get calendarRecurrenceWeekly => 'æ¯å‘¨';

  @override
  String get calendarRecurrenceMonthly => 'æ¯æœˆ';

  @override
  String get calendarRecurrenceYearly => 'æ¯å¹´';

  @override
  String get calendarRepeatCountLabel => 'é‡å¤æ¬¡æ•°';

  @override
  String get calendarRepeatCountHelper =>
      'æé†’åœæ­¢å‰è§¦å‘çš„æ¬¡æ•°ï¼ˆå…³é—­ = æ°¸è¿œé‡å¤ï¼‰';

  @override
  String get calendarRepeatCountError => 'è¯·è¾“å…¥ 2 åˆ° 100 ä¹‹é—´çš„æ•°å­—';

  @override
  String get calendarRepeatDaysLabel => 'é‡å¤äºŽ';

  @override
  String get calendarDayOfMonthLabel => 'æ¯æœˆå‡ å·';

  @override
  String get calendarYearlyMonthLabel => 'æœˆä»½';

  @override
  String get calendarYearlyDayLabel => 'æ—¥';

  @override
  String get calendarMonthlyBasisLabel => 'æœˆåº¦åŸºå‡†';

  @override
  String get calendarYearlyBasisLabel => 'å¹´åº¦åŸºå‡†';

  @override
  String get calendarYearlyBasisGregorian => 'å…¬åŽ†';

  @override
  String get calendarYearlyBasisHijri => 'å›žåŽ†';

  @override
  String get calendarReminderTitleRequired => 'è¯·è¾“å…¥æ ‡é¢˜';

  @override
  String get calendarAnchorClockTime => 'æ—¥åŽ†æ—¥æœŸ';

  @override
  String get calendarAnchorPrayerTime => 'ç¤¼æ‹œæ—¶é—´';

  @override
  String get calendarSelectPrayer => 'é€‰æ‹©ç¤¼æ‹œ';

  @override
  String get calendarOffsetOnTime => 'å‡†ç‚¹';

  @override
  String get calendarOffsetBefore => 'æå‰';

  @override
  String get calendarOffsetAfter => 'å»¶åŽ';

  @override
  String get calendarPickAnchorDate => 'é€‰æ‹©æ—¥æœŸ';

  @override
  String get datesPrayerTimesTab => 'ç¤¼æ‹œæ—¶é—´';

  @override
  String get datesCalendarTab => 'æ—¥åŽ†';

  @override
  String get undo => 'æ’¤é”€';

  @override
  String calendarReminderDeleted(Object title) {
    return 'å·²åˆ é™¤â€œ$titleâ€';
  }
}
