import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Language chosen in the settings (`es` or `en`); null follows the system. Kept up to date by the settings notifier.
String? languageOverride;

/// Localizations for code that runs without a `BuildContext` (notifications).
AppLocalizations currentL10n() {
  // Idempotent: reuses the binding when there is one (the app, widget tests).
  final systemLocale = WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locale;
  final code = languageOverride ?? systemLocale.languageCode;
  try {
    return lookupAppLocalizations(Locale(code));
  } on Object {
    return lookupAppLocalizations(const Locale('es'));
  }
}
