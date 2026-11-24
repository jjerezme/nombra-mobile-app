import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/environment.dart';
import '../core/providers.dart';
import '../core/theme/app_theme.dart';
import '../features/download/data/downloads_notifier.dart';
import '../features/rules/data/rules_notifier.dart';
import '../features/settings/app_settings.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';

/// Localization delegates shared by the main app and the share sheet.
List<LocalizationsDelegate<dynamic>> get appLocalizationsDelegates => [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// The language chosen in the settings as a locale; null follows the system.
Locale? localeFor(AppSettings settings) => settings.languageCode == null ? null : Locale(settings.languageCode!);

ThemeMode themeModeFor(AppSettings settings) => switch (settings.themeMode) {
  AppThemeMode.system => ThemeMode.system,
  AppThemeMode.light => ThemeMode.light,
  AppThemeMode.dark => ThemeMode.dark,
};

class NombraApp extends ConsumerStatefulWidget {
  const NombraApp({super.key});

  @override
  ConsumerState<NombraApp> createState() => _NombraAppState();
}

class _NombraAppState extends ConsumerState<NombraApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The share sheet runs in its own engine and writes to the same preferences: reload them on return.
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    await ref.read(sharedPreferencesProvider).reload();
    ref
      ..invalidate(settingsProvider)
      ..invalidate(rulesProvider)
      ..invalidate(downloadsProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the downloads listener alive so finished downloads are saved wherever the user is.
    ref.listen(downloadsProvider, (previous, next) {});
    final settings = ref.watch(settingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppEnvironment.current.name,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeModeFor(settings),
      locale: localeFor(settings),
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
