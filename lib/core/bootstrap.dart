import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crash_reporting.dart';
import 'environment.dart';

/// Initializes Firebase from the native config (google-services.json of the
/// flavor) and routes uncaught errors to Crashlytics, without any link they carry.
///
/// If the config file is missing (a fresh checkout) the app still starts, and
/// the reason is logged, so UI work does not depend on Firebase. Returns whether Firebase started.
Future<bool> initFirebase() async {
  try {
    await Firebase.initializeApp();
    await _activateAppCheck();
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

/// App Check: Play Integrity in production; the debug provider in development (register the token it logs in the
/// console of the dev project). A failure never stops the app: enforcement is decided in the Firebase console.
Future<void> _activateAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      providerAndroid: AppEnvironment.current.isProduction
          ? const AndroidPlayIntegrityProvider()
          : const AndroidDebugProvider(),
    );
  } on Object catch (error) {
    debugPrint('App Check is not available: ${redactUrls('$error')}');
  }
}
