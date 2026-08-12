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
  String get widgetRemainingLabel => 'Remaining';

  @override
  String get remindersOnOffTitle => 'Erinnerungen an/aus';

  @override
  String get remindersOnOffSubtitle =>
      'Gebetserinnerungen ein- oder ausschalten. Einstellungen pro Gebet bleiben erhalten.';

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
  String get remindBeforePrayerTitle => 'Erinnere mich vor dem Gebet';

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
  String get enterValidPositiveNumber => 'Gib eine gültige positive Zahl ein.';

  @override
  String get useValueUpTo240 => 'Verwende einen Wert bis 240 Minuten.';

  @override
  String get customMinutesSaved => 'Benutzerdefinierte Minuten gespeichert.';
}
