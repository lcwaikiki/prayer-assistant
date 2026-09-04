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
  String get homeNoLocationTitle => 'Kein Ort ausgewählt';

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
    return 'Qibla: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Ihre Position konnte nicht ermittelt werden. GPS aktivieren und erneut versuchen.';

  @override
  String get qiblaHeadingUnavailable =>
      'Kompass nicht verfügbar - feste Richtung wird angezeigt.';

  @override
  String get qiblaPointDevice =>
      'Drehen Sie das Gerät, bis die Nadel nach oben zeigt.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Heutige Zeiten teilen';

  @override
  String get calendarPreviousDay => 'Vorheriger Tag';

  @override
  String get calendarNextDay => 'Nächster Tag';

  @override
  String todayWithDate(Object date) {
    return 'Heute • $date';
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
    return 'An • Pünktlich + $minutes Min vorher';
  }

  @override
  String get reminderOnTimeOnly => 'An • Pünktlich';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'An • $minutes Min vorher';
  }

  @override
  String get reminderOff => 'Erinnerung aus';

  @override
  String get nextPrayerTitle => 'Nächstes Gebet';

  @override
  String get homeUpcomingRemindersTitle => 'Bevorstehende Erinnerungen';

  @override
  String startsIn(Object remaining) {
    return 'Beginnt in $remaining';
  }

  @override
  String get selectYourLocation => 'Wähle deinen Ort';

  @override
  String get locationHelp =>
      'Nutze GPS für schnelle Einrichtung oder wähle Land/Stadt manuell.';

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
    return 'Ausgewählt: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Wähle zuerst einen Ort, um die Gebetsliste für 1 Jahr zu sehen.';

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
  String get widgetSettingsSectionTitle => 'Widget-Einstellungen';

  @override
  String get widgetTextSizeTitle => 'Widget-Textgröße';

  @override
  String get widgetTextSizeSubtitle => 'Textgröße für die Homescreen-Widgets.';

  @override
  String get widgetTextSizeExtraSmall => 'Sehr klein';

  @override
  String get widgetTextSizeSmall => 'Klein';

  @override
  String get widgetTextSizeMedium => 'Mittel';

  @override
  String get widgetTextSizeLarge => 'Groß';

  @override
  String widgetTextSizePreview(Object size) {
    return 'Preview $size';
  }

  @override
  String get widgetMmssThresholdTitle => 'Countdown-Schwellenwert';

  @override
  String get widgetThemeTitle => 'Hintergrund-Design';

  @override
  String get widgetThemeSystem => 'Systemstandard';

  @override
  String get widgetThemeLight => 'Hell';

  @override
  String get widgetThemeDark => 'Dunkel';

  @override
  String get widgetThemeTransparent => 'Transparent';

  @override
  String get widgetCalendarDisplayTitle => 'Kalenderdatumsanzeige';

  @override
  String get widgetCalendarDisplayBoth => 'Beide (Hijri & Gregorianisch)';

  @override
  String get widgetCalendarDisplayHijri => 'Nur Hijri';

  @override
  String get widgetCalendarDisplayGregorian => 'Nur Gregorianisch';

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
      'Etwa 10 Sekunden lang pulsierend vibrieren, wenn eine Erinnerung ausgelöst wird.';

  @override
  String get reminderSoundTitle => 'Ton bei Erinnerung abspielen';

  @override
  String get reminderSoundSubtitle =>
      'Benachrichtigungston abspielen, wenn eine Erinnerung ausgelöst wird.';

  @override
  String get remindersOn => 'An';

  @override
  String get remindersOff => 'Aus';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer Erinnerung';
  }

  @override
  String get reminderTypeTitle => 'Erinnerungstyp (beides möglich)';

  @override
  String get onTime => 'Pünktlich';

  @override
  String get before => 'Vorher';

  @override
  String get after => 'Nachher';

  @override
  String get reminderAlertTitle => 'Alarm';

  @override
  String get reminderAlertSubtitle =>
      'Erfordert zusätzlich den passenden Schalter in den Einstellungen, damit tatsächlich alarmiert wird.';

  @override
  String get vibrateChip => 'Vibration';

  @override
  String get soundChip => 'Ton';

  @override
  String get adhanChip => 'Adhān';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total Gebete abgeschlossen';
  }

  @override
  String get holiday_islamic_new_year => 'Islamisches Neujahr';

  @override
  String get holiday_ashura => 'Aschura';

  @override
  String get holiday_mawlid => 'Mawlid an-Nabi';

  @override
  String get holiday_isra_miraj => 'Isra und Miraj';

  @override
  String get holiday_laylat_barat => 'Lailat al-Baraa';

  @override
  String get holiday_ramadan_first => 'Erster Ramadan';

  @override
  String get holiday_laylat_qadr => 'Lailat al-Qadr';

  @override
  String get holiday_eid_fitr => 'Eid al-Fitr';

  @override
  String get holiday_arafah => 'Tag von Arafah';

  @override
  String get holiday_eid_adha => 'Eid al-Adha';

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
      '\"Vorher\" aktivieren, um Minuten zu wählen.';

  @override
  String get enableAfterToSelectMinutes =>
      '\"Nachher\" aktivieren, um Minuten zu wählen.';

  @override
  String get enterValidPositiveNumber => 'Gib eine gültige positive Zahl ein.';

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
  String get calendarNextMonth => 'Nächster Monat';

  @override
  String get calendarSwapPrimary => 'Hidschri/Gregorianisch wechseln';

  @override
  String get calendarShowSecondary => 'Zweites Datum anzeigen';

  @override
  String get calendarHideSecondary => 'Zweites Datum ausblenden';

  @override
  String get calendarNoRemindersOnDay => 'Keine Erinnerungen an diesem Tag';

  @override
  String get calendarAddReminder => 'Erinnerung hinzufügen';

  @override
  String get calendarEditReminder => 'Bearbeiten';

  @override
  String get calendarDeleteReminder => 'Löschen';

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
  String get calendarRecurrenceDaily => 'Täglich';

  @override
  String get calendarRecurrenceWeekly => 'Wöchentlich';

  @override
  String get calendarRecurrenceMonthly => 'Monatlich';

  @override
  String get calendarRecurrenceYearly => 'Jährlich';

  @override
  String get calendarRepeatCountLabel => 'Wiederholungsanzahl';

  @override
  String get calendarRepeatCountHelper =>
      'Wie oft der Reminder ausgelöst wird, bevor er stoppt (aus = unbegrenzt)';

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
  String get calendarYearlyBasisLabel => 'Jährliche Basis';

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
  String get calendarSelectPrayer => 'Gebet auswählen';

  @override
  String get calendarOffsetOnTime => 'Pünktlich';

  @override
  String get calendarOffsetBefore => 'Vorher';

  @override
  String get calendarOffsetAfter => 'Nachher';

  @override
  String get calendarPickAnchorDate => 'Datum wählen';

  @override
  String get datesPrayerTimesTab => 'Gebetszeiten';

  @override
  String get datesCalendarTab => 'Kalender';

  @override
  String get undo => 'Rückgängig';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" gelöscht';
  }

  @override
  String get verseOfTheDay => 'Vers des Tages';

  @override
  String get hadithOfTheDay => 'Hadith des Tages';

  @override
  String get hisnAlMuslimTitle => 'Hisn al-Muslim';

  @override
  String get morningAdhkar => 'Morgen-Adhkar';

  @override
  String get eveningAdhkar => 'Abend-Adhkar';

  @override
  String get afterPrayerAdhkar => 'Nach dem Gebet';

  @override
  String get sleepingAdhkar => 'Vor dem Schlafen';

  @override
  String get dailyLifeDuas => 'Tägliche Bittgebete';

  @override
  String get shareWisdom => 'Teilen';

  @override
  String get copyText => 'Kopieren';

  @override
  String get copiedToClipboard => 'In Zwischenablage kopiert';

  @override
  String get searchSupplicationsHint => 'Bittgebete suchen...';

  @override
  String get noSupplicationsFound => 'Keine Bittgebete gefunden';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get tapToCount => 'Tippen zum Zählen';

  @override
  String get tabAll => 'Alle';

  @override
  String get kazaTitle => 'Qadaa';

  @override
  String get kazaSubtitle => 'Verfolgen und nachholen versäumter Gebete';

  @override
  String get kazaCalculatorWizard => 'Rechner';

  @override
  String get kazaBatchLogDay => '+1 Ganzer Tag';

  @override
  String get kazaBatchLogDayTooltip =>
      'Erhöhe die Anzahl für alle 6 Gebete um 1';

  @override
  String get kazaTotalRemaining => 'Gesamt Verbleibend';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target abgeschlossen';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Vorauss. Ende: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'Alle Kaza-Gebete nachgeholt! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Tägliches Tempo';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count Gebete / Tag';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Tägliches Tempo festlegen';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'Wie viele versäumte Gebete holen Sie täglich nach?';

  @override
  String get kazaCalculatorTitle => 'Kaza-Gebete Rechner';

  @override
  String get kazaCalculateByYears => 'Nach Zeit';

  @override
  String get kazaCalculateManual => 'Manuelle Eingabe';

  @override
  String get kazaYearsMissed => 'Versäumte Jahre';

  @override
  String get kazaMonthsMissed => 'Zusätzliche Monate';

  @override
  String get kazaCalculateButton => 'Ziele Speichern';

  @override
  String get kazaWitrLabel => 'Witr';

  @override
  String kazaRemainingCount(Object count) {
    return '$count verbleibend';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'Anzahl $name erledigt';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days Tage pro Gebet (Insgesamt $total Gebete)';
  }

  @override
  String get backupExportTitle => 'Sicherung & Export';

  @override
  String get backupExportSubtitle =>
      'App-Daten sichern oder Kalender exportieren';

  @override
  String get exportBackupJson => 'Sicherungsdaten exportieren (JSON)';

  @override
  String get restoreBackupJson => 'Daten aus Sicherung wiederherstellen';

  @override
  String get exportPrayerScheduleIcs => 'Gebetszeiten exportieren (.ics)';

  @override
  String get exportHolidaysIcs => 'Islamische Feiertage exportieren (.ics)';

  @override
  String get restoreConfirmTitle => 'Daten wiederherstellen?';

  @override
  String get restoreConfirmBody =>
      'Dies stellt Ihre Qadaa-Ziele, Gebetsverlauf, Erinnerungen und Tesbih-Daten wieder her. Fortfahren?';

  @override
  String get restoreSuccess => 'Daten erfolgreich wiederhergestellt!';

  @override
  String get restoreError => 'Ungültiges Sicherungsdateiformat';

  @override
  String get shareOrSave => 'Teilen / Speichern';

  @override
  String get analyticsTab => 'Analysen';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get longestStreak => 'Längste Serie';

  @override
  String get daysUnit => 'Tage';

  @override
  String get monthlyHeatmapTitle => 'Monatliche Erfüllung';

  @override
  String get completionBreakdownTitle => 'Gebetsaufschlüsselung';

  @override
  String get overallConsistency => 'Gesamtkonsistenz';

  @override
  String get totalPrayersCompleted => 'Gesamte Gebete';

  @override
  String get last30Days => 'Letzte 30 Tage';

  @override
  String get allTime => 'Gesamter Zeitraum';

  @override
  String get fastingTitle => 'Fasten';

  @override
  String get suhoorCountdownTitle => 'Zeit bis Suhoor';

  @override
  String get iftarCountdownTitle => 'Zeit bis Iftar';

  @override
  String get fastingTypeRamadan => 'Ramadan Fasten';

  @override
  String get fastingTypeSunnah => 'Sunnah Fasten';

  @override
  String get fastingTypeQadaa => 'Nachhol-Fasten (Qadaa)';

  @override
  String get whiteDaysTitle => 'Weiße Tage (Ayyam al-Beed)';

  @override
  String get mondayThursdayTitle => 'Montag & Donnerstag Sunnah';

  @override
  String get logFastAction => 'Fasten eintragen';

  @override
  String get totalFastsLogged => 'Gesamt gefastete Tage';

  @override
  String get suhoorEndsIn => 'Suhoor endet in';

  @override
  String get iftarIn => 'Iftar in';

  @override
  String get fastingTab => 'Fasten';

  @override
  String get trackTabTitle => 'Verfolgen';

  @override
  String get prayerAnalyticsTitle => 'Gebetsanalysen';

  @override
  String get prayerQadaaTitle => 'Gebete Qadaa';

  @override
  String get iftarTimeLabel => 'Iftar-Zeit';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% gefastet';
  }

  @override
  String get suhoorTickerTitle => 'Sahur-Ticker';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% vergangen';
  }

  @override
  String suhoorWithTime(String time) {
    return 'Sahur ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'Iftar ($time)';
  }

  @override
  String get upcomingSunnahDays => 'Kommende Sunnah-Tage';

  @override
  String get fastingCalendarLogger => 'Fastenkalender-Protokoll';

  @override
  String get removeFastLog => 'Fasteneintrag entfernen';

  @override
  String get calendarWeekStartTitle => 'Kalenderwoche beginnt am';

  @override
  String get calendarWeekStartSunday => 'Sonntag';

  @override
  String get calendarWeekStartMonday => 'Montag';

  @override
  String get hijriDateOffsetTitle => 'Anpassung des Hijri-Datums';

  @override
  String get hijriDateOffsetSubtitle =>
      'Hijri-Datum an lokale Mondsichtungen anpassen';

  @override
  String get showIslamicHolidaysTitle => 'Islamische Feiertage hervorheben';

  @override
  String get showIslamicHolidaysSubtitle =>
      'Besondere Abzeichen für islamische Feiertage anzeigen';

  @override
  String get showFastingBadgesTitle => 'Fastenprotokolle im Kalender anzeigen';

  @override
  String get showFastingBadgesSubtitle =>
      'Abzeichen an Tagen mit gefastetem Protokoll anzeigen';

  @override
  String get defaultCalendarDisplayTitle => 'Standard-Kalenderansicht';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'Standardbasis beim Öffnen des Kalenders';

  @override
  String get showCalendarReminderDotsTitle => 'Erinnerungspunkte anzeigen';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'Punkte auf Tagesfeldern mit Erinnerungen anzeigen';

  @override
  String get calendarSettingsSectionTitle => 'Kalendereinstellungen';

  @override
  String get moonPhaseTitle => 'Mondphase';

  @override
  String moonIllumination(int percent) {
    return '$percent% Beleuchtet';
  }

  @override
  String moonAgeDays(String days) {
    return 'Tag $days des Zyklus';
  }

  @override
  String get moonPhaseNewMoon => 'Neumond (Hilal)';

  @override
  String get moonPhaseWaxingCrescent => 'Zunehmender Sichelmond';

  @override
  String get moonPhaseFirstQuarter => 'Erstes Viertel';

  @override
  String get moonPhaseWaxingGibbous => 'Zunehmender Dreiviertelmond';

  @override
  String get moonPhaseFullMoon => 'Vollmond (Badr)';

  @override
  String get moonPhaseWaningGibbous => 'Abnehmender Dreiviertelmond';

  @override
  String get moonPhaseLastQuarter => 'Letztes Viertel';

  @override
  String get moonPhaseWaningCrescent => 'Abnehmender Sichelmond';

  @override
  String get whiteDaysSubtitle => 'Sunnah-Fasttage (13., 14., 15. Hijri)';

  @override
  String get homeDashboardCardsSectionTitle => 'Startseiten-Karten';

  @override
  String get showCardMoonPhaseTitle => 'Mondphasen-Karte anzeigen';

  @override
  String get showCardMoonPhaseSubtitle =>
      'Mondphase und Weiße Tage Karte anzeigen';

  @override
  String get showCardIftarSuhoorTitle => 'Suhoor & Iftar Karte anzeigen';

  @override
  String get showCardIftarSuhoorSubtitle =>
      'Live-Countdown für Suhoor und Iftar anzeigen';

  @override
  String get showCardDailyWisdomTitle => 'Tägliche Weisheit Karte anzeigen';

  @override
  String get showCardDailyWisdomSubtitle =>
      'Tägliches Hadith- oder Vers-Kärtchen anzeigen';

  @override
  String get showCardUpcomingRemindersTitle =>
      'Anstehende Erinnerungen Karte anzeigen';

  @override
  String get showCardUpcomingRemindersSubtitle =>
      'Karte mit den nächsten 3 Erinnerungen anzeigen';
}
