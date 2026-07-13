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
  String get tooltipToggleLightDark => 'Cambiar claro/oscuro';

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
  String get imsak => 'Imsak';

  @override
  String get gunes => 'Gunes';

  @override
  String get ogle => 'Dhuhr';

  @override
  String get ikindi => 'Asr';

  @override
  String get aksam => 'Magrib';

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
  String get remindBeforePrayerTitle => 'Recuérdame antes de la oración';

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
  String get enterValidPositiveNumber => 'Introduce un número positivo válido.';

  @override
  String get useValueUpTo240 => 'Usa un valor de hasta 240 minutos.';

  @override
  String get customMinutesSaved => 'Minutos personalizados guardados.';
}
