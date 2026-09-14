import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/logger.dart';

/// Displays a heads-up notification while the app is in the foreground (FCM
/// only shows tray notifications when the app is backgrounded). Also carries a
/// tapped notification's `payload` (our route string) back out via [onTapRoute].
class LocalNotifications {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'bizops_default',
    'General',
    description: 'Task, leave, payment, follow-up and deadline alerts.',
    importance: Importance.high,
  );

  /// Called with the payload (route) when a shown notification is tapped.
  void Function(String? route)? onTapRoute;

  var _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      // Permission is requested through firebase_messaging, not here.
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: (r) => onTapRoute?.call(r.payload),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // A launch tap that opened the app cold.
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      onTapRoute?.call(launch!.notificationResponse?.payload);
    }

    _ready = true;
  }

  Future<void> show({
    required String? title,
    required String? body,
    String? payload,
  }) async {
    if (!_ready) {
      AppLog.w('local notifications not ready — dropping "$title"');
      return;
    }
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
