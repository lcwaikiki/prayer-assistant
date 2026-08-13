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
  String get reminderAlertTitle => 'アラート';

  @override
  String get reminderAlertSubtitle => '実際にアラートするには環境設定内の対応するスイッチもオンである必要があります。';

  @override
  String get vibrateChip => '振動';

  @override
  String get soundChip => '音';

  @override
  String get remindBeforePrayerTitle => '礼拝前に通知';

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
  String get datesPrayerTimesTab => '礼拝時間';

  @override
  String get datesCalendarTab => 'カレンダー';

  @override
  String get undo => '元に戻す';

  @override
  String calendarReminderDeleted(Object title) {
    return '「$title」を削除しました';
  }
}
