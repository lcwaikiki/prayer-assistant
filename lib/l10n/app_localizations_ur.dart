// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'Ù†Ù…Ø§Ø² Ø§Ø³Ø³Ù¹Ù†Ù¹';

  @override
  String get tabLocation => 'Ù…Ù‚Ø§Ù…';

  @override
  String get tabToday => 'Ø¢Ø¬';

  @override
  String get tabDates => 'ØªØ§Ø±ÛŒØ®ÛŒÚº';

  @override
  String get tabTesbih => 'ØªØ³Ø¨ÛŒØ­';

  @override
  String get tooltipToggleLightDark => 'Ù„Ø§Ø¦Ù¹/ÚˆØ§Ø±Ú© ØªØ¨Ø¯ÛŒÙ„ Ú©Ø±ÛŒÚº';

  @override
  String get tooltipRemindersOn => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒØ§Úº Ø¢Ù† Ú©Ø±ÛŒÚº';

  @override
  String get tooltipRemindersOff => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒØ§Úº Ø¢Ù Ú©Ø±ÛŒÚº';

  @override
  String get tooltipPreferences => 'ØªØ±Ø¬ÛŒØ­Ø§Øª';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes Ù…Ù†Ù¹';
  }

  @override
  String get remainingMinutesUnknown => '-- Ù…Ù†Ù¹';

  @override
  String get homeNoLocationTitle => 'Ú©ÙˆØ¦ÛŒ Ù…Ù‚Ø§Ù… Ù…Ù†ØªØ®Ø¨ Ù†ÛÛŒÚº';

  @override
  String get homeNoLocationSubtitle =>
      'Ù…Ù‚Ø§Ù… Ù¹ÛŒØ¨ Ù…ÛŒÚº Ø¬Ø§ Ú©Ø± Ù¾ÛÙ„Û’ Ø§Ù¾Ù†Ø§ Ø¶Ù„Ø¹ Ù…Ø­ÙÙˆØ¸ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get homeNoPrayerTimesTitle =>
      'Ú©ÛŒØ´ Ù…ÛŒÚº Ù†Ù…Ø§Ø² Ø§ÙˆÙ‚Ø§Øª Ù†ÛÛŒÚº';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Ø³Ø§Ù„Ø§Ù†Û ÚˆÛŒÙ¹Ø§ ÛÙ… Ø¢ÛÙ†Ú¯ Ú©Ø±Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ Ø±ÛŒÙØ±ÛŒØ´ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get refresh => 'Ø±ÛŒÙØ±ÛŒØ´';

  @override
  String get qiblaTitle => 'Ù‚Ø¨Ù„Û';

  @override
  String qiblaBearing(int degrees) {
    return 'Ù‚Ø¨Ù„Û: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Ø¢Ù¾ Ú©Ø§ Ù…Ù‚Ø§Ù… Ù…Ø¹Ù„ÙˆÙ… Ù†ÛÛŒÚº ÛÙˆ Ø³Ú©Ø§Û” GPS Ø¢Ù† Ú©Ø± Ú©Û’ Ø¯ÙˆØ¨Ø§Ø±Û Ú©ÙˆØ´Ø´ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get qiblaHeadingUnavailable =>
      'Ù‚Ø·Ø¨ Ù†Ù…Ø§ Ø¯Ø³ØªÛŒØ§Ø¨ Ù†ÛÛŒÚº - Ù…Ù‚Ø±Ø±Û Ø³Ù…Øª Ø¯Ú©Ú¾Ø§Ø¦ÛŒ Ø¬Ø§ Ø±ÛÛŒ ÛÛ’Û”';

  @override
  String get qiblaPointDevice =>
      'Ø¬Ø¨ ØªÚ© Ø³ÙˆØ¦ÛŒ Ø§ÙˆÙ¾Ø± Ú©ÛŒ Ø·Ø±Ù Ù†Û Ø§Ø´Ø§Ø±Û Ú©Ø±Û’ Ø§Ù¾Ù†Ø§ Ø¢Ù„Û Ú¯Ú¾Ù…Ø§Ø¦ÛŒÚºÛ”';

  @override
  String get qiblaKaabaShort => 'Ù‚Ø¨Ù„Û';

  @override
  String get shareTodayTimes => 'Ø¢Ø¬ Ú©Û’ Ø§ÙˆÙ‚Ø§Øª Ø´ÛŒØ¦Ø± Ú©Ø±ÛŒÚº';

  @override
  String get calendarPreviousDay => 'Ù¾Ú†Ú¾Ù„Ø§ Ø¯Ù†';

  @override
  String get calendarNextDay => 'Ø§Ú¯Ù„Ø§ Ø¯Ù†';

  @override
  String todayWithDate(Object date) {
    return 'Ø¢Ø¬ â€¢ $date';
  }

  @override
  String get hijriUnknown => 'ÛØ¬Ø±ÛŒ: -';

  @override
  String hijriWithDate(Object date) {
    return 'ÛØ¬Ø±ÛŒ: $date';
  }

  @override
  String get reminderSettingsTitle => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø³ÛŒÙ¹Ù†Ú¯Ø²';

  @override
  String get reminderSettingsSubtitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø§ÙˆØ± Ù…Ù†Ù¹Ø³ Ù¾ÛÙ„Û’ Ú©Û’ Ù„ÛŒÛ’ Ø§ÙˆÙ¾Ø± ÙˆÙ‚Øª Ù¾Ø± Ù¹ÛŒÙ¾ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get tooltipScheduledDebug => 'Ø´ÛŒÚˆÙˆÙ„Úˆ Ø±ÛŒÙ…Ø§Ø¦Ù†ÚˆØ± ÚˆÛŒØ¨Ú¯';

  @override
  String get scheduledRemindersDebugTitle =>
      'Ø´ÛŒÚˆÙˆÙ„Úˆ Ø±ÛŒÙ…Ø§Ø¦Ù†ÚˆØ±Ø² (ÚˆÛŒØ¨Ú¯)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Ø²ÛŒØ± Ø§Ù„ØªÙˆØ§Ø¡ Ù†ÙˆÙ¹ÛŒÙÚ©ÛŒØ´Ù†Ø²: $count';
  }

  @override
  String get sendTestNotificationNow =>
      'Ù¹ÛŒØ³Ù¹ Ù†ÙˆÙ¹ÛŒÙÚ©ÛŒØ´Ù† Ø¨Ú¾ÛŒØ¬ÛŒÚº';

  @override
  String get testNotificationSent =>
      'Ù¹ÛŒØ³Ù¹ Ù†ÙˆÙ¹ÛŒÙÚ©ÛŒØ´Ù† Ø¨Ú¾ÛŒØ¬ Ø¯ÛŒØ§ Ú¯ÛŒØ§Û”';

  @override
  String get statusBarMinutesTitle => 'Ø§Ø³Ù¹ÛŒÙ¹Ø³ Ø¨Ø§Ø± Ù…Ù†Ù¹Ø³';

  @override
  String get statusBarMinutesSubtitle =>
      'Ø§Ø³Ù¹ÛŒÙ¹Ø³ Ø¨Ø§Ø± Ù…ÛŒÚº Ø¨Ø§Ù‚ÛŒ Ù…Ù†Ù¹Ø³ Ú©ÛŒ Ù…Ø³Ù„Ø³Ù„ Ø§Ø·Ù„Ø§Ø¹ Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚºÛ”';

  @override
  String get statusAutoRestoreTitle => 'ÛÙ¹Ø§Ù†Û’ Ù¾Ø± Ø¨Ø­Ø§Ù„ Ú©Ø±ÛŒÚº';

  @override
  String get statusAutoRestoreSubtitle =>
      'Ø§Ú¯Ø± ØµØ§Ø±Ù ÛÙ¹Ø§ Ø¯Û’ ØªÙˆ Ø§Ø³Ù¹ÛŒÙ¹Ø³ Ø¢Ø¦Ù¹Ù… Ø¯ÙˆØ¨Ø§Ø±Û Ø¨Ù†Ø§Ø¦ÛŒÚºÛ”';

  @override
  String get noPendingReminders =>
      'Ú©ÙˆØ¦ÛŒ Ø²ÛŒØ± Ø§Ù„ØªÙˆØ§Ø¡ ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù†ÛÛŒÚºÛ”';

  @override
  String get unknownFireTime => 'Ù†Ø§Ù…Ø¹Ù„ÙˆÙ… ÙˆÙ‚Øª';

  @override
  String get pastPrefix => '[Ú¯Ø²Ø± Ú¯ÛŒØ§] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Ø¢Ù† â€¢ ÙˆÙ‚Øª Ù¾Ø± + $minutes Ù…Ù†Ù¹ Ù¾ÛÙ„Û’';
  }

  @override
  String get reminderOnTimeOnly => 'Ø¢Ù† â€¢ ÙˆÙ‚Øª Ù¾Ø±';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Ø¢Ù† â€¢ $minutes Ù…Ù†Ù¹ Ù¾ÛÙ„Û’';
  }

  @override
  String get reminderOff => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø¨Ù†Ø¯';

  @override
  String get nextPrayerTitle => 'Ø§Ú¯Ù„ÛŒ Ù†Ù…Ø§Ø²';

  @override
  String get homeUpcomingRemindersTitle =>
      'Ø¢Ù†Û’ ÙˆØ§Ù„ÛŒ ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒØ§Úº';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total نمازیں مکمل';
  }

  @override
  String startsIn(Object remaining) {
    return '$remaining Ù…ÛŒÚº Ø´Ø±ÙˆØ¹ ÛÙˆÚ¯ÛŒ';
  }

  @override
  String get selectYourLocation => 'Ø§Ù¾Ù†Ø§ Ù…Ù‚Ø§Ù… Ù…Ù†ØªØ®Ø¨ Ú©Ø±ÛŒÚº';

  @override
  String get locationHelp =>
      'ÙÙˆØ±ÛŒ Ø³ÛŒÙ¹ Ø§Ù¾ Ú©Û’ Ù„ÛŒÛ’ GPS Ø§Ø³ØªØ¹Ù…Ø§Ù„ Ú©Ø±ÛŒÚº ÛŒØ§ Ù…Ù„Ú©/Ø´ÛØ± Ø¯Ø³ØªÛŒ Ø·ÙˆØ± Ù¾Ø± Ù…Ù†ØªØ®Ø¨ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get useCurrentLocation =>
      'Ù…ÙˆØ¬ÙˆØ¯Û Ù…Ù‚Ø§Ù… Ø§Ø³ØªØ¹Ù…Ø§Ù„ Ú©Ø±ÛŒÚº';

  @override
  String get country => 'Ù…Ù„Ú©';

  @override
  String get stateCity => 'ØµÙˆØ¨Û / Ø´ÛØ±';

  @override
  String get district => 'Ø¶Ù„Ø¹';

  @override
  String get saveLocation => 'Ù…Ù‚Ø§Ù… Ù…Ø­ÙÙˆØ¸ Ú©Ø±ÛŒÚº';

  @override
  String selectedLocation(Object location) {
    return 'Ù…Ù†ØªØ®Ø¨ Ø´Ø¯Û: $location';
  }

  @override
  String get historySelectLocationFirst =>
      '1 Ø³Ø§Ù„Û Ù†Ù…Ø§Ø² ÙÛØ±Ø³Øª Ø¯ÛŒÚ©Ú¾Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ Ù¾ÛÙ„Û’ Ù…Ù‚Ø§Ù… Ù…Ù†ØªØ®Ø¨ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get historyTableTitle =>
      'Ù†Ù…Ø§Ø² Ø§ÙˆÙ‚Ø§Øª Ø¬Ø¯ÙˆÙ„ (Ù¾ÙˆØ±Ø§ Ø³Ø§Ù„)';

  @override
  String get todayShort => 'Ø¢Ø¬';

  @override
  String get dateHeader => 'ØªØ§Ø±ÛŒØ®';

  @override
  String get imsak => 'ÙØ¬Ø±';

  @override
  String get gunes => 'Ø·Ù„ÙˆØ¹';

  @override
  String get ogle => 'Ø¸ÛØ±';

  @override
  String get ikindi => 'Ø¹ØµØ±';

  @override
  String get aksam => 'Ù…ØºØ±Ø¨';

  @override
  String get yatsi => 'Ø¹Ø´Ø§Ø¡';

  @override
  String get hijriHeader => 'ÛØ¬Ø±ÛŒ';

  @override
  String get preferencesTitle => 'ØªØ±Ø¬ÛŒØ­Ø§Øª';

  @override
  String get languageTitle => 'Ø²Ø¨Ø§Ù†';

  @override
  String get languageSystem => 'Ø³Ø³Ù¹Ù… ÚˆÛŒÙØ§Ù„Ù¹';

  @override
  String get themeModeTitle => 'ØªÚ¾ÛŒÙ… Ù…ÙˆÚˆ';

  @override
  String get themeSystem => 'Ø³Ø³Ù¹Ù… ÚˆÛŒÙØ§Ù„Ù¹';

  @override
  String get themeLight => 'Ù„Ø§Ø¦Ù¹';

  @override
  String get themeDark => 'ÚˆØ§Ø±Ú©';

  @override
  String get appBarRemainingTitle =>
      'ÛÙˆÙ… Ø§ÛŒÙ¾ Ø¨Ø§Ø± Ø¨Ø§Ù‚ÛŒ ÙˆÙ‚Øª Ù…ØªÙ†';

  @override
  String get showInTitle => 'Ø¹Ù†ÙˆØ§Ù† Ù…ÛŒÚº Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚº';

  @override
  String get showAtRight => 'Ø¯Ø§Ø¦ÛŒÚº Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚº';

  @override
  String get showAsSubtitle =>
      'Ø°ÛŒÙ„ÛŒ Ø¹Ù†ÙˆØ§Ù† Ú©Û’ Ø·ÙˆØ± Ù¾Ø± Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚº';

  @override
  String get hideRemainingText => 'Ø¨Ø§Ù‚ÛŒ Ù…ØªÙ† Ú†Ú¾Ù¾Ø§Ø¦ÛŒÚº';

  @override
  String get notificationMessageTitle => 'Ø§Ø·Ù„Ø§Ø¹ Ú©Ø§ Ù¾ÛŒØºØ§Ù…';

  @override
  String get notificationMessageShown => 'Ø¯Ú©Ú¾Ø§ÛŒØ§ Ú¯ÛŒØ§';

  @override
  String get notificationMessageHidden => 'Ú†Ú¾Ù¾Ø§ ÛÙˆØ§';

  @override
  String get widgetTextSizeTitle => 'ÙˆÛŒØ¬Ù¹ Ù…ØªÙ† Ú©Ø§ Ø³Ø§Ø¦Ø²';

  @override
  String get widgetTextSizeSubtitle =>
      'ÛÙˆÙ… Ø§Ø³Ú©Ø±ÛŒÙ† ÙˆÛŒØ¬Ù¹Ø³ Ù…ÛŒÚº Ø§Ø³ØªØ¹Ù…Ø§Ù„ ÛÙˆÙ†Û’ ÙˆØ§Ù„Û’ Ù…ØªÙ† Ú©Ø§ Ø³Ø§Ø¦Ø²Û”';

  @override
  String get widgetTextSizeExtraSmall => 'Ø¨ÛØª Ú†Ú¾ÙˆÙ¹Ø§';

  @override
  String get widgetTextSizeSmall => 'Ú†Ú¾ÙˆÙ¹Ø§';

  @override
  String get widgetTextSizeMedium => 'Ø¯Ø±Ù…ÛŒØ§Ù†Û';

  @override
  String get widgetTextSizeLarge => 'Ø¨Ú‘Ø§';

  @override
  String get widgetMmssThresholdTitle =>
      'ÙˆÛŒØ¬Ù¹ Ù…ÛŒÚº Ø³ÛŒÚ©Ù†Úˆ Ú©Ø§Ø¤Ù†Ù¹ ÚˆØ§Ø¤Ù†';

  @override
  String get widgetMmssThresholdNever => 'ÛÙ…ÛŒØ´Û HH:MM Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚº';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes Ù…Ù†Ù¹ Ø³Û’ Ú©Ù… Ù¾Ø± MM:SS';
  }

  @override
  String get remindersOnOffTitle => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒØ§Úº Ø¢Ù†/Ø¢Ù';

  @override
  String get remindersOnOffSubtitle =>
      'Ù†Ù…Ø§Ø² Ú©ÛŒ ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø¢Ù† ÛŒØ§ Ø¢Ù Ú©Ø±ÛŒÚºÛ” ÛØ± Ù†Ù…Ø§Ø² Ú©ÛŒ Ø³ÛŒÙ¹Ù†Ú¯Ø² Ù…Ø­ÙÙˆØ¸ Ø±ÛÛŒÚº Ú¯ÛŒÛ”';

  @override
  String get reminderVibrationTitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù¾Ø± ÙˆØ§Ø¦Ø¨Ø±ÛŒØ´Ù†';

  @override
  String get reminderVibrationSubtitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù¾Ø± ØªÙ‚Ø±ÛŒØ¨Ø§Ù‹ 10 Ø³ÛŒÚ©Ù†Úˆ ØªÚ© ÙˆÙ‚ÙÛ’ ÙˆÙ‚ÙÛ’ Ø³Û’ ÙˆØ§Ø¦Ø¨Ø±ÛŒØ´Ù† ÛÙˆÛ”';

  @override
  String get reminderSoundTitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù¾Ø± Ø¢ÙˆØ§Ø² Ú†Ù„Ø§Ø¦ÛŒÚº';

  @override
  String get reminderSoundSubtitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù¾Ø± Ù†ÙˆÙ¹ÛŒÙÚ©ÛŒØ´Ù† Ú©ÛŒ Ø¢ÙˆØ§Ø² Ú†Ù„Ø§Ø¦ÛŒÚºÛ”';

  @override
  String get remindersOn => 'Ø¢Ù†';

  @override
  String get remindersOff => 'Ø¢Ù';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ';
  }

  @override
  String get reminderTypeTitle =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ú©ÛŒ Ù‚Ø³Ù… (Ø¯ÙˆÙ†ÙˆÚº Ù…Ù†ØªØ®Ø¨ ÛÙˆ Ø³Ú©ØªÛ’ ÛÛŒÚº)';

  @override
  String get onTime => 'ÙˆÙ‚Øª Ù¾Ø±';

  @override
  String get before => 'Ù¾ÛÙ„Û’';

  @override
  String get after => 'Ø¨Ø¹Ø¯ Ù…ÛŒÚº';

  @override
  String get reminderAlertTitle => 'Ø§Ù„Ø±Ù¹';

  @override
  String get reminderAlertSubtitle =>
      'Ø¯Ø±Ø§ØµÙ„ Ø§Ù„Ø±Ù¹ Ú©Ø±Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ ØªØ±Ø¬ÛŒØ­Ø§Øª Ù…ÛŒÚº Ù…ØªØ¹Ù„Ù‚Û Ø³ÙˆØ¦Ú† Ú©Ø§ Ø¢Ù† ÛÙˆÙ†Ø§ Ø¨Ú¾ÛŒ Ø¶Ø±ÙˆØ±ÛŒ ÛÛ’Û”';

  @override
  String get vibrateChip => 'ÙˆØ§Ø¦Ø¨Ø±ÛŒØ´Ù†';

  @override
  String get soundChip => 'Ø¢ÙˆØ§Ø²';

  @override
  String get adhanChip => 'Ø§Ø°Ø§Ù†';

  @override
  String get remindBeforePrayerTitle =>
      'Ù†Ù…Ø§Ø² Ø³Û’ Ù¾ÛÙ„Û’ ÛŒØ§Ø¯ Ø¯Ù„Ø§Ø¦ÛŒÚº';

  @override
  String get remindAfterPrayerTitle =>
      'Ù†Ù…Ø§Ø² Ú©Û’ Ø¨Ø¹Ø¯ ÛŒØ§Ø¯ Ø¯Ù„Ø§Ø¦ÛŒÚº';

  @override
  String minutesValue(Object minutes) {
    return '$minutes Ù…Ù†Ù¹';
  }

  @override
  String get custom => 'Ú©Ø³Ù¹Ù…';

  @override
  String get customMinutes => 'Ú©Ø³Ù¹Ù… Ù…Ù†Ù¹Ø³';

  @override
  String get customMinutesHint => 'Ù…Ø«Ù„Ø§Ù‹ 12';

  @override
  String get save => 'Ù…Ø­ÙÙˆØ¸ Ú©Ø±ÛŒÚº';

  @override
  String get enableBeforeToSelectMinutes =>
      'Ù…Ù†Ù¹Ø³ Ù…Ù†ØªØ®Ø¨ Ú©Ø±Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ \"Ù¾ÛÙ„Û’\" ÙØ¹Ø§Ù„ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get enableAfterToSelectMinutes =>
      'Ù…Ù†Ù¹Ø³ Ù…Ù†ØªØ®Ø¨ Ú©Ø±Ù†Û’ Ú©Û’ Ù„ÛŒÛ’ \"Ø¨Ø¹Ø¯ Ù…ÛŒÚº\" ÙØ¹Ø§Ù„ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get enterValidPositiveNumber =>
      'Ø¯Ø±Ø³Øª Ù…Ø«Ø¨Øª Ù†Ù…Ø¨Ø± Ø¯Ø±Ø¬ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get useValueUpTo240 =>
      '240 Ù…Ù†Ù¹ ØªÚ© Ú©ÛŒ Ù‚Ø¯Ø± Ø§Ø³ØªØ¹Ù…Ø§Ù„ Ú©Ø±ÛŒÚºÛ”';

  @override
  String get customMinutesSaved => 'Ú©Ø³Ù¹Ù… Ù…Ù†Ù¹Ø³ Ù…Ø­ÙÙˆØ¸ ÛÙˆ Ú¯Ø¦Û’Û”';

  @override
  String get cancel => 'Ù…Ù†Ø³ÙˆØ® Ú©Ø±ÛŒÚº';

  @override
  String get calendarTabTooltip => 'ÛØ¬Ø±ÛŒ Ú©ÛŒÙ„Ù†ÚˆØ±';

  @override
  String get calendarPreviousMonth => 'Ù¾Ú†Ú¾Ù„Ø§ Ù…ÛÛŒÙ†Û';

  @override
  String get calendarNextMonth => 'Ø§Ú¯Ù„Ø§ Ù…ÛÛŒÙ†Û';

  @override
  String get calendarSwapPrimary => 'ÛØ¬Ø±ÛŒ/Ø¹ÛŒØ³ÙˆÛŒ ØªØ¨Ø¯ÛŒÙ„ Ú©Ø±ÛŒÚº';

  @override
  String get calendarShowSecondary => 'Ø«Ø§Ù†ÙˆÛŒ ØªØ§Ø±ÛŒØ® Ø¯Ú©Ú¾Ø§Ø¦ÛŒÚº';

  @override
  String get calendarHideSecondary => 'Ø«Ø§Ù†ÙˆÛŒ ØªØ§Ø±ÛŒØ® Ú†Ú¾Ù¾Ø§Ø¦ÛŒÚº';

  @override
  String get calendarNoRemindersOnDay =>
      'Ø§Ø³ Ø¯Ù† Ú©ÙˆØ¦ÛŒ ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù†ÛÛŒÚº';

  @override
  String get calendarAddReminder => 'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø´Ø§Ù…Ù„ Ú©Ø±ÛŒÚº';

  @override
  String get calendarEditReminder => 'ØªØ±Ù…ÛŒÙ… Ú©Ø±ÛŒÚº';

  @override
  String get calendarDeleteReminder => 'Ø­Ø°Ù Ú©Ø±ÛŒÚº';

  @override
  String get calendarReminderFormTitleNew => 'Ù†Ø¦ÛŒ ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ';

  @override
  String get calendarReminderFormTitleEdit =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ù…ÛŒÚº ØªØ±Ù…ÛŒÙ… Ú©Ø±ÛŒÚº';

  @override
  String get calendarReminderTitleLabel => 'Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get calendarReminderTitleHint => 'Ù…Ø«Ù„Ø§Ù‹ Ø±Ù…Ø¶Ø§Ù† Ú©Ø§ Ø¢ØºØ§Ø²';

  @override
  String get calendarReminderNotesLabel => 'Ù†ÙˆÙ¹Ø³ (Ø§Ø®ØªÛŒØ§Ø±ÛŒ)';

  @override
  String get calendarReminderDateTimeLabel => 'ØªØ§Ø±ÛŒØ® Ø§ÙˆØ± ÙˆÙ‚Øª';

  @override
  String get calendarReminderRecurrenceLabel => 'ØªÚ©Ø±Ø§Ø±';

  @override
  String get calendarRecurrenceOnce => 'Ø§ÛŒÚ© Ø¨Ø§Ø±';

  @override
  String get calendarRecurrenceDaily => 'Ø±ÙˆØ²Ø§Ù†Û';

  @override
  String get calendarRecurrenceWeekly => 'ÛÙØªÛ ÙˆØ§Ø±';

  @override
  String get calendarRecurrenceMonthly => 'Ù…Ø§ÛØ§Ù†Û';

  @override
  String get calendarRecurrenceYearly => 'Ø³Ø§Ù„Ø§Ù†Û';

  @override
  String get calendarRepeatCountLabel => 'ØªÚ©Ø±Ø§Ø± Ú©ÛŒ ØªØ¹Ø¯Ø§Ø¯';

  @override
  String get calendarRepeatCountHelper =>
      'ÛŒØ§Ø¯ Ø¯ÛØ§Ù†ÛŒ Ø±Ú©Ù†Û’ Ø³Û’ Ù¾ÛÙ„Û’ Ú©ØªÙ†ÛŒ Ø¨Ø§Ø± Ú†Ù„Û’ Ú¯ÛŒ (Ø¨Ù†Ø¯ = ÛÙ…ÛŒØ´Û Ø¯ÛØ±Ø§Ø¦ÛŒ Ø¬Ø§Ø¦Û’)';

  @override
  String get calendarRepeatCountError =>
      '2 Ø³Û’ 100 ØªÚ© Ù†Ù…Ø¨Ø± Ø¯Ø±Ø¬ Ú©Ø±ÛŒÚº';

  @override
  String get calendarRepeatDaysLabel => 'Ø¯ÛØ±Ø§Ø¦ÛŒÚº';

  @override
  String get calendarDayOfMonthLabel => 'Ù…ÛÛŒÙ†Û’ Ú©Ø§ Ø¯Ù†';

  @override
  String get calendarYearlyMonthLabel => 'Ù…ÛÛŒÙ†Û';

  @override
  String get calendarYearlyDayLabel => 'Ø¯Ù†';

  @override
  String get calendarMonthlyBasisLabel => 'Ù…Ø§ÛØ§Ù†Û Ø¨Ù†ÛŒØ§Ø¯';

  @override
  String get calendarYearlyBasisLabel => 'Ø³Ø§Ù„Ø§Ù†Û Ø¨Ù†ÛŒØ§Ø¯';

  @override
  String get calendarYearlyBasisGregorian => 'Ø¹ÛŒØ³ÙˆÛŒ';

  @override
  String get calendarYearlyBasisHijri => 'ÛØ¬Ø±ÛŒ';

  @override
  String get calendarReminderTitleRequired =>
      'Ø§ÛŒÚ© Ø¹Ù†ÙˆØ§Ù† Ø¯Ø±Ø¬ Ú©Ø±ÛŒÚº';

  @override
  String get calendarAnchorClockTime => 'Ú©ÛŒÙ„Ù†ÚˆØ± ØªØ§Ø±ÛŒØ®';

  @override
  String get calendarAnchorPrayerTime => 'Ù†Ù…Ø§Ø² Ú©Ø§ ÙˆÙ‚Øª';

  @override
  String get calendarSelectPrayer => 'Ù†Ù…Ø§Ø² Ù…Ù†ØªØ®Ø¨ Ú©Ø±ÛŒÚº';

  @override
  String get calendarOffsetOnTime => 'ÙˆÙ‚Øª Ù¾Ø±';

  @override
  String get calendarOffsetBefore => 'Ù¾ÛÙ„Û’';

  @override
  String get calendarOffsetAfter => 'Ø¨Ø¹Ø¯ Ù…ÛŒÚº';

  @override
  String get calendarPickAnchorDate => 'ØªØ§Ø±ÛŒØ® Ù…Ù†ØªØ®Ø¨ Ú©Ø±ÛŒÚº';

  @override
  String get datesPrayerTimesTab => 'Ù†Ù…Ø§Ø² Ú©Û’ Ø§ÙˆÙ‚Ø§Øª';

  @override
  String get datesCalendarTab => 'Ú©ÛŒÙ„Ù†ÚˆØ±';

  @override
  String get undo => 'ÙˆØ§Ù¾Ø³ Ù„Ø§Ø¦ÛŒÚº';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" Ø­Ø°Ù ÛÙˆÚ¯ÛŒØ§';
  }
}
