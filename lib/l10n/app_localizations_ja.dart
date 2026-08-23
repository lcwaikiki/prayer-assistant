// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '礼拝アシスタント';

  @override
  String get tabLocation => '場所';

  @override
  String get tabToday => '今日';

  @override
  String get tabDates => '日付';

  @override
  String get tabTesbih => 'ビーズ';

  @override
  String get tooltipToggleLightDark => 'ライト/ダーク切替';

  @override
  String get tooltipRemindersOn => 'リマインダーをオン';

  @override
  String get tooltipRemindersOff => 'リマインダーをオフ';

  @override
  String get tooltipPreferences => '設定';

  @override
  String remainingMinutesValue(Object minutes) {
    return '$minutes 分';
  }

  @override
  String get remainingMinutesUnknown => '-- 分';

  @override
  String get homeNoLocationTitle => '場所が未選択です';

  @override
  String get homeNoLocationSubtitle => 'まず「場所」タブで地区を保存してください。';

  @override
  String get homeNoPrayerTimesTitle => '礼拝時間のキャッシュがありません';

  @override
  String get homeNoPrayerTimesSubtitle => '更新して年間データを同期してください。';

  @override
  String get refresh => '更新';

  @override
  String get qiblaTitle => 'キブラ';

  @override
  String qiblaBearing(int degrees) {
    return 'キブラ: $degrees°';
  }

  @override
  String get qiblaLocationUnavailable => '現在地を特定できませんでした。GPSを有効にして再試行してください。';

  @override
  String get qiblaHeadingUnavailable => 'コンパスが利用できません - 固定方向を表示中。';

  @override
  String get qiblaPointDevice => '針が上を向くまでデバイスを回してください。';

  @override
  String get qiblaKaabaShort => 'キブラ';

  @override
  String get shareTodayTimes => '今日の時刻を共有';

  @override
  String get calendarPreviousDay => '前の日';

  @override
  String get calendarNextDay => '次の日';

  @override
  String todayWithDate(Object date) {
    return '今日 • $date';
  }

  @override
  String get hijriUnknown => 'ヒジュラ暦: -';

  @override
  String hijriWithDate(Object date) {
    return 'ヒジュラ暦: $date';
  }

  @override
  String get reminderSettingsTitle => 'リマインダー設定';

  @override
  String get reminderSettingsSubtitle => '上の礼拝時間をタップして通知タイプと事前分数を設定します。';

  @override
  String get tooltipScheduledDebug => '予約通知デバッグ';

  @override
  String get scheduledRemindersDebugTitle => '予約通知（デバッグ）';

  @override
  String pendingNotificationsCount(Object count) {
    return '保留中の通知: $count';
  }

  @override
  String get sendTestNotificationNow => 'テスト通知を送信';

  @override
  String get testNotificationSent => 'テスト通知を送信しました。';

  @override
  String get statusBarMinutesTitle => 'ステータスバー分表示';

  @override
  String get statusBarMinutesSubtitle => 'ステータスバーに残り分の継続通知を表示します。';

  @override
  String get statusAutoRestoreTitle => '削除時に自動復元';

  @override
  String get statusAutoRestoreSubtitle => 'ユーザーが消したら再作成します。';

  @override
  String get noPendingReminders => '保留中の通知はありません。';

  @override
  String get unknownFireTime => '不明な時刻';

  @override
  String get pastPrefix => '[過去] ';

  @override
  String reminderOnTimeAndBefore(Object minutes) {
    return 'オン • 定刻 + $minutes 分前';
  }

  @override
  String get reminderOnTimeOnly => 'オン • 定刻';

  @override
  String reminderBeforeOnly(Object minutes) {
    return 'オン • $minutes 分前';
  }

  @override
  String get reminderOff => '通知オフ';

  @override
  String get nextPrayerTitle => '次の礼拝';

  @override
  String get homeUpcomingRemindersTitle => '近日のリマインダー';

  @override
  String startsIn(Object remaining) {
    return '$remaining 後に開始';
  }

  @override
  String get selectYourLocation => '場所を選択';

  @override
  String get locationHelp => 'GPSで簡単設定、または国/都市を手動選択できます。';

  @override
  String get useCurrentLocation => '現在地を使用';

  @override
  String get country => '国';

  @override
  String get stateCity => '州 / 市';

  @override
  String get district => '地区';

  @override
  String get saveLocation => '場所を保存';

  @override
  String selectedLocation(Object location) {
    return '選択中: $location';
  }

  @override
  String get historySelectLocationFirst => '1年分の礼拝一覧を見るには先に場所を選択してください。';

  @override
  String get historyTableTitle => '礼拝時間表（年間）';

  @override
  String get todayShort => '今日';

  @override
  String get dateHeader => '日付';

  @override
  String get imsak => 'ファジュル';

  @override
  String get gunes => '日出';

  @override
  String get ogle => 'ズフル';

  @override
  String get ikindi => 'アスル';

  @override
  String get aksam => 'マグリブ';

  @override
  String get yatsi => 'イシャ';

  @override
  String get hijriHeader => 'ヒジュラ';

  @override
  String get preferencesTitle => '設定';

  @override
  String get languageTitle => '言語';

  @override
  String get languageSystem => 'システム設定';

  @override
  String get themeModeTitle => 'テーマモード';

  @override
  String get themeSystem => 'システム設定';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get appBarRemainingTitle => 'ホーム上部バーの残り時間表示';

  @override
  String get showInTitle => 'タイトルに表示';

  @override
  String get showAtRight => '右側に表示';

  @override
  String get showAsSubtitle => 'サブタイトルに表示';

  @override
  String get hideRemainingText => '残りテキストを非表示';

  @override
  String get notificationMessageTitle => '通知メッセージ';

  @override
  String get notificationMessageShown => '表示';

  @override
  String get notificationMessageHidden => '非表示';

  @override
  String get widgetTextSizeTitle => 'ウィジェットの文字サイズ';

  @override
  String get widgetTextSizeSubtitle => 'ホーム画面ウィジェットで使用する文字サイズ。';

  @override
  String get widgetTextSizeExtraSmall => '極小';

  @override
  String get widgetTextSizeSmall => '小';

  @override
  String get widgetTextSizeMedium => '中';

  @override
  String get widgetTextSizeLarge => '大';

  @override
  String get widgetMmssThresholdTitle => 'ウィジェットの秒カウントダウン';

  @override
  String get widgetMmssThresholdNever => '常にHH:MMを表示';

  @override
  String widgetMmssThresholdValue(Object minutes) {
    return '$minutes分未満はMM:SS';
  }

  @override
  String get remindersOnOffTitle => 'リマインダー on/off';

  @override
  String get remindersOnOffSubtitle => '礼拝リマインダー通知のオン/オフ。礼拝ごとの設定は保持されます。';

  @override
  String get reminderVibrationTitle => 'リマインダーで振動';

  @override
  String get reminderVibrationSubtitle => 'リマインダー発生時に約10秒間、断続的に振動します。';

  @override
  String get reminderSoundTitle => 'リマインダーで音を再生';

  @override
  String get reminderSoundSubtitle => 'リマインダー発生時に通知音を再生します。';

  @override
  String get remindersOn => 'オン';

  @override
  String get remindersOff => 'オフ';

  @override
  String reminderScreenTitle(Object prayer) {
    return '$prayer リマインダー';
  }

  @override
  String get reminderTypeTitle => '通知タイプ（両方選択可）';

  @override
  String get onTime => '定刻';

  @override
  String get before => '前';

  @override
  String get after => '後';

  @override
  String get reminderAlertTitle => 'アラート';

  @override
  String get reminderAlertSubtitle => '実際にアラートするには環境設定内の対応するスイッチもオンである必要があります。';

  @override
  String get vibrateChip => '振動';

  @override
  String get soundChip => '音';

  @override
  String get adhanChip => 'アザーン';

  @override
  String prayersCompleted(Object completed, Object total) {
    return '$completed/$total 礼拝完了';
  }

  @override
  String get holiday_islamic_new_year => 'イスラム新年';

  @override
  String get holiday_ashura => 'アーシューラー';

  @override
  String get holiday_mawlid => '予言者生誕祭';

  @override
  String get holiday_isra_miraj => 'イスラーとミウラージュ';

  @override
  String get holiday_laylat_barat => 'バラアトの夜';

  @override
  String get holiday_ramadan_first => 'ラマダーン初日';

  @override
  String get holiday_laylat_qadr => 'みいつの夜';

  @override
  String get holiday_eid_fitr => 'イード・アル＝フィトル';

  @override
  String get holiday_arafah => 'アラファの日';

  @override
  String get holiday_eid_adha => 'イード・アル＝アドハー';

  @override
  String get remindBeforePrayerTitle => '礼拝前に通知';

  @override
  String get remindAfterPrayerTitle => '礼拝後に通知';

  @override
  String minutesValue(Object minutes) {
    return '$minutes 分';
  }

  @override
  String get custom => 'カスタム';

  @override
  String get customMinutes => 'カスタム分';

  @override
  String get customMinutesHint => '例: 12';

  @override
  String get save => '保存';

  @override
  String get enableBeforeToSelectMinutes => '分を選ぶには「前」を有効にしてください。';

  @override
  String get enableAfterToSelectMinutes => '分を選ぶには「後」を有効にしてください。';

  @override
  String get enterValidPositiveNumber => '有効な正の数を入力してください。';

  @override
  String get useValueUpTo240 => '240分以下の値を入力してください。';

  @override
  String get customMinutesSaved => 'カスタム分を保存しました。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get calendarTabTooltip => 'ヒジュラ暦カレンダー';

  @override
  String get calendarPreviousMonth => '前の月';

  @override
  String get calendarNextMonth => '次の月';

  @override
  String get calendarSwapPrimary => 'ヒジュラ暦/西暦を切替';

  @override
  String get calendarShowSecondary => '副暦日を表示';

  @override
  String get calendarHideSecondary => '副暦日を非表示';

  @override
  String get calendarNoRemindersOnDay => 'この日のリマインダーはありません';

  @override
  String get calendarAddReminder => 'リマインダーを追加';

  @override
  String get calendarEditReminder => '編集';

  @override
  String get calendarDeleteReminder => '削除';

  @override
  String get calendarReminderFormTitleNew => '新しいリマインダー';

  @override
  String get calendarReminderFormTitleEdit => 'リマインダーを編集';

  @override
  String get calendarReminderTitleLabel => 'タイトル';

  @override
  String get calendarReminderTitleHint => '例：ラマダン開始';

  @override
  String get calendarReminderNotesLabel => 'メモ（任意）';

  @override
  String get calendarReminderDateTimeLabel => '日付と時刻';

  @override
  String get calendarReminderRecurrenceLabel => '繰り返し';

  @override
  String get calendarRecurrenceOnce => '1回のみ';

  @override
  String get calendarRecurrenceDaily => '毎日';

  @override
  String get calendarRecurrenceWeekly => '毎週';

  @override
  String get calendarRecurrenceMonthly => '毎月';

  @override
  String get calendarRecurrenceYearly => '毎年';

  @override
  String get calendarRepeatCountLabel => '繰り返し回数';

  @override
  String get calendarRepeatCountHelper => 'リマインダーが停止するまでの発火回数（オフ = 永久に繰り返す）';

  @override
  String get calendarRepeatCountError => '2〜100の数字を入力してください';

  @override
  String get calendarRepeatDaysLabel => '繰り返す曜日';

  @override
  String get calendarDayOfMonthLabel => '月の日';

  @override
  String get calendarYearlyMonthLabel => '月';

  @override
  String get calendarYearlyDayLabel => '日';

  @override
  String get calendarMonthlyBasisLabel => '月次基準';

  @override
  String get calendarYearlyBasisLabel => '年次基準';

  @override
  String get calendarYearlyBasisGregorian => '西暦';

  @override
  String get calendarYearlyBasisHijri => 'ヒジュラ暦';

  @override
  String get calendarReminderTitleRequired => 'タイトルを入力してください';

  @override
  String get calendarAnchorClockTime => 'カレンダーの日付';

  @override
  String get calendarAnchorPrayerTime => '礼拝時間';

  @override
  String get calendarSelectPrayer => '礼拝を選択';

  @override
  String get calendarOffsetOnTime => '定刻';

  @override
  String get calendarOffsetBefore => '前';

  @override
  String get calendarOffsetAfter => '後';

  @override
  String get calendarPickAnchorDate => '日付を選択';

  @override
  String get datesPrayerTimesTab => '礼拝時間';

  @override
  String get datesCalendarTab => 'カレンダー';

  @override
  String get undo => '元に戻す';

  @override
  String calendarReminderDeleted(Object title) {
    return '「$title」を削除しました';
  }

  @override
  String get verseOfTheDay => '今日のクルアーン';

  @override
  String get hadithOfTheDay => 'ハディースの言葉';

  @override
  String get hisnAlMuslimTitle => 'ヒスン・アル・ムスリム';

  @override
  String get morningAdhkar => '朝のメインの祈り';

  @override
  String get eveningAdhkar => '夕方の祈り';

  @override
  String get afterPrayerAdhkar => '礼拝後の祈り';

  @override
  String get sleepingAdhkar => '就寝前の祈り';

  @override
  String get dailyLifeDuas => '日常のデュアー';

  @override
  String get shareWisdom => '共有';

  @override
  String get copyText => 'コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String get searchSupplicationsHint => 'デュアーを検索...';

  @override
  String get noSupplicationsFound => '該当するデュアーが見つかりません';

  @override
  String get completed => '完了';

  @override
  String get tapToCount => 'タップしてカウント';

  @override
  String get tabAll => 'すべて';

  @override
  String get kazaTitle => 'カザー';

  @override
  String get kazaSubtitle => '過去の未実施のお祈りを記録・補填';

  @override
  String get kazaCalculatorWizard => '計算機';

  @override
  String get kazaBatchLogDay => '+1日分完了';

  @override
  String get kazaBatchLogDayTooltip => '6つのお祈りすべてを1回分追加';

  @override
  String get kazaTotalRemaining => '残り合計';

  @override
  String kazaCompletedProgress(Object completed, Object target) {
    return '$target回中$completed回完了';
  }

  @override
  String kazaEstimatedCompletion(Object date) {
    return '完了予定日: $date';
  }

  @override
  String get kazaEstimatedCompletionFinished => 'すべてのカザーが完了しました！🎉';

  @override
  String get kazaDailyPaceLabel => '1日の目標ペース';

  @override
  String kazaDailyPaceValue(Object count) {
    return '1日$count回';
  }

  @override
  String get kazaSetPaceDialogTitle => '1日のペースを設定';

  @override
  String get kazaSetPaceDialogSubtitle => '1日に何回分のカザーを行いますか？';

  @override
  String get kazaCalculatorTitle => 'カザー計算ウィザード';

  @override
  String get kazaCalculateByYears => '期間指定';

  @override
  String get kazaCalculateManual => '手動設定';

  @override
  String get kazaYearsMissed => '未実施の年数';

  @override
  String get kazaMonthsMissed => '追加の月数';

  @override
  String get kazaCalculateButton => '目標を設定';

  @override
  String get kazaWitrLabel => 'ウィトル';

  @override
  String kazaRemainingCount(Object count) {
    return '残り$count回';
  }

  @override
  String kazaEditCompletedTitle(Object name) {
    return '$nameの完了回数';
  }

  @override
  String kazaCalculatedDaysPerPrayer(Object days, Object total) {
    return '= お祈り1つあたり$days日分（合計$total回）';
  }

  @override
  String get backupExportTitle => 'バックアップとエクスポート';

  @override
  String get backupExportSubtitle => 'アプリデータをバックアップまたはカレンダーをエクスポート';

  @override
  String get exportBackupJson => 'バックアップデータをエクスポート (JSON)';

  @override
  String get restoreBackupJson => 'バックアップから復元';

  @override
  String get exportPrayerScheduleIcs => '礼拝時間をエクスポート (.ics)';

  @override
  String get exportHolidaysIcs => 'イスラムの祝日をエクスポート (.ics)';

  @override
  String get restoreConfirmTitle => 'データを復元しますか？';

  @override
  String get restoreConfirmBody =>
      'カザー目標、礼拝履歴、リマインダー、テスビーハットデータが復元されます。続行しますか？';

  @override
  String get restoreSuccess => 'データが正常に復元されました！';

  @override
  String get restoreError => '無効なバックアップファイル形式です';

  @override
  String get shareOrSave => '共有 / 保存';

  @override
  String get analyticsTab => '分析';

  @override
  String get currentStreak => '現在の継続';

  @override
  String get longestStreak => '最長継続';

  @override
  String get daysUnit => '日';

  @override
  String get monthlyHeatmapTitle => '月間達成状況';

  @override
  String get completionBreakdownTitle => '礼拝の内訳';

  @override
  String get overallConsistency => '全体の継続率';

  @override
  String get totalPrayersCompleted => '記録された総礼拝数';

  @override
  String get last30Days => '過去30日間';

  @override
  String get allTime => '全期間';
}
