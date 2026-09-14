import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import '../../core/notifications/local_notifications.dart';
import '../../core/observability/crash_reporter.dart';
import '../../core/utils/logger.dart';
import '../../domain/repositories/device_repository.dart';

/// Runs in a **separate background isolate** when a push arrives while the app
/// is backgrounded or killed. Notification-type messages are drawn by the OS
/// tray on their own; this surfaces data-only messages so they aren't silently
/// dropped. Must stay top-level / `vm:entry-point`.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null || message.data.isEmpty) return;

  final local = LocalNotifications();
  await local.init();
  await local.show(
    title: message.data['title'] as String?,
    body: message.data['body'] as String?,
    payload: message.data['route'] as String?,
  );
}

/// End-to-end Firebase Cloud Messaging: permission, token lifecycle, backend
/// device registration, foreground display, and deep-linking a tap to a route.
/// Registered permanent + `init()`ed from `bootstrap.dart` when Firebase is up.
class PushService {
  PushService(
    this._devices, {
    FirebaseMessaging? messaging,
    LocalNotifications? local,
  }) : _fm = messaging ?? FirebaseMessaging.instance,
       _local = local ?? LocalNotifications();

  final DeviceRepository _devices;
  final FirebaseMessaging _fm;
  final LocalNotifications _local;

  String? token;
  bool _permitted = false;

  String get _platform => Platform.isIOS ? 'ios' : 'android';

  Future<void> init() async {
    try {
      _local.onTapRoute = _route;
      await _local.init();

      final settings = await _fm.requestPermission();
      _permitted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      CrashReporter.instance.setKey('push_permitted', _permitted);
      if (!_permitted) {
        AppLog.i('push permission not granted');
        return;
      }

      await _fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (Platform.isIOS) {
        // APNs token must be available before getToken() on iOS.
        await _fm.getAPNSToken();
      }
      token = await _fm.getToken();
      if (token != null) {
        CrashReporter.instance.breadcrumb('fcm token acquired');
        unawaited(_register(token!));
      }
      _fm.onTokenRefresh.listen((t) {
        token = t;
        unawaited(_register(t));
      });

      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      final initial = await _fm.getInitialMessage();
      if (initial != null) _onOpened(initial);
    } on Object catch (e, s) {
      AppLog.w('push init failed: $e');
      unawaited(CrashReporter.instance.recordError(e, s, context: 'push.init'));
    }
  }

  /// Called after sign-in — (re)register the current token against the now
  /// authenticated session.
  Future<void> syncRegistration() async {
    final t = token;
    if (_permitted && t != null) await _register(t);
  }

  /// Called on sign-out — drop the registration and the token so the next user
  /// on this device gets a fresh one.
  Future<void> clearRegistration() async {
    final t = token;
    if (t != null) {
      await _devices.unregister(t);
    }
    await _fm.deleteToken();
    token = null;
  }

  Future<void> _register(String t) async {
    final result = await _devices.register(token: t, platform: _platform);
    result.fold(
      (_) {},
      (f) => AppLog.w('device register failed: ${f.message}'),
    );
  }

  void _onForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return; // data-only — nothing to show
    unawaited(
      _local.show(
        title: n.title,
        body: n.body,
        payload: message.data['route'] as String?,
      ),
    );
  }

  void _onOpened(RemoteMessage message) =>
      _route(message.data['route'] as String?);

  void _route(String? route) {
    if (route == null || route.isEmpty) return;
    // Same path AppNotification.route uses in-app.
    Get.toNamed<void>(route);
  }
}
