import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Adapter that exposes Beads/Tesbihat localization strings backed by the
/// standard Flutter [AppLocalizations].
class TesbihatLocalizations {
  TesbihatLocalizations(this.locale) : _appL10n = _safeLookup(locale);

  TesbihatLocalizations.fromAppLocalizations(this._appL10n, [Locale? locale])
      : locale = locale ?? Locale(_appL10n.localeName);

  static TesbihatLocalizations of(BuildContext context) {
    final appL10n = AppLocalizations.of(context);
    if (appL10n != null) {
      return TesbihatLocalizations.fromAppLocalizations(
        appL10n,
        Localizations.maybeLocaleOf(context),
      );
    }
    return TesbihatLocalizations(const Locale('en'));
  }

  final Locale locale;
  final AppLocalizations _appL10n;

  static const supportedLocales = AppLocalizations.supportedLocales;
  static const localizationsDelegates = <LocalizationsDelegate<dynamic>>[];

  static AppLocalizations _safeLookup(Locale locale) {
    try {
      return lookupAppLocalizations(locale);
    } catch (_) {
      return lookupAppLocalizations(const Locale('en'));
    }
  }

  String get appTitle => _appL10n.beadsAppTitle;
  String get milestones => _appL10n.beadsMilestones;
  String get switchToLight => _appL10n.beadsSwitchToLight;
  String get switchToDark => _appL10n.beadsSwitchToDark;
  String get language => _appL10n.beadsLanguage;
  String get chooseLanguage => _appL10n.beadsChooseLanguage;
  String get noMilestones => _appL10n.beadsNoMilestones;
  String get statsTitle => _appL10n.beadsStatsTitle;
  String get statsToday => _appL10n.beadsStatsToday;
  String get statsLast7Days => _appL10n.beadsStatsLast7Days;
  String get statsTotal => _appL10n.beadsStatsTotal;
  String deletedItem(String title) => '"$title" ${_appL10n.beadsDeleted}';
  String get undo => _appL10n.beadsUndo;
  String get edit => _appL10n.beadsEdit;
  String get duplicate => _appL10n.beadsDuplicate;
  String get clear => _appL10n.beadsClear;
  String get delete => _appL10n.beadsDelete;
  String get count => _appL10n.beadsCount;
  String get check => _appL10n.beadsCheck;
  String get set => _appL10n.beadsSet;
  String get progress => _appL10n.beadsProgress;
  String get createMilestone => _appL10n.beadsCreateMilestone;
  String get editMilestone => _appL10n.beadsEditMilestone;
  String get title => _appL10n.beadsTitle;
  String get notes => _appL10n.beadsNotes;
  String get notesHint => _appL10n.beadsNotesHint;
  String get countField => _appL10n.beadsCountField;
  String get checkInterval => _appL10n.beadsCheckInterval;
  String get checkHelper => _appL10n.beadsCheckHelper;
  String get setCount => _appL10n.beadsSetCount;
  String get setCountHelper => _appL10n.beadsSetCountHelper;
  String get setCountReadonlyHelper => _appL10n.beadsSetCountReadonlyHelper;
  String get vibrationIntensity => _appL10n.beadsVibrationIntensity;
  String get reminderTitle => _appL10n.beadsReminderTitle;
  String get reminderEnable => _appL10n.beadsReminderEnable;
  String get reminderRepeatOnce => _appL10n.beadsReminderRepeatOnce;
  String get reminderRepeatDaily => _appL10n.beadsReminderRepeatDaily;
  String get reminderRepeatWeekly => _appL10n.beadsReminderRepeatWeekly;
  String get reminderRepeatMonthly => _appL10n.beadsReminderRepeatMonthly;
  String get reminderRepeatYearly => _appL10n.beadsReminderRepeatYearly;
  String get reminderRepeatCountLabel => _appL10n.beadsReminderRepeatCountLabel;
  String get reminderRepeatCountHelper => _appL10n.beadsReminderRepeatCountHelper;
  String get reminderRepeatCountRangeError =>
      _appL10n.beadsReminderRepeatCountRangeError;
  String get reminderRepeatDaysLabel => _appL10n.beadsReminderRepeatDaysLabel;
  String get reminderDayOfMonthLabel => _appL10n.beadsReminderDayOfMonthLabel;
  String get reminderYearlyMonthLabel => _appL10n.beadsReminderYearlyMonthLabel;
  String get reminderYearlyDayLabel => _appL10n.beadsReminderYearlyDayLabel;
  String get reminderRecurrenceLabel => _appL10n.beadsReminderRecurrenceLabel;
  String get reminderMonthlyBasisLabel => _appL10n.beadsReminderMonthlyBasisLabel;
  String get reminderYearlyBasisLabel => _appL10n.beadsReminderYearlyBasisLabel;
  String get reminderBasisGregorian => _appL10n.beadsReminderBasisGregorian;
  String get reminderBasisHijri => _appL10n.beadsReminderBasisHijri;
  String get reminderPickDateTime => _appL10n.beadsReminderPickDateTime;
  String get reminderPickDate => _appL10n.beadsReminderPickDate;
  String get reminderPickTime => _appL10n.beadsReminderPickTime;
  String get reminderNotSet => _appL10n.beadsReminderNotSet;
  String get reminderAnchorTime => _appL10n.beadsReminderAnchorTime;
  String get reminderAnchorPrayer => _appL10n.beadsReminderAnchorPrayer;
  String get reminderOffsetOnTime => _appL10n.beadsReminderOffsetOnTime;
  String get reminderOffsetBefore => _appL10n.beadsReminderOffsetBefore;
  String get reminderOffsetAfter => _appL10n.beadsReminderOffsetAfter;
  String get reminderMinutesLabel => _appL10n.beadsReminderMinutesLabel;
  String get reminderSelectPrayer => _appL10n.beadsReminderSelectPrayer;
  String get save => _appL10n.beadsSave;
  String get update => _appL10n.beadsUpdate;
  String requiredField(String fieldName) =>
      '$fieldName ${_appL10n.beadsRequiredSuffix}';
  String fieldMustBeInteger(String fieldName) =>
      '$fieldName ${_appL10n.beadsMustBeInteger}';
  String get countPositive => _appL10n.beadsCountPositive;
  String get checkGreaterThanZero => _appL10n.beadsCheckGreaterThanZero;
  String get checkHalfError => _appL10n.beadsCheckHalfError;
  String get enterValidCountFirst => _appL10n.beadsEnterValidCountFirst;
  String get setCountNegative => _appL10n.beadsSetCountNegative;
  String get setCountGreaterCount => _appL10n.beadsSetCountGreaterCount;
  String get setCountValueRequired => _appL10n.beadsSetCountValueRequired;
  String get itemNotFound => _appL10n.beadsItemNotFound;
  String get resetProgressTitle => _appL10n.beadsResetProgressTitle;
  String get resetProgressBody => _appL10n.beadsResetProgressBody;
  String get cancel => _appL10n.beadsCancel;
  String get reset => _appL10n.beadsReset;
  String get editProgressAndSetCount => _appL10n.beadsEditProgressAndSetCount;
  String get progressCount => _appL10n.beadsProgressCount;
  String get setCountCannotNegative => _appL10n.beadsSetCountCannotNegative;
  String get validProgressNumber => _appL10n.beadsValidProgressNumber;
  String progressBetween(int max) => _appL10n.beadsProgressBetween(max);
  String get maxMinusCount => _appL10n.beadsMaxMinusCount;
  String get tap => _appL10n.beadsTap;
  String get noNotesAdded => _appL10n.beadsNoNotesAdded;
  String get groups => _appL10n.beadsGroups;
  String get newGroup => _appL10n.beadsNewGroup;
  String get editGroup => _appL10n.beadsEditGroup;
  String get groupName => _appL10n.beadsGroupName;
  String get groupMembers => _appL10n.beadsGroupMembers;
  String get noBeadsInGroup => _appL10n.beadsNoBeadsInGroup;
  String get addBead => _appL10n.beadsAddBead;
  String get addBeads => _appL10n.beadsAddBeads;
  String get newBead => _appL10n.beadsNewBead;
  String get deleteGroup => _appL10n.beadsDeleteGroup;
  String get deleteGroupConfirm => _appL10n.beadsDeleteGroupConfirm;
  String get removeFromGroup => _appL10n.beadsRemoveFromGroup;
  String get select => _appL10n.beadsSelect;
  String get selectAll => _appL10n.beadsSelectAll;
  String selectedCount(int count) => _appL10n.beadsSelectedCount(count);
  String deleteSelectedConfirm(int count) =>
      _appL10n.beadsDeleteSelectedConfirm(count);
  String deletedSelected(int count) => _appL10n.beadsDeletedSelected(count);
}

extension TesbihatLocalizationsX on BuildContext {
  TesbihatLocalizations get tesbihatL10n => TesbihatLocalizations.of(this);
}
