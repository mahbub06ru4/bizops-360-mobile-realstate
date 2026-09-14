import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';

/// [CrashReporter] backed by Firebase Crashlytics. Installed from
/// `bootstrap.dart` only when `Firebase.initializeApp` succeeded.
class FirebaseCrashReporter extends CrashReporter {
  FirebaseCrashReporter() {
    _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);
  }

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? context,
  }) => _crashlytics.recordError(error, stack, reason: context, fatal: fatal);

  @override
  void breadcrumb(String message) => _crashlytics.log(message);

  @override
  void setKey(String key, Object? value) {
    _crashlytics.setCustomKey(key, value?.toString() ?? 'null');
    if (key == 'user_id') {
      _crashlytics.setUserIdentifier(value?.toString() ?? '');
    }
  }
}
