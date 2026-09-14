import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../utils/logger.dart';

/// The seam production error reporting plugs into. The default
/// [LoggingCrashReporter] just writes to [AppLog]; swap in a Sentry /
/// Crashlytics-backed implementation from `bootstrap.dart` once that's wired
/// (see docs/HANDOFF.md M6).
abstract class CrashReporter {
  static CrashReporter instance = const LoggingCrashReporter();

  const CrashReporter();

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? context,
  });

  /// A breadcrumb — low-signal, high-volume trail leading up to a crash.
  void breadcrumb(String message);

  /// Attach a tag to every subsequent report (user id, tenant, screen).
  void setKey(String key, Object? value);
}

/// No-op — for tests and any build that opts out of reporting.
class NoopCrashReporter extends CrashReporter {
  const NoopCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? context,
  }) async {}

  @override
  void breadcrumb(String message) {}

  @override
  void setKey(String key, Object? value) {}
}

/// Default: route everything through [AppLog]. Silent in prod (AppLog is), so
/// this is effectively a no-op there until a real backend is attached.
class LoggingCrashReporter extends CrashReporter {
  const LoggingCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? context,
  }) async {
    AppLog.e(
      '${fatal ? 'FATAL' : 'error'}${context == null ? '' : ' [$context]'}',
      name: 'crash',
      error: error,
      stackTrace: stack,
    );
  }

  @override
  void breadcrumb(String message) => AppLog.d(message, name: 'crumb');

  @override
  void setKey(String key, Object? value) =>
      AppLog.d('$key = $value', name: 'crash.key');
}

/// Wire Flutter's error channels into [CrashReporter.instance]. Call once from
/// `bootstrap.dart` before `runApp`.
void installCrashHandlers() {
  final reporter = CrashReporter.instance;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reporter.recordError(
      details.exception,
      details.stack,
      context: details.context?.toDescription(),
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    reporter.recordError(error, stack, fatal: true);
    return true;
  };

  if (!Env.isProd) {
    reporter.breadcrumb('crash handlers installed (${Env.flavor.name})');
  }
}
