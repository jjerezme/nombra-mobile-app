import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crash_reporting.dart';

/// Initializes Firebase from the native config (google-services.json of the
/// flavor) and routes uncaught errors to Crashlytics, without any link they carry.
///
/// If the config file is missing (a fresh checkout) the app still starts, and
/// the reason is logged, so UI work does not depend on Firebase. Returns whether Firebase started.
Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = (details) => FirebaseCrashlytics.instance.recordError(
      RedactedError(details.exception),
      details.stack,
      reason: redactUrls(details.context?.toDescription() ?? ''),
      fatal: true,
    );
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(RedactedError(error), stack, fatal: true);
      return true;
    };
    return true;
  } on Object catch (error) {
    debugPrint('Firebase is not available: $error');
    return false;
  }
}
