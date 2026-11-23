import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

/// Localizations for code that runs without a `BuildContext` (seed data, notifications).
AppLocalizations currentL10n() {
  // Idempotent: reuses the binding when there is one (the app, widget tests).
  final locale = WidgetsFlutterBinding.ensureInitialized().platformDispatcher.locale;
  try {
    return lookupAppLocalizations(Locale(locale.languageCode));
  } on Object {
    return lookupAppLocalizations(const Locale('es'));
  }
}
