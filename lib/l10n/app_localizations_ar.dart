// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Ù…Ø³Ø§Ø¹Ø¯ Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String get tabLocation => 'Ø§Ù„Ù…ÙˆÙ‚Ø¹';

  @override
  String get tabToday => 'Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get tabDates => 'Ø§Ù„ØªÙˆØ§Ø±ÙŠØ®';

  @override
  String get tabTesbih => 'Ù…ÙØ³Ù’Ø¨ÙŽØ­ÙŽØ©';

  @override
  String get tooltipToggleLightDark => 'ØªØ¨Ø¯ÙŠÙ„ ÙØ§ØªØ­/Ø¯Ø§ÙƒÙ†';

  @override
  String get tooltipRemindersOn => 'ØªØ´ØºÙŠÙ„ Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª';

  @override
  String get tooltipRemindersOff => 'Ø¥ÙŠÙ‚Ø§Ù Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª';

  @override
  String get tooltipPreferences => 'Ø§Ù„ØªÙØ¶ÙŠÙ„Ø§Øª';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes Ø¯';
  }

  @override
  String get remainingMinutesUnknown => '-- Ø¯';

  @override
  String get homeNoLocationTitle => 'Ù„Ù… ÙŠØªÙ… Ø§Ø®ØªÙŠØ§Ø± Ù…ÙˆÙ‚Ø¹';

  @override
  String get homeNoLocationSubtitle =>
      'Ø§Ø°Ù‡Ø¨ Ø¥Ù„Ù‰ ØªØ¨ÙˆÙŠØ¨ Ø§Ù„Ù…ÙˆÙ‚Ø¹ ÙˆØ§Ø­ÙØ¸ Ù…Ù†Ø·Ù‚ØªÙƒ Ø£ÙˆÙ„Ø§Ù‹.';

  @override
  String get homeNoPrayerTimesTitle =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø£ÙˆÙ‚Ø§Øª ØµÙ„Ø§Ø© Ù…Ø®Ø²Ù†Ø©';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Ø§Ø¶ØºØ· ØªØ­Ø¯ÙŠØ« Ù„Ù…Ø²Ø§Ù…Ù†Ø© Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø³Ù†Ø©.';

  @override
  String get refresh => 'ØªØ­Ø¯ÙŠØ«';

  @override
  String get qiblaTitle => 'Ø§Ù„Ù‚Ø¨Ù„Ø©';

  @override
  String qiblaBearing(int degrees) {
    return 'Ø§Ù„Ù‚Ø¨Ù„Ø©: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ¯ Ù…ÙˆÙ‚Ø¹Ùƒ. ÙØ¹Ù‘Ù„ Ù†Ø¸Ø§Ù… ØªØ­Ø¯ÙŠØ¯ Ø§Ù„Ù…ÙˆØ§Ù‚Ø¹ ÙˆØ­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.';

  @override
  String get qiblaHeadingUnavailable =>
      'Ø§Ù„Ø¨ÙˆØµÙ„Ø© ØºÙŠØ± Ù…ØªØ§Ø­Ø© - ÙŠØªÙ… Ø¹Ø±Ø¶ Ø§Ù„Ø§ØªØ¬Ø§Ù‡ Ø§Ù„Ø«Ø§Ø¨Øª.';

  @override
  String get qiblaPointDevice =>
      'Ø£Ø¯Ø± Ø¬Ù‡Ø§Ø²Ùƒ Ø­ØªÙ‰ ÙŠØ´ÙŠØ± Ø§Ù„Ø³Ù‡Ù… Ø¥Ù„Ù‰ Ø§Ù„Ø£Ø¹Ù„Ù‰.';

  @override
  String get qiblaKaabaShort => 'Ø§Ù„Ù‚Ø¨Ù„Ø©';

  @override
  String get shareTodayTimes => 'Ù…Ø´Ø§Ø±ÙƒØ© Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get calendarPreviousDay => 'Ø§Ù„ÙŠÙˆÙ… Ø§Ù„Ø³Ø§Ø¨Ù‚';

  @override
  String get calendarNextDay => 'Ø§Ù„ÙŠÙˆÙ… Ø§Ù„ØªØ§Ù„ÙŠ';

  @override
  String todayWithDate(Object date) {
    return 'Ø§Ù„ÙŠÙˆÙ… â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Ù‡Ø¬Ø±ÙŠ: -';

  @override
  String hijriWithDate(Object date) {
    return 'Ù‡Ø¬Ø±ÙŠ: $date';
  }

  @override
  String get reminderSettingsTitle => 'Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª Ø§Ù„ØªØ°ÙƒÙŠØ±';

  @override
  String get reminderSettingsSubtitle =>
      'Ø§Ø¶ØºØ· Ø¹Ù„Ù‰ Ø£ÙŠ ÙˆÙ‚Øª ØµÙ„Ø§Ø© Ø¨Ø§Ù„Ø£Ø¹Ù„Ù‰ Ù„Ø¶Ø¨Ø· Ø§Ù„ØªØ°ÙƒÙŠØ± ÙˆØ¹Ø¯Ø¯ Ø§Ù„Ø¯Ù‚Ø§Ø¦Ù‚ Ù‚Ø¨Ù„Ù‡Ø§.';

  @override
  String get tooltipScheduledDebug =>
      'ØªØµØ­ÙŠØ­ Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª Ø§Ù„Ù…Ø¬Ø¯ÙˆÙ„Ø©';

  @override
  String get scheduledRemindersDebugTitle =>
      'Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª Ø§Ù„Ù…Ø¬Ø¯ÙˆÙ„Ø© (ØªØµØ­ÙŠØ­)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø§Ù„Ù…Ø¹Ù„Ù‚Ø©: $count';
  }

  @override
  String get sendTestNotificationNow => 'Ø¥Ø±Ø³Ø§Ù„ Ø¥Ø´Ø¹Ø§Ø± ØªØ¬Ø±ÙŠØ¨ÙŠ';

  @override
  String get testNotificationSent =>
      'ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø¥Ø´Ø¹Ø§Ø± Ø§Ù„ØªØ¬Ø±ÙŠØ¨ÙŠ.';

  @override
  String get statusBarMinutesTitle => 'Ø¯Ù‚Ø§Ø¦Ù‚ Ø´Ø±ÙŠØ· Ø§Ù„Ø­Ø§Ù„Ø©';

  @override
  String get statusBarMinutesSubtitle =>
      'Ø¥Ø¸Ù‡Ø§Ø± Ø¥Ø´Ø¹Ø§Ø± Ù…Ø³ØªÙ…Ø± Ù„Ù„Ø¯Ù‚Ø§Ø¦Ù‚ Ø§Ù„Ù…ØªØ¨Ù‚ÙŠØ© ÙÙŠ Ø´Ø±ÙŠØ· Ø§Ù„Ø­Ø§Ù„Ø©.';

  @override
  String get statusAutoRestoreTitle =>
      'Ø¥Ø¹Ø§Ø¯Ø© ØªÙ„Ù‚Ø§Ø¦ÙŠØ© Ø¹Ù†Ø¯ Ø§Ù„Ø¥Ø²Ø§Ù„Ø©';

  @override
  String get statusAutoRestoreSubtitle =>
      'Ø¥Ø¹Ø§Ø¯Ø© Ø¥Ù†Ø´Ø§Ø¡ Ø¹Ù†ØµØ± Ø§Ù„Ø­Ø§Ù„Ø© Ø¥Ø°Ø§ Ù‚Ø§Ù… Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… Ø¨Ø¥Ø²Ø§Ù„ØªÙ‡.';

  @override
  String get noPendingReminders => 'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªØ°ÙƒÙŠØ±Ø§Øª Ù…Ø¹Ù„Ù‚Ø©.';

  @override
  String get unknownFireTime => 'ÙˆÙ‚Øª ØºÙŠØ± Ù…Ø¹Ø±ÙˆÙ';

  @override
  String get pastPrefix => '[Ù…Ø¶Ù‰] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Ù…ÙØ¹Ù„ â€¢ ÙÙŠ Ø§Ù„ÙˆÙ‚Øª + Ù‚Ø¨Ù„ $minutes Ø¯';
  }

  @override
  String get reminderOnTimeOnly => 'Ù…ÙØ¹Ù„ â€¢ ÙÙŠ Ø§Ù„ÙˆÙ‚Øª';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Ù…ÙØ¹Ù„ â€¢ Ù‚Ø¨Ù„ $minutes Ø¯';
  }

  @override
  String get reminderOff => 'Ø§Ù„ØªØ°ÙƒÙŠØ± Ù…ØªÙˆÙ‚Ù';

  @override
  String get nextPrayerTitle => 'Ø§Ù„ØµÙ„Ø§Ø© Ø§Ù„ØªØ§Ù„ÙŠØ©';

  @override
  String get homeUpcomingRemindersTitle => 'Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª Ø§Ù„Ù‚Ø§Ø¯Ù…Ø©';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total صلاة مكتملة';
  }

  @override
  String startsIn(Object remaining) {
    return 'ØªØ¨Ø¯Ø£ Ø¨Ø¹Ø¯ $remaining';
  }

  @override
  String get selectYourLocation => 'Ø§Ø®ØªØ± Ù…ÙˆÙ‚Ø¹Ùƒ';

  @override
  String get locationHelp =>
      'Ø§Ø³ØªØ®Ø¯Ù… GPS Ù„Ù„Ø¥Ø¹Ø¯Ø§Ø¯ Ø§Ù„Ø³Ø±ÙŠØ¹ Ø£Ùˆ Ø§Ø®ØªØ± Ø§Ù„Ø¯ÙˆÙ„Ø©/Ø§Ù„Ù…Ø¯ÙŠÙ†Ø© ÙŠØ¯ÙˆÙŠÙ‹Ø§.';

  @override
  String get useCurrentLocation => 'Ø§Ø³ØªØ®Ø¯Ù… Ø§Ù„Ù…ÙˆÙ‚Ø¹ Ø§Ù„Ø­Ø§Ù„ÙŠ';

  @override
  String get country => 'Ø§Ù„Ø¯ÙˆÙ„Ø©';

  @override
  String get stateCity => 'Ø§Ù„ÙˆÙ„Ø§ÙŠØ© / Ø§Ù„Ù…Ø¯ÙŠÙ†Ø©';

  @override
  String get district => 'Ø§Ù„Ù…Ù†Ø·Ù‚Ø©';

  @override
  String get saveLocation => 'Ø­ÙØ¸ Ø§Ù„Ù…ÙˆÙ‚Ø¹';

  @override
  String selectedLocation(Object location) {
    return 'Ø§Ù„Ù…Ø­Ø¯Ø¯: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Ø§Ø®ØªØ± Ù…ÙˆÙ‚Ø¹Ù‹Ø§ Ø£ÙˆÙ„Ù‹Ø§ Ù„Ø¹Ø±Ø¶ Ù‚Ø§Ø¦Ù…Ø© Ø§Ù„ØµÙ„Ø§Ø© Ù„Ø³Ù†Ø© ÙƒØ§Ù…Ù„Ø©.';

  @override
  String get historyTableTitle =>
      'Ø¬Ø¯ÙˆÙ„ Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ØµÙ„Ø§Ø© (Ø³Ù†Ø© ÙƒØ§Ù…Ù„Ø©)';

  @override
  String get todayShort => 'Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get dateHeader => 'Ø§Ù„ØªØ§Ø±ÙŠØ®';

  @override
  String get imsak => 'ÙØ¬Ø±';

  @override
  String get gunes => 'Ø´Ø±ÙˆÙ‚';

  @override
  String get ogle => 'Ø¸Ù‡Ø±';

  @override
  String get ikindi => 'Ø¹ØµØ±';

  @override
  String get aksam => 'Ù…ØºØ±Ø¨';

  @override
  String get yatsi => 'Ø¹Ø´Ø§Ø¡';

  @override
  String get hijriHeader => 'Ù‡Ø¬Ø±ÙŠ';

  @override
  String get preferencesTitle => 'Ø§Ù„ØªÙØ¶ÙŠÙ„Ø§Øª';

  @override
  String get languageTitle => 'Ø§Ù„Ù„ØºØ©';

  @override
  String get languageSystem => 'Ø§ÙØªØ±Ø§Ø¶ÙŠ Ø§Ù„Ù†Ø¸Ø§Ù…';

  @override
  String get themeModeTitle => 'ÙˆØ¶Ø¹ Ø§Ù„Ù…Ø¸Ù‡Ø±';

  @override
  String get themeSystem => 'Ø§ÙØªØ±Ø§Ø¶ÙŠ Ø§Ù„Ù†Ø¸Ø§Ù…';

  @override
  String get themeLight => 'ÙØ§ØªØ­';

  @override
  String get themeDark => 'Ø¯Ø§ÙƒÙ†';

  @override
  String get appBarRemainingTitle =>
      'Ù†Øµ Ø§Ù„ÙˆÙ‚Øª Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ ÙÙŠ Ø´Ø±ÙŠØ· Ø§Ù„ØªØ·Ø¨ÙŠÙ‚';

  @override
  String get showInTitle => 'Ø¥Ø¸Ù‡Ø§Ø± ÙÙŠ Ø§Ù„Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get showAtRight => 'Ø¥Ø¸Ù‡Ø§Ø± ÙÙŠ Ø§Ù„ÙŠÙ…ÙŠÙ†';

  @override
  String get showAsSubtitle => 'Ø¥Ø¸Ù‡Ø§Ø± ÙƒØ¹Ù†ÙˆØ§Ù† ÙØ±Ø¹ÙŠ';

  @override
  String get hideRemainingText => 'Ø¥Ø®ÙØ§Ø¡ Ø§Ù„Ù†Øµ Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ';

  @override
  String get notificationMessageTitle => 'Ø±Ø³Ø§Ù„Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±';

  @override
  String get notificationMessageShown => 'Ø¸Ø§Ù‡Ø±Ø©';

  @override
  String get notificationMessageHidden => 'Ù…Ø®ÙÙŠØ©';

  @override
  String get widgetTextSizeTitle => 'Ø­Ø¬Ù… Ø®Ø· Ø§Ù„ÙˆØ¯Ø¬Øª';

  @override
  String get widgetTextSizeSubtitle =>
      'Ø­Ø¬Ù… Ø§Ù„Ø®Ø· Ø§Ù„Ù…Ø³ØªØ®Ø¯Ù… ÙÙŠ ÙˆØ¯Ø¬ØªØ§Øª Ø§Ù„Ø´Ø§Ø´Ø© Ø§Ù„Ø±Ø¦ÙŠØ³ÙŠØ©.';

  @override
  String get widgetTextSizeExtraSmall => 'ØµØºÙŠØ± Ø¬Ø¯Ù‹Ø§';

  @override
  String get widgetTextSizeSmall => 'ØµØºÙŠØ±';

  @override
  String get widgetTextSizeMedium => 'Ù…ØªÙˆØ³Ø·';

  @override
  String get widgetTextSizeLarge => 'ÙƒØ¨ÙŠØ±';

  @override
  String get widgetMmssThresholdTitle =>
      'Ø¹Ø¯ ØªÙ†Ø§Ø²Ù„ÙŠ Ø¨Ø§Ù„Ø«ÙˆØ§Ù†ÙŠ ÙÙŠ Ø§Ù„ÙˆØ¯Ø¬Øª';

  @override
  String get widgetMmssThresholdNever => 'Ø¹Ø±Ø¶ HH:MM Ø¯Ø§Ø¦Ù…Ù‹Ø§';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS Ø£Ù‚Ù„ Ù…Ù† $minutes Ø¯Ù‚ÙŠÙ‚Ø©';
  }

  @override
  String get remindersOnOffTitle => 'Ø§Ù„ØªØ°ÙƒÙŠØ±Ø§Øª ØªØ´ØºÙŠÙ„/Ø¥ÙŠÙ‚Ø§Ù';

  @override
  String get remindersOnOffSubtitle =>
      'ØªØ´ØºÙŠÙ„ Ø£Ùˆ Ø¥ÙŠÙ‚Ø§Ù Ø¥Ø´Ø¹Ø§Ø±Ø§Øª ØªØ°ÙƒÙŠØ± Ø§Ù„ØµÙ„Ø§Ø© Ù…Ø¹ Ø§Ù„Ø§Ø­ØªÙØ§Ø¸ Ø¨Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª ÙƒÙ„ ØµÙ„Ø§Ø©.';

  @override
  String get reminderVibrationTitle => 'Ø§Ù„Ø§Ù‡ØªØ²Ø§Ø² Ø¹Ù†Ø¯ Ø§Ù„ØªØ°ÙƒÙŠØ±';

  @override
  String get reminderVibrationSubtitle =>
      'Ø§Ù‡ØªØ²Ø§Ø² Ù†Ø§Ø¨Ø¶ Ù„Ù…Ø¯Ø© 10 Ø«ÙˆØ§Ù†Ù ØªÙ‚Ø±ÙŠØ¨Ù‹Ø§ Ø¹Ù†Ø¯ ØªÙØ¹ÙŠÙ„ Ø§Ù„ØªØ°ÙƒÙŠØ±.';

  @override
  String get reminderSoundTitle =>
      'ØªØ´ØºÙŠÙ„ Ø§Ù„ØµÙˆØª Ø¹Ù†Ø¯ Ø§Ù„ØªØ°ÙƒÙŠØ±';

  @override
  String get reminderSoundSubtitle =>
      'ØªØ´ØºÙŠÙ„ ØµÙˆØª Ø§Ù„Ø¥Ø´Ø¹Ø§Ø± Ø¹Ù†Ø¯ ØªÙØ¹ÙŠÙ„ Ø§Ù„ØªØ°ÙƒÙŠØ±.';

  @override
  String get remindersOn => 'ØªØ´ØºÙŠÙ„';

  @override
  String get remindersOff => 'Ø¥ÙŠÙ‚Ø§Ù';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'ØªØ°ÙƒÙŠØ± $prayer';
  }

  @override
  String get reminderTypeTitle =>
      'Ù†ÙˆØ¹ Ø§Ù„ØªØ°ÙƒÙŠØ± (ÙŠÙ…ÙƒÙ† Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø§Ø«Ù†ÙŠÙ†)';

  @override
  String get onTime => 'ÙÙŠ Ø§Ù„ÙˆÙ‚Øª';

  @override
  String get before => 'Ù‚Ø¨Ù„';

  @override
  String get after => 'Ø¨Ø¹Ø¯';

  @override
  String get reminderAlertTitle => 'Ø§Ù„ØªÙ†Ø¨ÙŠÙ‡';

  @override
  String get reminderAlertSubtitle =>
      'ÙŠØªØ·Ù„Ø¨ Ø£ÙŠØ¶Ù‹Ø§ ØªÙØ¹ÙŠÙ„ Ø§Ù„Ù…ÙØªØ§Ø­ Ø§Ù„Ù…Ø·Ø§Ø¨Ù‚ ÙÙŠ Ø§Ù„ØªÙØ¶ÙŠÙ„Ø§Øª Ù„ÙŠØ¹Ù…Ù„ Ø§Ù„ØªÙ†Ø¨ÙŠÙ‡ ÙØ¹Ù„ÙŠÙ‹Ø§.';

  @override
  String get vibrateChip => 'Ø§Ù‡ØªØ²Ø§Ø²';

  @override
  String get soundChip => 'ØµÙˆØª';

  @override
  String get adhanChip => 'Ø£Ø°Ø§Ù†';

  @override
  String get remindBeforePrayerTitle => 'Ø°ÙƒÙ‘Ø±Ù†ÙŠ Ù‚Ø¨Ù„ Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String get remindAfterPrayerTitle => 'Ø°ÙƒÙ‘Ø±Ù†ÙŠ Ø¨Ø¹Ø¯ Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String minutesValue(Object minutes) {
    return '$minutes Ø¯';
  }

  @override
  String get custom => 'Ù…Ø®ØµØµ';

  @override
  String get customMinutes => 'Ø¯Ù‚Ø§Ø¦Ù‚ Ù…Ø®ØµØµØ©';

  @override
  String get customMinutesHint => 'Ù…Ø«Ø§Ù„: 12';

  @override
  String get save => 'Ø­ÙØ¸';

  @override
  String get enableBeforeToSelectMinutes =>
      'ÙØ¹Ù‘Ù„ \"Ù‚Ø¨Ù„\" Ù„Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¯Ù‚Ø§Ø¦Ù‚.';

  @override
  String get enableAfterToSelectMinutes =>
      'ÙØ¹Ù‘Ù„ \"Ø¨Ø¹Ø¯\" Ù„Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¯Ù‚Ø§Ø¦Ù‚.';

  @override
  String get enterValidPositiveNumber =>
      'Ø£Ø¯Ø®Ù„ Ø±Ù‚Ù…Ù‹Ø§ Ù…ÙˆØ¬Ø¨Ù‹Ø§ ØµØ­ÙŠØ­Ù‹Ø§.';

  @override
  String get useValueUpTo240 => 'Ø§Ø³ØªØ®Ø¯Ù… Ù‚ÙŠÙ…Ø© Ø­ØªÙ‰ 240 Ø¯Ù‚ÙŠÙ‚Ø©.';

  @override
  String get customMinutesSaved => 'ØªÙ… Ø­ÙØ¸ Ø§Ù„Ø¯Ù‚Ø§Ø¦Ù‚ Ø§Ù„Ù…Ø®ØµØµØ©.';

  @override
  String get cancel => 'Ø¥Ù„ØºØ§Ø¡';

  @override
  String get calendarTabTooltip => 'Ø§Ù„ØªÙ‚ÙˆÙŠÙ… Ø§Ù„Ù‡Ø¬Ø±ÙŠ';

  @override
  String get calendarPreviousMonth => 'Ø§Ù„Ø´Ù‡Ø± Ø§Ù„Ø³Ø§Ø¨Ù‚';

  @override
  String get calendarNextMonth => 'Ø§Ù„Ø´Ù‡Ø± Ø§Ù„ØªØ§Ù„ÙŠ';

  @override
  String get calendarSwapPrimary => 'ØªØ¨Ø¯ÙŠÙ„ Ø§Ù„Ù‡Ø¬Ø±ÙŠ/Ø§Ù„Ù…ÙŠÙ„Ø§Ø¯ÙŠ';

  @override
  String get calendarShowSecondary =>
      'Ø¥Ø¸Ù‡Ø§Ø± Ø§Ù„ØªØ§Ø±ÙŠØ® Ø§Ù„Ø«Ø§Ù†ÙˆÙŠ';

  @override
  String get calendarHideSecondary =>
      'Ø¥Ø®ÙØ§Ø¡ Ø§Ù„ØªØ§Ø±ÙŠØ® Ø§Ù„Ø«Ø§Ù†ÙˆÙŠ';

  @override
  String get calendarNoRemindersOnDay =>
      'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªØ°ÙƒÙŠØ±Ø§Øª ÙÙŠ Ù‡Ø°Ø§ Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get calendarAddReminder => 'Ø¥Ø¶Ø§ÙØ© ØªØ°ÙƒÙŠØ±';

  @override
  String get calendarEditReminder => 'ØªØ¹Ø¯ÙŠÙ„';

  @override
  String get calendarDeleteReminder => 'Ø­Ø°Ù';

  @override
  String get calendarReminderFormTitleNew => 'ØªØ°ÙƒÙŠØ± Ø¬Ø¯ÙŠØ¯';

  @override
  String get calendarReminderFormTitleEdit => 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„ØªØ°ÙƒÙŠØ±';

  @override
  String get calendarReminderTitleLabel => 'Ø§Ù„Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get calendarReminderTitleHint => 'Ù…Ø«Ø§Ù„: Ø¨Ø¯Ø§ÙŠØ© Ø±Ù…Ø¶Ø§Ù†';

  @override
  String get calendarReminderNotesLabel => 'Ù…Ù„Ø§Ø­Ø¸Ø§Øª (Ø§Ø®ØªÙŠØ§Ø±ÙŠ)';

  @override
  String get calendarReminderDateTimeLabel => 'Ø§Ù„ØªØ§Ø±ÙŠØ® ÙˆØ§Ù„ÙˆÙ‚Øª';

  @override
  String get calendarReminderRecurrenceLabel => 'Ø§Ù„ØªÙƒØ±Ø§Ø±';

  @override
  String get calendarRecurrenceOnce => 'Ù…Ø±Ø© ÙˆØ§Ø­Ø¯Ø©';

  @override
  String get calendarRecurrenceDaily => 'ÙŠÙˆÙ…ÙŠÙ‹Ø§';

  @override
  String get calendarRecurrenceWeekly => 'Ø£Ø³Ø¨ÙˆØ¹ÙŠÙ‹Ø§';

  @override
  String get calendarRecurrenceMonthly => 'Ø´Ù‡Ø±ÙŠÙ‹Ø§';

  @override
  String get calendarRecurrenceYearly => 'Ø³Ù†ÙˆÙŠÙ‹Ø§';

  @override
  String get calendarRepeatCountLabel => 'Ø¹Ø¯Ø¯ Ø§Ù„ØªÙƒØ±Ø§Ø±';

  @override
  String get calendarRepeatCountHelper =>
      'Ø¹Ø¯Ø¯ Ù…Ø±Ø§Øª ØªØ´ØºÙŠÙ„ Ø§Ù„ØªØ°ÙƒÙŠØ± Ù‚Ø¨Ù„ Ø§Ù„ØªÙˆÙ‚Ù (Ø¥ÙŠÙ‚Ø§Ù = ÙŠØªÙƒØ±Ø± Ø¯Ø§Ø¦Ù…Ù‹Ø§)';

  @override
  String get calendarRepeatCountError =>
      'Ø£Ø¯Ø®Ù„ Ø±Ù‚Ù…Ù‹Ø§ Ù…Ù† 2 Ø¥Ù„Ù‰ 100';

  @override
  String get calendarRepeatDaysLabel => 'Ø§Ù„ØªÙƒØ±Ø§Ø± ÙÙŠ';

  @override
  String get calendarDayOfMonthLabel => 'ÙŠÙˆÙ… Ù…Ù† Ø§Ù„Ø´Ù‡Ø±';

  @override
  String get calendarYearlyMonthLabel => 'Ø§Ù„Ø´Ù‡Ø±';

  @override
  String get calendarYearlyDayLabel => 'Ø§Ù„ÙŠÙˆÙ…';

  @override
  String get calendarMonthlyBasisLabel => 'Ø§Ù„Ø£Ø³Ø§Ø³ Ø§Ù„Ø´Ù‡Ø±ÙŠ';

  @override
  String get calendarYearlyBasisLabel => 'Ø§Ù„Ø£Ø³Ø§Ø³ Ø§Ù„Ø³Ù†ÙˆÙŠ';

  @override
  String get calendarYearlyBasisGregorian => 'Ù…ÙŠÙ„Ø§Ø¯ÙŠ';

  @override
  String get calendarYearlyBasisHijri => 'Ù‡Ø¬Ø±ÙŠ';

  @override
  String get calendarReminderTitleRequired => 'Ø£Ø¯Ø®Ù„ Ø¹Ù†ÙˆØ§Ù†Ù‹Ø§';

  @override
  String get calendarAnchorClockTime => 'ØªØ§Ø±ÙŠØ® Ø§Ù„ØªÙ‚ÙˆÙŠÙ…';

  @override
  String get calendarAnchorPrayerTime => 'ÙˆÙ‚Øª Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String get calendarSelectPrayer => 'Ø§Ø®ØªØ± Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String get calendarOffsetOnTime => 'ÙÙŠ Ø§Ù„ÙˆÙ‚Øª';

  @override
  String get calendarOffsetBefore => 'Ù‚Ø¨Ù„';

  @override
  String get calendarOffsetAfter => 'Ø¨Ø¹Ø¯';

  @override
  String get calendarPickAnchorDate => 'Ø§Ø®ØªØ± Ø§Ù„ØªØ§Ø±ÙŠØ®';

  @override
  String get datesPrayerTimesTab => 'Ø£ÙˆÙ‚Ø§Øª Ø§Ù„ØµÙ„Ø§Ø©';

  @override
  String get datesCalendarTab => 'Ø§Ù„ØªÙ‚ÙˆÙŠÙ…';

  @override
  String get undo => 'ØªØ±Ø§Ø¬Ø¹';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" ØªÙ… Ø§Ù„Ø­Ø°Ù';
  }
}
