import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/bootstrap.dart';
import 'core/conflict_prompt.dart';
import 'core/providers.dart';
import 'features/download/data/downloads_notifier.dart';
import 'features/share/share_app.dart';

Future<ProviderScope> _scopeFor(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  final preferences = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(preferences),
      conflictPromptProvider.overrideWithValue(promptConflict),
    ],
    child: app,
  );
}

Future<void> main() async {
  runApp(await _scopeFor(const NombraApp()));
}

/// Entry point of ShareActivity: the "Save with Nombra" sheet shown over the app that shares a file or link.
@pragma('vm:entry-point')
Future<void> shareMain() async {
  runApp(await _scopeFor(const ShareApp()));
}
