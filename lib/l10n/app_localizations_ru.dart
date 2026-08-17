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
}
