import 'dart:developer' as developer;

import '../config/env.dart';

/// Thin logging seam. Prints in non-prod builds; silent in prod (swap the body
/// for Crashlytics / Sentry breadcrumbs in M6). Call `AppLog.d('msg')`.
abstract final class AppLog {
  static void d(Object? message, {String name = 'bizops'}) =>
      _log(message, name: name, level: 500);

  static void i(Object? message, {String name = 'bizops'}) =>
      _log(message, name: name, level: 800);

  static void w(Object? message, {String name = 'bizops'}) =>
      _log(message, name: name, level: 900);

  static void e(
    Object? message, {
    String name = 'bizops',
    Object? error,
    StackTrace? stackTrace,
  }) => _log(message, name: name, level: 1000, error: error, stack: stackTrace);

  static void _log(
    Object? message, {
    required String name,
    required int level,
    Object? error,
    StackTrace? stack,
  }) {
    if (Env.isProd) return;
    developer.log(
      '$message',
      name: name,
      level: level,
      error: error,
      stackTrace: stack,
    );
  }
}
