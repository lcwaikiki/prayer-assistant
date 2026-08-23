// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prayer Assist';

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
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaBearing(int degrees) {
    return 'Qibla: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Could not determine your location. Enable GPS and try again.';

  @override
  String get qiblaHeadingUnavailable =>
      'Compass unavailable - showing fixed bearing.';

  @override
  String get qiblaPointDevice =>
      'Rotate your device until the needle points up.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Share today\'s times';

  @override
  String get calendarPreviousDay => 'Previous day';

  @override
  String get calendarNextDay => 'Next day';

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
  String get widgetMmssThresholdTitle => 'Widget seconds countdown';

  @override
  String get widgetMmssThresholdNever => 'Always show HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS below $minutes min';
  }

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
  String get after => 'After';

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
  String get adhanChip => 'Adhan';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total prayers completed';
  }

  @override
  String get holiday_islamic_new_year => 'Islamic New Year';

  @override
  String get holiday_ashura => 'Ashura';

  @override
  String get holiday_mawlid => 'Mawlid al-Nabi';

  @override
  String get holiday_isra_miraj => 'Isra and Miraj';

  @override
  String get holiday_laylat_barat => 'Laylat al-Baraat';

  @override
  String get holiday_ramadan_first => 'First of Ramadan';

  @override
  String get holiday_laylat_qadr => 'Laylat al-Qadr';

  @override
  String get holiday_eid_fitr => 'Eid al-Fitr';

  @override
  String get holiday_arafah => 'Day of Arafah';

  @override
  String get holiday_eid_adha => 'Eid al-Adha';

  @override
  String get remindBeforePrayerTitle => 'Remind me before prayer';

  @override
  String get remindAfterPrayerTitle => 'Remind me after prayer';

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
  String get enableAfterToSelectMinutes =>
      'Enable \"After\" to select minutes.';

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
  String get calendarRepeatCountLabel => 'Repeat count';

  @override
  String get calendarRepeatCountHelper =>
      'Number of times the reminder fires before stopping (off = repeats forever)';

  @override
  String get calendarRepeatCountError => 'Enter a number from 2 to 100';

  @override
  String get calendarRepeatDaysLabel => 'Repeat on';

  @override
  String get calendarDayOfMonthLabel => 'Day of month';

  @override
  String get calendarYearlyMonthLabel => 'Month';

  @override
  String get calendarYearlyDayLabel => 'Day';

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

  @override
  String get verseOfTheDay => 'Verse of the Day';

  @override
  String get hadithOfTheDay => 'Hadith of the Day';

  @override
  String get hisnAlMuslimTitle => 'Hisn al-Muslim';

  @override
  String get morningAdhkar => 'Morning Adhkar';

  @override
  String get eveningAdhkar => 'Evening Adhkar';

  @override
  String get afterPrayerAdhkar => 'After Prayer';

  @override
  String get sleepingAdhkar => 'Before Sleeping';

  @override
  String get dailyLifeDuas => 'Daily Life Duas';

  @override
  String get shareWisdom => 'Share';

  @override
  String get copyText => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get searchSupplicationsHint => 'Search supplications...';

  @override
  String get noSupplicationsFound => 'No supplications found';

  @override
  String get completed => 'Completed';

  @override
  String get tapToCount => 'Tap to count';

  @override
  String get tabAll => 'All';

  @override
  String get kazaTitle => 'Qadaa';

  @override
  String get kazaSubtitle => 'Track and make up missed past prayers';

  @override
  String get kazaCalculatorWizard => 'Calculator';

  @override
  String get kazaBatchLogDay => '+1 Full Day';

  @override
  String get kazaBatchLogDayTooltip =>
      'Increment 1 completed count for all 6 prayers';

  @override
  String get kazaTotalRemaining => 'Total Remaining';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target completed';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Est. Completion: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'All missed prayers completed! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Daily Pace';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count prayers / day';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Set Daily Pace';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'How many missed prayers do you make up each day?';

  @override
  String get kazaCalculatorTitle => 'Missed Prayers Calculator';

  @override
  String get kazaCalculateByYears => 'Missed Time';

  @override
  String get kazaCalculateManual => 'Manual Targets';

  @override
  String get kazaYearsMissed => 'Years Missed';

  @override
  String get kazaMonthsMissed => 'Additional Months';

  @override
  String get kazaCalculateButton => 'Set Targets';

  @override
  String get kazaWitrLabel => 'Witr';

  @override
  String kazaRemainingCount(Object count) {
    return '$count remaining';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name Completed Count';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days days per prayer ($total total prayers)';
  }

  @override
  String get backupExportTitle => 'Backup & Export';

  @override
  String get backupExportSubtitle =>
      'Backup app data or export calendar schedules';

  @override
  String get exportBackupJson => 'Export Backup Data (JSON)';

  @override
  String get restoreBackupJson => 'Restore Data from Backup';

  @override
  String get exportPrayerScheduleIcs => 'Export Prayer Schedule (.ics)';

  @override
  String get exportHolidaysIcs => 'Export Islamic Holidays (.ics)';

  @override
  String get restoreConfirmTitle => 'Restore App Data?';

  @override
  String get restoreConfirmBody =>
      'This will restore your Qadaa targets, prayer history, reminders, and Tesbihat data. Continue?';

  @override
  String get restoreSuccess => 'Data restored successfully!';

  @override
  String get restoreError => 'Invalid backup file format';

  @override
  String get shareOrSave => 'Share / Save';

  @override
  String get analyticsTab => 'Analytics';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get daysUnit => 'days';

  @override
  String get monthlyHeatmapTitle => 'Monthly Completion';

  @override
  String get completionBreakdownTitle => 'Prayer Breakdown';

  @override
  String get overallConsistency => 'Overall Consistency';

  @override
  String get totalPrayersCompleted => 'Total Prayers Logged';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get allTime => 'All Time';

  @override
  String get fastingTitle => 'Fasting';

  @override
  String get suhoorCountdownTitle => 'Time Until Suhoor (Imsak)';

  @override
  String get iftarCountdownTitle => 'Time Until Iftar (Maghrib)';

  @override
  String get fastingTypeRamadan => 'Ramadan Fast';

  @override
  String get fastingTypeSunnah => 'Sunnah Fast';

  @override
  String get fastingTypeQadaa => 'Make-up (Qadaa) Fast';

  @override
  String get whiteDaysTitle => 'White Days (13th, 14th, 15th)';

  @override
  String get mondayThursdayTitle => 'Monday & Thursday Sunnah';

  @override
  String get logFastAction => 'Log Fast';

  @override
  String get totalFastsLogged => 'Total Fasts Logged';

  @override
  String get suhoorEndsIn => 'Suhoor ends in';

  @override
  String get iftarIn => 'Iftar in';

  @override
  String get fastingTab => 'Fasting';

  @override
  String get trackTabTitle => 'Track';

  @override
  String get prayerAnalyticsTitle => 'Prayer Analytics';

  @override
  String get prayerQadaaTitle => 'Prayer Qadaa';

  @override
  String get iftarTimeLabel => 'Iftar Time';
}
