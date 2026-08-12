// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Assistant de Prière';

  @override
  String get tabLocation => 'Lieu';

  @override
  String get tabToday => 'Aujourd\'hui';

  @override
  String get tabDates => 'Dates';

  @override
  String get tooltipToggleLightDark => 'Basculer clair/sombre';

  @override
  String get tooltipRemindersOn => 'Activer les rappels';

  @override
  String get tooltipRemindersOff => 'Désactiver les rappels';

  @override
  String get tooltipPreferences => 'Préférences';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get remainingMinutesUnknown => '-- min';

  @override
  String get homeNoLocationTitle => 'Aucun lieu sélectionné';

  @override
  String get homeNoLocationSubtitle =>
      'Allez à l\'onglet Lieu et enregistrez d\'abord votre district.';

  @override
  String get homeNoPrayerTimesTitle => 'Aucun horaire en cache';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Touchez actualiser pour synchroniser les données annuelles.';

  @override
  String get refresh => 'Actualiser';

  @override
  String todayWithDate(Object date) {
    return 'Aujourd\'hui • $date';
  }

  @override
  String get hijriUnknown => 'Hijri : -';

  @override
  String hijriWithDate(Object date) {
    return 'Hijri : $date';
  }

  @override
  String get reminderSettingsTitle => 'Paramètres de rappel';

  @override
  String get reminderSettingsSubtitle =>
      'Touchez une heure de prière ci-dessus pour configurer le rappel et les minutes avant.';

  @override
  String get tooltipScheduledDebug => 'Débogage des rappels';

  @override
  String get scheduledRemindersDebugTitle => 'Rappels planifiés (Débogage)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Notifications en attente : $count';
  }

  @override
  String get sendTestNotificationNow => 'Envoyer une notification test';

  @override
  String get testNotificationSent => 'Notification test envoyée.';

  @override
  String get statusBarMinutesTitle => 'Minutes dans la barre d\'état';

  @override
  String get statusBarMinutesSubtitle =>
      'Afficher une notification continue des minutes restantes dans la barre d\'état.';

  @override
  String get statusAutoRestoreTitle => 'Restaurer si supprimé';

  @override
  String get statusAutoRestoreSubtitle =>
      'Recréer l\'élément d\'état si l\'utilisateur le ferme.';

  @override
  String get noPendingReminders => 'Aucun rappel en attente.';

  @override
  String get unknownFireTime => 'Heure inconnue';

  @override
  String get pastPrefix => '[PASSÉ] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Activé • À l\'heure + $minutes min avant';
  }

  @override
  String get reminderOnTimeOnly => 'Activé • À l\'heure';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Activé • $minutes min avant';
  }

  @override
  String get reminderOff => 'Rappel désactivé';

  @override
  String get nextPrayerTitle => 'Prochaine prière';

  @override
  String startsIn(Object remaining) {
    return 'Commence dans $remaining';
  }

  @override
  String get selectYourLocation => 'Sélectionnez votre lieu';

  @override
  String get locationHelp =>
      'Utilisez le GPS pour une configuration rapide ou choisissez pays/ville manuellement.';

  @override
  String get useCurrentLocation => 'Utiliser la position actuelle';

  @override
  String get country => 'Pays';

  @override
  String get stateCity => 'État / Ville';

  @override
  String get district => 'District';

  @override
  String get saveLocation => 'Enregistrer le lieu';

  @override
  String selectedLocation(Object location) {
    return 'Sélectionné : $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Sélectionnez d\'abord un lieu pour voir la liste des prières sur 1 an.';

  @override
  String get historyTableTitle => 'Table des heures de prière (Année complète)';

  @override
  String get todayShort => 'Aujourd\'hui';

  @override
  String get dateHeader => 'Date';

  @override
  String get imsak => 'Fajr';

  @override
  String get gunes => 'Lever du soleil';

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
  String get preferencesTitle => 'Préférences';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Par défaut du système';

  @override
  String get themeModeTitle => 'Mode du thème';

  @override
  String get themeSystem => 'Par défaut système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get appBarRemainingTitle =>
      'Texte restant dans la barre d\'application';

  @override
  String get showInTitle => 'Afficher dans le titre';

  @override
  String get showAtRight => 'Afficher à droite';

  @override
  String get showAsSubtitle => 'Afficher en sous-titre';

  @override
  String get hideRemainingText => 'Masquer le texte restant';

  @override
  String get notificationMessageTitle => 'Message de notification';

  @override
  String get notificationMessageShown => 'Affiché';

  @override
  String get notificationMessageHidden => 'Masqué';

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
  String get remindersOnOffTitle => 'Rappels on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Active ou désactive les notifications de prière. Les réglages par prière sont conservés.';

  @override
  String get remindersOn => 'On';

  @override
  String get remindersOff => 'Off';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'Rappel $prayer';
  }

  @override
  String get reminderTypeTitle =>
      'Type de rappel (vous pouvez choisir les deux)';

  @override
  String get onTime => 'À l\'heure';

  @override
  String get before => 'Avant';

  @override
  String get remindBeforePrayerTitle => 'Me rappeler avant la prière';

  @override
  String minutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get custom => 'Perso';

  @override
  String get customMinutes => 'Minutes personnalisées';

  @override
  String get customMinutesHint => 'ex. 12';

  @override
  String get save => 'Enregistrer';

  @override
  String get enableBeforeToSelectMinutes =>
      'Activez \"Avant\" pour choisir les minutes.';

  @override
  String get enterValidPositiveNumber => 'Entrez un nombre positif valide.';

  @override
  String get useValueUpTo240 => 'Utilisez une valeur jusqu\'à 240 minutes.';

  @override
  String get customMinutesSaved => 'Minutes personnalisées enregistrées.';
}
