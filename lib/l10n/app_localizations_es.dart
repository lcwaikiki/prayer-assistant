// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Asistente de Oración';

  @override
  String get tabLocation => 'Ubicación';

  @override
  String get tabToday => 'Hoy';

  @override
  String get tabDates => 'Fechas';

  @override
  String get tabTesbih => 'Cuentas';

  @override
  String get tooltipToggleLightDark => 'Cambiar claro/oscuro';

  @override
  String get tooltipRemindersOn => 'Activar recordatorios';

  @override
  String get tooltipRemindersOff => 'Desactivar recordatorios';

  @override
  String get tooltipPreferences => 'Preferencias';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get remainingMinutesUnknown => '-- min';

  @override
  String get homeNoLocationTitle => 'No hay ubicación seleccionada';

  @override
  String get homeNoLocationSubtitle =>
      'Ve a la pestaña Ubicación y guarda primero tu distrito.';

  @override
  String get homeNoPrayerTimesTitle => 'No hay horarios en caché';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Toca actualizar para sincronizar datos anuales.';

  @override
  String get refresh => 'Actualizar';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String qiblaBearing(int degrees) {
    return 'Qibla: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'No se pudo determinar tu ubicación. Activa el GPS e inténtalo de nuevo.';

  @override
  String get qiblaHeadingUnavailable =>
      'Brújula no disponible - mostrando dirección fija.';

  @override
  String get qiblaPointDevice =>
      'Gira el dispositivo hasta que la flecha apunte hacia arriba.';

  @override
  String get qiblaKaabaShort => 'Qibla';

  @override
  String get shareTodayTimes => 'Compartir horarios de hoy';

  @override
  String get calendarPreviousDay => 'Día anterior';

  @override
  String get calendarNextDay => 'Día siguiente';

  @override
  String todayWithDate(Object date) {
    return 'Hoy • $date';
  }

  @override
  String get hijriUnknown => 'Hégira: -';

  @override
  String hijriWithDate(Object date) {
    return 'Hégira: $date';
  }

  @override
  String get reminderSettingsTitle => 'Ajustes de recordatorio';

  @override
  String get reminderSettingsSubtitle =>
      'Toca cualquier hora de oración para configurar recordatorios y minutos antes.';

  @override
  String get tooltipScheduledDebug => 'Depuración de recordatorios';

  @override
  String get scheduledRemindersDebugTitle =>
      'Recordatorios programados (Depuración)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Notificaciones pendientes: $count';
  }

  @override
  String get sendTestNotificationNow => 'Enviar notificación de prueba';

  @override
  String get testNotificationSent => 'Notificación de prueba enviada.';

  @override
  String get statusBarMinutesTitle => 'Minutos en barra de estado';

  @override
  String get statusBarMinutesSubtitle =>
      'Mostrar notificación persistente de minutos restantes en la barra de estado.';

  @override
  String get statusAutoRestoreTitle => 'Restaurar al descartarse';

  @override
  String get statusAutoRestoreSubtitle =>
      'Recrear el elemento de estado si el usuario lo descarta.';

  @override
  String get noPendingReminders => 'No hay recordatorios pendientes.';

  @override
  String get unknownFireTime => 'Hora desconocida';

  @override
  String get pastPrefix => '[PASADO] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Activado • En hora + $minutes min antes';
  }

  @override
  String get reminderOnTimeOnly => 'Activado • En hora';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Activado • $minutes min antes';
  }

  @override
  String get reminderOff => 'Recordatorio desactivado';

  @override
  String get nextPrayerTitle => 'Próxima oración';

  @override
  String get homeUpcomingRemindersTitle => 'Próximos recordatorios';

  @override
  String startsIn(Object remaining) {
    return 'Comienza en $remaining';
  }

  @override
  String get selectYourLocation => 'Selecciona tu ubicación';

  @override
  String get locationHelp =>
      'Usa GPS para una configuración rápida o elige país/ciudad manualmente.';

  @override
  String get useCurrentLocation => 'Usar ubicación actual';

  @override
  String get country => 'País';

  @override
  String get stateCity => 'Estado / Ciudad';

  @override
  String get district => 'Distrito';

  @override
  String get saveLocation => 'Guardar ubicación';

  @override
  String selectedLocation(Object location) {
    return 'Seleccionado: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Selecciona primero una ubicación para ver la lista anual de oraciones.';

  @override
  String get historyTableTitle => 'Tabla de Horarios de Oración (Año completo)';

  @override
  String get todayShort => 'Hoy';

  @override
  String get dateHeader => 'Fecha';

  @override
  String get imsak => 'Fajr';

  @override
  String get gunes => 'Amanecer';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Magreb';

  @override
  String get yatsi => 'Isha';

  @override
  String get hijriHeader => 'Hégira';

  @override
  String get preferencesTitle => 'Preferencias';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSystem => 'Predeterminado del sistema';

  @override
  String get themeModeTitle => 'Modo de tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get appBarRemainingTitle => 'Texto restante en barra superior';

  @override
  String get showInTitle => 'Mostrar en título';

  @override
  String get showAtRight => 'Mostrar a la derecha';

  @override
  String get showAsSubtitle => 'Mostrar como subtítulo';

  @override
  String get hideRemainingText => 'Ocultar texto restante';

  @override
  String get notificationMessageTitle => 'Mensaje de notificación';

  @override
  String get notificationMessageShown => 'Visible';

  @override
  String get notificationMessageHidden => 'Oculto';

  @override
  String get widgetSettingsSectionTitle => 'Ajustes del widget';

  @override
  String get widgetTextSizeTitle => 'Tamaño de texto del widget';

  @override
  String get widgetTextSizeSubtitle =>
      'Tamaño de texto usado en los widgets de la pantalla de inicio.';

  @override
  String get widgetTextSizeExtraSmall => 'Muy pequeño';

  @override
  String get widgetTextSizeSmall => 'Pequeño';

  @override
  String get widgetTextSizeMedium => 'Mediano';

  @override
  String get widgetTextSizeLarge => 'Grande';

  @override
  String get widgetMmssThresholdTitle => 'Cuenta atrás en segundos del widget';

  @override
  String get widgetThemeTitle => 'Widget background theme';

  @override
  String get widgetThemeSystem => 'System';

  @override
  String get widgetThemeLight => 'Light';

  @override
  String get widgetThemeDark => 'Dark';

  @override
  String get widgetThemeTransparent => 'Transparent';

  @override
  String get widgetCalendarDisplayTitle => 'Widget calendar date display';

  @override
  String get widgetCalendarDisplayBoth => 'Both (Hijri & Gregorian)';

  @override
  String get widgetCalendarDisplayHijri => 'Hijri only';

  @override
  String get widgetCalendarDisplayGregorian => 'Gregorian only';

  @override
  String get widgetMmssThresholdNever => 'Mostrar siempre HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'MM:SS por debajo de $minutes min';
  }

  @override
  String get remindersOnOffTitle => 'Recordatorios on/off';

  @override
  String get remindersOnOffSubtitle =>
      'Activa o desactiva las notificaciones de oración. Se conservan los ajustes por oración.';

  @override
  String get reminderVibrationTitle => 'Vibrar al recordar';

  @override
  String get reminderVibrationSubtitle =>
      'Vibración por pulsos durante unos 10 segundos cuando se active un recordatorio.';

  @override
  String get reminderSoundTitle => 'Reproducir sonido al recordar';

  @override
  String get reminderSoundSubtitle =>
      'Reproduce el sonido de notificación cuando se active un recordatorio.';

  @override
  String get remindersOn => 'On';

  @override
  String get remindersOff => 'Off';

  @override
  String reminderScreenTitle(Object prayer) {
    return 'Recordatorio de $prayer';
  }

  @override
  String get reminderTypeTitle =>
      'Tipo de recordatorio (puedes seleccionar ambos)';

  @override
  String get onTime => 'En hora';

  @override
  String get before => 'Antes';

  @override
  String get after => 'Después';

  @override
  String get reminderAlertTitle => 'Alerta';

  @override
  String get reminderAlertSubtitle =>
      'También requiere que el interruptor correspondiente esté activado en Preferencias para alertar realmente.';

  @override
  String get vibrateChip => 'Vibrar';

  @override
  String get soundChip => 'Sonido';

  @override
  String get adhanChip => 'Adhan';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total oraciones completadas';
  }

  @override
  String get holiday_islamic_new_year => 'Año Nuevo Islámico';

  @override
  String get holiday_ashura => 'Ashura';

  @override
  String get holiday_mawlid => 'Mawlid al-Nabi';

  @override
  String get holiday_isra_miraj => 'Isra y Miraj';

  @override
  String get holiday_laylat_barat => 'Lailat al-Baraat';

  @override
  String get holiday_ramadan_first => 'Primer día de Ramadán';

  @override
  String get holiday_laylat_qadr => 'Lailat al-Qadr';

  @override
  String get holiday_eid_fitr => 'Eid al-Fitr';

  @override
  String get holiday_arafah => 'Día de Arafah';

  @override
  String get holiday_eid_adha => 'Eid al-Adha';

  @override
  String get remindBeforePrayerTitle => 'Recuérdame antes de la oración';

  @override
  String get remindAfterPrayerTitle => 'Recuérdame después de la oración';

  @override
  String minutesValue(Object minutes) {
    return '$minutes min';
  }

  @override
  String get custom => 'Personalizado';

  @override
  String get customMinutes => 'Minutos personalizados';

  @override
  String get customMinutesHint => 'p. ej. 12';

  @override
  String get save => 'Guardar';

  @override
  String get enableBeforeToSelectMinutes =>
      'Activa \"Antes\" para elegir minutos.';

  @override
  String get enableAfterToSelectMinutes =>
      'Activa \"Después\" para elegir minutos.';

  @override
  String get enterValidPositiveNumber => 'Introduce un número positivo válido.';

  @override
  String get useValueUpTo240 => 'Usa un valor de hasta 240 minutos.';

  @override
  String get customMinutesSaved => 'Minutos personalizados guardados.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get calendarTabTooltip => 'Calendario Hégira';

  @override
  String get calendarPreviousMonth => 'Mes anterior';

  @override
  String get calendarNextMonth => 'Mes siguiente';

  @override
  String get calendarSwapPrimary => 'Cambiar Hégira/Gregoriano';

  @override
  String get calendarShowSecondary => 'Mostrar fecha secundaria';

  @override
  String get calendarHideSecondary => 'Ocultar fecha secundaria';

  @override
  String get calendarNoRemindersOnDay => 'No hay recordatorios en este día';

  @override
  String get calendarAddReminder => 'Añadir recordatorio';

  @override
  String get calendarEditReminder => 'Editar';

  @override
  String get calendarDeleteReminder => 'Eliminar';

  @override
  String get calendarReminderFormTitleNew => 'Nuevo recordatorio';

  @override
  String get calendarReminderFormTitleEdit => 'Editar recordatorio';

  @override
  String get calendarReminderTitleLabel => 'Título';

  @override
  String get calendarReminderTitleHint => 'p. ej. Comienza el Ramadán';

  @override
  String get calendarReminderNotesLabel => 'Notas (opcional)';

  @override
  String get calendarReminderDateTimeLabel => 'Fecha y hora';

  @override
  String get calendarReminderRecurrenceLabel => 'Repetir';

  @override
  String get calendarRecurrenceOnce => 'Una vez';

  @override
  String get calendarRecurrenceDaily => 'Diario';

  @override
  String get calendarRecurrenceWeekly => 'Semanal';

  @override
  String get calendarRecurrenceMonthly => 'Mensual';

  @override
  String get calendarRecurrenceYearly => 'Anual';

  @override
  String get calendarRepeatCountLabel => 'Número de repeticiones';

  @override
  String get calendarRepeatCountHelper =>
      'Cuántas veces se activa el recordatorio antes de detenerse (desactivado = se repite siempre)';

  @override
  String get calendarRepeatCountError => 'Introduce un número del 2 al 100';

  @override
  String get calendarRepeatDaysLabel => 'Repetir en';

  @override
  String get calendarDayOfMonthLabel => 'Día del mes';

  @override
  String get calendarYearlyMonthLabel => 'Mes';

  @override
  String get calendarYearlyDayLabel => 'Día';

  @override
  String get calendarMonthlyBasisLabel => 'Base mensual';

  @override
  String get calendarYearlyBasisLabel => 'Base anual';

  @override
  String get calendarYearlyBasisGregorian => 'Gregoriano';

  @override
  String get calendarYearlyBasisHijri => 'Hégira';

  @override
  String get calendarReminderTitleRequired => 'Introduce un título';

  @override
  String get calendarAnchorClockTime => 'Fecha del calendario';

  @override
  String get calendarAnchorPrayerTime => 'Hora de oración';

  @override
  String get calendarSelectPrayer => 'Selecciona la oración';

  @override
  String get calendarOffsetOnTime => 'En hora';

  @override
  String get calendarOffsetBefore => 'Antes';

  @override
  String get calendarOffsetAfter => 'Después';

  @override
  String get calendarPickAnchorDate => 'Elegir fecha';

  @override
  String get datesPrayerTimesTab => 'Horarios de oración';

  @override
  String get datesCalendarTab => 'Calendario';

  @override
  String get undo => 'Deshacer';

  @override
  String calendarReminderDeleted(Object title) {
    return '\"$title\" eliminado';
  }

  @override
  String get verseOfTheDay => 'Versículo del Día';

  @override
  String get hadithOfTheDay => 'Hadiz del Día';

  @override
  String get hisnAlMuslimTitle => 'Hisn al-Muslim';

  @override
  String get morningAdhkar => 'Adhkar de la Mañana';

  @override
  String get eveningAdhkar => 'Adhkar de la Tarde';

  @override
  String get afterPrayerAdhkar => 'Después de la Oración';

  @override
  String get sleepingAdhkar => 'Antes de Dormir';

  @override
  String get dailyLifeDuas => 'Súplicas Diarias';

  @override
  String get shareWisdom => 'Compartir';

  @override
  String get copyText => 'Copiar';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String get searchSupplicationsHint => 'Buscar súplicas...';

  @override
  String get noSupplicationsFound => 'No se encontraron súplicas';

  @override
  String get completed => 'Completado';

  @override
  String get tapToCount => 'Toca para contar';

  @override
  String get tabAll => 'Todos';

  @override
  String get kazaTitle => 'Qadaa';

  @override
  String get kazaSubtitle => 'Rastrea y recupera las oraciones pasadas';

  @override
  String get kazaCalculatorWizard => 'Calculadora';

  @override
  String get kazaBatchLogDay => '+1 Día Completo';

  @override
  String get kazaBatchLogDayTooltip => 'Incrementa en 1 todas las 6 oraciones';

  @override
  String get kazaTotalRemaining => 'Total Restante';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed / $target completadas';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Est. Finalización: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      '¡Todas las oraciones Kaza completadas! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Ritmo Diario';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count oraciones / día';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Establecer Ritmo Diario';

  @override
  String get kazaSetPaceDialogSubtitle =>
      '¿Cuántas oraciones Kaza realizas al día?';

  @override
  String get kazaCalculatorTitle => 'Calculadora de Oraciones Kaza';

  @override
  String get kazaCalculateByYears => 'Por Tiempo';

  @override
  String get kazaCalculateManual => 'Valores Manuales';

  @override
  String get kazaYearsMissed => 'Años Perdidos';

  @override
  String get kazaMonthsMissed => 'Meses Adicionales';

  @override
  String get kazaCalculateButton => 'Establecer Metas';

  @override
  String get kazaWitrLabel => 'Witr';

  @override
  String kazaRemainingCount(Object count) {
    return '$count restantes';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'Cantidad realizada de $name';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days días por oración ($total oraciones en total)';
  }

  @override
  String get backupExportTitle => 'Copia de seguridad y exportación';

  @override
  String get backupExportSubtitle => 'Respaldar datos o exportar horarios';

  @override
  String get exportBackupJson => 'Exportar copia de seguridad (JSON)';

  @override
  String get restoreBackupJson => 'Restaurar datos desde copia';

  @override
  String get exportPrayerScheduleIcs => 'Exportar horarios de oración (.ics)';

  @override
  String get exportHolidaysIcs => 'Exportar festividades islámicas (.ics)';

  @override
  String get restoreConfirmTitle => '¿Restaurar datos de la aplicación?';

  @override
  String get restoreConfirmBody =>
      'Se restaurarán sus objetivos de Qadaa, historial de oración, recordatorios y Tesbihat. ¿Continuar?';

  @override
  String get restoreSuccess => '¡Datos restaurados con éxito!';

  @override
  String get restoreError => 'Formato de archivo de respaldo no válido';

  @override
  String get shareOrSave => 'Compartir / Guardar';

  @override
  String get analyticsTab => 'Análisis';

  @override
  String get currentStreak => 'Racha Actual';

  @override
  String get longestStreak => 'Racha Más Larga';

  @override
  String get daysUnit => 'días';

  @override
  String get monthlyHeatmapTitle => 'Cumplimiento Mensual';

  @override
  String get completionBreakdownTitle => 'Desglose de Oraciones';

  @override
  String get overallConsistency => 'Consistencia General';

  @override
  String get totalPrayersCompleted => 'Total de Oraciones';

  @override
  String get last30Days => 'Últimos 30 Días';

  @override
  String get allTime => 'Todo el Tiempo';

  @override
  String get fastingTitle => 'Ayuno';

  @override
  String get suhoorCountdownTitle => 'Tiempo hasta Suhoor';

  @override
  String get iftarCountdownTitle => 'Tiempo hasta Iftar';

  @override
  String get fastingTypeRamadan => 'Ayuno de Ramadan';

  @override
  String get fastingTypeSunnah => 'Ayuno Sunnah';

  @override
  String get fastingTypeQadaa => 'Ayuno de Compensación (Qadaa)';

  @override
  String get whiteDaysTitle => 'Días Blancos (13, 14, 15)';

  @override
  String get mondayThursdayTitle => 'Sunnah de Lunes y Jueves';

  @override
  String get logFastAction => 'Registrar Ayuno';

  @override
  String get totalFastsLogged => 'Total de Ayunos Registrados';

  @override
  String get suhoorEndsIn => 'Suhoor termina en';

  @override
  String get iftarIn => 'Iftar en';

  @override
  String get fastingTab => 'Ayuno';

  @override
  String get trackTabTitle => 'Seguimiento';

  @override
  String get prayerAnalyticsTitle => 'Análisis de Oración';

  @override
  String get prayerQadaaTitle => 'Qadaa de Oración';

  @override
  String get iftarTimeLabel => 'Hora de Iftar';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% ayunado';
  }

  @override
  String get suhoorTickerTitle => 'Contador de Suhur';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% transcurrido';
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
  String get upcomingSunnahDays => 'Próximos días de Sunnah';

  @override
  String get fastingCalendarLogger => 'Registro del calendario de ayuno';

  @override
  String get removeFastLog => 'Eliminar registro de ayuno';

  @override
  String get calendarWeekStartTitle => 'La semana del calendario empieza en';

  @override
  String get calendarWeekStartSunday => 'Domingo';

  @override
  String get calendarWeekStartMonday => 'Lunes';

  @override
  String get hijriDateOffsetTitle => 'Ajuste de fecha Híyri';

  @override
  String get hijriDateOffsetSubtitle =>
      'Ajustar fecha Híyri según avistamiento local de la luna';

  @override
  String get showIslamicHolidaysTitle => 'Destacar festividades islámicas';

  @override
  String get showIslamicHolidaysSubtitle =>
      'Mostrar insignias en días sagrados islámicos';

  @override
  String get showFastingBadgesTitle =>
      'Mostrar registros de ayuno en el calendario';

  @override
  String get showFastingBadgesSubtitle =>
      'Mostrar insignias en fechas con ayunos registrados';

  @override
  String get defaultCalendarDisplayTitle =>
      'Vista de calendario predeterminada';

  @override
  String get defaultCalendarDisplaySubtitle =>
      'Base inicial al abrir el calendario';

  @override
  String get showCalendarReminderDotsTitle => 'Mostrar puntos de recordatorios';

  @override
  String get showCalendarReminderDotsSubtitle =>
      'Mostrar puntos en celdas con recordatorios programados';

  @override
  String get calendarSettingsSectionTitle => 'Ajustes del calendario';
}
