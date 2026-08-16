// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Assistant';

  @override
  String get tabLocation => 'Location';

  @override
  String get tabToday => 'Today';

  @override
  String get tabDates => 'Dates';

  @override
  String get tabTesbih => 'Beads';

  @override
  String get tooltipToggleLightDark => 'Toggle light/dark';

  @override
  String get tooltipRemindersOn => 'Turn reminders on';

  @override
  String get tooltipRemindersOff => 'Turn reminders off';

  @override
  String get tooltipPreferences => 'Preferences';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get remainingMinutesUnknown => '-- min';

  @override
  String get homeNoLocationTitle => 'No location selected';

  @override
  String get homeNoLocationSubtitle =>
      'Go to Location tab and save your district first.';

  @override
  String get homeNoPrayerTimesTitle => 'No prayer times in cache';

  @override
  String get homeNoPrayerTimesSubtitle => 'Tap refresh to sync yearly data.';

  @override
  String get refresh => 'Refresh';

  @override
  String todayWithDate(Object date) {
    return 'Today • $date';
  }

  @override
  String get hijriUnknown => 'Hijri: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hijri: $date';
  }

  @override
  String get reminderSettingsTitle => 'Reminder settings';

  @override
  String get reminderSettingsSubtitle =>
      'Tap any prayer time above to configure reminder hook and minutes-before.';

  @override
  String get tooltipScheduledDebug => 'Scheduled reminders debug';

  @override
  String get scheduledRemindersDebugTitle => 'Scheduled Reminders (Debug)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Pending notifications: $count';
  }

  @override
  String get sendTestNotificationNow => 'Send test notification now';

  @override
  String get testNotificationSent => 'Test notification sent.';

  @override
  String get statusBarMinutesTitle => 'Status bar minutes';

  @override
  String get statusBarMinutesSubtitle =>
      'Show ongoing remaining-minutes notification in status bar.';

  @override
  String get statusAutoRestoreTitle => 'Auto-restore if dismissed';

  @override
  String get statusAutoRestoreSubtitle =>
      'Recreate the status item if user swipes it away.';

  @override
  String get noPendingReminders => 'No pending reminder notifications.';

  @override
  String get unknownFireTime => 'Unknown fire time';

  @override
  String get pastPrefix => '[PAST] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'On • On time + $minutes min before';
  }

  @override
  String get reminderOnTimeOnly => 'On • On time';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'On • $minutes min before';
  }

  @override
  String get reminderOff => 'Reminder off';

  @override
  String get nextPrayerTitle => 'Next Prayer';

  @override
  String get homeUpcomingRemindersTitle => 'Upcoming reminders';

  @override
  String startsIn(Object remaining) {
    return 'Starts in $remaining';
  }

  @override
  String get selectYourLocation => 'Select Your Location';

  @override
  String get locationHelp =>
      'Use GPS for quick setup or pick country/city manually.';

  @override
  String get useCurrentLocation => 'Use Current Location';

  @override
  String get country => 'Country';

  @override
  String get stateCity => 'State / City';

  @override
  String get district => 'District';

  @override
  String get saveLocation => 'Save Location';

  @override
  String selectedLocation(Object location) {
    return 'Selected: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Select a location first to view 1-year prayer list.';

  @override
  String get historyTableTitle => 'Prayer Times Table (Full Year)';

  @override
  String get todayShort => 'Today';

  @override
  String get dateHeader => 'Date';

  @override
  String get imsak => 'Fajr';

  @override
  String get gunes => 'Sunrise';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Isha';

  @override
  String get hijriHeader => 'Hijri';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System default';

  @override
  String get themeModeTitle => 'Theme mode';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get appBarRemainingTitle => 'Home app bar remaining text';

  @override
  String get showInTitle => 'Show in title';

  @override
  String get showAtRight => 'Show at right';

  @override
  String get showAsSubtitle => 'Show as subtitle';

  @override
  String get hideRemainingText => 'Hide remaining text';

  @override
  String get notificationMessageTitle => 'Notification message';

  @override
  String get notificationMessageShown => 'Shown';

  @override
  String get notificationMessageHidden => 'Hidden';

  @override
  String get widgetTextSizeTitle => 'Widget text size';

  @override
  String get widgetTextSizeSubtitle =>
      'Text size used in the home screen widgets.';

  @override
  String get widgetTextSizeExtraSmall => 'Extra small';

  @override
  String get widgetTextSizeSmall => 'Small';

  @override
  String get widgetTextSizeMedium => 'Medium';

  @override
  String get widgetTextSizeLarge => 'Large';

  @override
  String get remindersOnOffTitle => 'Reminders on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Turn prayer reminder notifications on or off. Per-prayer settings are kept.';

  @override
  String get reminderVibrationTitle => 'Vibrate on reminder';

  @override
  String get reminderVibrationSubtitle =>
      'Pulse-vibrate for about 10 seconds when a reminder fires.';

  @override
  String get reminderSoundTitle => 'Play sound on reminder';

  @override
  String get reminderSoundSubtitle =>
      'Play the notification sound when a reminder fires.';

  @override
  String get remindersOn => 'On';

  @override
  String get remindersOff => 'Off';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer Reminder';
  }

  @override
  String get reminderTypeTitle => 'Reminder type (can select both)';

  @override
  String get onTime => 'On time';

  @override
  String get before => 'Before';

  @override
  String get reminderAlertTitle => 'Alert';

  @override
  String get reminderAlertSubtitle =>
      'Also needs the matching switch on in Preferences to actually alert.';

  @override
  String get vibrateChip => 'Vibrate';

  @override
  String get soundChip => 'Sound';

  @override
  String get remindBeforePrayerTitle => 'Remind me before prayer';

  @override
  String minutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get custom => 'Custom';

  @override
  String get customMinutes => 'Custom minutes';

  @override
  String get customMinutesHint => 'e.g. 12';

  @override
  String get save => 'Save';

  @override
  String get enableBeforeToSelectMinutes =>
      'Enable \"Before\" to select minutes.';

  @override
  String get enterValidPositiveNumber => 'Enter a valid positive number.';

  @override
  String get useValueUpTo240 => 'Use a value up to 240 minutes.';

  @override
  String get customMinutesSaved => 'Custom minutes saved.';

  @override
  String get cancel => 'Cancel';

  @override
  String get calendarTabTooltip => 'Hijri calendar';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarSwapPrimary => 'Switch Hijri/Gregorian';

  @override
  String get calendarShowSecondary => 'Show secondary date';

  @override
  String get calendarHideSecondary => 'Hide secondary date';

  @override
  String get calendarNoRemindersOnDay => 'No reminders on this day';

  @override
  String get calendarAddReminder => 'Add reminder';

  @override
  String get calendarEditReminder => 'Edit';

  @override
  String get calendarDeleteReminder => 'Delete';

  @override
  String get calendarReminderFormTitleNew => 'New reminder';

  @override
  String get calendarReminderFormTitleEdit => 'Edit reminder';

  @override
  String get calendarReminderTitleLabel => 'Title';

  @override
  String get calendarReminderTitleHint => 'e.g. Ramadan starts';

  @override
  String get calendarReminderNotesLabel => 'Notes (optional)';

  @override
  String get calendarReminderDateTimeLabel => 'Date & time';

  @override
  String get calendarReminderRecurrenceLabel => 'Repeat';

  @override
  String get calendarRecurrenceOnce => 'Once';

  @override
  String get calendarRecurrenceDaily => 'Daily';

  @override
  String get calendarRecurrenceWeekly => 'Weekly';

  @override
  String get calendarRecurrenceMonthly => 'Monthly';

  @override
  String get calendarRecurrenceYearly => 'Yearly';

  @override
  String get calendarMonthlyBasisLabel => 'Monthly basis';

  @override
  String get calendarYearlyBasisLabel => 'Yearly basis';

  @override
  String get calendarYearlyBasisGregorian => 'Gregorian';

  @override
  String get calendarYearlyBasisHijri => 'Hijri';

  @override
  String get calendarReminderTitleRequired => 'Enter a title';

  @override
  String get calendarAnchorClockTime => 'Calendar date';

  @override
  String get calendarAnchorPrayerTime => 'Prayer time';

  @override
  String get calendarSelectPrayer => 'Select prayer';

  @override
  String get calendarOffsetOnTime => 'On time';

  @override
  String get calendarOffsetBefore => 'Before';

  @override
  String get calendarOffsetAfter => 'After';

  @override
  String get calendarPickAnchorDate => 'Pick date';

  @override
  String get datesPrayerTimesTab => 'Prayer Times';

  @override
  String get datesCalendarTab => 'Calendar';

  @override
  String get undo => 'Undo';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" deleted';
  }
}
