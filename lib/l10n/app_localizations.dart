import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_ur.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Assistant'**
  String get appTitle;

  /// No description provided for @tabLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get tabLocation;

  /// No description provided for @tabToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get tabToday;

  /// No description provided for @tabDates.
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get tabDates;

  /// No description provided for @tooltipToggleLightDark.
  ///
  /// In en, this message translates to:
  /// **'Toggle light/dark'**
  String get tooltipToggleLightDark;

  /// No description provided for @tooltipRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders on'**
  String get tooltipRemindersOn;

  /// No description provided for @tooltipRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Turn reminders off'**
  String get tooltipRemindersOff;

  /// No description provided for @tooltipPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get tooltipPreferences;

  /// No description provided for @remainingMinutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String remainingMinutesValue(Object minutes);

  /// No description provided for @remainingMinutesUnknown.
  ///
  /// In en, this message translates to:
  /// **'-- min'**
  String get remainingMinutesUnknown;

  /// No description provided for @homeNoLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'No location selected'**
  String get homeNoLocationTitle;

  /// No description provided for @homeNoLocationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Location tab and save your district first.'**
  String get homeNoLocationSubtitle;

  /// No description provided for @homeNoPrayerTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'No prayer times in cache'**
  String get homeNoPrayerTimesTitle;

  /// No description provided for @homeNoPrayerTimesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap refresh to sync yearly data.'**
  String get homeNoPrayerTimesSubtitle;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @todayWithDate.
  ///
  /// In en, this message translates to:
  /// **'Today • {date}'**
  String todayWithDate(Object date);

  /// No description provided for @hijriUnknown.
  ///
  /// In en, this message translates to:
  /// **'Hijri: -'**
  String get hijriUnknown;

  /// No description provided for @hijriWithDate.
  ///
  /// In en, this message translates to:
  /// **'Hijri: {date}'**
  String hijriWithDate(Object date);

  /// No description provided for @reminderSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder settings'**
  String get reminderSettingsTitle;

  /// No description provided for @reminderSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap any prayer time above to configure reminder hook and minutes-before.'**
  String get reminderSettingsSubtitle;

  /// No description provided for @tooltipScheduledDebug.
  ///
  /// In en, this message translates to:
  /// **'Scheduled reminders debug'**
  String get tooltipScheduledDebug;

  /// No description provided for @scheduledRemindersDebugTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Reminders (Debug)'**
  String get scheduledRemindersDebugTitle;

  /// No description provided for @pendingNotificationsCount.
  ///
  /// In en, this message translates to:
  /// **'Pending notifications: {count}'**
  String pendingNotificationsCount(Object count);

  /// No description provided for @sendTestNotificationNow.
  ///
  /// In en, this message translates to:
  /// **'Send test notification now'**
  String get sendTestNotificationNow;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent.'**
  String get testNotificationSent;

  /// No description provided for @statusBarMinutesTitle.
  ///
  /// In en, this message translates to:
  /// **'Status bar minutes'**
  String get statusBarMinutesTitle;

  /// No description provided for @statusBarMinutesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show ongoing remaining-minutes notification in status bar.'**
  String get statusBarMinutesSubtitle;

  /// No description provided for @statusAutoRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-restore if dismissed'**
  String get statusAutoRestoreTitle;

  /// No description provided for @statusAutoRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Recreate the status item if user swipes it away.'**
  String get statusAutoRestoreSubtitle;

  /// No description provided for @noPendingReminders.
  ///
  /// In en, this message translates to:
  /// **'No pending reminder notifications.'**
  String get noPendingReminders;

  /// No description provided for @unknownFireTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown fire time'**
  String get unknownFireTime;

  /// No description provided for @pastPrefix.
  ///
  /// In en, this message translates to:
  /// **'[PAST] '**
  String get pastPrefix;

  /// No description provided for @reminderOnTimeAndBefore.
  ///
  /// In en, this message translates to:
  /// **'On • On time + {minutes} min before'**
  String reminderOnTimeAndBefore(Object minutes);

  /// No description provided for @reminderOnTimeOnly.
  ///
  /// In en, this message translates to:
  /// **'On • On time'**
  String get reminderOnTimeOnly;

  /// No description provided for @reminderBeforeOnly.
  ///
  /// In en, this message translates to:
  /// **'On • {minutes} min before'**
  String reminderBeforeOnly(Object minutes);

  /// No description provided for @reminderOff.
  ///
  /// In en, this message translates to:
  /// **'Reminder off'**
  String get reminderOff;

  /// No description provided for @nextPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Prayer'**
  String get nextPrayerTitle;

  /// No description provided for @startsIn.
  ///
  /// In en, this message translates to:
  /// **'Starts in {remaining}'**
  String startsIn(Object remaining);

  /// No description provided for @selectYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Your Location'**
  String get selectYourLocation;

  /// No description provided for @locationHelp.
  ///
  /// In en, this message translates to:
  /// **'Use GPS for quick setup or pick country/city manually.'**
  String get locationHelp;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @stateCity.
  ///
  /// In en, this message translates to:
  /// **'State / City'**
  String get stateCity;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Location'**
  String get saveLocation;

  /// No description provided for @selectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected: {location}'**
  String selectedLocation(Object location);

  /// No description provided for @historySelectLocationFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a location first to view 1-year prayer list.'**
  String get historySelectLocationFirst;

  /// No description provided for @historyTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times Table (Full Year)'**
  String get historyTableTitle;

  /// No description provided for @todayShort.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayShort;

  /// No description provided for @dateHeader.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateHeader;

  /// No description provided for @imsak.
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get imsak;

  /// No description provided for @gunes.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get gunes;

  /// No description provided for @ogle.
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get ogle;

  /// No description provided for @ikindi.
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get ikindi;

  /// No description provided for @aksam.
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get aksam;

  /// No description provided for @yatsi.
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get yatsi;

  /// No description provided for @hijriHeader.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get hijriHeader;

  /// No description provided for @preferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferencesTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystem;

  /// No description provided for @themeModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeModeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @appBarRemainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Home app bar remaining text'**
  String get appBarRemainingTitle;

  /// No description provided for @showInTitle.
  ///
  /// In en, this message translates to:
  /// **'Show in title'**
  String get showInTitle;

  /// No description provided for @showAtRight.
  ///
  /// In en, this message translates to:
  /// **'Show at right'**
  String get showAtRight;

  /// No description provided for @showAsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show as subtitle'**
  String get showAsSubtitle;

  /// No description provided for @hideRemainingText.
  ///
  /// In en, this message translates to:
  /// **'Hide remaining text'**
  String get hideRemainingText;

  /// No description provided for @notificationMessageTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification message'**
  String get notificationMessageTitle;

  /// No description provided for @notificationMessageShown.
  ///
  /// In en, this message translates to:
  /// **'Shown'**
  String get notificationMessageShown;

  /// No description provided for @notificationMessageHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get notificationMessageHidden;

  /// No description provided for @widgetTextSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget text size'**
  String get widgetTextSizeTitle;

  /// No description provided for @widgetTextSizeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text size used in the home screen widgets.'**
  String get widgetTextSizeSubtitle;

  /// No description provided for @widgetTextSizeExtraSmall.
  ///
  /// In en, this message translates to:
  /// **'Extra small'**
  String get widgetTextSizeExtraSmall;

  /// No description provided for @widgetTextSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get widgetTextSizeSmall;

  /// No description provided for @widgetTextSizeMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get widgetTextSizeMedium;

  /// No description provided for @widgetTextSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get widgetTextSizeLarge;

  /// No description provided for @remindersOnOffTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders on/off'**
  String get remindersOnOffTitle;

  /// No description provided for @remindersOnOffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn prayer reminder notifications on or off. Per-prayer settings are kept.'**
  String get remindersOnOffSubtitle;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get remindersOn;

  /// No description provided for @remindersOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get remindersOff;

  /// No description provided for @reminderScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'{prayer} Reminder'**
  String reminderScreenTitle(Object prayer);

  /// No description provided for @reminderTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder type (can select both)'**
  String get reminderTypeTitle;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @remindBeforePrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me before prayer'**
  String get remindBeforePrayerTitle;

  /// No description provided for @minutesValue.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesValue(Object minutes);

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @customMinutes.
  ///
  /// In en, this message translates to:
  /// **'Custom minutes'**
  String get customMinutes;

  /// No description provided for @customMinutesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get customMinutesHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @enableBeforeToSelectMinutes.
  ///
  /// In en, this message translates to:
  /// **'Enable \"Before\" to select minutes.'**
  String get enableBeforeToSelectMinutes;

  /// No description provided for @enterValidPositiveNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number.'**
  String get enterValidPositiveNumber;

  /// No description provided for @useValueUpTo240.
  ///
  /// In en, this message translates to:
  /// **'Use a value up to 240 minutes.'**
  String get useValueUpTo240;

  /// No description provided for @customMinutesSaved.
  ///
  /// In en, this message translates to:
  /// **'Custom minutes saved.'**
  String get customMinutesSaved;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'id',
    'ja',
    'tr',
    'ur',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fa':
      return AppLocalizationsFa();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'tr':
      return AppLocalizationsTr();
    case 'ur':
      return AppLocalizationsUr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
