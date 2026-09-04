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
  String get tabTesbih => 'Perles';

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
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaBearing(int degrees) {
    return 'Qibla : $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Impossible de déterminer votre position. Activez le GPS et réessayez.';

  @override
  String get qiblaHeadingUnavailable =>
      'Boussole indisponible - direction fixe affichée.';

  @override
  String get qiblaPointDevice =>
      'Tournez l\'appareil jusqu\'à ce que la flèche pointe vers le haut.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Partager les horaires du jour';

  @override
  String get calendarPreviousDay => 'Jour précédent';

  @override
  String get calendarNextDay => 'Jour suivant';

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
  String get homeUpcomingRemindersTitle => 'Rappels à venir';

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
  String get widgetTextSizeTitle => 'Taille du texte des widgets';

  @override
  String get widgetTextSizeSubtitle =>
      'Taille du texte utilisée dans les widgets d\'écran d\'accueil.';

  @override
  String get widgetTextSizeExtraSmall => 'Très petit';

  @override
  String get widgetTextSizeSmall => 'Petit';

  @override
  String get widgetTextSizeMedium => 'Moyen';

  @override
  String get widgetTextSizeLarge => 'Grand';

  @override
  String get widgetMmssThresholdTitle =>
      'Compte à rebours en secondes du widget';

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
      'Active ou désactive les notifications de prière. Les réglages par prière sont conservés.';

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
  String get onTime => 'À l\'heure';

  @override
  String get before => 'Avant';

  @override
  String get after => 'Après';

  @override
  String get reminderAlertTitle => 'Alerte';

  @override
  String get reminderAlertSubtitle =>
      'Nécessite aussi que l\'interrupteur correspondant soit activé dans Préférences pour alerter réellement.';

  @override
  String get vibrateChip => 'Vibrer';

  @override
  String get soundChip => 'Son';

  @override
  String get adhanChip => 'Adhan';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total prières accomplies';
  }

  @override
  String get holiday_islamic_new_year => 'Nouvel An Islamique';

  @override
  String get holiday_ashura => 'Achoura';

  @override
  String get holiday_mawlid => 'Mawlid al-Nabi';

  @override
  String get holiday_isra_miraj => 'Isra et Miraj';

  @override
  String get holiday_laylat_barat => 'Lailat al-Baraa';

  @override
  String get holiday_ramadan_first => 'Premier jour de Ramadan';

  @override
  String get holiday_laylat_qadr => 'Lailat al-Qadr';

  @override
  String get holiday_eid_fitr => 'Aïd al-Fitr';

  @override
  String get holiday_arafah => 'Jour d\'Arafah';

  @override
  String get holiday_eid_adha => 'Aïd al-Adha';

  @override
  String get remindBeforePrayerTitle => 'Me rappeler avant la prière';

  @override
  String get remindAfterPrayerTitle => 'Me rappeler après la prière';

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
  String get enableAfterToSelectMinutes =>
      'Activez \"Après\" pour choisir les minutes.';

  @override
  String get enterValidPositiveNumber => 'Entrez un nombre positif valide.';

  @override
  String get useValueUpTo240 => 'Utilisez une valeur jusqu\'à 240 minutes.';

  @override
  String get customMinutesSaved => 'Minutes personnalisées enregistrées.';

  @override
  String get cancel => 'Annuler';

  @override
  String get calendarTabTooltip => 'Calendrier hégirien';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarSwapPrimary => 'Basculer Hijri/Grégorien';

  @override
  String get calendarShowSecondary => 'Afficher la date secondaire';

  @override
  String get calendarHideSecondary => 'Masquer la date secondaire';

  @override
  String get calendarNoRemindersOnDay => 'Aucun rappel ce jour-là';

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
  String get calendarReminderTitleHint => 'ex. Début du Ramadan';

  @override
  String get calendarReminderNotesLabel => 'Notes (facultatif)';

  @override
  String get calendarReminderDateTimeLabel => 'Date et heure';

  @override
  String get calendarReminderRecurrenceLabel => 'Répétition';

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
  String get calendarRepeatCountLabel => 'Nombre de répétitions';

  @override
  String get calendarRepeatCountHelper =>
      'Nombre de fois où le rappel se déclenche avant de s\'arrêter (désactivé = répétition illimitée)';

  @override
  String get calendarRepeatCountError => 'Entrez un nombre entre 2 et 100';

  @override
  String get calendarRepeatDaysLabel => 'Répéter le';

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
  String get calendarYearlyBasisGregorian => 'Grégorien';

  @override
  String get calendarYearlyBasisHijri => 'Hijri';

  @override
  String get calendarReminderTitleRequired => 'Entrez un titre';

  @override
  String get calendarAnchorClockTime => 'Date du calendrier';

  @override
  String get calendarAnchorPrayerTime => 'Heure de prière';

  @override
  String get calendarSelectPrayer => 'Sélectionner la prière';

  @override
  String get calendarOffsetOnTime => 'À l\'heure';

  @override
  String get calendarOffsetBefore => 'Avant';

  @override
  String get calendarOffsetAfter => 'Après';

  @override
  String get calendarPickAnchorDate => 'Choisir la date';

  @override
  String get datesPrayerTimesTab => 'Heures de prière';

  @override
  String get datesCalendarTab => 'Calendrier';

  @override
  String get undo => 'Annuler';

  @override
  String calendarReminderDeleted(Object title) {
    return '« $title » supprimé';
  }

  @override
  String get verseOfTheDay => 'Verset du Jour';

  @override
  String get hadithOfTheDay => 'Hadith du Jour';

  @override
  String get hisnAlMuslimTitle => 'Hisn al-Muslim';

  @override
  String get morningAdhkar => 'Invocations du Matin';

  @override
  String get eveningAdhkar => 'Invocations du Soir';

  @override
  String get afterPrayerAdhkar => 'Après la Prière';

  @override
  String get sleepingAdhkar => 'Avant de Dormir';

  @override
  String get dailyLifeDuas => 'Invocations du Quotidien';

  @override
  String get shareWisdom => 'Partager';

  @override
  String get copyText => 'Copier';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papier';

  @override
  String get searchSupplicationsHint => 'Rechercher des invocations...';

  @override
  String get noSupplicationsFound => 'Aucune invocation trouvée';

  @override
  String get completed => 'Terminé';

  @override
  String get tapToCount => 'Appuyez pour compter';

  @override
  String get tabAll => 'Tous';

  @override
  String get kazaTitle => 'Qadaa';

  @override
  String get kazaSubtitle => 'Suivez et rattrapez vos prières manquées';

  @override
  String get kazaCalculatorWizard => 'Calculateur';

  @override
  String get kazaBatchLogDay => '+1 Journée Complète';

  @override
  String get kazaBatchLogDayTooltip => 'Ajouter 1 à chacune des 6 prières';

  @override
  String get kazaTotalRemaining => 'Total Restant';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target effectuées';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Fin estimée: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'Toutes les prières manquées sont rattrapées! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Rythme Quotidien';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count prières / jour';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Définir le Rythme Quotidien';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'Combien de prières manquées rattrapez-vous par jour?';

  @override
  String get kazaCalculatorTitle => 'Calculateur de Prières Manquées';

  @override
  String get kazaCalculateByYears => 'Par Durée';

  @override
  String get kazaCalculateManual => 'Saisie Manuelle';

  @override
  String get kazaYearsMissed => 'Années Manquées';

  @override
  String get kazaMonthsMissed => 'Mois Supplémentaires';

  @override
  String get kazaCalculateButton => 'Définir les Objectifs';

  @override
  String get kazaWitrLabel => 'Witr';

  @override
  String kazaRemainingCount(Object count) {
    return '$count restantes';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'Nombre effectué pour $name';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days jours par prière ($total prières au total)';
  }

  @override
  String get backupExportTitle => 'Sauvegarde et Exportation';

  @override
  String get backupExportSubtitle =>
      'Sauvegarder les données ou exporter le calendrier';

  @override
  String get exportBackupJson => 'Exporter la sauvegarde (JSON)';

  @override
  String get restoreBackupJson => 'Restaurer les données de la sauvegarde';

  @override
  String get exportPrayerScheduleIcs =>
      'Exporter les horaires de prière (.ics)';

  @override
  String get exportHolidaysIcs => 'Exporter les fêtes islamiques (.ics)';

  @override
  String get restoreConfirmTitle => 'Restaurer les données?';

  @override
  String get restoreConfirmBody =>
      'Vos objectifs Qadaa, l\'historique des prières, les rappels et les données Tesbihat seront restaurés. Continuer?';

  @override
  String get restoreSuccess => 'Données restaurées avec succès!';

  @override
  String get restoreError => 'Format de fichier de sauvegarde non valide';

  @override
  String get shareOrSave => 'Partager / Enregistrer';

  @override
  String get analyticsTab => 'Analyses';

  @override
  String get currentStreak => 'Série Actuelle';

  @override
  String get longestStreak => 'Plus Longue Série';

  @override
  String get daysUnit => 'jours';

  @override
  String get monthlyHeatmapTitle => 'Suivi Mensuel';

  @override
  String get completionBreakdownTitle => 'Répartition des Prières';

  @override
  String get overallConsistency => 'Régularité Globale';

  @override
  String get totalPrayersCompleted => 'Total Prières Enregistrées';

  @override
  String get last30Days => '30 Derniers Jours';

  @override
  String get allTime => 'Tout le Temps';

  @override
  String get fastingTitle => 'Jeûne';

  @override
  String get suhoorCountdownTitle => 'Jusqu\'au Suhoor';

  @override
  String get iftarCountdownTitle => 'Jusqu\'à l\'Iftar';

  @override
  String get fastingTypeRamadan => 'Jeûne du Ramadan';

  @override
  String get fastingTypeSunnah => 'Jeûne Surérogatoire (Sunnah)';

  @override
  String get fastingTypeQadaa => 'Jeûne de Rattrapage (Qadaa)';

  @override
  String get whiteDaysTitle => 'Jours Blancs (13e, 14e, 15e)';

  @override
  String get mondayThursdayTitle => 'Sunnah Lundi & Jeudi';

  @override
  String get logFastAction => 'Enregistrer le Jeûne';

  @override
  String get totalFastsLogged => 'Total Jeûnes Enregistrés';

  @override
  String get suhoorEndsIn => 'Fin du Suhoor dans';

  @override
  String get iftarIn => 'Iftar dans';

  @override
  String get fastingTab => 'Jeûne';

  @override
  String get trackTabTitle => 'Suivi';

  @override
  String get prayerAnalyticsTitle => 'Analyses de Prière';

  @override
  String get prayerQadaaTitle => 'Qadaa de Prière';

  @override
  String get iftarTimeLabel => 'Heure de Iftar';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% jeûné';
  }

  @override
  String get suhoorTickerTitle => 'Compteur Suhur';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% écoulé';
  }

  @override
  String suhoorWithTime(String time) {
    return 'Suhur ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return 'Iftar ($time)';
  }

  @override
  String get upcomingSunnahDays => 'Jours de Sunnah à venir';

  @override
  String get fastingCalendarLogger => 'Journal du calendrier de jeûne';

  @override
  String get removeFastLog => 'Supprimer le suivi du jeûne';

  @override
  String get calendarWeekStartTitle => 'La semaine commence le';

  @override
  String get calendarWeekStartSunday => 'Dimanche';

  @override
  String get calendarWeekStartMonday => 'Lundi';

  @override
  String get hijriDateOffsetTitle => 'Ajustement de la date Hégirienne';

  @override
  String get hijriDateOffsetSubtitle =>
      'Ajuster la date Hégirienne selon la vision de la lune';

  @override
  String get showIslamicHolidaysTitle =>
      'Mettre en valeur les fêtes islamiques';

  @override
  String get showIslamicHolidaysSubtitle =>
      'Afficher des badges sur les jours saints islamiques';

  @override
  String get showFastingBadgesTitle =>
      'Afficher les suivis de jeûne sur le calendrier';

  @override
  String get showFastingBadgesSubtitle =>
      'Afficher des badges sur les dates avec jeûne enregistré';

  @override
  String get defaultCalendarDisplayTitle =>
      'Affichage par défaut du calendrier';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'Base initiale lors de l\'ouverture du calendrier';

  @override
  String get showCalendarReminderDotsTitle => 'Afficher les points de rappel';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'Afficher des points sur les jours avec rappels programmés';

  @override
  String get calendarSettingsSectionTitle => 'Paramètres du calendrier';
}
