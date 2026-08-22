// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'ÐœÐ¾Ð»Ð¸Ñ‚Ð²ÐµÐ½Ð½Ñ‹Ð¹ Ð¿Ð¾Ð¼Ð¾Ñ‰Ð½Ð¸Ðº';

  @override
  String get tabLocation => 'ÐœÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ';

  @override
  String get tabToday => 'Ð¡ÐµÐ³Ð¾Ð´Ð½Ñ';

  @override
  String get tabDates => 'Ð”Ð°Ñ‚Ñ‹';

  @override
  String get tabTesbih => 'Ð¢Ð°ÑÐ±Ð¸Ñ…';

  @override
  String get tooltipToggleLightDark =>
      'ÐŸÐµÑ€ÐµÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ ÑÐ²ÐµÑ‚Ð»ÑƒÑŽ/Ñ‚Ñ‘Ð¼Ð½ÑƒÑŽ Ñ‚ÐµÐ¼Ñƒ';

  @override
  String get tooltipRemindersOn => 'Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ';

  @override
  String get tooltipRemindersOff => 'Ð’Ñ‹ÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ';

  @override
  String get tooltipPreferences => 'ÐÐ°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes Ð¼Ð¸Ð½';
  }

  @override
  String get remainingMinutesUnknown => '-- Ð¼Ð¸Ð½';

  @override
  String get homeNoLocationTitle =>
      'ÐœÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ Ð½Ðµ Ð²Ñ‹Ð±Ñ€Ð°Ð½Ð¾';

  @override
  String get homeNoLocationSubtitle =>
      'ÐŸÐµÑ€ÐµÐ¹Ð´Ð¸Ñ‚Ðµ Ð½Ð° Ð²ÐºÐ»Ð°Ð´ÐºÑƒ Â«ÐœÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸ÐµÂ» Ð¸ ÑÐ¾Ñ…Ñ€Ð°Ð½Ð¸Ñ‚Ðµ Ð²Ð°Ñˆ Ñ€Ð°Ð¹Ð¾Ð½.';

  @override
  String get homeNoPrayerTimesTitle =>
      'ÐÐµÑ‚ Ð²Ñ€ÐµÐ¼ÐµÐ½Ð¸ Ð½Ð°Ð¼Ð°Ð·Ð° Ð² ÐºÑÑˆÐµ';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'ÐÐ°Ð¶Ð¼Ð¸Ñ‚Ðµ Â«ÐžÐ±Ð½Ð¾Ð²Ð¸Ñ‚ÑŒÂ», Ñ‡Ñ‚Ð¾Ð±Ñ‹ Ð·Ð°Ð³Ñ€ÑƒÐ·Ð¸Ñ‚ÑŒ Ð´Ð°Ð½Ð½Ñ‹Ðµ Ð½Ð° Ð³Ð¾Ð´.';

  @override
  String get refresh => 'ÐžÐ±Ð½Ð¾Ð²Ð¸Ñ‚ÑŒ';

  @override
  String get qiblaTitle => 'ÐšÐ¸Ð±Ð»Ð°';

  @override
  String qiblaBearing(int degrees) {
    return 'ÐšÐ¸Ð±Ð»Ð°: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'ÐÐµ ÑƒÐ´Ð°Ð»Ð¾ÑÑŒ Ð¾Ð¿Ñ€ÐµÐ´ÐµÐ»Ð¸Ñ‚ÑŒ Ð¼ÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ. Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚Ðµ GPS Ð¸ Ð¿Ð¾Ð¿Ñ€Ð¾Ð±ÑƒÐ¹Ñ‚Ðµ ÑÐ½Ð¾Ð²Ð°.';

  @override
  String get qiblaHeadingUnavailable =>
      'ÐšÐ¾Ð¼Ð¿Ð°Ñ Ð½ÐµÐ´Ð¾ÑÑ‚ÑƒÐ¿ÐµÐ½ - Ð¿Ð¾ÐºÐ°Ð·Ð°Ð½Ð¾ Ñ„Ð¸ÐºÑÐ¸Ñ€Ð¾Ð²Ð°Ð½Ð½Ð¾Ðµ Ð½Ð°Ð¿Ñ€Ð°Ð²Ð»ÐµÐ½Ð¸Ðµ.';

  @override
  String get qiblaPointDevice =>
      'ÐŸÐ¾Ð²ÐµÑ€Ð½Ð¸Ñ‚Ðµ ÑƒÑÑ‚Ñ€Ð¾Ð¹ÑÑ‚Ð²Ð¾, Ð¿Ð¾ÐºÐ° ÑÑ‚Ñ€ÐµÐ»ÐºÐ° Ð½Ðµ ÑƒÐºÐ°Ð¶ÐµÑ‚ Ð²Ð²ÐµÑ€Ñ….';

  @override
  String get qiblaKaabaShort => 'ÐšÐ¸Ð±Ð»Ð°';

  @override
  String get shareTodayTimes =>
      'ÐŸÐ¾Ð´ÐµÐ»Ð¸Ñ‚ÑŒÑÑ Ð²Ñ€ÐµÐ¼ÐµÐ½ÐµÐ¼ Ð½Ð° ÑÐµÐ³Ð¾Ð´Ð½Ñ';

  @override
  String get calendarPreviousDay => 'ÐŸÑ€ÐµÐ´Ñ‹Ð´ÑƒÑ‰Ð¸Ð¹ Ð´ÐµÐ½ÑŒ';

  @override
  String get calendarNextDay => 'Ð¡Ð»ÐµÐ´ÑƒÑŽÑ‰Ð¸Ð¹ Ð´ÐµÐ½ÑŒ';

  @override
  String todayWithDate(Object date) {
    return 'Ð¡ÐµÐ³Ð¾Ð´Ð½Ñ â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Ð¥Ð¸Ð´Ð¶Ñ€Ð°: -';

  @override
  String hijriWithDate(Object date) {
    return 'Ð¥Ð¸Ð´Ð¶Ñ€Ð°: $date';
  }

  @override
  String get reminderSettingsTitle =>
      'ÐÐ°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¹';

  @override
  String get reminderSettingsSubtitle =>
      'ÐÐ°Ð¶Ð¼Ð¸Ñ‚Ðµ Ð½Ð° Ð²Ñ€ÐµÐ¼Ñ Ð½Ð°Ð¼Ð°Ð·Ð° Ð²Ñ‹ÑˆÐµ, Ñ‡Ñ‚Ð¾Ð±Ñ‹ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¸Ñ‚ÑŒ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ Ð¸ Ð¼Ð¸Ð½ÑƒÑ‚Ñ‹ Ð´Ð¾.';

  @override
  String get tooltipScheduledDebug =>
      'ÐžÑ‚Ð»Ð°Ð´ÐºÐ° Ð·Ð°Ð¿Ð»Ð°Ð½Ð¸Ñ€Ð¾Ð²Ð°Ð½Ð½Ñ‹Ñ… Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¹';

  @override
  String get scheduledRemindersDebugTitle =>
      'Ð—Ð°Ð¿Ð»Ð°Ð½Ð¸Ñ€Ð¾Ð²Ð°Ð½Ð½Ñ‹Ðµ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ (Ð¾Ñ‚Ð»Ð°Ð´ÐºÐ°)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'ÐžÐ¶Ð¸Ð´Ð°ÑŽÑ‰Ð¸Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ñ: $count';
  }

  @override
  String get sendTestNotificationNow =>
      'ÐžÑ‚Ð¿Ñ€Ð°Ð²Ð¸Ñ‚ÑŒ Ñ‚ÐµÑÑ‚Ð¾Ð²Ð¾Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ðµ ÑÐµÐ¹Ñ‡Ð°Ñ';

  @override
  String get testNotificationSent =>
      'Ð¢ÐµÑÑ‚Ð¾Ð²Ð¾Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ðµ Ð¾Ñ‚Ð¿Ñ€Ð°Ð²Ð»ÐµÐ½Ð¾.';

  @override
  String get statusBarMinutesTitle =>
      'ÐœÐ¸Ð½ÑƒÑ‚Ñ‹ Ð² ÑÑ‚Ñ€Ð¾ÐºÐµ ÑÐ¾ÑÑ‚Ð¾ÑÐ½Ð¸Ñ';

  @override
  String get statusBarMinutesSubtitle =>
      'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ Ð¿Ð¾ÑÑ‚Ð¾ÑÐ½Ð½Ð¾Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ðµ Ð¾Ð± Ð¾ÑÑ‚Ð°Ð²ÑˆÐ¸Ñ…ÑÑ Ð¼Ð¸Ð½ÑƒÑ‚Ð°Ñ… Ð² ÑÑ‚Ñ€Ð¾ÐºÐµ ÑÐ¾ÑÑ‚Ð¾ÑÐ½Ð¸Ñ.';

  @override
  String get statusAutoRestoreTitle =>
      'ÐÐ²Ñ‚Ð¾Ð²Ð¾ÑÑÑ‚Ð°Ð½Ð¾Ð²Ð»ÐµÐ½Ð¸Ðµ Ð¿Ñ€Ð¸ Ð·Ð°ÐºÑ€Ñ‹Ñ‚Ð¸Ð¸';

  @override
  String get statusAutoRestoreSubtitle =>
      'ÐŸÐ¾Ð²Ñ‚Ð¾Ñ€Ð½Ð¾ ÑÐ¾Ð·Ð´Ð°Ñ‚ÑŒ ÑÐ»ÐµÐ¼ÐµÐ½Ñ‚ ÑÑ‚Ð°Ñ‚ÑƒÑÐ°, ÐµÑÐ»Ð¸ Ð¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÐµÐ»ÑŒ ÐµÐ³Ð¾ Ð¾Ñ‚ÐºÐ»Ð¾Ð½Ð¸Ð».';

  @override
  String get noPendingReminders =>
      'ÐÐµÑ‚ Ð¾Ð¶Ð¸Ð´Ð°ÑŽÑ‰Ð¸Ñ… Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¹.';

  @override
  String get unknownFireTime =>
      'ÐÐµÐ¸Ð·Ð²ÐµÑÑ‚Ð½Ð¾Ðµ Ð²Ñ€ÐµÐ¼Ñ ÑÑ€Ð°Ð±Ð°Ñ‚Ñ‹Ð²Ð°Ð½Ð¸Ñ';

  @override
  String get pastPrefix => '[ÐŸÐ ÐžÐ¨Ð›ÐžÐ•] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Ð’ÐºÐ» â€¢ Ð’Ð¾Ð²Ñ€ÐµÐ¼Ñ + $minutes Ð¼Ð¸Ð½ Ð´Ð¾';
  }

  @override
  String get reminderOnTimeOnly => 'Ð’ÐºÐ» â€¢ Ð’Ð¾Ð²Ñ€ÐµÐ¼Ñ';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Ð’ÐºÐ» â€¢ $minutes Ð¼Ð¸Ð½ Ð´Ð¾';
  }

  @override
  String get reminderOff => 'ÐÐ°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ Ð²Ñ‹ÐºÐ»ÑŽÑ‡ÐµÐ½Ð¾';

  @override
  String get nextPrayerTitle => 'Ð¡Ð»ÐµÐ´ÑƒÑŽÑ‰Ð¸Ð¹ Ð½Ð°Ð¼Ð°Ð·';

  @override
  String get homeUpcomingRemindersTitle =>
      'ÐŸÑ€ÐµÐ´ÑÑ‚Ð¾ÑÑ‰Ð¸Ðµ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total намазов выполнено';
  }

  @override
  String startsIn(Object remaining) {
    return 'ÐÐ°Ñ‡Ð½Ñ‘Ñ‚ÑÑ Ñ‡ÐµÑ€ÐµÐ· $remaining';
  }

  @override
  String get selectYourLocation =>
      'Ð’Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ Ð¼ÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ';

  @override
  String get locationHelp =>
      'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐ¹Ñ‚Ðµ GPS Ð´Ð»Ñ Ð±Ñ‹ÑÑ‚Ñ€Ð¾Ð¹ Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸ Ð¸Ð»Ð¸ Ð²Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ ÑÑ‚Ñ€Ð°Ð½Ñƒ/Ð³Ð¾Ñ€Ð¾Ð´ Ð²Ñ€ÑƒÑ‡Ð½ÑƒÑŽ.';

  @override
  String get useCurrentLocation =>
      'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·Ð¾Ð²Ð°Ñ‚ÑŒ Ñ‚ÐµÐºÑƒÑ‰ÐµÐµ Ð¼ÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ';

  @override
  String get country => 'Ð¡Ñ‚Ñ€Ð°Ð½Ð°';

  @override
  String get stateCity => 'Ð ÐµÐ³Ð¸Ð¾Ð½ / Ð“Ð¾Ñ€Ð¾Ð´';

  @override
  String get district => 'Ð Ð°Ð¹Ð¾Ð½';

  @override
  String get saveLocation => 'Ð¡Ð¾Ñ…Ñ€Ð°Ð½Ð¸Ñ‚ÑŒ Ð¼ÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ';

  @override
  String selectedLocation(Object location) {
    return 'Ð’Ñ‹Ð±Ñ€Ð°Ð½Ð¾: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Ð¡Ð½Ð°Ñ‡Ð°Ð»Ð° Ð²Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ Ð¼ÐµÑÑ‚Ð¾Ð¿Ð¾Ð»Ð¾Ð¶ÐµÐ½Ð¸Ðµ, Ñ‡Ñ‚Ð¾Ð±Ñ‹ ÑƒÐ²Ð¸Ð´ÐµÑ‚ÑŒ ÑÐ¿Ð¸ÑÐ¾Ðº Ð½Ð°Ð¼Ð°Ð·Ð¾Ð² Ð·Ð° Ð³Ð¾Ð´.';

  @override
  String get historyTableTitle =>
      'Ð¢Ð°Ð±Ð»Ð¸Ñ†Ð° Ð²Ñ€ÐµÐ¼ÐµÐ½Ð¸ Ð½Ð°Ð¼Ð°Ð·Ð° (Ð²ÐµÑÑŒ Ð³Ð¾Ð´)';

  @override
  String get todayShort => 'Ð¡ÐµÐ³Ð¾Ð´Ð½Ñ';

  @override
  String get dateHeader => 'Ð”Ð°Ñ‚Ð°';

  @override
  String get imsak => 'Ð¤Ð°Ð´Ð¶Ñ€';

  @override
  String get gunes => 'Ð’Ð¾ÑÑ…Ð¾Ð´';

  @override
  String get ogle => 'Ð—ÑƒÑ…Ñ€';

  @override
  String get ikindi => 'ÐÑÑ€';

  @override
  String get aksam => 'ÐœÐ°Ð³Ñ€Ð¸Ð±';

  @override
  String get yatsi => 'Ð˜ÑˆÐ°';

  @override
  String get hijriHeader => 'Ð¥Ð¸Ð´Ð¶Ñ€Ð°';

  @override
  String get preferencesTitle => 'ÐÐ°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸';

  @override
  String get languageTitle => 'Ð¯Ð·Ñ‹Ðº';

  @override
  String get languageSystem => 'Ð¡Ð¸ÑÑ‚ÐµÐ¼Ð½Ñ‹Ð¹ Ð¿Ð¾ ÑƒÐ¼Ð¾Ð»Ñ‡Ð°Ð½Ð¸ÑŽ';

  @override
  String get themeModeTitle => 'Ð¢ÐµÐ¼Ð° Ð¾Ñ„Ð¾Ñ€Ð¼Ð»ÐµÐ½Ð¸Ñ';

  @override
  String get themeSystem => 'Ð¡Ð¸ÑÑ‚ÐµÐ¼Ð½Ð°Ñ';

  @override
  String get themeLight => 'Ð¡Ð²ÐµÑ‚Ð»Ð°Ñ';

  @override
  String get themeDark => 'Ð¢Ñ‘Ð¼Ð½Ð°Ñ';

  @override
  String get appBarRemainingTitle =>
      'Ð¢ÐµÐºÑÑ‚ Ð¾ÑÑ‚Ð°Ð²ÑˆÐµÐ³Ð¾ÑÑ Ð²Ñ€ÐµÐ¼ÐµÐ½Ð¸ Ð² Ð·Ð°Ð³Ð¾Ð»Ð¾Ð²ÐºÐµ';

  @override
  String get showInTitle => 'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ Ð² Ð·Ð°Ð³Ð¾Ð»Ð¾Ð²ÐºÐµ';

  @override
  String get showAtRight => 'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ ÑÐ¿Ñ€Ð°Ð²Ð°';

  @override
  String get showAsSubtitle =>
      'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ ÐºÐ°Ðº Ð¿Ð¾Ð´Ð·Ð°Ð³Ð¾Ð»Ð¾Ð²Ð¾Ðº';

  @override
  String get hideRemainingText =>
      'Ð¡ÐºÑ€Ñ‹Ñ‚ÑŒ Ñ‚ÐµÐºÑÑ‚ Ð¾ÑÑ‚Ð°Ð²ÑˆÐµÐ³Ð¾ÑÑ Ð²Ñ€ÐµÐ¼ÐµÐ½Ð¸';

  @override
  String get notificationMessageTitle =>
      'Ð¡Ð¾Ð¾Ð±Ñ‰ÐµÐ½Ð¸Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ñ';

  @override
  String get notificationMessageShown => 'ÐŸÐ¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ';

  @override
  String get notificationMessageHidden => 'Ð¡ÐºÑ€Ñ‹Ñ‚Ð¾';

  @override
  String get widgetTextSizeTitle => 'Ð Ð°Ð·Ð¼ÐµÑ€ Ñ‚ÐµÐºÑÑ‚Ð° Ð²Ð¸Ð´Ð¶ÐµÑ‚Ð°';

  @override
  String get widgetTextSizeSubtitle =>
      'Ð Ð°Ð·Ð¼ÐµÑ€ Ñ‚ÐµÐºÑÑ‚Ð°, Ð¸ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐµÐ¼Ñ‹Ð¹ Ð² Ð²Ð¸Ð´Ð¶ÐµÑ‚Ð°Ñ… Ð³Ð»Ð°Ð²Ð½Ð¾Ð³Ð¾ ÑÐºÑ€Ð°Ð½Ð°.';

  @override
  String get widgetTextSizeExtraSmall => 'ÐžÑ‡ÐµÐ½ÑŒ Ð¼Ð°Ð»ÐµÐ½ÑŒÐºÐ¸Ð¹';

  @override
  String get widgetTextSizeSmall => 'ÐœÐ°Ð»ÐµÐ½ÑŒÐºÐ¸Ð¹';

  @override
  String get widgetTextSizeMedium => 'Ð¡Ñ€ÐµÐ´Ð½Ð¸Ð¹';

  @override
  String get widgetTextSizeLarge => 'Ð‘Ð¾Ð»ÑŒÑˆÐ¾Ð¹';

  @override
  String get widgetMmssThresholdTitle =>
      'Ð¡ÐµÐºÑƒÐ½Ð´Ð½Ñ‹Ð¹ Ð¾Ñ‚ÑÑ‡Ñ‘Ñ‚ Ð² Ð²Ð¸Ð´Ð¶ÐµÑ‚Ðµ';

  @override
  String get widgetMmssThresholdNever =>
      'Ð’ÑÐµÐ³Ð´Ð° Ð¿Ð¾ÐºÐ°Ð·Ñ‹Ð²Ð°Ñ‚ÑŒ Ð§Ð§:ÐœÐœ';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'ÐœÐœ:Ð¡Ð¡ Ð¼ÐµÐ½ÐµÐµ $minutes Ð¼Ð¸Ð½';
  }

  @override
  String get remindersOnOffTitle => 'ÐÐ°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ Ð²ÐºÐ»/Ð²Ñ‹ÐºÐ»';

  @override
  String get remindersOnOffSubtitle =>
      'Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚Ðµ Ð¸Ð»Ð¸ Ð²Ñ‹ÐºÐ»ÑŽÑ‡Ð¸Ñ‚Ðµ ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ñ Ð¾ Ð½Ð°Ð¼Ð°Ð·Ðµ. ÐÐ°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ¸ Ð´Ð»Ñ ÐºÐ°Ð¶Ð´Ð¾Ð³Ð¾ Ð½Ð°Ð¼Ð°Ð·Ð° ÑÐ¾Ñ…Ñ€Ð°Ð½ÑÑŽÑ‚ÑÑ.';

  @override
  String get reminderVibrationTitle =>
      'Ð’Ð¸Ð±Ñ€Ð°Ñ†Ð¸Ñ Ð¿Ñ€Ð¸ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¸';

  @override
  String get reminderVibrationSubtitle =>
      'ÐŸÑƒÐ»ÑŒÑÐ¸Ñ€ÑƒÑŽÑ‰Ð°Ñ Ð²Ð¸Ð±Ñ€Ð°Ñ†Ð¸Ñ Ð¾ÐºÐ¾Ð»Ð¾ 10 ÑÐµÐºÑƒÐ½Ð´ Ð¿Ñ€Ð¸ ÑÑ€Ð°Ð±Ð°Ñ‚Ñ‹Ð²Ð°Ð½Ð¸Ð¸ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ.';

  @override
  String get reminderSoundTitle => 'Ð—Ð²ÑƒÐº Ð¿Ñ€Ð¸ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¸';

  @override
  String get reminderSoundSubtitle =>
      'Ð’Ð¾ÑÐ¿Ñ€Ð¾Ð¸Ð·Ð²Ð¾Ð´Ð¸Ñ‚ÑŒ Ð·Ð²ÑƒÐº ÑƒÐ²ÐµÐ´Ð¾Ð¼Ð»ÐµÐ½Ð¸Ñ Ð¿Ñ€Ð¸ ÑÑ€Ð°Ð±Ð°Ñ‚Ñ‹Ð²Ð°Ð½Ð¸Ð¸ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ.';

  @override
  String get remindersOn => 'Ð’ÐºÐ»';

  @override
  String get remindersOff => 'Ð’Ñ‹ÐºÐ»';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer â€” Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ';
  }

  @override
  String get reminderTypeTitle =>
      'Ð¢Ð¸Ð¿ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ñ (Ð¼Ð¾Ð¶Ð½Ð¾ Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð¾Ð±Ð°)';

  @override
  String get onTime => 'Ð’Ð¾Ð²Ñ€ÐµÐ¼Ñ';

  @override
  String get before => 'Ð”Ð¾';

  @override
  String get after => 'ÐŸÐ¾ÑÐ»Ðµ';

  @override
  String get reminderAlertTitle => 'Ð¡Ð¸Ð³Ð½Ð°Ð»';

  @override
  String get reminderAlertSubtitle =>
      'Ð”Ð»Ñ Ñ„Ð°ÐºÑ‚Ð¸Ñ‡ÐµÑÐºÐ¾Ð³Ð¾ ÑÐ¸Ð³Ð½Ð°Ð»Ð° Ñ‚Ð°ÐºÐ¶Ðµ Ð½ÑƒÐ¶ÐµÐ½ Ð²ÐºÐ»ÑŽÑ‡Ñ‘Ð½Ð½Ñ‹Ð¹ Ð¿ÐµÑ€ÐµÐºÐ»ÑŽÑ‡Ð°Ñ‚ÐµÐ»ÑŒ Ð² Ð½Ð°ÑÑ‚Ñ€Ð¾Ð¹ÐºÐ°Ñ….';

  @override
  String get vibrateChip => 'Ð’Ð¸Ð±Ñ€Ð°Ñ†Ð¸Ñ';

  @override
  String get soundChip => 'Ð—Ð²ÑƒÐº';

  @override
  String get adhanChip => 'ÐÐ·Ð°Ð½';

  @override
  String get remindBeforePrayerTitle =>
      'ÐÐ°Ð¿Ð¾Ð¼Ð½Ð¸Ñ‚ÑŒ Ð¿ÐµÑ€ÐµÐ´ Ð½Ð°Ð¼Ð°Ð·Ð¾Ð¼';

  @override
  String get remindAfterPrayerTitle =>
      'ÐÐ°Ð¿Ð¾Ð¼Ð½Ð¸Ñ‚ÑŒ Ð¿Ð¾ÑÐ»Ðµ Ð½Ð°Ð¼Ð°Ð·Ð°';

  @override
  String minutesValue(Object minutes) {
    return '$minutes Ð¼Ð¸Ð½';
  }

  @override
  String get custom => 'Ð¡Ð²Ð¾Ñ‘';

  @override
  String get customMinutes => 'Ð¡Ð²Ð¾Ð¸ Ð¼Ð¸Ð½ÑƒÑ‚Ñ‹';

  @override
  String get customMinutesHint => 'Ð½Ð°Ð¿Ñ€Ð¸Ð¼ÐµÑ€ 12';

  @override
  String get save => 'Ð¡Ð¾Ñ…Ñ€Ð°Ð½Ð¸Ñ‚ÑŒ';

  @override
  String get enableBeforeToSelectMinutes =>
      'Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚Ðµ Â«Ð”Ð¾Â», Ñ‡Ñ‚Ð¾Ð±Ñ‹ Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð¼Ð¸Ð½ÑƒÑ‚Ñ‹.';

  @override
  String get enableAfterToSelectMinutes =>
      'Ð’ÐºÐ»ÑŽÑ‡Ð¸Ñ‚Ðµ Â«ÐŸÐ¾ÑÐ»ÐµÂ», Ñ‡Ñ‚Ð¾Ð±Ñ‹ Ð²Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð¼Ð¸Ð½ÑƒÑ‚Ñ‹.';

  @override
  String get enterValidPositiveNumber =>
      'Ð’Ð²ÐµÐ´Ð¸Ñ‚Ðµ ÐºÐ¾Ñ€Ñ€ÐµÐºÑ‚Ð½Ð¾Ðµ Ð¿Ð¾Ð»Ð¾Ð¶Ð¸Ñ‚ÐµÐ»ÑŒÐ½Ð¾Ðµ Ñ‡Ð¸ÑÐ»Ð¾.';

  @override
  String get useValueUpTo240 =>
      'Ð˜ÑÐ¿Ð¾Ð»ÑŒÐ·ÑƒÐ¹Ñ‚Ðµ Ð·Ð½Ð°Ñ‡ÐµÐ½Ð¸Ðµ Ð´Ð¾ 240 Ð¼Ð¸Ð½ÑƒÑ‚.';

  @override
  String get customMinutesSaved => 'Ð¡Ð²Ð¾Ð¸ Ð¼Ð¸Ð½ÑƒÑ‚Ñ‹ ÑÐ¾Ñ…Ñ€Ð°Ð½ÐµÐ½Ñ‹.';

  @override
  String get cancel => 'ÐžÑ‚Ð¼ÐµÐ½Ð°';

  @override
  String get calendarTabTooltip => 'Ð¥Ð¸Ð´Ð¶Ñ€Ð°-ÐºÐ°Ð»ÐµÐ½Ð´Ð°Ñ€ÑŒ';

  @override
  String get calendarPreviousMonth => 'ÐŸÑ€ÐµÐ´Ñ‹Ð´ÑƒÑ‰Ð¸Ð¹ Ð¼ÐµÑÑÑ†';

  @override
  String get calendarNextMonth => 'Ð¡Ð»ÐµÐ´ÑƒÑŽÑ‰Ð¸Ð¹ Ð¼ÐµÑÑÑ†';

  @override
  String get calendarSwapPrimary =>
      'ÐŸÐµÑ€ÐµÐºÐ»ÑŽÑ‡Ð¸Ñ‚ÑŒ Ð¥Ð¸Ð´Ð¶Ñ€Ð°/Ð“Ñ€Ð¸Ð³Ð¾Ñ€Ð¸Ð°Ð½ÑÐºÐ¸Ð¹';

  @override
  String get calendarShowSecondary =>
      'ÐŸÐ¾ÐºÐ°Ð·Ð°Ñ‚ÑŒ Ð²Ñ‚Ð¾Ñ€Ð¸Ñ‡Ð½ÑƒÑŽ Ð´Ð°Ñ‚Ñƒ';

  @override
  String get calendarHideSecondary =>
      'Ð¡ÐºÑ€Ñ‹Ñ‚ÑŒ Ð²Ñ‚Ð¾Ñ€Ð¸Ñ‡Ð½ÑƒÑŽ Ð´Ð°Ñ‚Ñƒ';

  @override
  String get calendarNoRemindersOnDay =>
      'ÐÐµÑ‚ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ð¹ Ð½Ð° ÑÑ‚Ð¾Ñ‚ Ð´ÐµÐ½ÑŒ';

  @override
  String get calendarAddReminder => 'Ð”Ð¾Ð±Ð°Ð²Ð¸Ñ‚ÑŒ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ';

  @override
  String get calendarEditReminder => 'Ð˜Ð·Ð¼ÐµÐ½Ð¸Ñ‚ÑŒ';

  @override
  String get calendarDeleteReminder => 'Ð£Ð´Ð°Ð»Ð¸Ñ‚ÑŒ';

  @override
  String get calendarReminderFormTitleNew =>
      'ÐÐ¾Ð²Ð¾Ðµ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ';

  @override
  String get calendarReminderFormTitleEdit =>
      'Ð˜Ð·Ð¼ÐµÐ½Ð¸Ñ‚ÑŒ Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ';

  @override
  String get calendarReminderTitleLabel => 'ÐÐ°Ð·Ð²Ð°Ð½Ð¸Ðµ';

  @override
  String get calendarReminderTitleHint =>
      'Ð½Ð°Ð¿Ñ€Ð¸Ð¼ÐµÑ€, Ð½Ð°Ñ‡Ð°Ð»Ð¾ Ð Ð°Ð¼Ð°Ð´Ð°Ð½Ð°';

  @override
  String get calendarReminderNotesLabel =>
      'Ð—Ð°Ð¼ÐµÑ‚ÐºÐ¸ (Ð½ÐµÐ¾Ð±ÑÐ·Ð°Ñ‚ÐµÐ»ÑŒÐ½Ð¾)';

  @override
  String get calendarReminderDateTimeLabel => 'Ð”Ð°Ñ‚Ð° Ð¸ Ð²Ñ€ÐµÐ¼Ñ';

  @override
  String get calendarReminderRecurrenceLabel => 'ÐŸÐ¾Ð²Ñ‚Ð¾Ñ€';

  @override
  String get calendarRecurrenceOnce => 'ÐžÐ´Ð¸Ð½ Ñ€Ð°Ð·';

  @override
  String get calendarRecurrenceDaily => 'Ð•Ð¶ÐµÐ´Ð½ÐµÐ²Ð½Ð¾';

  @override
  String get calendarRecurrenceWeekly => 'Ð•Ð¶ÐµÐ½ÐµÐ´ÐµÐ»ÑŒÐ½Ð¾';

  @override
  String get calendarRecurrenceMonthly => 'Ð•Ð¶ÐµÐ¼ÐµÑÑÑ‡Ð½Ð¾';

  @override
  String get calendarRecurrenceYearly => 'Ð•Ð¶ÐµÐ³Ð¾Ð´Ð½Ð¾';

  @override
  String get calendarRepeatCountLabel =>
      'ÐšÐ¾Ð»Ð¸Ñ‡ÐµÑÑ‚Ð²Ð¾ Ð¿Ð¾Ð²Ñ‚Ð¾Ñ€ÐµÐ½Ð¸Ð¹';

  @override
  String get calendarRepeatCountHelper =>
      'Ð¡ÐºÐ¾Ð»ÑŒÐºÐ¾ Ñ€Ð°Ð· Ð½Ð°Ð¿Ð¾Ð¼Ð¸Ð½Ð°Ð½Ð¸Ðµ ÑÑ€Ð°Ð±Ð¾Ñ‚Ð°ÐµÑ‚ Ð¿ÐµÑ€ÐµÐ´ Ð¾ÑÑ‚Ð°Ð½Ð¾Ð²ÐºÐ¾Ð¹ (Ð²Ñ‹ÐºÐ» = Ð¿Ð¾Ð²Ñ‚Ð¾Ñ€ÑÑ‚ÑŒ Ð±ÐµÑÐºÐ¾Ð½ÐµÑ‡Ð½Ð¾)';

  @override
  String get calendarRepeatCountError =>
      'Ð’Ð²ÐµÐ´Ð¸Ñ‚Ðµ Ñ‡Ð¸ÑÐ»Ð¾ Ð¾Ñ‚ 2 Ð´Ð¾ 100';

  @override
  String get calendarRepeatDaysLabel => 'ÐŸÐ¾Ð²Ñ‚Ð¾Ñ€ÑÑ‚ÑŒ Ð²';

  @override
  String get calendarDayOfMonthLabel => 'Ð”ÐµÐ½ÑŒ Ð¼ÐµÑÑÑ†Ð°';

  @override
  String get calendarYearlyMonthLabel => 'ÐœÐµÑÑÑ†';

  @override
  String get calendarYearlyDayLabel => 'Ð”ÐµÐ½ÑŒ';

  @override
  String get calendarMonthlyBasisLabel => 'ÐžÑÐ½Ð¾Ð²Ð° Ð¼ÐµÑÑÑ†Ð°';

  @override
  String get calendarYearlyBasisLabel => 'ÐžÑÐ½Ð¾Ð²Ð° Ð³Ð¾Ð´Ð°';

  @override
  String get calendarYearlyBasisGregorian => 'Ð“Ñ€Ð¸Ð³Ð¾Ñ€Ð¸Ð°Ð½ÑÐºÐ¸Ð¹';

  @override
  String get calendarYearlyBasisHijri => 'Ð¥Ð¸Ð´Ð¶Ñ€Ð°';

  @override
  String get calendarReminderTitleRequired => 'Ð’Ð²ÐµÐ´Ð¸Ñ‚Ðµ Ð½Ð°Ð·Ð²Ð°Ð½Ð¸Ðµ';

  @override
  String get calendarAnchorClockTime => 'ÐšÐ°Ð»ÐµÐ½Ð´Ð°Ñ€Ð½Ð°Ñ Ð´Ð°Ñ‚Ð°';

  @override
  String get calendarAnchorPrayerTime => 'Ð’Ñ€ÐµÐ¼Ñ Ð½Ð°Ð¼Ð°Ð·Ð°';

  @override
  String get calendarSelectPrayer => 'Ð’Ñ‹Ð±ÐµÑ€Ð¸Ñ‚Ðµ Ð½Ð°Ð¼Ð°Ð·';

  @override
  String get calendarOffsetOnTime => 'Ð’Ð¾Ð²Ñ€ÐµÐ¼Ñ';

  @override
  String get calendarOffsetBefore => 'Ð”Ð¾';

  @override
  String get calendarOffsetAfter => 'ÐŸÐ¾ÑÐ»Ðµ';

  @override
  String get calendarPickAnchorDate => 'Ð’Ñ‹Ð±Ñ€Ð°Ñ‚ÑŒ Ð´Ð°Ñ‚Ñƒ';

  @override
  String get datesPrayerTimesTab => 'Ð’Ñ€ÐµÐ¼Ñ Ð½Ð°Ð¼Ð°Ð·Ð°';

  @override
  String get datesCalendarTab => 'ÐšÐ°Ð»ÐµÐ½Ð´Ð°Ñ€ÑŒ';

  @override
  String get undo => 'ÐžÑ‚Ð¼ÐµÐ½Ð¸Ñ‚ÑŒ';

  @override
  String calendarReminderDeleted(Object title) {
    return 'Â«$titleÂ» ÑƒÐ´Ð°Ð»ÐµÐ½Ð¾';
  }
}
