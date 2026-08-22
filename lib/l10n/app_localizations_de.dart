// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Gebetsassistent';

  @override
  String get tabLocation => 'Ort';

  @override
  String get tabToday => 'Heute';

  @override
  String get tabDates => 'Daten';

  @override
  String get tabTesbih => 'Perlen';

  @override
  String get tooltipToggleLightDark => 'Hell/Dunkel umschalten';

  @override
  String get tooltipRemindersOn => 'Erinnerungen einschalten';

  @override
  String get tooltipRemindersOff => 'Erinnerungen ausschalten';

  @override
  String get tooltipPreferences => 'Einstellungen';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes Min';
  }

  @override
  String get remainingMinutesUnknown => '-- Min';

  @override
  String get homeNoLocationTitle => 'Kein Ort ausgewÃ¤hlt';

  @override
  String get homeNoLocationSubtitle =>
      'Gehe zum Ort-Tab und speichere zuerst deinen Bezirk.';

  @override
  String get homeNoPrayerTimesTitle => 'Keine Gebetszeiten im Cache';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Tippe auf Aktualisieren, um Jahresdaten zu synchronisieren.';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaBearing(int degrees) {
    return 'Qibla: $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Ihre Position konnte nicht ermittelt werden. GPS aktivieren und erneut versuchen.';

  @override
  String get qiblaHeadingUnavailable =>
      'Kompass nicht verfÃ¼gbar - feste Richtung wird angezeigt.';

  @override
  String get qiblaPointDevice =>
      'Drehen Sie das GerÃ¤t, bis die Nadel nach oben zeigt.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Heutige Zeiten teilen';

  @override
  String get calendarPreviousDay => 'Vorheriger Tag';

  @override
  String get calendarNextDay => 'NÃ¤chster Tag';

  @override
  String todayWithDate(Object date) {
    return 'Heute â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Hidschri: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hidschri: $date';
  }

  @override
  String get reminderSettingsTitle => 'Erinnerungseinstellungen';

  @override
  String get reminderSettingsSubtitle =>
      'Tippe auf eine Gebetszeit, um Erinnerung und Minuten davor zu konfigurieren.';

  @override
  String get tooltipScheduledDebug => 'Geplante Erinnerungen Debug';

  @override
  String get scheduledRemindersDebugTitle => 'Geplante Erinnerungen (Debug)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Ausstehende Benachrichtigungen: $count';
  }

  @override
  String get sendTestNotificationNow => 'Testbenachrichtigung senden';

  @override
  String get testNotificationSent => 'Testbenachrichtigung gesendet.';

  @override
  String get statusBarMinutesTitle => 'Statusleisten-Minuten';

  @override
  String get statusBarMinutesSubtitle =>
      'Zeige laufende Restminuten-Benachrichtigung in der Statusleiste.';

  @override
  String get statusAutoRestoreTitle => 'Automatisch wiederherstellen';

  @override
  String get statusAutoRestoreSubtitle =>
      'Element neu erstellen, wenn der Nutzer es wegwischt.';

  @override
  String get noPendingReminders => 'Keine ausstehenden Erinnerungen.';

  @override
  String get unknownFireTime => 'Unbekannte Zeit';

  @override
  String get pastPrefix => '[VERGANGEN] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'An â€¢ PÃ¼nktlich + $minutes Min vorher';
  }

  @override
  String get reminderOnTimeOnly => 'An â€¢ PÃ¼nktlich';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'An â€¢ $minutes Min vorher';
  }

  @override
  String get reminderOff => 'Erinnerung aus';

  @override
  String get nextPrayerTitle => 'NÃ¤chstes Gebet';

  @override
  String get homeUpcomingRemindersTitle => 'Bevorstehende Erinnerungen';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total Gebete abgeschlossen';
  }

  @override
  String startsIn(Object remaining) {
    return 'Beginnt in $remaining';
  }

  @override
  String get selectYourLocation => 'WÃ¤hle deinen Ort';

  @override
  String get locationHelp =>
      'Nutze GPS fÃ¼r schnelle Einrichtung oder wÃ¤hle Land/Stadt manuell.';

  @override
  String get useCurrentLocation => 'Aktuellen Standort verwenden';

  @override
  String get country => 'Land';

  @override
  String get stateCity => 'Bundesland / Stadt';

  @override
  String get district => 'Bezirk';

  @override
  String get saveLocation => 'Ort speichern';

  @override
  String selectedLocation(Object location) {
    return 'AusgewÃ¤hlt: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'WÃ¤hle zuerst einen Ort, um die Gebetsliste fÃ¼r 1 Jahr zu sehen.';

  @override
  String get historyTableTitle => 'Gebetszeitentabelle (Ganzes Jahr)';

  @override
  String get todayShort => 'Heute';

  @override
  String get dateHeader => 'Datum';

  @override
  String get imsak => 'Fadschr';

  @override
  String get gunes => 'Sonnenaufgang';

  @override
  String get ogle => 'Dhuhur';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Maghrib';

  @override
  String get yatsi => 'Ischa';

  @override
  String get hijriHeader => 'Hidschri';

  @override
  String get preferencesTitle => 'Einstellungen';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Systemstandard';

  @override
  String get themeModeTitle => 'Designmodus';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get appBarRemainingTitle => 'Restzeit im App-Bar';

  @override
  String get showInTitle => 'Im Titel anzeigen';

  @override
  String get showAtRight => 'Rechts anzeigen';

  @override
  String get showAsSubtitle => 'Als Untertitel anzeigen';

  @override
  String get hideRemainingText => 'Resttext ausblenden';

  @override
  String get notificationMessageTitle => 'Benachrichtigungstext';

  @override
  String get notificationMessageShown => 'Angezeigt';

  @override
  String get notificationMessageHidden => 'Ausgeblendet';

  @override
  String get widgetTextSizeTitle => 'Widget-TextgrÃ¶ÃŸe';

  @override
  String get widgetTextSizeSubtitle =>
      'TextgrÃ¶ÃŸe fÃ¼r die Homescreen-Widgets.';

  @override
  String get widgetTextSizeExtraSmall => 'Sehr klein';

  @override
  String get widgetTextSizeSmall => 'Klein';

  @override
  String get widgetTextSizeMedium => 'Mittel';

  @override
  String get widgetTextSizeLarge => 'GroÃŸ';

  @override
  String get widgetMmssThresholdTitle => 'Widget-Sekunden-Countdown';

  @override
  String get widgetMmssThresholdNever => 'Immer HH:MM anzeigen';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS unter $minutes Min';
  }

  @override
  String get remindersOnOffTitle => 'Erinnerungen an/aus';

  @override
  String get remindersOnOffSubtitle =>
      'Gebetserinnerungen ein- oder ausschalten. Einstellungen pro Gebet bleiben erhalten.';

  @override
  String get reminderVibrationTitle => 'Bei Erinnerung vibrieren';

  @override
  String get reminderVibrationSubtitle =>
      'Etwa 10 Sekunden lang pulsierend vibrieren, wenn eine Erinnerung ausgelÃ¶st wird.';

  @override
  String get reminderSoundTitle => 'Ton bei Erinnerung abspielen';

  @override
  String get reminderSoundSubtitle =>
      'Benachrichtigungston abspielen, wenn eine Erinnerung ausgelÃ¶st wird.';

  @override
  String get remindersOn => 'An';

  @override
  String get remindersOff => 'Aus';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer Erinnerung';
  }

  @override
  String get reminderTypeTitle => 'Erinnerungstyp (beides mÃ¶glich)';

  @override
  String get onTime => 'PÃ¼nktlich';

  @override
  String get before => 'Vorher';

  @override
  String get after => 'Nachher';

  @override
  String get reminderAlertTitle => 'Alarm';

  @override
  String get reminderAlertSubtitle =>
      'Erfordert zusÃ¤tzlich den passenden Schalter in den Einstellungen, damit tatsÃ¤chlich alarmiert wird.';

  @override
  String get vibrateChip => 'Vibration';

  @override
  String get soundChip => 'Ton';

  @override
  String get adhanChip => 'AdhÄn';

  @override
  String get remindBeforePrayerTitle => 'Erinnere mich vor dem Gebet';

  @override
  String get remindAfterPrayerTitle => 'Erinnere mich nach dem Gebet';

  @override
  String minutesValue(Object minutes) {
    return '$minutes Min';
  }

  @override
  String get custom => 'Eigene';

  @override
  String get customMinutes => 'Benutzerdefinierte Minuten';

  @override
  String get customMinutesHint => 'z. B. 12';

  @override
  String get save => 'Speichern';

  @override
  String get enableBeforeToSelectMinutes =>
      '\"Vorher\" aktivieren, um Minuten zu wÃ¤hlen.';

  @override
  String get enableAfterToSelectMinutes =>
      '\"Nachher\" aktivieren, um Minuten zu wÃ¤hlen.';

  @override
  String get enterValidPositiveNumber => 'Gib eine gÃ¼ltige positive Zahl ein.';

  @override
  String get useValueUpTo240 => 'Verwende einen Wert bis 240 Minuten.';

  @override
  String get customMinutesSaved => 'Benutzerdefinierte Minuten gespeichert.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get calendarTabTooltip => 'Hidschri-Kalender';

  @override
  String get calendarPreviousMonth => 'Vorheriger Monat';

  @override
  String get calendarNextMonth => 'NÃ¤chster Monat';

  @override
  String get calendarSwapPrimary => 'Hidschri/Gregorianisch wechseln';

  @override
  String get calendarShowSecondary => 'Zweites Datum anzeigen';

  @override
  String get calendarHideSecondary => 'Zweites Datum ausblenden';

  @override
  String get calendarNoRemindersOnDay => 'Keine Erinnerungen an diesem Tag';

  @override
  String get calendarAddReminder => 'Erinnerung hinzufÃ¼gen';

  @override
  String get calendarEditReminder => 'Bearbeiten';

  @override
  String get calendarDeleteReminder => 'LÃ¶schen';

  @override
  String get calendarReminderFormTitleNew => 'Neue Erinnerung';

  @override
  String get calendarReminderFormTitleEdit => 'Erinnerung bearbeiten';

  @override
  String get calendarReminderTitleLabel => 'Titel';

  @override
  String get calendarReminderTitleHint => 'z. B. Ramadanbeginn';

  @override
  String get calendarReminderNotesLabel => 'Notizen (optional)';

  @override
  String get calendarReminderDateTimeLabel => 'Datum & Uhrzeit';

  @override
  String get calendarReminderRecurrenceLabel => 'Wiederholung';

  @override
  String get calendarRecurrenceOnce => 'Einmalig';

  @override
  String get calendarRecurrenceDaily => 'TÃ¤glich';

  @override
  String get calendarRecurrenceWeekly => 'WÃ¶chentlich';

  @override
  String get calendarRecurrenceMonthly => 'Monatlich';

  @override
  String get calendarRecurrenceYearly => 'JÃ¤hrlich';

  @override
  String get calendarRepeatCountLabel => 'Wiederholungsanzahl';

  @override
  String get calendarRepeatCountHelper =>
      'Wie oft der Reminder ausgelÃ¶st wird, bevor er stoppt (aus = unbegrenzt)';

  @override
  String get calendarRepeatCountError =>
      'Geben Sie eine Zahl von 2 bis 100 ein';

  @override
  String get calendarRepeatDaysLabel => 'Wiederholen am';

  @override
  String get calendarDayOfMonthLabel => 'Tag des Monats';

  @override
  String get calendarYearlyMonthLabel => 'Monat';

  @override
  String get calendarYearlyDayLabel => 'Tag';

  @override
  String get calendarMonthlyBasisLabel => 'Monatliche Basis';

  @override
  String get calendarYearlyBasisLabel => 'JÃ¤hrliche Basis';

  @override
  String get calendarYearlyBasisGregorian => 'Gregorianisch';

  @override
  String get calendarYearlyBasisHijri => 'Hidschri';

  @override
  String get calendarReminderTitleRequired => 'Titel eingeben';

  @override
  String get calendarAnchorClockTime => 'Kalenderdatum';

  @override
  String get calendarAnchorPrayerTime => 'Gebetszeit';

  @override
  String get calendarSelectPrayer => 'Gebet auswÃ¤hlen';

  @override
  String get calendarOffsetOnTime => 'PÃ¼nktlich';

  @override
  String get calendarOffsetBefore => 'Vorher';

  @override
  String get calendarOffsetAfter => 'Nachher';

  @override
  String get calendarPickAnchorDate => 'Datum wÃ¤hlen';

  @override
  String get datesPrayerTimesTab => 'Gebetszeiten';

  @override
  String get datesCalendarTab => 'Kalender';

  @override
  String get undo => 'RÃ¼ckgÃ¤ngig';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" gelÃ¶scht';
  }
}
