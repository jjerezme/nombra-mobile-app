import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'environment.dart';

/// Overridden in `main()` (and in tests) with the loaded preferences.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

/// Which build this is; overridden in tests.
final appEnvironmentProvider = Provider<AppEnvironment>((ref) => AppEnvironment.current);
