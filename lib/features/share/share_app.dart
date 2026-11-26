import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/app.dart';
import '../../core/conflict_prompt.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../download/data/downloads_notifier.dart';
import '../settings/app_settings.dart';
import 'share_sheet_screen.dart';

/// The app shown by ShareActivity: only the "Save with Nombra" sheet, over a transparent window.
class ShareApp extends ConsumerWidget {
  const ShareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the downloads listener alive so a finished download is saved while the sheet is open.
    ref.listen(downloadsProvider, (previous, next) {});
    final settings = ref.watch(settingsProvider);
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
      onGenerateTitle: (context) => AppLocalizations.of(context).shareTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeFor(settings),
      locale: localeFor(settings),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShareSheetScreen(),
    );
  }
}
