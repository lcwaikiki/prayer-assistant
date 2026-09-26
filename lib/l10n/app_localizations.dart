import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_ta.dart';
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
    Locale('bn'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ru'),
    Locale('ta'),
    Locale('tr'),
    Locale('ur'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Assist'**
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

  /// No description provided for @tabTesbih.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get tabTesbih;

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

  /// No description provided for @qiblaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaTitle;

  /// No description provided for @qiblaBearing.
  ///
  /// In en, this message translates to:
  /// **'Qibla: {degrees}°'**
  String qiblaBearing(int degrees);

  /// No description provided for @qiblaLocationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Enable GPS and try again.'**
  String get qiblaLocationUnavailable;

  /// No description provided for @qiblaHeadingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Compass unavailable - showing fixed bearing.'**
  String get qiblaHeadingUnavailable;

  /// No description provided for @qiblaPointDevice.
  ///
  /// In en, this message translates to:
  /// **'Rotate your device until the needle points up.'**
  String get qiblaPointDevice;

  /// No description provided for @qiblaKaabaShort.
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qiblaKaabaShort;

  /// No description provided for @shareTodayTimes.
  ///
  /// In en, this message translates to:
  /// **'Share today\'s times'**
  String get shareTodayTimes;

  /// No description provided for @calendarPreviousDay.
  ///
  /// In en, this message translates to:
  /// **'Previous day'**
  String get calendarPreviousDay;

  /// No description provided for @calendarNextDay.
  ///
  /// In en, this message translates to:
  /// **'Next day'**
  String get calendarNextDay;

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

  /// No description provided for @homeUpcomingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Upcoming reminders'**
  String get homeUpcomingRemindersTitle;

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

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the prayer server. Check your connection and try again.'**
  String get noInternetMessage;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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

  /// No description provided for @homeScreenSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Home screen settings'**
  String get homeScreenSettingsSectionTitle;

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

  /// No description provided for @widgetSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Widget Settings'**
  String get widgetSettingsSectionTitle;

  /// No description provided for @widgetTextSizeTitle.
  ///
  /// In en, this message translates to:
  /// **'Font Size'**
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

  /// No description provided for @widgetTextSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Preview {size}'**
  String widgetTextSizePreview(Object size);

  /// No description provided for @widgetMmssThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Seconds countdown'**
  String get widgetMmssThresholdTitle;

  /// No description provided for @widgetThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Background theme'**
  String get widgetThemeTitle;

  /// No description provided for @widgetThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get widgetThemeSystem;

  /// No description provided for @widgetThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get widgetThemeLight;

  /// No description provided for @widgetThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get widgetThemeDark;

  /// No description provided for @widgetThemeTransparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get widgetThemeTransparent;

  /// No description provided for @widgetCalendarDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar date display'**
  String get widgetCalendarDisplayTitle;

  /// No description provided for @widgetCalendarDisplayBoth.
  ///
  /// In en, this message translates to:
  /// **'Both (Hijri & Gregorian)'**
  String get widgetCalendarDisplayBoth;

  /// No description provided for @widgetCalendarDisplayHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri only'**
  String get widgetCalendarDisplayHijri;

  /// No description provided for @widgetCalendarDisplayGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian only'**
  String get widgetCalendarDisplayGregorian;

  /// No description provided for @widgetMmssThresholdNever.
  ///
  /// In en, this message translates to:
  /// **'Always show HH:MM'**
  String get widgetMmssThresholdNever;

  /// No description provided for @widgetMmssThresholdValue.
  ///
  /// In en, this message translates to:
  /// **'MM:SS below {minutes} min'**
  String widgetMmssThresholdValue(Object minutes);

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

  /// No description provided for @reminderVibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Vibrate on reminder'**
  String get reminderVibrationTitle;

  /// No description provided for @reminderVibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pulse-vibrate for about 10 seconds when a reminder fires.'**
  String get reminderVibrationSubtitle;

  /// No description provided for @reminderSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Play sound on reminder'**
  String get reminderSoundTitle;

  /// No description provided for @reminderSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play the notification sound when a reminder fires.'**
  String get reminderSoundSubtitle;

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

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @reminderAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get reminderAlertTitle;

  /// No description provided for @reminderAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Also needs the matching switch on in Preferences to actually alert.'**
  String get reminderAlertSubtitle;

  /// No description provided for @vibrateChip.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get vibrateChip;

  /// No description provided for @soundChip.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundChip;

  /// No description provided for @adhanChip.
  ///
  /// In en, this message translates to:
  /// **'Adhan'**
  String get adhanChip;

  /// No description provided for @prayersCompleted.
  ///
  /// In en, this message translates to:
  /// **'{completed}/{total} prayers completed'**
  String prayersCompleted(Object completed, Object total);

  /// No description provided for @holiday_islamic_new_year.
  ///
  /// In en, this message translates to:
  /// **'Islamic New Year'**
  String get holiday_islamic_new_year;

  /// No description provided for @holiday_ashura.
  ///
  /// In en, this message translates to:
  /// **'Ashura'**
  String get holiday_ashura;

  /// No description provided for @holiday_mawlid.
  ///
  /// In en, this message translates to:
  /// **'Mawlid al-Nabi'**
  String get holiday_mawlid;

  /// No description provided for @holiday_isra_miraj.
  ///
  /// In en, this message translates to:
  /// **'Isra and Miraj'**
  String get holiday_isra_miraj;

  /// No description provided for @holiday_laylat_barat.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Baraat'**
  String get holiday_laylat_barat;

  /// No description provided for @holiday_ramadan_first.
  ///
  /// In en, this message translates to:
  /// **'First of Ramadan'**
  String get holiday_ramadan_first;

  /// No description provided for @holiday_laylat_qadr.
  ///
  /// In en, this message translates to:
  /// **'Laylat al-Qadr'**
  String get holiday_laylat_qadr;

  /// No description provided for @holiday_eid_fitr.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Fitr'**
  String get holiday_eid_fitr;

  /// No description provided for @holiday_arafah.
  ///
  /// In en, this message translates to:
  /// **'Day of Arafah'**
  String get holiday_arafah;

  /// No description provided for @holiday_eid_adha.
  ///
  /// In en, this message translates to:
  /// **'Eid al-Adha'**
  String get holiday_eid_adha;

  /// No description provided for @remindBeforePrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me before prayer'**
  String get remindBeforePrayerTitle;

  /// No description provided for @remindAfterPrayerTitle.
  ///
  /// In en, this message translates to:
  /// **'Remind me after prayer'**
  String get remindAfterPrayerTitle;

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

  /// No description provided for @enableAfterToSelectMinutes.
  ///
  /// In en, this message translates to:
  /// **'Enable \"After\" to select minutes.'**
  String get enableAfterToSelectMinutes;

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @calendarTabTooltip.
  ///
  /// In en, this message translates to:
  /// **'Hijri calendar'**
  String get calendarTabTooltip;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get calendarNextMonth;

  /// No description provided for @calendarSwapPrimary.
  ///
  /// In en, this message translates to:
  /// **'Switch Hijri/Gregorian'**
  String get calendarSwapPrimary;

  /// No description provided for @calendarShowSecondary.
  ///
  /// In en, this message translates to:
  /// **'Show secondary date'**
  String get calendarShowSecondary;

  /// No description provided for @calendarHideSecondary.
  ///
  /// In en, this message translates to:
  /// **'Hide secondary date'**
  String get calendarHideSecondary;

  /// No description provided for @calendarNoRemindersOnDay.
  ///
  /// In en, this message translates to:
  /// **'No reminders on this day'**
  String get calendarNoRemindersOnDay;

  /// No description provided for @calendarAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get calendarAddReminder;

  /// No description provided for @calendarEditReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get calendarEditReminder;

  /// No description provided for @calendarDeleteReminder.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get calendarDeleteReminder;

  /// No description provided for @calendarDeleteOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Delete this occurrence'**
  String get calendarDeleteOccurrence;

  /// No description provided for @calendarDeleteOccurrenceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove just this day from the series?'**
  String get calendarDeleteOccurrenceConfirm;

  /// No description provided for @calendarOccurrenceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Occurrence deleted'**
  String get calendarOccurrenceDeleted;

  /// No description provided for @calendarExcludedOccurrencesLabel.
  ///
  /// In en, this message translates to:
  /// **'Deleted occurrences'**
  String get calendarExcludedOccurrencesLabel;

  /// No description provided for @calendarRestoreOccurrence.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get calendarRestoreOccurrence;

  /// No description provided for @calendarRestoreAllOccurrences.
  ///
  /// In en, this message translates to:
  /// **'Restore all'**
  String get calendarRestoreAllOccurrences;

  /// No description provided for @calendarReminderFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New reminder'**
  String get calendarReminderFormTitleNew;

  /// No description provided for @calendarReminderFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get calendarReminderFormTitleEdit;

  /// No description provided for @calendarReminderTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get calendarReminderTitleLabel;

  /// No description provided for @calendarReminderTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ramadan starts'**
  String get calendarReminderTitleHint;

  /// No description provided for @calendarReminderNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get calendarReminderNotesLabel;

  /// No description provided for @calendarReminderDateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get calendarReminderDateTimeLabel;

  /// No description provided for @calendarReminderRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get calendarReminderRecurrenceLabel;

  /// No description provided for @calendarRecurrenceOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get calendarRecurrenceOnce;

  /// No description provided for @calendarRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get calendarRecurrenceDaily;

  /// No description provided for @calendarRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get calendarRecurrenceWeekly;

  /// No description provided for @calendarRecurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get calendarRecurrenceMonthly;

  /// No description provided for @calendarRecurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get calendarRecurrenceYearly;

  /// No description provided for @calendarRepeatCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat count'**
  String get calendarRepeatCountLabel;

  /// No description provided for @calendarRepeatCountHelper.
  ///
  /// In en, this message translates to:
  /// **'Number of times the reminder fires before stopping (off = repeats forever)'**
  String get calendarRepeatCountHelper;

  /// No description provided for @calendarRepeatCountError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 2 to 100'**
  String get calendarRepeatCountError;

  /// No description provided for @calendarRepeatDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get calendarRepeatDaysLabel;

  /// No description provided for @calendarDayOfMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get calendarDayOfMonthLabel;

  /// No description provided for @calendarYearlyMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get calendarYearlyMonthLabel;

  /// No description provided for @calendarYearlyDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get calendarYearlyDayLabel;

  /// No description provided for @calendarMonthlyBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly basis'**
  String get calendarMonthlyBasisLabel;

  /// No description provided for @calendarYearlyBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Yearly basis'**
  String get calendarYearlyBasisLabel;

  /// No description provided for @calendarYearlyBasisGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get calendarYearlyBasisGregorian;

  /// No description provided for @calendarYearlyBasisHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get calendarYearlyBasisHijri;

  /// No description provided for @calendarReminderTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get calendarReminderTitleRequired;

  /// No description provided for @calendarAnchorClockTime.
  ///
  /// In en, this message translates to:
  /// **'Calendar date'**
  String get calendarAnchorClockTime;

  /// No description provided for @calendarAnchorPrayerTime.
  ///
  /// In en, this message translates to:
  /// **'Prayer time'**
  String get calendarAnchorPrayerTime;

  /// No description provided for @calendarSelectPrayer.
  ///
  /// In en, this message translates to:
  /// **'Select prayer'**
  String get calendarSelectPrayer;

  /// No description provided for @calendarOffsetOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get calendarOffsetOnTime;

  /// No description provided for @calendarOffsetBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get calendarOffsetBefore;

  /// No description provided for @calendarOffsetAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get calendarOffsetAfter;

  /// No description provided for @calendarPickAnchorDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get calendarPickAnchorDate;

  /// No description provided for @datesPrayerTimesTab.
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get datesPrayerTimesTab;

  /// No description provided for @datesCalendarTab.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get datesCalendarTab;

  /// No description provided for @datesMoonPhaseTab.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get datesMoonPhaseTab;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @calendarReminderDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" deleted'**
  String calendarReminderDeleted(Object title);

  /// No description provided for @verseOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Verse of the Day'**
  String get verseOfTheDay;

  /// No description provided for @hadithOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Hadith of the Day'**
  String get hadithOfTheDay;

  /// No description provided for @hisnAlMuslimTitle.
  ///
  /// In en, this message translates to:
  /// **'Hisn al-Muslim'**
  String get hisnAlMuslimTitle;

  /// No description provided for @morningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Morning Adhkar'**
  String get morningAdhkar;

  /// No description provided for @eveningAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Evening Adhkar'**
  String get eveningAdhkar;

  /// No description provided for @afterPrayerAdhkar.
  ///
  /// In en, this message translates to:
  /// **'After Prayer'**
  String get afterPrayerAdhkar;

  /// No description provided for @sleepingAdhkar.
  ///
  /// In en, this message translates to:
  /// **'Before Sleeping'**
  String get sleepingAdhkar;

  /// No description provided for @dailyLifeDuas.
  ///
  /// In en, this message translates to:
  /// **'Daily Life Duas'**
  String get dailyLifeDuas;

  /// No description provided for @shareWisdom.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareWisdom;

  /// No description provided for @copyText.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copyText;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @searchSupplicationsHint.
  ///
  /// In en, this message translates to:
  /// **'Search supplications...'**
  String get searchSupplicationsHint;

  /// No description provided for @noSupplicationsFound.
  ///
  /// In en, this message translates to:
  /// **'No supplications found'**
  String get noSupplicationsFound;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @tapToCount.
  ///
  /// In en, this message translates to:
  /// **'Tap to count'**
  String get tapToCount;

  /// No description provided for @tabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get tabAll;

  /// No description provided for @kazaTitle.
  ///
  /// In en, this message translates to:
  /// **'Qadaa'**
  String get kazaTitle;

  /// No description provided for @kazaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and make up missed past prayers'**
  String get kazaSubtitle;

  /// No description provided for @kazaCalculatorWizard.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get kazaCalculatorWizard;

  /// No description provided for @kazaBatchLogDay.
  ///
  /// In en, this message translates to:
  /// **'+1 Full Day'**
  String get kazaBatchLogDay;

  /// No description provided for @kazaBatchLogDayTooltip.
  ///
  /// In en, this message translates to:
  /// **'Increment 1 completed count for all 6 prayers'**
  String get kazaBatchLogDayTooltip;

  /// No description provided for @kazaTotalRemaining.
  ///
  /// In en, this message translates to:
  /// **'Total Remaining'**
  String get kazaTotalRemaining;

  /// No description provided for @kazaCompletedProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {target} completed'**
  String kazaCompletedProgress(Object completed, Object target);

  /// No description provided for @kazaEstimatedCompletion.
  ///
  /// In en, this message translates to:
  /// **'Est. Completion: {date}'**
  String kazaEstimatedCompletion(Object date);

  /// No description provided for @kazaEstimatedCompletionFinished.
  ///
  /// In en, this message translates to:
  /// **'All missed prayers completed! 🎉'**
  String get kazaEstimatedCompletionFinished;

  /// No description provided for @kazaDailyPaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Pace'**
  String get kazaDailyPaceLabel;

  /// No description provided for @kazaDailyPaceValue.
  ///
  /// In en, this message translates to:
  /// **'{count} prayers / day'**
  String kazaDailyPaceValue(Object count);

  /// No description provided for @kazaSetPaceDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Daily Pace'**
  String get kazaSetPaceDialogTitle;

  /// No description provided for @kazaSetPaceDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How many missed prayers do you make up each day?'**
  String get kazaSetPaceDialogSubtitle;

  /// No description provided for @kazaCalculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Missed Prayers Calculator'**
  String get kazaCalculatorTitle;

  /// No description provided for @kazaCalculateByYears.
  ///
  /// In en, this message translates to:
  /// **'Missed Time'**
  String get kazaCalculateByYears;

  /// No description provided for @kazaCalculateManual.
  ///
  /// In en, this message translates to:
  /// **'Manual Targets'**
  String get kazaCalculateManual;

  /// No description provided for @kazaYearsMissed.
  ///
  /// In en, this message translates to:
  /// **'Years Missed'**
  String get kazaYearsMissed;

  /// No description provided for @kazaMonthsMissed.
  ///
  /// In en, this message translates to:
  /// **'Additional Months'**
  String get kazaMonthsMissed;

  /// No description provided for @kazaCalculateButton.
  ///
  /// In en, this message translates to:
  /// **'Set Targets'**
  String get kazaCalculateButton;

  /// No description provided for @kazaWitrLabel.
  ///
  /// In en, this message translates to:
  /// **'Witr'**
  String get kazaWitrLabel;

  /// No description provided for @kazaRemainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String kazaRemainingCount(Object count);

  /// No description provided for @kazaEditCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} Completed Count'**
  String kazaEditCompletedTitle(Object name);

  /// No description provided for @kazaCalculatedDaysPerPrayer.
  ///
  /// In en, this message translates to:
  /// **'= {days} days per prayer ({total} total prayers)'**
  String kazaCalculatedDaysPerPrayer(Object days, Object total);

  /// No description provided for @backupExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup & Export'**
  String get backupExportTitle;

  /// No description provided for @backupExportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Backup app data or export calendar schedules'**
  String get backupExportSubtitle;

  /// No description provided for @exportBackupJson.
  ///
  /// In en, this message translates to:
  /// **'Export Backup Data (JSON)'**
  String get exportBackupJson;

  /// No description provided for @restoreBackupJson.
  ///
  /// In en, this message translates to:
  /// **'Restore Data from Backup'**
  String get restoreBackupJson;

  /// No description provided for @exportPrayerScheduleIcs.
  ///
  /// In en, this message translates to:
  /// **'Export Prayer Schedule (.ics)'**
  String get exportPrayerScheduleIcs;

  /// No description provided for @exportHolidaysIcs.
  ///
  /// In en, this message translates to:
  /// **'Export Islamic Holidays (.ics)'**
  String get exportHolidaysIcs;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore App Data?'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will restore your Qadaa targets, prayer history, reminders, and Tesbihat data. Continue?'**
  String get restoreConfirmBody;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully!'**
  String get restoreSuccess;

  /// No description provided for @restoreNewerVersionError.
  ///
  /// In en, this message translates to:
  /// **'This backup was created by a newer app version. Please update the app and try again.'**
  String get restoreNewerVersionError;

  /// No description provided for @restoreError.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file format'**
  String get restoreError;

  /// Button label to share or save exported file
  ///
  /// In en, this message translates to:
  /// **'Share / Save'**
  String get shareOrSave;

  /// No description provided for @googleDriveSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Google Drive'**
  String get googleDriveSignIn;

  /// No description provided for @googleDriveSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Google Drive'**
  String get googleDriveSignOut;

  /// No description provided for @googleDriveBackup.
  ///
  /// In en, this message translates to:
  /// **'Save Backup to Google Drive'**
  String get googleDriveBackup;

  /// No description provided for @googleDriveRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from Google Drive'**
  String get googleDriveRestore;

  /// No description provided for @googleDriveBackupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to Google Drive'**
  String get googleDriveBackupSuccess;

  /// No description provided for @googleDriveBackupError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save backup to Google Drive'**
  String get googleDriveBackupError;

  /// No description provided for @googleDriveWorking.
  ///
  /// In en, this message translates to:
  /// **'Working...'**
  String get googleDriveWorking;

  /// No description provided for @googleDriveRestoreConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will restore data from your Google Drive backup. Continue?'**
  String get googleDriveRestoreConfirm;

  /// Shows when the last Google Drive backup was made
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String googleDriveLastBackup(String date);

  /// No description provided for @googleDriveNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use Google Drive backup'**
  String get googleDriveNotSignedIn;

  /// No description provided for @googleDriveSignInError.
  ///
  /// In en, this message translates to:
  /// **'Failed to sign in to Google Drive'**
  String get googleDriveSignInError;

  /// No description provided for @googleDriveConfigError.
  ///
  /// In en, this message translates to:
  /// **'Google Drive sign-in is not configured. Add the web OAuth client ID via --dart-define=GOOGLE_SERVER_CLIENT_ID and the SHA-1 fingerprint in Google Cloud Console.'**
  String get googleDriveConfigError;

  /// No description provided for @googleDriveSignOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of Google Drive?'**
  String get googleDriveSignOutConfirmTitle;

  /// Confirmation message when signing out of Google Drive
  ///
  /// In en, this message translates to:
  /// **'Sign out using {email}? You can sign in again later.'**
  String googleDriveSignOutConfirmBody(String email);

  /// No description provided for @googleDriveRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backups found on Google Drive.'**
  String get googleDriveRestoreEmpty;

  /// No description provided for @driveRestorePromptBody.
  ///
  /// In en, this message translates to:
  /// **'No data found on this device. Restore your data from Google Drive?'**
  String get driveRestorePromptBody;

  /// No description provided for @offlineFolderChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose backup folder'**
  String get offlineFolderChoose;

  /// No description provided for @offlineFolderChange.
  ///
  /// In en, this message translates to:
  /// **'Change backup folder'**
  String get offlineFolderChange;

  /// No description provided for @offlineFolderNone.
  ///
  /// In en, this message translates to:
  /// **'No folder chosen. Backups are not saved offline.'**
  String get offlineFolderNone;

  /// No description provided for @offlineFolderSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved to folder.'**
  String get offlineFolderSaved;

  /// No description provided for @offlineFolderRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore from backup folder'**
  String get offlineFolderRestore;

  /// No description provided for @offlineFolderRestoreEmpty.
  ///
  /// In en, this message translates to:
  /// **'No backup file found in the chosen folder.'**
  String get offlineFolderRestoreEmpty;

  /// No description provided for @offlineFolderRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove backup folder'**
  String get offlineFolderRemove;

  /// No description provided for @restoreOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'What to restore?'**
  String get restoreOptionsTitle;

  /// No description provided for @restoreOptionsData.
  ///
  /// In en, this message translates to:
  /// **'App data'**
  String get restoreOptionsData;

  /// No description provided for @restoreOptionsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get restoreOptionsPreferences;

  /// Number of items in a backup
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String googleDriveBackupItemCount(int count);

  /// No description provided for @googleDriveHistoryLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup history length'**
  String get googleDriveHistoryLimitTitle;

  /// No description provided for @googleDriveHistoryLimitAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get googleDriveHistoryLimitAll;

  /// No description provided for @analyticsTab.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsTab;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @monthlyHeatmapTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Completion'**
  String get monthlyHeatmapTitle;

  /// No description provided for @completionBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Breakdown'**
  String get completionBreakdownTitle;

  /// No description provided for @overallConsistency.
  ///
  /// In en, this message translates to:
  /// **'Overall Consistency'**
  String get overallConsistency;

  /// No description provided for @totalPrayersCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total Prayers Logged'**
  String get totalPrayersCompleted;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @fastingTitle.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fastingTitle;

  /// No description provided for @suhoorCountdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Suhoor'**
  String get suhoorCountdownTitle;

  /// No description provided for @iftarCountdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Time to Iftar'**
  String get iftarCountdownTitle;

  /// No description provided for @fastingTypeRamadan.
  ///
  /// In en, this message translates to:
  /// **'Ramadan Fast'**
  String get fastingTypeRamadan;

  /// No description provided for @fastingTypeSunnah.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Fast'**
  String get fastingTypeSunnah;

  /// No description provided for @fastingTypeQadaa.
  ///
  /// In en, this message translates to:
  /// **'Make-up (Qadaa) Fast'**
  String get fastingTypeQadaa;

  /// No description provided for @whiteDaysTitle.
  ///
  /// In en, this message translates to:
  /// **'White Days (13th, 14th, 15th)'**
  String get whiteDaysTitle;

  /// No description provided for @mondayThursdayTitle.
  ///
  /// In en, this message translates to:
  /// **'Monday & Thursday Sunnah'**
  String get mondayThursdayTitle;

  /// No description provided for @logFastAction.
  ///
  /// In en, this message translates to:
  /// **'Log Fast'**
  String get logFastAction;

  /// No description provided for @totalFastsLogged.
  ///
  /// In en, this message translates to:
  /// **'Total Fasts Logged'**
  String get totalFastsLogged;

  /// No description provided for @suhoorEndsIn.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ends in'**
  String get suhoorEndsIn;

  /// No description provided for @iftarIn.
  ///
  /// In en, this message translates to:
  /// **'Iftar in'**
  String get iftarIn;

  /// No description provided for @fastingTab.
  ///
  /// In en, this message translates to:
  /// **'Fasting'**
  String get fastingTab;

  /// No description provided for @trackTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Track'**
  String get trackTabTitle;

  /// No description provided for @prayerAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Analytics'**
  String get prayerAnalyticsTitle;

  /// No description provided for @prayerQadaaTitle.
  ///
  /// In en, this message translates to:
  /// **'Prayer Qadaa'**
  String get prayerQadaaTitle;

  /// No description provided for @iftarTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Iftar Time'**
  String get iftarTimeLabel;

  /// No description provided for @fastingProgressFasted.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Fasted'**
  String fastingProgressFasted(int percent);

  /// No description provided for @suhoorTickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Suhoor Ticker'**
  String get suhoorTickerTitle;

  /// No description provided for @fastingProgressElapsed.
  ///
  /// In en, this message translates to:
  /// **'{percent}% elapsed'**
  String fastingProgressElapsed(String percent);

  /// No description provided for @suhoorWithTime.
  ///
  /// In en, this message translates to:
  /// **'Suhoor ({time})'**
  String suhoorWithTime(String time);

  /// No description provided for @iftarWithTime.
  ///
  /// In en, this message translates to:
  /// **'Iftar ({time})'**
  String iftarWithTime(String time);

  /// No description provided for @upcomingSunnahDays.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Sunnah Days'**
  String get upcomingSunnahDays;

  /// No description provided for @fastingCalendarLogger.
  ///
  /// In en, this message translates to:
  /// **'Fasting Calendar Logger'**
  String get fastingCalendarLogger;

  /// No description provided for @removeFastLog.
  ///
  /// In en, this message translates to:
  /// **'Remove Fast Log'**
  String get removeFastLog;

  /// No description provided for @calendarWeekStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Week Starts On'**
  String get calendarWeekStartTitle;

  /// No description provided for @calendarWeekStartSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get calendarWeekStartSunday;

  /// No description provided for @calendarWeekStartMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get calendarWeekStartMonday;

  /// No description provided for @hijriDateOffsetTitle.
  ///
  /// In en, this message translates to:
  /// **'Hijri Date Adjustment'**
  String get hijriDateOffsetTitle;

  /// No description provided for @hijriDateOffsetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust Hijri date for local moon sightings'**
  String get hijriDateOffsetSubtitle;

  /// No description provided for @showIslamicHolidaysTitle.
  ///
  /// In en, this message translates to:
  /// **'Highlight Islamic Holidays'**
  String get showIslamicHolidaysTitle;

  /// No description provided for @showIslamicHolidaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show special badges for Islamic holy days'**
  String get showIslamicHolidaysSubtitle;

  /// No description provided for @showFastingBadgesTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Fasting Logs on Calendar'**
  String get showFastingBadgesTitle;

  /// No description provided for @showFastingBadgesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display badges on dates with logged fasts'**
  String get showFastingBadgesSubtitle;

  /// No description provided for @defaultCalendarDisplayTitle.
  ///
  /// In en, this message translates to:
  /// **'Default Calendar View'**
  String get defaultCalendarDisplayTitle;

  /// No description provided for @defaultCalendarDisplaySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Initial basis when opening the calendar'**
  String get defaultCalendarDisplaySubtitle;

  /// No description provided for @showCalendarReminderDotsTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Reminder Indicator Dots'**
  String get showCalendarReminderDotsTitle;

  /// No description provided for @showCalendarReminderDotsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display dots on day cells with scheduled reminders'**
  String get showCalendarReminderDotsSubtitle;

  /// No description provided for @calendarSettingsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar Settings'**
  String get calendarSettingsSectionTitle;

  /// No description provided for @moonPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase'**
  String get moonPhaseTitle;

  /// No description provided for @moonIllumination.
  ///
  /// In en, this message translates to:
  /// **'{percent}% Illuminated'**
  String moonIllumination(int percent);

  /// No description provided for @moonAgeDays.
  ///
  /// In en, this message translates to:
  /// **'Day {days} of cycle'**
  String moonAgeDays(String days);

  /// No description provided for @moonPhaseNewMoon.
  ///
  /// In en, this message translates to:
  /// **'New Moon (Hilal)'**
  String get moonPhaseNewMoon;

  /// No description provided for @moonPhaseWaxingCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waxing Crescent'**
  String get moonPhaseWaxingCrescent;

  /// No description provided for @moonPhaseFirstQuarter.
  ///
  /// In en, this message translates to:
  /// **'First Quarter'**
  String get moonPhaseFirstQuarter;

  /// No description provided for @moonPhaseWaxingGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waxing Gibbous'**
  String get moonPhaseWaxingGibbous;

  /// No description provided for @moonPhaseFullMoon.
  ///
  /// In en, this message translates to:
  /// **'Full Moon (Badr)'**
  String get moonPhaseFullMoon;

  /// No description provided for @moonPhaseWaningGibbous.
  ///
  /// In en, this message translates to:
  /// **'Waning Gibbous'**
  String get moonPhaseWaningGibbous;

  /// No description provided for @moonPhaseLastQuarter.
  ///
  /// In en, this message translates to:
  /// **'Last Quarter'**
  String get moonPhaseLastQuarter;

  /// No description provided for @moonPhaseWaningCrescent.
  ///
  /// In en, this message translates to:
  /// **'Waning Crescent'**
  String get moonPhaseWaningCrescent;

  /// No description provided for @whiteDaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sunnah Fasting Days (13, 14, 15 Hijri)'**
  String get whiteDaysSubtitle;

  /// No description provided for @homeDashboardCardsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Dashboard Cards'**
  String get homeDashboardCardsSectionTitle;

  /// No description provided for @showCardMoonPhaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Moon Phase Card'**
  String get showCardMoonPhaseTitle;

  /// No description provided for @showCardMoonPhaseSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display vector moon phase and White Days card'**
  String get showCardMoonPhaseSubtitle;

  /// No description provided for @showCardIftarSuhoorTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Suhoor & Iftar Card'**
  String get showCardIftarSuhoorTitle;

  /// No description provided for @showCardIftarSuhoorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display live Suhoor and Iftar countdown card'**
  String get showCardIftarSuhoorSubtitle;

  /// No description provided for @showCardDailyWisdomTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Daily Wisdom Card'**
  String get showCardDailyWisdomTitle;

  /// No description provided for @showCardDailyWisdomSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display daily inspirational Hadith or verse card'**
  String get showCardDailyWisdomSubtitle;

  /// No description provided for @showCardUpcomingRemindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Show Upcoming Reminders Card'**
  String get showCardUpcomingRemindersTitle;

  /// No description provided for @showCardUpcomingRemindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Display card listing your next 3 upcoming calendar reminders'**
  String get showCardUpcomingRemindersSubtitle;

  /// No description provided for @moonCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Moon Phase Calendar'**
  String get moonCalendarTitle;

  /// No description provided for @calendarGoToDate.
  ///
  /// In en, this message translates to:
  /// **'Go to date'**
  String get calendarGoToDate;

  /// No description provided for @whiteDaysBannerPrefix.
  ///
  /// In en, this message translates to:
  /// **'White Days (13, 14, 15)'**
  String get whiteDaysBannerPrefix;

  /// No description provided for @beadsAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Beads Counter'**
  String get beadsAppTitle;

  /// No description provided for @beadsMilestones.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get beadsMilestones;

  /// No description provided for @beadsSwitchToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get beadsSwitchToLight;

  /// No description provided for @beadsSwitchToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get beadsSwitchToDark;

  /// No description provided for @beadsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get beadsLanguage;

  /// No description provided for @beadsChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get beadsChooseLanguage;

  /// No description provided for @beadsNoMilestones.
  ///
  /// In en, this message translates to:
  /// **'No beads yet. Tap + to add one.'**
  String get beadsNoMilestones;

  /// No description provided for @beadsStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get beadsStatsTitle;

  /// No description provided for @beadsStatsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get beadsStatsToday;

  /// No description provided for @beadsStatsLast7Days.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get beadsStatsLast7Days;

  /// No description provided for @beadsStatsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get beadsStatsTotal;

  /// No description provided for @beadsDeleted.
  ///
  /// In en, this message translates to:
  /// **'deleted'**
  String get beadsDeleted;

  /// No description provided for @beadsUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get beadsUndo;

  /// No description provided for @beadsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get beadsEdit;

  /// No description provided for @beadsDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get beadsDuplicate;

  /// No description provided for @beadsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get beadsClear;

  /// No description provided for @beadsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get beadsDelete;

  /// No description provided for @beadsCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get beadsCount;

  /// No description provided for @beadsCheck.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get beadsCheck;

  /// No description provided for @beadsSet.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get beadsSet;

  /// No description provided for @beadsProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get beadsProgress;

  /// No description provided for @beadsCreateMilestone.
  ///
  /// In en, this message translates to:
  /// **'Create Beads'**
  String get beadsCreateMilestone;

  /// No description provided for @beadsEditMilestone.
  ///
  /// In en, this message translates to:
  /// **'Edit Beads'**
  String get beadsEditMilestone;

  /// No description provided for @beadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get beadsTitle;

  /// No description provided for @beadsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get beadsNotes;

  /// No description provided for @beadsNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes for these beads...'**
  String get beadsNotesHint;

  /// No description provided for @beadsCountField.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get beadsCountField;

  /// No description provided for @beadsCheckInterval.
  ///
  /// In en, this message translates to:
  /// **'Check Interval'**
  String get beadsCheckInterval;

  /// No description provided for @beadsCheckHelper.
  ///
  /// In en, this message translates to:
  /// **'Less or equal to half of count. Leave empty or 0 for no checkpoints.'**
  String get beadsCheckHelper;

  /// No description provided for @beadsSetCount.
  ///
  /// In en, this message translates to:
  /// **'Set Count'**
  String get beadsSetCount;

  /// No description provided for @beadsSetCountHelper.
  ///
  /// In en, this message translates to:
  /// **'Set count must be less than or equal to count.'**
  String get beadsSetCountHelper;

  /// No description provided for @beadsSetCountReadonlyHelper.
  ///
  /// In en, this message translates to:
  /// **'Set count can only be changed from progress screen.'**
  String get beadsSetCountReadonlyHelper;

  /// No description provided for @beadsVibrationIntensity.
  ///
  /// In en, this message translates to:
  /// **'Vibration Intensity'**
  String get beadsVibrationIntensity;

  /// No description provided for @beadsReminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get beadsReminderTitle;

  /// No description provided for @beadsReminderEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable reminder'**
  String get beadsReminderEnable;

  /// No description provided for @beadsReminderRepeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get beadsReminderRepeatOnce;

  /// No description provided for @beadsReminderRepeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get beadsReminderRepeatDaily;

  /// No description provided for @beadsReminderRepeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get beadsReminderRepeatWeekly;

  /// No description provided for @beadsReminderRepeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get beadsReminderRepeatMonthly;

  /// No description provided for @beadsReminderRepeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get beadsReminderRepeatYearly;

  /// No description provided for @beadsReminderRepeatCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat count'**
  String get beadsReminderRepeatCountLabel;

  /// No description provided for @beadsReminderRepeatCountHelper.
  ///
  /// In en, this message translates to:
  /// **'Number of times the reminder fires before stopping (off = repeats forever)'**
  String get beadsReminderRepeatCountHelper;

  /// No description provided for @beadsReminderRepeatCountRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a number from 2 to 100'**
  String get beadsReminderRepeatCountRangeError;

  /// No description provided for @beadsReminderRepeatDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get beadsReminderRepeatDaysLabel;

  /// No description provided for @beadsReminderDayOfMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get beadsReminderDayOfMonthLabel;

  /// No description provided for @beadsReminderYearlyMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get beadsReminderYearlyMonthLabel;

  /// No description provided for @beadsReminderYearlyDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get beadsReminderYearlyDayLabel;

  /// No description provided for @beadsReminderRecurrenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get beadsReminderRecurrenceLabel;

  /// No description provided for @beadsReminderMonthlyBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly basis'**
  String get beadsReminderMonthlyBasisLabel;

  /// No description provided for @beadsReminderYearlyBasisLabel.
  ///
  /// In en, this message translates to:
  /// **'Yearly basis'**
  String get beadsReminderYearlyBasisLabel;

  /// No description provided for @beadsReminderBasisGregorian.
  ///
  /// In en, this message translates to:
  /// **'Gregorian'**
  String get beadsReminderBasisGregorian;

  /// No description provided for @beadsReminderBasisHijri.
  ///
  /// In en, this message translates to:
  /// **'Hijri'**
  String get beadsReminderBasisHijri;

  /// No description provided for @beadsReminderPickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick date & time'**
  String get beadsReminderPickDateTime;

  /// No description provided for @beadsReminderPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get beadsReminderPickDate;

  /// No description provided for @beadsReminderPickTime.
  ///
  /// In en, this message translates to:
  /// **'Pick time'**
  String get beadsReminderPickTime;

  /// No description provided for @beadsReminderNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get beadsReminderNotSet;

  /// No description provided for @beadsReminderAnchorTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get beadsReminderAnchorTime;

  /// No description provided for @beadsReminderAnchorPrayer.
  ///
  /// In en, this message translates to:
  /// **'Prayer time'**
  String get beadsReminderAnchorPrayer;

  /// No description provided for @beadsReminderOffsetOnTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get beadsReminderOffsetOnTime;

  /// No description provided for @beadsReminderOffsetBefore.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beadsReminderOffsetBefore;

  /// No description provided for @beadsReminderOffsetAfter.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get beadsReminderOffsetAfter;

  /// No description provided for @beadsReminderMinutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get beadsReminderMinutesLabel;

  /// No description provided for @beadsReminderSelectPrayer.
  ///
  /// In en, this message translates to:
  /// **'Select prayer'**
  String get beadsReminderSelectPrayer;

  /// No description provided for @beadsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get beadsSave;

  /// No description provided for @beadsUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get beadsUpdate;

  /// No description provided for @beadsRequiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'is required'**
  String get beadsRequiredSuffix;

  /// No description provided for @beadsMustBeInteger.
  ///
  /// In en, this message translates to:
  /// **'must be an integer'**
  String get beadsMustBeInteger;

  /// No description provided for @beadsCountPositive.
  ///
  /// In en, this message translates to:
  /// **'Count must be a positive integer'**
  String get beadsCountPositive;

  /// No description provided for @beadsCheckGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Check must be greater than 0'**
  String get beadsCheckGreaterThanZero;

  /// No description provided for @beadsCheckHalfError.
  ///
  /// In en, this message translates to:
  /// **'Check cannot be greater than half of count'**
  String get beadsCheckHalfError;

  /// No description provided for @beadsEnterValidCountFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid count first'**
  String get beadsEnterValidCountFirst;

  /// No description provided for @beadsSetCountNegative.
  ///
  /// In en, this message translates to:
  /// **'Set count cannot be negative'**
  String get beadsSetCountNegative;

  /// No description provided for @beadsSetCountGreaterCount.
  ///
  /// In en, this message translates to:
  /// **'Set count cannot be greater than count'**
  String get beadsSetCountGreaterCount;

  /// No description provided for @beadsSetCountValueRequired.
  ///
  /// In en, this message translates to:
  /// **'Set count is required'**
  String get beadsSetCountValueRequired;

  /// No description provided for @beadsItemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get beadsItemNotFound;

  /// No description provided for @beadsResetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset progress?'**
  String get beadsResetProgressTitle;

  /// No description provided for @beadsResetProgressBody.
  ///
  /// In en, this message translates to:
  /// **'This will set current progress back to 0.'**
  String get beadsResetProgressBody;

  /// No description provided for @beadsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get beadsCancel;

  /// No description provided for @beadsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get beadsReset;

  /// No description provided for @beadsEditProgressAndSetCount.
  ///
  /// In en, this message translates to:
  /// **'Edit progress and set count'**
  String get beadsEditProgressAndSetCount;

  /// No description provided for @beadsProgressCount.
  ///
  /// In en, this message translates to:
  /// **'Progress Count'**
  String get beadsProgressCount;

  /// No description provided for @beadsSetCountCannotNegative.
  ///
  /// In en, this message translates to:
  /// **'Set count cannot be negative'**
  String get beadsSetCountCannotNegative;

  /// No description provided for @beadsValidProgressNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid progress number'**
  String get beadsValidProgressNumber;

  /// No description provided for @beadsProgressBetween.
  ///
  /// In en, this message translates to:
  /// **'Progress must be between 0 and {max}'**
  String beadsProgressBetween(int max);

  /// No description provided for @beadsMaxMinusCount.
  ///
  /// In en, this message translates to:
  /// **'Left Count'**
  String get beadsMaxMinusCount;

  /// No description provided for @beadsTap.
  ///
  /// In en, this message translates to:
  /// **'TAP'**
  String get beadsTap;

  /// No description provided for @beadsGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get beadsGroups;

  /// No description provided for @beadsNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get beadsNewGroup;

  /// No description provided for @beadsEditGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit Group'**
  String get beadsEditGroup;

  /// No description provided for @beadsGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get beadsGroupName;

  /// No description provided for @beadsGroupMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get beadsGroupMembers;

  /// No description provided for @beadsNoBeadsInGroup.
  ///
  /// In en, this message translates to:
  /// **'No beads in this group yet.'**
  String get beadsNoBeadsInGroup;

  /// No description provided for @beadsAddBead.
  ///
  /// In en, this message translates to:
  /// **'Add bead'**
  String get beadsAddBead;

  /// No description provided for @beadsAddBeads.
  ///
  /// In en, this message translates to:
  /// **'Add beads'**
  String get beadsAddBeads;

  /// No description provided for @beadsNewBead.
  ///
  /// In en, this message translates to:
  /// **'New Bead'**
  String get beadsNewBead;

  /// No description provided for @beadsDeleteGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete Group'**
  String get beadsDeleteGroup;

  /// No description provided for @beadsDeleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this group? Its beads are kept.'**
  String get beadsDeleteGroupConfirm;

  /// No description provided for @beadsRemoveFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove from group'**
  String get beadsRemoveFromGroup;

  /// No description provided for @beadsNoNotesAdded.
  ///
  /// In en, this message translates to:
  /// **'No notes added.'**
  String get beadsNoNotesAdded;

  /// No description provided for @beadsSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get beadsSelect;

  /// No description provided for @beadsSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get beadsSelectAll;

  /// No description provided for @beadsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String beadsSelectedCount(int count);

  /// No description provided for @beadsDeleteSelectedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} selected items?'**
  String beadsDeleteSelectedConfirm(int count);

  /// No description provided for @beadsDeletedSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} deleted'**
  String beadsDeletedSelected(int count);

  /// No description provided for @notificationActionSnooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get notificationActionSnooze;

  /// No description provided for @notificationActionDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get notificationActionDismiss;

  /// No description provided for @notificationActionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get notificationActionDone;

  /// No description provided for @snoozeDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Snooze Duration'**
  String get snoozeDurationTitle;

  /// No description provided for @snoozeDurationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Duration before reminding again'**
  String get snoozeDurationSubtitle;

  /// No description provided for @snoozeMinutesOption.
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes'**
  String snoozeMinutesOption(int minutes);
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
    'bn',
    'de',
    'en',
    'es',
    'fa',
    'fr',
    'id',
    'ja',
    'ru',
    'ta',
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
    case 'bn':
      return AppLocalizationsBn();
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
    case 'ru':
      return AppLocalizationsRu();
    case 'ta':
      return AppLocalizationsTa();
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
