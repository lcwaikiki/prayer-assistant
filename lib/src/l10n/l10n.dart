import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

export 'prayer_names.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
