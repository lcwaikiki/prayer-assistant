// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Ø¯Ø³ØªÛŒØ§Ø± Ù†Ù…Ø§Ø²';

  @override
  String get tabLocation => 'Ù…Ú©Ø§Ù†';

  @override
  String get tabToday => 'Ø§Ù…Ø±ÙˆØ²';

  @override
  String get tabDates => 'ØªØ§Ø±ÛŒØ®â€ŒÙ‡Ø§';

  @override
  String get tabTesbih => 'ØªØ³Ø¨ÛŒØ­';

  @override
  String get tooltipToggleLightDark => 'ØªØºÛŒÛŒØ± Ø±ÙˆØ´Ù†/ØªÛŒØ±Ù‡';

  @override
  String get tooltipRemindersOn => 'ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ Ø±Ø§ Ø±ÙˆØ´Ù† Ú©Ù†ÛŒØ¯';

  @override
  String get tooltipRemindersOff => 'ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ Ø±Ø§ Ø®Ø§Ù…ÙˆØ´ Ú©Ù†ÛŒØ¯';

  @override
  String get tooltipPreferences => 'ØªÙ†Ø¸ÛŒÙ…Ø§Øª';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes Ø¯Ù‚ÛŒÙ‚Ù‡';
  }

  @override
  String get remainingMinutesUnknown => '-- Ø¯Ù‚ÛŒÙ‚Ù‡';

  @override
  String get homeNoLocationTitle => 'Ù…Ú©Ø§Ù†ÛŒ Ø§Ù†ØªØ®Ø§Ø¨ Ù†Ø´Ø¯Ù‡ Ø§Ø³Øª';

  @override
  String get homeNoLocationSubtitle =>
      'Ø¨Ù‡ ØªØ¨ Ù…Ú©Ø§Ù† Ø¨Ø±ÙˆÛŒØ¯ Ùˆ Ø§Ø¨ØªØ¯Ø§ Ù†Ø§Ø­ÛŒÙ‡ Ø®ÙˆØ¯ Ø±Ø§ Ø°Ø®ÛŒØ±Ù‡ Ú©Ù†ÛŒØ¯.';

  @override
  String get homeNoPrayerTimesTitle =>
      'Ø§ÙˆÙ‚Ø§Øª Ù†Ù…Ø§Ø² Ø¯Ø± Ú©Ø´ Ù…ÙˆØ¬ÙˆØ¯ Ù†ÛŒØ³Øª';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Ø¨Ø±Ø§ÛŒ Ù‡Ù…Ú¯Ø§Ù…â€ŒØ³Ø§Ø²ÛŒ Ø¯Ø§Ø¯Ù‡ Ø³Ø§Ù„Ø§Ù†Ù‡ØŒ Ù†ÙˆØ³Ø§Ø²ÛŒ Ú©Ù†ÛŒØ¯.';

  @override
  String get refresh => 'Ù†ÙˆØ³Ø§Ø²ÛŒ';

  @override
  String get qiblaTitle => 'Ù‚Ø¨Ù„Ù‡';

  @override
  String qiblaBearing(int degrees) {
    return 'Ù‚Ø¨Ù„Ù‡: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Ù…Ú©Ø§Ù† Ø´Ù…Ø§ Ù…Ø´Ø®Øµ Ù†Ø´Ø¯. GPS Ø±Ø§ ÙØ¹Ø§Ù„ Ùˆ Ø¯ÙˆØ¨Ø§Ø±Ù‡ ØªÙ„Ø§Ø´ Ú©Ù†ÛŒØ¯.';

  @override
  String get qiblaHeadingUnavailable =>
      'Ù‚Ø·Ø¨â€ŒÙ†Ù…Ø§ Ø¯Ø± Ø¯Ø³ØªØ±Ø³ Ù†ÛŒØ³Øª - Ø¬Ù‡Øª Ø«Ø§Ø¨Øª Ù†Ù…Ø§ÛŒØ´ Ø¯Ø§Ø¯Ù‡ Ù…ÛŒâ€ŒØ´ÙˆØ¯.';

  @override
  String get qiblaPointDevice =>
      'Ø¯Ø³ØªÚ¯Ø§Ù‡ Ø±Ø§ Ø¨Ú†Ø±Ø®Ø§Ù†ÛŒØ¯ ØªØ§ Ø¹Ù‚Ø±Ø¨Ù‡ Ø±Ùˆ Ø¨Ù‡ Ø¨Ø§Ù„Ø§ Ù‚Ø±Ø§Ø± Ú¯ÛŒØ±Ø¯.';

  @override
  String get qiblaKaabaShort => 'Ù‚Ø¨Ù„Ù‡';

  @override
  String get shareTodayTimes => 'Ø§Ø´ØªØ±Ø§Ú© Ø§ÙˆÙ‚Ø§Øª Ø§Ù…Ø±ÙˆØ²';

  @override
  String get calendarPreviousDay => 'Ø±ÙˆØ² Ù‚Ø¨Ù„';

  @override
  String get calendarNextDay => 'Ø±ÙˆØ² Ø¨Ø¹Ø¯';

  @override
  String todayWithDate(Object date) {
    return 'Ø§Ù…Ø±ÙˆØ² â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Ù‡Ø¬Ø±ÛŒ: -';

  @override
  String hijriWithDate(Object date) {
    return 'Ù‡Ø¬Ø±ÛŒ: $date';
  }

  @override
  String get reminderSettingsTitle => 'ØªÙ†Ø¸ÛŒÙ…Ø§Øª ÛŒØ§Ø¯Ø¢ÙˆØ±';

  @override
  String get reminderSettingsSubtitle =>
      'Ø¨Ø±Ø§ÛŒ ØªÙ†Ø¸ÛŒÙ… ÛŒØ§Ø¯Ø¢ÙˆØ± Ùˆ Ø¯Ù‚ÛŒÙ‚Ù‡â€ŒÙ‡Ø§ÛŒ Ù‚Ø¨Ù„ØŒ Ø±ÙˆÛŒ ÛŒÚ©ÛŒ Ø§Ø² Ø§ÙˆÙ‚Ø§Øª Ù†Ù…Ø§Ø² Ø¨Ø²Ù†ÛŒØ¯.';

  @override
  String get tooltipScheduledDebug =>
      'Ø§Ø´Ú©Ø§Ù„â€ŒØ²Ø¯Ø§ÛŒÛŒ ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ÛŒ Ø²Ù…Ø§Ù†â€ŒØ¨Ù†Ø¯ÛŒâ€ŒØ´Ø¯Ù‡';

  @override
  String get scheduledRemindersDebugTitle =>
      'ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ÛŒ Ø²Ù…Ø§Ù†â€ŒØ¨Ù†Ø¯ÛŒâ€ŒØ´Ø¯Ù‡ (Ø§Ø´Ú©Ø§Ù„â€ŒØ²Ø¯Ø§ÛŒÛŒ)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Ø§Ø¹Ù„Ø§Ù†â€ŒÙ‡Ø§ÛŒ Ø¯Ø± Ø§Ù†ØªØ¸Ø§Ø±: $count';
  }

  @override
  String get sendTestNotificationNow => 'Ø§Ø±Ø³Ø§Ù„ Ø§Ø¹Ù„Ø§Ù† Ø¢Ø²Ù…Ø§ÛŒØ´ÛŒ';

  @override
  String get testNotificationSent =>
      'Ø§Ø¹Ù„Ø§Ù† Ø¢Ø²Ù…Ø§ÛŒØ´ÛŒ Ø§Ø±Ø³Ø§Ù„ Ø´Ø¯.';

  @override
  String get statusBarMinutesTitle => 'Ø¯Ù‚Ø§ÛŒÙ‚ Ù†ÙˆØ§Ø± ÙˆØ¶Ø¹ÛŒØª';

  @override
  String get statusBarMinutesSubtitle =>
      'Ù†Ù…Ø§ÛŒØ´ Ø§Ø¹Ù„Ø§Ù† Ø¯Ø§Ø¦Ù…ÛŒ Ø¯Ù‚Ø§ÛŒÙ‚ Ø¨Ø§Ù‚ÛŒâ€ŒÙ…Ø§Ù†Ø¯Ù‡ Ø¯Ø± Ù†ÙˆØ§Ø± ÙˆØ¶Ø¹ÛŒØª.';

  @override
  String get statusAutoRestoreTitle =>
      'Ø¨Ø§Ø²ÛŒØ§Ø¨ÛŒ Ø®ÙˆØ¯Ú©Ø§Ø± Ø¯Ø± ØµÙˆØ±Øª Ø­Ø°Ù';

  @override
  String get statusAutoRestoreSubtitle =>
      'Ø§Ú¯Ø± Ú©Ø§Ø±Ø¨Ø± Ø§Ø¹Ù„Ø§Ù† Ø±Ø§ Ø¨Ø¨Ù†Ø¯Ø¯ØŒ Ø¯ÙˆØ¨Ø§Ø±Ù‡ Ø§ÛŒØ¬Ø§Ø¯ Ø´ÙˆØ¯.';

  @override
  String get noPendingReminders =>
      'ÛŒØ§Ø¯Ø¢ÙˆØ± Ø¯Ø± Ø§Ù†ØªØ¸Ø§Ø±ÛŒ ÙˆØ¬ÙˆØ¯ Ù†Ø¯Ø§Ø±Ø¯.';

  @override
  String get unknownFireTime => 'Ø²Ù…Ø§Ù† Ù†Ø§Ù…Ø´Ø®Øµ';

  @override
  String get pastPrefix => '[Ú¯Ø°Ø´ØªÙ‡] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Ø±ÙˆØ´Ù† â€¢ Ø¨Ù‡â€ŒÙ…ÙˆÙ‚Ø¹ + $minutes Ø¯Ù‚ÛŒÙ‚Ù‡ Ù‚Ø¨Ù„';
  }

  @override
  String get reminderOnTimeOnly => 'Ø±ÙˆØ´Ù† â€¢ Ø¨Ù‡â€ŒÙ…ÙˆÙ‚Ø¹';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Ø±ÙˆØ´Ù† â€¢ $minutes Ø¯Ù‚ÛŒÙ‚Ù‡ Ù‚Ø¨Ù„';
  }

  @override
  String get reminderOff => 'ÛŒØ§Ø¯Ø¢ÙˆØ± Ø®Ø§Ù…ÙˆØ´';

  @override
  String get nextPrayerTitle => 'Ù†Ù…Ø§Ø² Ø¨Ø¹Ø¯ÛŒ';

  @override
  String get homeUpcomingRemindersTitle => 'ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ÛŒ Ù¾ÛŒØ´ Ø±Ùˆ';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total نماز تکمیل شد';
  }

  @override
  String startsIn(Object remaining) {
    return 'Ø´Ø±ÙˆØ¹ Ø¯Ø± $remaining';
  }

  @override
  String get selectYourLocation => 'Ù…Ú©Ø§Ù† Ø®ÙˆØ¯ Ø±Ø§ Ø§Ù†ØªØ®Ø§Ø¨ Ú©Ù†ÛŒØ¯';

  @override
  String get locationHelp =>
      'Ø¨Ø±Ø§ÛŒ ØªÙ†Ø¸ÛŒÙ… Ø³Ø±ÛŒØ¹ Ø§Ø² GPS Ø§Ø³ØªÙØ§Ø¯Ù‡ Ú©Ù†ÛŒØ¯ ÛŒØ§ Ú©Ø´ÙˆØ±/Ø´Ù‡Ø± Ø±Ø§ Ø¯Ø³ØªÛŒ Ø§Ù†ØªØ®Ø§Ø¨ Ú©Ù†ÛŒØ¯.';

  @override
  String get useCurrentLocation => 'Ø§Ø³ØªÙØ§Ø¯Ù‡ Ø§Ø² Ù…Ú©Ø§Ù† ÙØ¹Ù„ÛŒ';

  @override
  String get country => 'Ú©Ø´ÙˆØ±';

  @override
  String get stateCity => 'Ø§Ø³ØªØ§Ù† / Ø´Ù‡Ø±';

  @override
  String get district => 'Ù†Ø§Ø­ÛŒÙ‡';

  @override
  String get saveLocation => 'Ø°Ø®ÛŒØ±Ù‡ Ù…Ú©Ø§Ù†';

  @override
  String selectedLocation(Object location) {
    return 'Ø§Ù†ØªØ®Ø§Ø¨â€ŒØ´Ø¯Ù‡: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Ø¨Ø±Ø§ÛŒ Ø¯ÛŒØ¯Ù† ÙÙ‡Ø±Ø³Øª ÛŒÚ©â€ŒØ³Ø§Ù„Ù‡ Ù†Ù…Ø§Ø² Ø§Ø¨ØªØ¯Ø§ ÛŒÚ© Ù…Ú©Ø§Ù† Ø§Ù†ØªØ®Ø§Ø¨ Ú©Ù†ÛŒØ¯.';

  @override
  String get historyTableTitle => 'Ø¬Ø¯ÙˆÙ„ Ø§ÙˆÙ‚Ø§Øª Ù†Ù…Ø§Ø² (Ú©Ù„ Ø³Ø§Ù„)';

  @override
  String get todayShort => 'Ø§Ù…Ø±ÙˆØ²';

  @override
  String get dateHeader => 'ØªØ§Ø±ÛŒØ®';

  @override
  String get imsak => 'ÙØ¬Ø±';

  @override
  String get gunes => 'Ø·Ù„ÙˆØ¹';

  @override
  String get ogle => 'Ø¸Ù‡Ø±';

  @override
  String get ikindi => 'Ø¹ØµØ±';

  @override
  String get aksam => 'Ù…ØºØ±Ø¨';

  @override
  String get yatsi => 'Ø¹Ø´Ø§Ø¡';

  @override
  String get hijriHeader => 'Ù‡Ø¬Ø±ÛŒ';

  @override
  String get preferencesTitle => 'ØªÙ†Ø¸ÛŒÙ…Ø§Øª';

  @override
  String get languageTitle => 'Ø²Ø¨Ø§Ù†';

  @override
  String get languageSystem => 'Ù¾ÛŒØ´â€ŒÙØ±Ø¶ Ø³ÛŒØ³ØªÙ…';

  @override
  String get themeModeTitle => 'Ø­Ø§Ù„Øª Ù¾ÙˆØ³ØªÙ‡';

  @override
  String get themeSystem => 'Ù¾ÛŒØ´â€ŒÙØ±Ø¶ Ø³ÛŒØ³ØªÙ…';

  @override
  String get themeLight => 'Ø±ÙˆØ´Ù†';

  @override
  String get themeDark => 'ØªÛŒØ±Ù‡';

  @override
  String get appBarRemainingTitle =>
      'Ù…ØªÙ† Ø²Ù…Ø§Ù† Ø¨Ø§Ù‚ÛŒâ€ŒÙ…Ø§Ù†Ø¯Ù‡ Ù†ÙˆØ§Ø± Ø¨Ø§Ù„Ø§';

  @override
  String get showInTitle => 'Ù†Ù…Ø§ÛŒØ´ Ø¯Ø± Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get showAtRight => 'Ù†Ù…Ø§ÛŒØ´ Ø¯Ø± Ø±Ø§Ø³Øª';

  @override
  String get showAsSubtitle => 'Ù†Ù…Ø§ÛŒØ´ Ø¨Ù‡â€ŒØ¹Ù†ÙˆØ§Ù† Ø²ÛŒØ±Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get hideRemainingText =>
      'Ù…Ø®ÙÛŒ Ú©Ø±Ø¯Ù† Ù…ØªÙ† Ø¨Ø§Ù‚ÛŒâ€ŒÙ…Ø§Ù†Ø¯Ù‡';

  @override
  String get notificationMessageTitle => 'Ù¾ÛŒØ§Ù… Ø§Ø¹Ù„Ø§Ù†';

  @override
  String get notificationMessageShown => 'Ù†Ù…Ø§ÛŒØ´ Ø¯Ø§Ø¯Ù‡ Ù…ÛŒâ€ŒØ´ÙˆØ¯';

  @override
  String get notificationMessageHidden => 'Ù¾Ù†Ù‡Ø§Ù†';

  @override
  String get widgetTextSizeTitle => 'Ø§Ù†Ø¯Ø§Ø²Ù‡ Ù…ØªÙ† Ø§Ø¨Ø²Ø§Ø±Ú©';

  @override
  String get widgetTextSizeSubtitle =>
      'Ø§Ù†Ø¯Ø§Ø²Ù‡ Ù…ØªÙ† Ø§Ø³ØªÙØ§Ø¯Ù‡â€ŒØ´Ø¯Ù‡ Ø¯Ø± Ø§Ø¨Ø²Ø§Ø±Ú©â€ŒÙ‡Ø§ÛŒ ØµÙØ­Ù‡ Ø§ØµÙ„ÛŒ.';

  @override
  String get widgetTextSizeExtraSmall => 'Ø®ÛŒÙ„ÛŒ Ú©ÙˆÚ†Ú©';

  @override
  String get widgetTextSizeSmall => 'Ú©ÙˆÚ†Ú©';

  @override
  String get widgetTextSizeMedium => 'Ù…ØªÙˆØ³Ø·';

  @override
  String get widgetTextSizeLarge => 'Ø¨Ø²Ø±Ú¯';

  @override
  String get widgetMmssThresholdTitle =>
      'Ø´Ù…Ø§Ø±Ø´ Ù…Ø¹Ú©ÙˆØ³ Ø«Ø§Ù†ÛŒÙ‡Ø§ÛŒ ÙˆÛŒØ¬Øª';

  @override
  String get widgetMmssThresholdNever => 'Ù‡Ù…ÛŒØ´Ù‡ HH:MM Ù†Ù…Ø§ÛŒØ´ Ø¨Ø¯Ù‡';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS Ú©Ù…ØªØ± Ø§Ø² $minutes Ø¯Ù‚ÛŒÙ‚Ù‡';
  }

  @override
  String get remindersOnOffTitle => 'ÛŒØ§Ø¯Ø¢ÙˆØ±Ù‡Ø§ Ø±ÙˆØ´Ù†/Ø®Ø§Ù…ÙˆØ´';

  @override
  String get remindersOnOffSubtitle =>
      'Ø§Ø¹Ù„Ø§Ù†â€ŒÙ‡Ø§ÛŒ ÛŒØ§Ø¯Ø¢ÙˆØ± Ù†Ù…Ø§Ø² Ø±Ø§ Ø±ÙˆØ´Ù† ÛŒØ§ Ø®Ø§Ù…ÙˆØ´ Ú©Ù†ÛŒØ¯. ØªÙ†Ø¸ÛŒÙ…Ø§Øª Ù‡Ø± Ù†Ù…Ø§Ø² Ø­ÙØ¸ Ù…ÛŒâ€ŒØ´ÙˆØ¯.';

  @override
  String get reminderVibrationTitle => 'Ù„Ø±Ø²Ø´ Ù‡Ù†Ú¯Ø§Ù… ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ';

  @override
  String get reminderVibrationSubtitle =>
      'Ù„Ø±Ø²Ø´ Ø¶Ø±Ø¨Ø§Ù†ÛŒ Ø¨Ù‡ Ù…Ø¯Øª Ø­Ø¯ÙˆØ¯ Û±Û° Ø«Ø§Ù†ÛŒÙ‡ Ù‡Ù†Ú¯Ø§Ù… ÙØ¹Ø§Ù„ Ø´Ø¯Ù† ÛŒØ§Ø¯Ø¢ÙˆØ±.';

  @override
  String get reminderSoundTitle => 'Ù¾Ø®Ø´ ØµØ¯Ø§ Ù‡Ù†Ú¯Ø§Ù… ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ';

  @override
  String get reminderSoundSubtitle =>
      'Ù¾Ø®Ø´ ØµØ¯Ø§ÛŒ Ø§Ø¹Ù„Ø§Ù† Ù‡Ù†Ú¯Ø§Ù… ÙØ¹Ø§Ù„ Ø´Ø¯Ù† ÛŒØ§Ø¯Ø¢ÙˆØ±.';

  @override
  String get remindersOn => 'Ø±ÙˆØ´Ù†';

  @override
  String get remindersOff => 'Ø®Ø§Ù…ÙˆØ´';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'ÛŒØ§Ø¯Ø¢ÙˆØ± $prayer';
  }

  @override
  String get reminderTypeTitle =>
      'Ù†ÙˆØ¹ ÛŒØ§Ø¯Ø¢ÙˆØ± (Ù…ÛŒâ€ŒØªÙˆØ§Ù†ÛŒØ¯ Ù‡Ø± Ø¯Ùˆ Ø±Ø§ Ø§Ù†ØªØ®Ø§Ø¨ Ú©Ù†ÛŒØ¯)';

  @override
  String get onTime => 'Ø¨Ù‡â€ŒÙ…ÙˆÙ‚Ø¹';

  @override
  String get before => 'Ù‚Ø¨Ù„';

  @override
  String get after => 'Ø¨Ø¹Ø¯';

  @override
  String get reminderAlertTitle => 'Ù‡Ø´Ø¯Ø§Ø±';

  @override
  String get reminderAlertSubtitle =>
      'Ø¨Ø±Ø§ÛŒ Ù‡Ø´Ø¯Ø§Ø± ÙˆØ§Ù‚Ø¹ÛŒØŒ Ú©Ù„ÛŒØ¯ Ù…Ø±Ø¨ÙˆØ·Ù‡ Ø¯Ø± ØªÙ†Ø¸ÛŒÙ…Ø§Øª Ù‡Ù… Ø¨Ø§ÛŒØ¯ Ø±ÙˆØ´Ù† Ø¨Ø§Ø´Ø¯.';

  @override
  String get vibrateChip => 'Ù„Ø±Ø²Ø´';

  @override
  String get soundChip => 'ØµØ¯Ø§';

  @override
  String get adhanChip => 'Ø§Ø°Ø§Ù†';

  @override
  String get remindBeforePrayerTitle =>
      'Ù‚Ø¨Ù„ Ø§Ø² Ù†Ù…Ø§Ø² ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ Ú©Ù†';

  @override
  String get remindAfterPrayerTitle =>
      'Ø¨Ø¹Ø¯ Ø§Ø² Ù†Ù…Ø§Ø² ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ Ú©Ù†';

  @override
  String minutesValue(Object minutes) {
    return '$minutes Ø¯Ù‚ÛŒÙ‚Ù‡';
  }

  @override
  String get custom => 'Ø³ÙØ§Ø±Ø´ÛŒ';

  @override
  String get customMinutes => 'Ø¯Ù‚ÛŒÙ‚Ù‡ Ø³ÙØ§Ø±Ø´ÛŒ';

  @override
  String get customMinutesHint => 'Ù…Ø«Ù„Ø§Ù‹ 12';

  @override
  String get save => 'Ø°Ø®ÛŒØ±Ù‡';

  @override
  String get enableBeforeToSelectMinutes =>
      'Ø¨Ø±Ø§ÛŒ Ø§Ù†ØªØ®Ø§Ø¨ Ø¯Ù‚ÛŒÙ‚Ù‡ØŒ \"Ù‚Ø¨Ù„\" Ø±Ø§ ÙØ¹Ø§Ù„ Ú©Ù†ÛŒØ¯.';

  @override
  String get enableAfterToSelectMinutes =>
      'Ø¨Ø±Ø§ÛŒ Ø§Ù†ØªØ®Ø§Ø¨ Ø¯Ù‚ÛŒÙ‚Ù‡ØŒ \"Ø¨Ø¹Ø¯\" Ø±Ø§ ÙØ¹Ø§Ù„ Ú©Ù†ÛŒØ¯.';

  @override
  String get enterValidPositiveNumber =>
      'ÛŒÚ© Ø¹Ø¯Ø¯ Ù…Ø«Ø¨Øª Ù…Ø¹ØªØ¨Ø± ÙˆØ§Ø±Ø¯ Ú©Ù†ÛŒØ¯.';

  @override
  String get useValueUpTo240 =>
      'Ø§Ø² Ù…Ù‚Ø¯Ø§Ø± ØªØ§ 240 Ø¯Ù‚ÛŒÙ‚Ù‡ Ø§Ø³ØªÙØ§Ø¯Ù‡ Ú©Ù†ÛŒØ¯.';

  @override
  String get customMinutesSaved => 'Ø¯Ù‚ÛŒÙ‚Ù‡ Ø³ÙØ§Ø±Ø´ÛŒ Ø°Ø®ÛŒØ±Ù‡ Ø´Ø¯.';

  @override
  String get cancel => 'Ù„ØºÙˆ';

  @override
  String get calendarTabTooltip => 'ØªÙ‚ÙˆÛŒÙ… Ù‡Ø¬Ø±ÛŒ';

  @override
  String get calendarPreviousMonth => 'Ù…Ø§Ù‡ Ù‚Ø¨Ù„';

  @override
  String get calendarNextMonth => 'Ù…Ø§Ù‡ Ø¨Ø¹Ø¯';

  @override
  String get calendarSwapPrimary => 'ØªØ¹ÙˆÛŒØ¶ Ù‡Ø¬Ø±ÛŒ/Ù…ÛŒÙ„Ø§Ø¯ÛŒ';

  @override
  String get calendarShowSecondary => 'Ù†Ù…Ø§ÛŒØ´ ØªØ§Ø±ÛŒØ® Ø«Ø§Ù†ÙˆÛŒÙ‡';

  @override
  String get calendarHideSecondary =>
      'Ù¾Ù†Ù‡Ø§Ù† Ú©Ø±Ø¯Ù† ØªØ§Ø±ÛŒØ® Ø«Ø§Ù†ÙˆÛŒÙ‡';

  @override
  String get calendarNoRemindersOnDay =>
      'ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ Ø¯Ø± Ø§ÛŒÙ† Ø±ÙˆØ² ÙˆØ¬ÙˆØ¯ Ù†Ø¯Ø§Ø±Ø¯';

  @override
  String get calendarAddReminder => 'Ø§ÙØ²ÙˆØ¯Ù† ÛŒØ§Ø¯Ø¢ÙˆØ±';

  @override
  String get calendarEditReminder => 'ÙˆÛŒØ±Ø§ÛŒØ´';

  @override
  String get calendarDeleteReminder => 'Ø­Ø°Ù';

  @override
  String get calendarReminderFormTitleNew => 'ÛŒØ§Ø¯Ø¢ÙˆØ± Ø¬Ø¯ÛŒØ¯';

  @override
  String get calendarReminderFormTitleEdit => 'ÙˆÛŒØ±Ø§ÛŒØ´ ÛŒØ§Ø¯Ø¢ÙˆØ±';

  @override
  String get calendarReminderTitleLabel => 'Ø¹Ù†ÙˆØ§Ù†';

  @override
  String get calendarReminderTitleHint =>
      'Ù…Ø«Ù„Ø§Ù‹ Ø´Ø±ÙˆØ¹ Ù…Ø§Ù‡ Ø±Ù…Ø¶Ø§Ù†';

  @override
  String get calendarReminderNotesLabel => 'ÛŒØ§Ø¯Ø¯Ø§Ø´Øª (Ø§Ø®ØªÛŒØ§Ø±ÛŒ)';

  @override
  String get calendarReminderDateTimeLabel => 'ØªØ§Ø±ÛŒØ® Ùˆ Ø³Ø§Ø¹Øª';

  @override
  String get calendarReminderRecurrenceLabel => 'ØªÚ©Ø±Ø§Ø±';

  @override
  String get calendarRecurrenceOnce => 'ÛŒÚ©â€ŒØ¨Ø§Ø±';

  @override
  String get calendarRecurrenceDaily => 'Ø±ÙˆØ²Ø§Ù†Ù‡';

  @override
  String get calendarRecurrenceWeekly => 'Ù‡ÙØªÚ¯ÛŒ';

  @override
  String get calendarRecurrenceMonthly => 'Ù…Ø§Ù‡Ø§Ù†Ù‡';

  @override
  String get calendarRecurrenceYearly => 'Ø³Ø§Ù„Ø§Ù†Ù‡';

  @override
  String get calendarRepeatCountLabel => 'ØªØ¹Ø¯Ø§Ø¯ ØªÚ©Ø±Ø§Ø±';

  @override
  String get calendarRepeatCountHelper =>
      'ØªØ¹Ø¯Ø§Ø¯ Ø¯ÙØ¹Ø§ØªÛŒ Ú©Ù‡ ÛŒØ§Ø¯Ø¢ÙˆØ±ÛŒ Ù‚Ø¨Ù„ Ø§Ø² ØªÙˆÙ‚Ù Ø§Ø¬Ø±Ø§ Ù…ÛŒâ€ŒØ´ÙˆØ¯ (Ø®Ø§Ù…ÙˆØ´ = Ù‡Ù…ÛŒØ´Ù‡ ØªÚ©Ø±Ø§Ø± Ù…ÛŒâ€ŒØ´ÙˆØ¯)';

  @override
  String get calendarRepeatCountError =>
      'Ø¹Ø¯Ø¯ÛŒ Ø§Ø² Û² ØªØ§ Û±Û°Û° ÙˆØ§Ø±Ø¯ Ú©Ù†ÛŒØ¯';

  @override
  String get calendarRepeatDaysLabel => 'ØªÚ©Ø±Ø§Ø± Ø¯Ø±';

  @override
  String get calendarDayOfMonthLabel => 'Ø±ÙˆØ² Ù…Ø§Ù‡';

  @override
  String get calendarYearlyMonthLabel => 'Ù…Ø§Ù‡';

  @override
  String get calendarYearlyDayLabel => 'Ø±ÙˆØ²';

  @override
  String get calendarMonthlyBasisLabel => 'Ù…Ø¨Ù†Ø§ÛŒ Ù…Ø§Ù‡Ø§Ù†Ù‡';

  @override
  String get calendarYearlyBasisLabel => 'Ù…Ø¨Ù†Ø§ÛŒ Ø³Ø§Ù„Ø§Ù†Ù‡';

  @override
  String get calendarYearlyBasisGregorian => 'Ù…ÛŒÙ„Ø§Ø¯ÛŒ';

  @override
  String get calendarYearlyBasisHijri => 'Ù‡Ø¬Ø±ÛŒ';

  @override
  String get calendarReminderTitleRequired =>
      'ÛŒÚ© Ø¹Ù†ÙˆØ§Ù† ÙˆØ§Ø±Ø¯ Ú©Ù†ÛŒØ¯';

  @override
  String get calendarAnchorClockTime => 'ØªØ§Ø±ÛŒØ® ØªÙ‚ÙˆÛŒÙ…';

  @override
  String get calendarAnchorPrayerTime => 'ÙˆÙ‚Øª Ù†Ù…Ø§Ø²';

  @override
  String get calendarSelectPrayer => 'Ø§Ù†ØªØ®Ø§Ø¨ Ù†Ù…Ø§Ø²';

  @override
  String get calendarOffsetOnTime => 'Ø¨Ù‡â€ŒÙ…ÙˆÙ‚Ø¹';

  @override
  String get calendarOffsetBefore => 'Ù‚Ø¨Ù„';

  @override
  String get calendarOffsetAfter => 'Ø¨Ø¹Ø¯';

  @override
  String get calendarPickAnchorDate => 'Ø§Ù†ØªØ®Ø§Ø¨ ØªØ§Ø±ÛŒØ®';

  @override
  String get datesPrayerTimesTab => 'Ø§ÙˆÙ‚Ø§Øª Ù†Ù…Ø§Ø²';

  @override
  String get datesCalendarTab => 'ØªÙ‚ÙˆÛŒÙ…';

  @override
  String get undo => 'Ø¨Ø§Ø²Ú¯Ø±Ø¯Ø§Ù†ÛŒ';

  @override
  String calendarReminderDeleted(Object title) {
    return 'Â«$titleÂ» Ø­Ø°Ù Ø´Ø¯';
  }
}
