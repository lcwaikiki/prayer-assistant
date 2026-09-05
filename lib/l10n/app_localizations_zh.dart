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
  String get calendarPreviousDay => '前一天';

  @override
  String get calendarNextDay => '第二天';

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
  String get widgetSettingsSectionTitle => '小组件设置';

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
  String widgetTextSizePreview(Object size) {
    return 'Preview $size';
  }

  @override
  String get widgetMmssThresholdTitle => '倒计时阈值';

  @override
  String get widgetThemeTitle => '背景主题';

  @override
  String get widgetThemeSystem => '系统默认';

  @override
  String get widgetThemeLight => '浅色';

  @override
  String get widgetThemeDark => '深色';

  @override
  String get widgetThemeTransparent => '透明';

  @override
  String get widgetCalendarDisplayTitle => '日历日期显示';

  @override
  String get widgetCalendarDisplayBoth => '两者 (伊斯兰历和公历)';

  @override
  String get widgetCalendarDisplayHijri => '仅伊斯兰历';

  @override
  String get widgetCalendarDisplayGregorian => '仅公历';

  @override
  String get widgetMmssThresholdNever => '始终显示 HH:MM';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '低于 $minutes 分钟显示 MM:SS';
  }

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
  String get adhanChip => '宣礼';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total 礼拜已完成';
  }

  @override
  String get holiday_islamic_new_year => '伊斯兰新年';

  @override
  String get holiday_ashura => '阿舒拉节';

  @override
  String get holiday_mawlid => '圣纪节';

  @override
  String get holiday_isra_miraj => '登霄节';

  @override
  String get holiday_laylat_barat => '白拉特夜';

  @override
  String get holiday_ramadan_first => '斋月首日';

  @override
  String get holiday_laylat_qadr => '盖德尔夜';

  @override
  String get holiday_eid_fitr => '开斋节';

  @override
  String get holiday_arafah => '阿拉法日';

  @override
  String get holiday_eid_adha => '古尔邦节';

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
  String get calendarRepeatCountLabel => '重复次数';

  @override
  String get calendarRepeatCountHelper => '提醒停止前触发的次数（关闭 = 永远重复）';

  @override
  String get calendarRepeatCountError => '请输入 2 到 100 之间的数字';

  @override
  String get calendarRepeatDaysLabel => '重复于';

  @override
  String get calendarDayOfMonthLabel => '每月几号';

  @override
  String get calendarYearlyMonthLabel => '月份';

  @override
  String get calendarYearlyDayLabel => '日';

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
  String get datesMoonPhaseTab => 'Moon Phase';

  @override
  String get undo => '撤销';

  @override
  String calendarReminderDeleted(Object title) {
    return '已删除“$title”';
  }

  @override
  String get verseOfTheDay => '今日节文';

  @override
  String get hadithOfTheDay => '今日圣训';

  @override
  String get hisnAlMuslimTitle => '穆斯林的堡垒';

  @override
  String get morningAdhkar => '晨间赞词';

  @override
  String get eveningAdhkar => '晚间赞词';

  @override
  String get afterPrayerAdhkar => '拜后赞词';

  @override
  String get sleepingAdhkar => '睡前赞词';

  @override
  String get dailyLifeDuas => '日常祈祷词';

  @override
  String get shareWisdom => '分享';

  @override
  String get copyText => '复制';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String get searchSupplicationsHint => '搜索祈祷词...';

  @override
  String get noSupplicationsFound => '未找到相关祈祷词';

  @override
  String get completed => '已完成';

  @override
  String get tapToCount => '轻按以计数';

  @override
  String get tabAll => '全部';

  @override
  String get kazaTitle => '补礼';

  @override
  String get kazaSubtitle => '计算并追踪主命拜功补礼';

  @override
  String get kazaCalculatorWizard => '计算器';

  @override
  String get kazaBatchLogDay => '+1 整天';

  @override
  String get kazaBatchLogDayTooltip => '为所有 6 次拜功增加 1 次';

  @override
  String get kazaTotalRemaining => '剩余总计';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '已完成 $completed / $target';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return '预计完成日期：$date';
  }

  @override
  String get kazaEstimatedCompletionFinished => '已补完所有卡扎拜功！🎉';

  @override
  String get kazaDailyPaceLabel => '每日速度';

  @override
  String kazaDailyPaceValue(Object count) {
    return '每天 $count 次';
  }

  @override
  String get kazaSetPaceDialogTitle => '设置每日速度';

  @override
  String get kazaSetPaceDialogSubtitle => '您每天补多少次卡扎拜功？';

  @override
  String get kazaCalculatorTitle => '补礼计算器';

  @override
  String get kazaCalculateByYears => '按时长';

  @override
  String get kazaCalculateManual => '手动设置';

  @override
  String get kazaYearsMissed => '遗漏年数';

  @override
  String get kazaMonthsMissed => '额外月数';

  @override
  String get kazaCalculateButton => '设置目标';

  @override
  String get kazaWitrLabel => '奇数拜';

  @override
  String kazaRemainingCount(Object count) {
    return '还剩 $count 次';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$name 完成次数';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= 每次拜功 $days 天（共计 $total 次拜功）';
  }

  @override
  String get backupExportTitle => '备份与导出';

  @override
  String get backupExportSubtitle => '备份应用数据或导出礼拜时间表';

  @override
  String get exportBackupJson => '导出备份数据 (JSON)';

  @override
  String get restoreBackupJson => '从备份恢复数据';

  @override
  String get exportPrayerScheduleIcs => '导出礼拜时间表 (.ics)';

  @override
  String get exportHolidaysIcs => '导出伊斯兰节日 (.ics)';

  @override
  String get restoreConfirmTitle => '恢复应用数据？';

  @override
  String get restoreConfirmBody => '这将恢复您的补礼目标、礼拜记录、提醒和赞词数据。是否继续？';

  @override
  String get restoreSuccess => '数据已成功恢复！';

  @override
  String get restoreError => '无效的备份文件格式';

  @override
  String get shareOrSave => '分享 / 保存';

  @override
  String get analyticsTab => '分析';

  @override
  String get currentStreak => '当前连续';

  @override
  String get longestStreak => '最长连续';

  @override
  String get daysUnit => '天';

  @override
  String get monthlyHeatmapTitle => '月度完成度';

  @override
  String get completionBreakdownTitle => '礼拜明细';

  @override
  String get overallConsistency => '整体一致性';

  @override
  String get totalPrayersCompleted => '已记录礼拜总数';

  @override
  String get last30Days => '最近30天';

  @override
  String get allTime => '所有时间';

  @override
  String get fastingTitle => '斋戒';

  @override
  String get suhoorCountdownTitle => '距离封斋';

  @override
  String get iftarCountdownTitle => '距离开斋';

  @override
  String get fastingTypeRamadan => '莱麦丹月斋戒';

  @override
  String get fastingTypeSunnah => '副功斋 (Sunnah)';

  @override
  String get fastingTypeQadaa => '还补斋 (Qadaa)';

  @override
  String get whiteDaysTitle => '白日（Ayyam al-Beed）';

  @override
  String get mondayThursdayTitle => '周一与周四圣行斋';

  @override
  String get logFastAction => '记录斋戒';

  @override
  String get totalFastsLogged => '已记录斋戒总数';

  @override
  String get suhoorEndsIn => '距离封斋结束';

  @override
  String get iftarIn => '距离开斋剩余';

  @override
  String get fastingTab => '斋戒';

  @override
  String get trackTabTitle => '追踪';

  @override
  String get prayerAnalyticsTitle => '礼拜分析';

  @override
  String get prayerQadaaTitle => '还补礼拜 (Qadaa)';

  @override
  String get iftarTimeLabel => '开斋时间';

  @override
  String fastingProgressFasted(int percent) {
    return '$percent% 已斋戒';
  }

  @override
  String get suhoorTickerTitle => '封斋倒计时';

  @override
  String fastingProgressElapsed(String percent) {
    return '$percent% 已过';
  }

  @override
  String suhoorWithTime(String time) {
    return '封斋 ($time)';
  }

  @override
  String iftarWithTime(String time) {
    return '开斋 ($time)';
  }

  @override
  String get upcomingSunnahDays => '即将来临的圣行日';

  @override
  String get fastingCalendarLogger => '斋戒日历记录';

  @override
  String get removeFastLog => '删除斋戒记录';

  @override
  String get calendarWeekStartTitle => '日历一周开始于';

  @override
  String get calendarWeekStartSunday => '星期日';

  @override
  String get calendarWeekStartMonday => '星期一';

  @override
  String get hijriDateOffsetTitle => '伊斯兰历日期微调';

  @override
  String get hijriDateOffsetSubtitle => '根据当地新月观测微调伊斯兰历';

  @override
  String get showIslamicHolidaysTitle => '突出显示伊斯兰节日';

  @override
  String get showIslamicHolidaysSubtitle => '在伊斯兰圣日显示特别徽标';

  @override
  String get showFastingBadgesTitle => '在日历上显示斋戒记录';

  @override
  String get showFastingBadgesSubtitle => '在已记录斋戒的日期显示徽标';

  @override
  String get defaultCalendarDisplayTitle => '默认日历视图';

  @override
  String get defaultCalendarDisplaySubtitle => '打开日历时的初始基础视图';

  @override
  String get showCalendarReminderDotsTitle => '显示提醒指示点';

  @override
  String get showCalendarReminderDotsSubtitle => '在有提醒的日期显示指示点';

  @override
  String get calendarSettingsSectionTitle => '日历设置';

  @override
  String get moonPhaseTitle => '月相';

  @override
  String moonIllumination(int percent) {
    return '$percent% 照亮';
  }

  @override
  String moonAgeDays(String days) {
    return '周期的第 $days 天';
  }

  @override
  String get moonPhaseNewMoon => '新月（新月）';

  @override
  String get moonPhaseWaxingCrescent => '峨眉月';

  @override
  String get moonPhaseFirstQuarter => '上弦月';

  @override
  String get moonPhaseWaxingGibbous => '盈凸月';

  @override
  String get moonPhaseFullMoon => '满月（满月）';

  @override
  String get moonPhaseWaningGibbous => '亏凸月';

  @override
  String get moonPhaseLastQuarter => '下弦月';

  @override
  String get moonPhaseWaningCrescent => '残月';

  @override
  String get whiteDaysSubtitle => '圣行斋戒日（伊斯兰历13、14、15日）';

  @override
  String get homeDashboardCardsSectionTitle => '首页仪表板卡片';

  @override
  String get showCardMoonPhaseTitle => '显示月相卡片';

  @override
  String get showCardMoonPhaseSubtitle => '显示月相与白日提示卡片';

  @override
  String get showCardIftarSuhoorTitle => '显示封斋与开斋卡片';

  @override
  String get showCardIftarSuhoorSubtitle => '显示封斋与开斋实时倒计时卡片';

  @override
  String get showCardDailyWisdomTitle => '显示每日智慧卡片';

  @override
  String get showCardDailyWisdomSubtitle => '显示每日圣训或经文卡片';

  @override
  String get showCardUpcomingRemindersTitle => '显示近期提醒卡片';

  @override
  String get showCardUpcomingRemindersSubtitle => '显示列出接下来 3 个提醒的卡片';
}
