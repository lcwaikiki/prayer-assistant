// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '礼拜助手';

  @override
  String get tabLocation => '位置';

  @override
  String get tabToday => '今天';

  @override
  String get tabDates => '日期';

  @override
  String get tabTesbih => '念珠';

  @override
  String get tooltipToggleLightDark => '切换明暗模式';

  @override
  String get tooltipRemindersOn => '开启提醒';

  @override
  String get tooltipRemindersOff => '关闭提醒';

  @override
  String get tooltipPreferences => '偏好设置';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes 分钟';
  }

  @override
  String get remainingMinutesUnknown => '-- 分钟';

  @override
  String get homeNoLocationTitle => '未选择位置';

  @override
  String get homeNoLocationSubtitle => '请先到“位置”页保存你的地区。';

  @override
  String get homeNoPrayerTimesTitle => '暂无缓存礼拜时间';

  @override
  String get homeNoPrayerTimesSubtitle => '点击刷新以同步全年数据。';

  @override
  String get refresh => '刷新';

  @override
  String get qiblaTitle => '朝拜方向';

  @override
  String qiblaBearing(int degrees) {
    return '朝拜方向: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable => '无法确定您的位置。请启用GPS后重试。';

  @override
  String get qiblaHeadingUnavailable => '指南针不可用 - 显示固定方向。';

  @override
  String get qiblaPointDevice => '旋转设备直到指针朝上。';

  @override
  String get qiblaKaabaShort => '朝拜';

  @override
  String get shareTodayTimes => '分享今日时间';

  @override
  String todayWithDate(Object date) {
    return '今天 • $date';
  }

  @override
  String get hijriUnknown => '回历: -';

  @override
  String hijriWithDate(Object date) {
    return '回历: $date';
  }

  @override
  String get reminderSettingsTitle => '提醒设置';

  @override
  String get reminderSettingsSubtitle => '点击上方任一礼拜时间以设置提醒及提前分钟数。';

  @override
  String get tooltipScheduledDebug => '计划提醒调试';

  @override
  String get scheduledRemindersDebugTitle => '计划提醒（调试）';

  @override
  String pendingNotificationsCount(Object count) {
    return '待处理通知：$count';
  }

  @override
  String get sendTestNotificationNow => '立即发送测试通知';

  @override
  String get testNotificationSent => '测试通知已发送。';

  @override
  String get statusBarMinutesTitle => '状态栏分钟数';

  @override
  String get statusBarMinutesSubtitle => '在状态栏显示持续的剩余分钟通知。';

  @override
  String get statusAutoRestoreTitle => '被划掉后自动恢复';

  @override
  String get statusAutoRestoreSubtitle => '用户划掉后自动重新创建状态项。';

  @override
  String get noPendingReminders => '没有待处理提醒通知。';

  @override
  String get unknownFireTime => '未知触发时间';

  @override
  String get pastPrefix => '[已过] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return '开启 • 准点 + 提前 $minutes 分钟';
  }

  @override
  String get reminderOnTimeOnly => '开启 • 准点';

  @override
  String reminderBeforeOnly(Object minutes) {
    return '开启 • 提前 $minutes 分钟';
  }

  @override
  String get reminderOff => '提醒已关闭';

  @override
  String get nextPrayerTitle => '下一次礼拜';

  @override
  String get homeUpcomingRemindersTitle => '即将到来的提醒';

  @override
  String startsIn(Object remaining) {
    return '$remaining 后开始';
  }

  @override
  String get selectYourLocation => '选择你的位置';

  @override
  String get locationHelp => '可使用 GPS 快速设置，或手动选择国家/城市。';

  @override
  String get useCurrentLocation => '使用当前位置';

  @override
  String get country => '国家';

  @override
  String get stateCity => '省/州 / 城市';

  @override
  String get district => '地区';

  @override
  String get saveLocation => '保存位置';

  @override
  String selectedLocation(Object location) {
    return '已选择：$location';
  }

  @override
  String get historySelectLocationFirst => '请先选择位置以查看 1 年礼拜时间列表。';

  @override
  String get historyTableTitle => '礼拜时间表（全年）';

  @override
  String get todayShort => '今天';

  @override
  String get dateHeader => '日期';

  @override
  String get imsak => '晨礼';

  @override
  String get gunes => '日出';

  @override
  String get ogle => '晌礼';

  @override
  String get ikindi => '晡礼';

  @override
  String get aksam => '昏礼';

  @override
  String get yatsi => '宵礼';

  @override
  String get hijriHeader => '回历';

  @override
  String get preferencesTitle => '偏好设置';

  @override
  String get languageTitle => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get themeModeTitle => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get appBarRemainingTitle => '首页顶栏剩余时间显示';

  @override
  String get showInTitle => '显示在标题';

  @override
  String get showAtRight => '显示在右侧';

  @override
  String get showAsSubtitle => '显示为副标题';

  @override
  String get hideRemainingText => '隐藏剩余文字';

  @override
  String get notificationMessageTitle => '通知消息';

  @override
  String get notificationMessageShown => '显示';

  @override
  String get notificationMessageHidden => '隐藏';

  @override
  String get widgetTextSizeTitle => '小组件文字大小';

  @override
  String get widgetTextSizeSubtitle => '主屏幕小组件使用的文字大小。';

  @override
  String get widgetTextSizeExtraSmall => '极小';

  @override
  String get widgetTextSizeSmall => '小';

  @override
  String get widgetTextSizeMedium => '中';

  @override
  String get widgetTextSizeLarge => '大';

  @override
  String get remindersOnOffTitle => '提醒开/关';

  @override
  String get remindersOnOffSubtitle => '开启或关闭礼拜提醒通知，各礼拜的设置会保留。';

  @override
  String get reminderVibrationTitle => '提醒时振动';

  @override
  String get reminderVibrationSubtitle => '提醒触发时脉冲式振动约10秒。';

  @override
  String get reminderSoundTitle => '提醒时播放声音';

  @override
  String get reminderSoundSubtitle => '提醒触发时播放通知声音。';

  @override
  String get remindersOn => '开';

  @override
  String get remindersOff => '关';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer 提醒';
  }

  @override
  String get reminderTypeTitle => '提醒类型（可同时选择）';

  @override
  String get onTime => '准点';

  @override
  String get before => '提前';

  @override
  String get after => '延后';

  @override
  String get reminderAlertTitle => '提醒方式';

  @override
  String get reminderAlertSubtitle => '还需要在偏好设置中打开对应开关才会真正提醒。';

  @override
  String get vibrateChip => '振动';

  @override
  String get soundChip => '声音';

  @override
  String get remindBeforePrayerTitle => '在礼拜前提醒我';

  @override
  String get remindAfterPrayerTitle => '在礼拜后提醒我';

  @override
  String minutesValue(Object minutes) {
    return '$minutes 分钟';
  }

  @override
  String get custom => '自定义';

  @override
  String get customMinutes => '自定义分钟';

  @override
  String get customMinutesHint => '例如 12';

  @override
  String get save => '保存';

  @override
  String get enableBeforeToSelectMinutes => '启用“提前”后可选择分钟。';

  @override
  String get enableAfterToSelectMinutes => '启用“延后”后可选择分钟。';

  @override
  String get enterValidPositiveNumber => '请输入有效的正数。';

  @override
  String get useValueUpTo240 => '请输入不超过 240 的分钟值。';

  @override
  String get customMinutesSaved => '自定义分钟已保存。';

  @override
  String get cancel => '取消';

  @override
  String get calendarTabTooltip => '回历日历';

  @override
  String get calendarPreviousMonth => '上个月';

  @override
  String get calendarNextMonth => '下个月';

  @override
  String get calendarSwapPrimary => '切换回历/公历';

  @override
  String get calendarShowSecondary => '显示副历日期';

  @override
  String get calendarHideSecondary => '隐藏副历日期';

  @override
  String get calendarNoRemindersOnDay => '这一天没有提醒';

  @override
  String get calendarAddReminder => '添加提醒';

  @override
  String get calendarEditReminder => '编辑';

  @override
  String get calendarDeleteReminder => '删除';

  @override
  String get calendarReminderFormTitleNew => '新建提醒';

  @override
  String get calendarReminderFormTitleEdit => '编辑提醒';

  @override
  String get calendarReminderTitleLabel => '标题';

  @override
  String get calendarReminderTitleHint => '例如：斋月开始';

  @override
  String get calendarReminderNotesLabel => '备注（可选）';

  @override
  String get calendarReminderDateTimeLabel => '日期和时间';

  @override
  String get calendarReminderRecurrenceLabel => '重复';

  @override
  String get calendarRecurrenceOnce => '仅一次';

  @override
  String get calendarRecurrenceDaily => '每天';

  @override
  String get calendarRecurrenceWeekly => '每周';

  @override
  String get calendarRecurrenceMonthly => '每月';

  @override
  String get calendarRecurrenceYearly => '每年';

  @override
  String get calendarMonthlyBasisLabel => '月度基准';

  @override
  String get calendarYearlyBasisLabel => '年度基准';

  @override
  String get calendarYearlyBasisGregorian => '公历';

  @override
  String get calendarYearlyBasisHijri => '回历';

  @override
  String get calendarReminderTitleRequired => '请输入标题';

  @override
  String get calendarAnchorClockTime => '日历日期';

  @override
  String get calendarAnchorPrayerTime => '礼拜时间';

  @override
  String get calendarSelectPrayer => '选择礼拜';

  @override
  String get calendarOffsetOnTime => '准点';

  @override
  String get calendarOffsetBefore => '提前';

  @override
  String get calendarOffsetAfter => '延后';

  @override
  String get calendarPickAnchorDate => '选择日期';

  @override
  String get datesPrayerTimesTab => '礼拜时间';

  @override
  String get datesCalendarTab => '日历';

  @override
  String get undo => '撤销';

  @override
  String calendarReminderDeleted(Object title) {
    return '已删除“$title”';
  }
}
