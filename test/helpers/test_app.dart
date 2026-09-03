import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:prayer_assistant/l10n/app_localizations.dart';
import 'package:prayer_assistant/src/controller/prayer_app_controller.dart';
import 'package:prayer_assistant/src/l10n/locale_options.dart';
import 'package:prayer_assistant/src/models/prayer_models.dart';
import 'package:prayer_assistant/src/tesbihat/l10n/tesbihat_localizations.dart';
import 'package:provider/provider.dart';

/// A complete [PrayerDay] for a fixed date, useful across model, service,
/// controller and widget tests.
PrayerDay samplePrayerDay({
  DateTime? date,
  String imsak = '05:10',
  String gunes = '06:42',
  String ogle = '12:35',
  String ikindi = '16:10',
  String aksam = '18:20',
  String yatsi = '19:45',
  String hijriDate = '1 Ramadan 1446',
}) {
  final day = date ?? DateTime(2026, 8, 17);
  return PrayerDay(
    date: day,
    hijriDate: hijriDate,
    imsak: imsak,
    gunes: gunes,
    ogle: ogle,
    ikindi: ikindi,
    aksam: aksam,
    yatsi: yatsi,
  );
}

SelectedLocation sampleSelectedLocation() {
  return SelectedLocation(
    countryId: 'tr',
    countryName: 'Turkiye',
    stateId: '34',
    stateName: 'Istanbul',
    districtId: '541',
    districtName: 'Uskudar',
  );
}

LocationNode sampleLocationNode({
  String id = 'tr',
  String name = 'Türkiye',
  String englishName = 'Turkey',
}) {
  return LocationNode(id: id, name: name, englishName: englishName);
}

/// Wraps [child] in the same localization setup the real app uses, so
/// screens that call `context.l10n` / `context.tesbihatL10n` render fully.
Widget testLocalizedApp({
  required Widget child,
  Locale? locale,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    navigatorKey: navigatorKey,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...TesbihatLocalizations.localizationsDelegates,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: supportedAppLocales,
    home: child,
  );
}

/// Pumps [child] under the full localization setup, ready for screens that
/// read [PrayerAppController] via Provider.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  PrayerAppController? controller,
  bool settle = true,
}) async {
  await initializeDateFormatting();
  Widget app = testLocalizedApp(child: child);
  if (controller != null) {
    app = ChangeNotifierProvider<PrayerAppController>.value(
      value: controller,
      child: app,
    );
  }
  await tester.pumpWidget(app);
  if (settle) {
    await tester.pumpAndSettle();
  }
}