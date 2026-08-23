// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Молитвенный помощник';

  @override
  String get tabLocation => 'Местоположение';

  @override
  String get tabToday => 'Сегодня';

  @override
  String get tabDates => 'Даты';

  @override
  String get tabTesbih => 'Тасбих';

  @override
  String get tooltipToggleLightDark => 'Переключить светлую/тёмную тему';

  @override
  String get tooltipRemindersOn => 'Включить напоминания';

  @override
  String get tooltipRemindersOff => 'Выключить напоминания';

  @override
  String get tooltipPreferences => 'Настройки';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes мин';
  }

  @override
  String get remainingMinutesUnknown => '-- мин';

  @override
  String get homeNoLocationTitle => 'Местоположение не выбрано';

  @override
  String get homeNoLocationSubtitle =>
      'Перейдите на вкладку «Местоположение» и сохраните ваш район.';

  @override
  String get homeNoPrayerTimesTitle => 'Нет времени намаза в кэше';

  @override
  String get homeNoPrayerTimesSubtitle =>
      'Нажмите «Обновить», чтобы загрузить данные на год.';

  @override
  String get refresh => 'Обновить';

  @override
  String get qiblaTitle => 'Кибла';

  @override
  String qiblaBearing(int degrees) {
    return 'Кибла: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable =>
      'Не удалось определить местоположение. Включите GPS и попробуйте снова.';

  @override
  String get qiblaHeadingUnavailable =>
      'Компас недоступен - показано фиксированное направление.';

  @override
  String get qiblaPointDevice =>
      'Поверните устройство, пока стрелка не укажет вверх.';

  @override
  String get qiblaKaabaShort => 'Кибла';

  @override
  String get shareTodayTimes => 'Поделиться временем на сегодня';

  @override
  String get calendarPreviousDay => 'Предыдущий день';

  @override
  String get calendarNextDay => 'Следующий день';

  @override
  String todayWithDate(Object date) {
    return 'Сегодня • $date';
  }

  @override
  String get hijriUnknown => 'Хиджра: -';

  @override
  String hijriWithDate(Object date) {
    return 'Хиджра: $date';
  }

  @override
  String get reminderSettingsTitle => 'Настройки напоминаний';

  @override
  String get reminderSettingsSubtitle =>
      'Нажмите на время намаза выше, чтобы настроить напоминание и минуты до.';

  @override
  String get tooltipScheduledDebug => 'Отладка запланированных напоминаний';

  @override
  String get scheduledRemindersDebugTitle =>
      'Запланированные напоминания (отладка)';

  @override
  String pendingNotificationsCount(Object count) {
    return 'Ожидающие уведомления: $count';
  }

  @override
  String get sendTestNotificationNow => 'Отправить тестовое уведомление сейчас';

  @override
  String get testNotificationSent => 'Тестовое уведомление отправлено.';

  @override
  String get statusBarMinutesTitle => 'Минуты в строке состояния';

  @override
  String get statusBarMinutesSubtitle =>
      'Показывать постоянное уведомление об оставшихся минутах в строке состояния.';

  @override
  String get statusAutoRestoreTitle => 'Автовосстановление при закрытии';

  @override
  String get statusAutoRestoreSubtitle =>
      'Повторно создать элемент статуса, если пользователь его отклонил.';

  @override
  String get noPendingReminders => 'Нет ожидающих напоминаний.';

  @override
  String get unknownFireTime => 'Неизвестное время срабатывания';

  @override
  String get pastPrefix => '[ПРОШЛОЕ] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'Вкл • Вовремя + $minutes мин до';
  }

  @override
  String get reminderOnTimeOnly => 'Вкл • Вовремя';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'Вкл • $minutes мин до';
  }

  @override
  String get reminderOff => 'Напоминание выключено';

  @override
  String get nextPrayerTitle => 'Следующий намаз';

  @override
  String get homeUpcomingRemindersTitle => 'Предстоящие напоминания';

  @override
  String startsIn(Object remaining) {
    return 'Начнётся через $remaining';
  }

  @override
  String get selectYourLocation => 'Выберите местоположение';

  @override
  String get locationHelp =>
      'Используйте GPS для быстрой настройки или выберите страну/город вручную.';

  @override
  String get useCurrentLocation => 'Использовать текущее местоположение';

  @override
  String get country => 'Страна';

  @override
  String get stateCity => 'Регион / Город';

  @override
  String get district => 'Район';

  @override
  String get saveLocation => 'Сохранить местоположение';

  @override
  String selectedLocation(Object location) {
    return 'Выбрано: $location';
  }

  @override
  String get historySelectLocationFirst =>
      'Сначала выберите местоположение, чтобы увидеть список намазов за год.';

  @override
  String get historyTableTitle => 'Таблица времени намаза (весь год)';

  @override
  String get todayShort => 'Сегодня';

  @override
  String get dateHeader => 'Дата';

  @override
  String get imsak => 'Фаджр';

  @override
  String get gunes => 'Восход';

  @override
  String get ogle => 'Зухр';

  @override
  String get ikindi => 'Аср';

  @override
  String get aksam => 'Магриб';

  @override
  String get yatsi => 'Иша';

  @override
  String get hijriHeader => 'Хиджра';

  @override
  String get preferencesTitle => 'Настройки';

  @override
  String get languageTitle => 'Язык';

  @override
  String get languageSystem => 'Системный по умолчанию';

  @override
  String get themeModeTitle => 'Тема оформления';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get appBarRemainingTitle => 'Текст оставшегося времени в заголовке';

  @override
  String get showInTitle => 'Показывать в заголовке';

  @override
  String get showAtRight => 'Показывать справа';

  @override
  String get showAsSubtitle => 'Показывать как подзаголовок';

  @override
  String get hideRemainingText => 'Скрыть текст оставшегося времени';

  @override
  String get notificationMessageTitle => 'Сообщение уведомления';

  @override
  String get notificationMessageShown => 'Показывать';

  @override
  String get notificationMessageHidden => 'Скрыто';

  @override
  String get widgetTextSizeTitle => 'Размер текста виджета';

  @override
  String get widgetTextSizeSubtitle =>
      'Размер текста, используемый в виджетах главного экрана.';

  @override
  String get widgetTextSizeExtraSmall => 'Очень маленький';

  @override
  String get widgetTextSizeSmall => 'Маленький';

  @override
  String get widgetTextSizeMedium => 'Средний';

  @override
  String get widgetTextSizeLarge => 'Большой';

  @override
  String get widgetMmssThresholdTitle => 'Секундный отсчёт в виджете';

  @override
  String get widgetMmssThresholdNever => 'Всегда показывать ЧЧ:ММ';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return 'ММ:СС менее $minutes мин';
  }

  @override
  String get remindersOnOffTitle => 'Напоминания вкл/выкл';

  @override
  String get remindersOnOffSubtitle =>
      'Включите или выключите уведомления о намазе. Настройки для каждого намаза сохраняются.';

  @override
  String get reminderVibrationTitle => 'Вибрация при напоминании';

  @override
  String get reminderVibrationSubtitle =>
      'Пульсирующая вибрация около 10 секунд при срабатывании напоминания.';

  @override
  String get reminderSoundTitle => 'Звук при напоминании';

  @override
  String get reminderSoundSubtitle =>
      'Воспроизводить звук уведомления при срабатывании напоминания.';

  @override
  String get remindersOn => 'Вкл';

  @override
  String get remindersOff => 'Выкл';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer — напоминание';
  }

  @override
  String get reminderTypeTitle => 'Тип напоминания (можно выбрать оба)';

  @override
  String get onTime => 'Вовремя';

  @override
  String get before => 'До';

  @override
  String get after => 'После';

  @override
  String get reminderAlertTitle => 'Сигнал';

  @override
  String get reminderAlertSubtitle =>
      'Для фактического сигнала также нужен включённый переключатель в настройках.';

  @override
  String get vibrateChip => 'Вибрация';

  @override
  String get soundChip => 'Звук';

  @override
  String get adhanChip => 'Азан';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total намазов выполнено';
  }

  @override
  String get holiday_islamic_new_year => 'Исламский Новый год';

  @override
  String get holiday_ashura => 'Ашура';

  @override
  String get holiday_mawlid => 'Маулид ан-Наби';

  @override
  String get holiday_isra_miraj => 'Исра и Мирадж';

  @override
  String get holiday_laylat_barat => 'Ляйлят аль-Бараат';

  @override
  String get holiday_ramadan_first => 'Первый день Рамадана';

  @override
  String get holiday_laylat_qadr => 'Ляйлят аль-Кадр';

  @override
  String get holiday_eid_fitr => 'Ураза-байрам';

  @override
  String get holiday_arafah => 'День Арафа';

  @override
  String get holiday_eid_adha => 'Курбан-байрам';

  @override
  String get remindBeforePrayerTitle => 'Напомнить перед намазом';

  @override
  String get remindAfterPrayerTitle => 'Напомнить после намаза';

  @override
  String minutesValue(Object minutes) {
    return '$minutes мин';
  }

  @override
  String get custom => 'Своё';

  @override
  String get customMinutes => 'Свои минуты';

  @override
  String get customMinutesHint => 'например 12';

  @override
  String get save => 'Сохранить';

  @override
  String get enableBeforeToSelectMinutes =>
      'Включите «До», чтобы выбрать минуты.';

  @override
  String get enableAfterToSelectMinutes =>
      'Включите «После», чтобы выбрать минуты.';

  @override
  String get enterValidPositiveNumber =>
      'Введите корректное положительное число.';

  @override
  String get useValueUpTo240 => 'Используйте значение до 240 минут.';

  @override
  String get customMinutesSaved => 'Свои минуты сохранены.';

  @override
  String get cancel => 'Отмена';

  @override
  String get calendarTabTooltip => 'Хиджра-календарь';

  @override
  String get calendarPreviousMonth => 'Предыдущий месяц';

  @override
  String get calendarNextMonth => 'Следующий месяц';

  @override
  String get calendarSwapPrimary => 'Переключить Хиджра/Григорианский';

  @override
  String get calendarShowSecondary => 'Показать вторичную дату';

  @override
  String get calendarHideSecondary => 'Скрыть вторичную дату';

  @override
  String get calendarNoRemindersOnDay => 'Нет напоминаний на этот день';

  @override
  String get calendarAddReminder => 'Добавить напоминание';

  @override
  String get calendarEditReminder => 'Изменить';

  @override
  String get calendarDeleteReminder => 'Удалить';

  @override
  String get calendarReminderFormTitleNew => 'Новое напоминание';

  @override
  String get calendarReminderFormTitleEdit => 'Изменить напоминание';

  @override
  String get calendarReminderTitleLabel => 'Название';

  @override
  String get calendarReminderTitleHint => 'например, начало Рамадана';

  @override
  String get calendarReminderNotesLabel => 'Заметки (необязательно)';

  @override
  String get calendarReminderDateTimeLabel => 'Дата и время';

  @override
  String get calendarReminderRecurrenceLabel => 'Повтор';

  @override
  String get calendarRecurrenceOnce => 'Один раз';

  @override
  String get calendarRecurrenceDaily => 'Ежедневно';

  @override
  String get calendarRecurrenceWeekly => 'Еженедельно';

  @override
  String get calendarRecurrenceMonthly => 'Ежемесячно';

  @override
  String get calendarRecurrenceYearly => 'Ежегодно';

  @override
  String get calendarRepeatCountLabel => 'Количество повторений';

  @override
  String get calendarRepeatCountHelper =>
      'Сколько раз напоминание сработает перед остановкой (выкл = повторять бесконечно)';

  @override
  String get calendarRepeatCountError => 'Введите число от 2 до 100';

  @override
  String get calendarRepeatDaysLabel => 'Повторять в';

  @override
  String get calendarDayOfMonthLabel => 'День месяца';

  @override
  String get calendarYearlyMonthLabel => 'Месяц';

  @override
  String get calendarYearlyDayLabel => 'День';

  @override
  String get calendarMonthlyBasisLabel => 'Основа месяца';

  @override
  String get calendarYearlyBasisLabel => 'Основа года';

  @override
  String get calendarYearlyBasisGregorian => 'Григорианский';

  @override
  String get calendarYearlyBasisHijri => 'Хиджра';

  @override
  String get calendarReminderTitleRequired => 'Введите название';

  @override
  String get calendarAnchorClockTime => 'Календарная дата';

  @override
  String get calendarAnchorPrayerTime => 'Время намаза';

  @override
  String get calendarSelectPrayer => 'Выберите намаз';

  @override
  String get calendarOffsetOnTime => 'Вовремя';

  @override
  String get calendarOffsetBefore => 'До';

  @override
  String get calendarOffsetAfter => 'После';

  @override
  String get calendarPickAnchorDate => 'Выбрать дату';

  @override
  String get datesPrayerTimesTab => 'Время намаза';

  @override
  String get datesCalendarTab => 'Календарь';

  @override
  String get undo => 'Отменить';

  @override
  String calendarReminderDeleted(Object title) {
    return '«$title» удалено';
  }

  @override
  String get verseOfTheDay => 'Аят дня';

  @override
  String get hadithOfTheDay => 'Хадис дня';

  @override
  String get hisnAlMuslimTitle => 'Крепость мусульманина';

  @override
  String get morningAdhkar => 'Утренние азкары';

  @override
  String get eveningAdhkar => 'Вечерние азкары';

  @override
  String get afterPrayerAdhkar => 'Азкары بعد намаза';

  @override
  String get sleepingAdhkar => 'Азкары перед сном';

  @override
  String get dailyLifeDuas => 'Повседневные дуа';

  @override
  String get shareWisdom => 'Поделиться';

  @override
  String get copyText => 'Копировать';

  @override
  String get copiedToClipboard => 'Скопировано в буфер';

  @override
  String get searchSupplicationsHint => 'Поиск мольб...';

  @override
  String get noSupplicationsFound => 'Мольбы не найдены';

  @override
  String get completed => 'Завершено';

  @override
  String get tapToCount => 'Нажмите для счета';

  @override
  String get tabAll => 'Все';

  @override
  String get kazaTitle => 'Каза';

  @override
  String get kazaSubtitle => 'Отслеживайте и совершайте пропущенные намазы';

  @override
  String get kazaCalculatorWizard => 'Калькулятор';

  @override
  String get kazaBatchLogDay => '+1 Полный день';

  @override
  String get kazaBatchLogDayTooltip => 'Прибавить 1 ко всем 6 намазам';

  @override
  String get kazaTotalRemaining => 'Всего осталось';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$completed из $target выполнено';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return 'Примерное окончание: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished =>
      'Все пропущенные намазы выполнены! 🎉';

  @override
  String get kazaDailyPaceLabel => 'Дневной темп';

  @override
  String kazaDailyPaceValue(Object count) {
    return '$count намазов в день';
  }

  @override
  String get kazaSetPaceDialogTitle => 'Указать дневной темп';

  @override
  String get kazaSetPaceDialogSubtitle =>
      'Сколько пропущенных намазов вы совершаете в день?';

  @override
  String get kazaCalculatorTitle => 'Калькулятор пропущенных намазов';

  @override
  String get kazaCalculateByYears => 'По времени';

  @override
  String get kazaCalculateManual => 'Ручной ввод';

  @override
  String get kazaYearsMissed => 'Пропущенных лет';

  @override
  String get kazaMonthsMissed => 'Дополнительные месяцы';

  @override
  String get kazaCalculateButton => 'Сохранить цели';

  @override
  String get kazaWitrLabel => 'Витр';

  @override
  String kazaRemainingCount(Object count) {
    return '$count осталось';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return 'Выполнено намазов $name';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= $days дней на намаз (Всего $total намазов)';
  }

  @override
  String get backupExportTitle => 'Резервное копирование и экспорт';

  @override
  String get backupExportSubtitle =>
      'Резервное копирование данных или экспорт расписания';

  @override
  String get exportBackupJson => 'Экспорт резервной копии (JSON)';

  @override
  String get restoreBackupJson => 'Восстановить данные из копии';

  @override
  String get exportPrayerScheduleIcs => 'Экспорт расписания намазов (.ics)';

  @override
  String get exportHolidaysIcs => 'Экспорт мусульманских праздников (.ics)';

  @override
  String get restoreConfirmTitle => 'Восстановить данные приложения?';

  @override
  String get restoreConfirmBody =>
      'Будут восстановлены цели Каза, история намазов, напоминания и данные Тасбих. Продолжить?';

  @override
  String get restoreSuccess => 'Данные успешно восстановлены!';

  @override
  String get restoreError => 'Неверный формат файла резервной копии';

  @override
  String get shareOrSave => 'Поделиться / Сохранить';

  @override
  String get analyticsTab => 'Аналитика';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get longestStreak => 'Рекордная серия';

  @override
  String get daysUnit => 'дней';

  @override
  String get monthlyHeatmapTitle => 'Месячный прогресс';

  @override
  String get completionBreakdownTitle => 'Статистика молитв';

  @override
  String get overallConsistency => 'Общая регулярность';

  @override
  String get totalPrayersCompleted => 'Всего совершено молитв';

  @override
  String get last30Days => 'За 30 дней';

  @override
  String get allTime => 'За всё время';
}
