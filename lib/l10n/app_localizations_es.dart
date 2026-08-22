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
}
