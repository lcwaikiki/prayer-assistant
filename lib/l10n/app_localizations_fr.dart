// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Assistant de PriÃ¨re';

  @override
  String get tabLocation => 'Lieu';

  @override
  String get tabToday => 'Aujourd\'hui';

  @override
  String get tabDates => 'Dates';

  @override
  String get tabTesbih => 'Perles';

  @override
  String get tooltipToggleLightDark => 'Basculer clair/sombre';

  @override
  String get tooltipRemindersOn => 'Activer les rappels';

  @override
  String get tooltipRemindersOff => 'DÃ©sactiver les rappels';

  @override
  String get tooltipPreferences => 'PrÃ©fÃ©rences';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get remainingMinutesUnknown => '-- min';

  @override
  String get homeNoLocationTitle => 'Aucun lieu sÃ©lectionnÃ©';

  @override
  String get homeNoLocationSubtitle =>
      'Allez Ã  l\'onglet Lieu et enregistrez d\'abord votre district.';

  @override
  String get homeNoPrayerTimesTitle => 'Aucun horaire en cache';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Touchez actualiser pour synchroniser les donnÃ©es annuelles.';

  @override
  String get refresh => 'Actualiser';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaBearing(int degrees) {
    return 'Qibla : $degreesÂ°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Impossible de dÃ©terminer votre position. Activez le GPS et rÃ©essayez.';

  @override
  String get qiblaHeadingUnavailable =>
      'Boussole indisponible - direction fixe affichÃ©e.';

  @override
  String get qiblaPointDevice =>
      'Tournez l\'appareil jusqu\'Ã  ce que la flÃ¨che pointe vers le haut.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Partager les horaires du jour';

  @override
  String get calendarPreviousDay => 'Jour prÃ©cÃ©dent';

  @override
  String get calendarNextDay => 'Jour suivant';

  @override
  String todayWithDate(Object date) {
    return 'Aujourd\'hui â€¢ $date';
  }

  @override
  String get hijriUnknown => 'Hijri : -';

  @override
  String hijriWithDate(Object date) {
    return 'Hijri : $date';
  }

  @override
  String get reminderSettingsTitle => 'ParamÃ¨tres de rappel';

  @override
  String get reminderSettingsSubtitle =>
      'Touchez une heure de priÃ¨re ci-dessus pour configurer le rappel et les minutes avant.';

  @override
  String get tooltipScheduledDebug => 'DÃ©bogage des rappels';

  @override
  String get scheduledRemindersDebugTitle => 'Rappels planifiÃ©s (DÃ©bogage)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Notifications en attente : $count';
  }

  @override
  String get sendTestNotificationNow => 'Envoyer une notification test';

  @override
  String get testNotificationSent => 'Notification test envoyÃ©e.';

  @override
  String get statusBarMinutesTitle => 'Minutes dans la barre d\'Ã©tat';

  @override
  String get statusBarMinutesSubtitle =>
      'Afficher une notification continue des minutes restantes dans la barre d\'Ã©tat.';

  @override
  String get statusAutoRestoreTitle => 'Restaurer si supprimÃ©';

  @override
  String get statusAutoRestoreSubtitle =>
      'RecrÃ©er l\'Ã©lÃ©ment d\'Ã©tat si l\'utilisateur le ferme.';

  @override
  String get noPendingReminders => 'Aucun rappel en attente.';

  @override
  String get unknownFireTime => 'Heure inconnue';

  @override
  String get pastPrefix => '[PASSÃ‰] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'ActivÃ© â€¢ Ã€ l\'heure + $minutes min avant';
  }

  @override
  String get reminderOnTimeOnly => 'ActivÃ© â€¢ Ã€ l\'heure';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'ActivÃ© â€¢ $minutes min avant';
  }

  @override
  String get reminderOff => 'Rappel dÃ©sactivÃ©';

  @override
  String get nextPrayerTitle => 'Prochaine priÃ¨re';

  @override
  String get homeUpcomingRemindersTitle => 'Rappels Ã  venir';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total prières accomplies';
  }

  @override
  String startsIn(Object remaining) {
    return 'Commence dans $remaining';
  }

  @override
  String get selectYourLocation => 'SÃ©lectionnez votre lieu';

  @override
  String get locationHelp =>
      'Utilisez le GPS pour une configuration rapide ou choisissez pays/ville manuellement.';

  @override
  String get useCurrentLocation => 'Utiliser la position actuelle';

  @override
  String get country => 'Pays';

  @override
  String get stateCity => 'Ã‰tat / Ville';

  @override
  String get district => 'District';

  @override
  String get saveLocation => 'Enregistrer le lieu';

  @override
  String selectedLocation(Object location) {
    return 'SÃ©lectionnÃ© : $location';
  }

  @override
  String get historySelectLocationFirst =>
      'SÃ©lectionnez d\'abord un lieu pour voir la liste des priÃ¨res sur 1 an.';

  @override
  String get historyTableTitle =>
      'Table des heures de priÃ¨re (AnnÃ©e complÃ¨te)';

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
  String get preferencesTitle => 'PrÃ©fÃ©rences';

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSystem => 'Par dÃ©faut du systÃ¨me';

  @override
  String get themeModeTitle => 'Mode du thÃ¨me';

  @override
  String get themeSystem => 'Par dÃ©faut systÃ¨me';

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
  String get showAtRight => 'Afficher Ã  droite';

  @override
  String get showAsSubtitle => 'Afficher en sous-titre';

  @override
  String get hideRemainingText => 'Masquer le texte restant';

  @override
  String get notificationMessageTitle => 'Message de notification';

  @override
  String get notificationMessageShown => 'AffichÃ©';

  @override
  String get notificationMessageHidden => 'MasquÃ©';

  @override
  String get widgetTextSizeTitle => 'Taille du texte des widgets';

  @override
  String get widgetTextSizeSubtitle =>
      'Taille du texte utilisÃ©e dans les widgets d\'Ã©cran d\'accueil.';

  @override
  String get widgetTextSizeExtraSmall => 'TrÃ¨s petit';

  @override
  String get widgetTextSizeSmall => 'Petit';

  @override
  String get widgetTextSizeMedium => 'Moyen';

  @override
  String get widgetTextSizeLarge => 'Grand';

  @override
  String get widgetMmssThresholdTitle =>
      'Compte Ã  rebours en secondes du widget';

  @override
  String get widgetMmssThresholdNever => 'Toujours afficher HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS sous $minutes min';
  }

  @override
  String get remindersOnOffTitle => 'Rappels on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Active ou dÃ©sactive les notifications de priÃ¨re. Les rÃ©glages par priÃ¨re sont conservÃ©s.';

  @override
  String get reminderVibrationTitle => 'Vibrer au rappel';

  @override
  String get reminderVibrationSubtitle =>
      'Vibration par pulsations pendant environ 10 secondes lors d\'un rappel.';

  @override
  String get reminderSoundTitle => 'Jouer un son au rappel';

  @override
  String get reminderSoundSubtitle =>
      'Jouer le son de notification lors d\'un rappel.';

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
  String get onTime => 'Ã€ l\'heure';

  @override
  String get before => 'Avant';

  @override
  String get after => 'AprÃ¨s';

  @override
  String get reminderAlertTitle => 'Alerte';

  @override
  String get reminderAlertSubtitle =>
      'NÃ©cessite aussi que l\'interrupteur correspondant soit activÃ© dans PrÃ©fÃ©rences pour alerter rÃ©ellement.';

  @override
  String get vibrateChip => 'Vibrer';

  @override
  String get soundChip => 'Son';

  @override
  String get adhanChip => 'Adhan';

  @override
  String get remindBeforePrayerTitle => 'Me rappeler avant la priÃ¨re';

  @override
  String get remindAfterPrayerTitle => 'Me rappeler aprÃ¨s la priÃ¨re';

  @override
  String minutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get custom => 'Perso';

  @override
  String get customMinutes => 'Minutes personnalisÃ©es';

  @override
  String get customMinutesHint => 'ex. 12';

  @override
  String get save => 'Enregistrer';

  @override
  String get enableBeforeToSelectMinutes =>
      'Activez \"Avant\" pour choisir les minutes.';

  @override
  String get enableAfterToSelectMinutes =>
      'Activez \"AprÃ¨s\" pour choisir les minutes.';

  @override
  String get enterValidPositiveNumber => 'Entrez un nombre positif valide.';

  @override
  String get useValueUpTo240 => 'Utilisez une valeur jusqu\'Ã  240 minutes.';

  @override
  String get customMinutesSaved => 'Minutes personnalisÃ©es enregistrÃ©es.';

  @override
  String get cancel => 'Annuler';

  @override
  String get calendarTabTooltip => 'Calendrier hÃ©girien';

  @override
  String get calendarPreviousMonth => 'Mois prÃ©cÃ©dent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarSwapPrimary => 'Basculer Hijri/GrÃ©gorien';

  @override
  String get calendarShowSecondary => 'Afficher la date secondaire';

  @override
  String get calendarHideSecondary => 'Masquer la date secondaire';

  @override
  String get calendarNoRemindersOnDay => 'Aucun rappel ce jour-lÃ ';

  @override
  String get calendarAddReminder => 'Ajouter un rappel';

  @override
  String get calendarEditReminder => 'Modifier';

  @override
  String get calendarDeleteReminder => 'Supprimer';

  @override
  String get calendarReminderFormTitleNew => 'Nouveau rappel';

  @override
  String get calendarReminderFormTitleEdit => 'Modifier le rappel';

  @override
  String get calendarReminderTitleLabel => 'Titre';

  @override
  String get calendarReminderTitleHint => 'ex. DÃ©but du Ramadan';

  @override
  String get calendarReminderNotesLabel => 'Notes (facultatif)';

  @override
  String get calendarReminderDateTimeLabel => 'Date et heure';

  @override
  String get calendarReminderRecurrenceLabel => 'RÃ©pÃ©tition';

  @override
  String get calendarRecurrenceOnce => 'Une fois';

  @override
  String get calendarRecurrenceDaily => 'Quotidien';

  @override
  String get calendarRecurrenceWeekly => 'Hebdomadaire';

  @override
  String get calendarRecurrenceMonthly => 'Mensuel';

  @override
  String get calendarRecurrenceYearly => 'Annuel';

  @override
  String get calendarRepeatCountLabel => 'Nombre de rÃ©pÃ©titions';

  @override
  String get calendarRepeatCountHelper =>
      'Nombre de fois oÃ¹ le rappel se dÃ©clenche avant de s\'arrÃªter (dÃ©sactivÃ© = rÃ©pÃ©tition illimitÃ©e)';

  @override
  String get calendarRepeatCountError => 'Entrez un nombre entre 2 et 100';

  @override
  String get calendarRepeatDaysLabel => 'RÃ©pÃ©ter le';

  @override
  String get calendarDayOfMonthLabel => 'Jour du mois';

  @override
  String get calendarYearlyMonthLabel => 'Mois';

  @override
  String get calendarYearlyDayLabel => 'Jour';

  @override
  String get calendarMonthlyBasisLabel => 'Base mensuelle';

  @override
  String get calendarYearlyBasisLabel => 'Base annuelle';

  @override
  String get calendarYearlyBasisGregorian => 'GrÃ©gorien';

  @override
  String get calendarYearlyBasisHijri => 'Hijri';

  @override
  String get calendarReminderTitleRequired => 'Entrez un titre';

  @override
  String get calendarAnchorClockTime => 'Date du calendrier';

  @override
  String get calendarAnchorPrayerTime => 'Heure de priÃ¨re';

  @override
  String get calendarSelectPrayer => 'SÃ©lectionner la priÃ¨re';

  @override
  String get calendarOffsetOnTime => 'Ã€ l\'heure';

  @override
  String get calendarOffsetBefore => 'Avant';

  @override
  String get calendarOffsetAfter => 'AprÃ¨s';

  @override
  String get calendarPickAnchorDate => 'Choisir la date';

  @override
  String get datesPrayerTimesTab => 'Heures de priÃ¨re';

  @override
  String get datesCalendarTab => 'Calendrier';

  @override
  String get undo => 'Annuler';

  @override
  String calendarReminderDeleted(Object title) {
    return 'Â« $title Â» supprimÃ©';
  }
}
