import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'application/app_binding.dart';
import 'application/push/push_service.dart';
import 'core/config/env.dart';
import 'core/config/flavor.dart';
import 'core/observability/crash_reporter.dart';
import 'core/observability/firebase_crash_reporter.dart';
import 'core/storage/kv_store.dart';
import 'core/utils/logger.dart';

/// Shared startup for every flavor entrypoint: pin the flavor, bring up Firebase
/// (best effort), warm the KV box, wire the object graph, install crash
/// handlers, then run the app — all inside a guarded zone so async errors are
/// captured too.
Future<void> bootstrap(FlavorConfig config) async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      Env.init(config);

      final firebaseReady = await _initFirebase();
      if (firebaseReady) {
        CrashReporter.instance = FirebaseCrashReporter();
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );
      }
      installCrashHandlers();

      await KvStore.ensureInitialised();
      AppBinding().dependencies();

      runApp(const BizOpsApp());

      if (firebaseReady) {
        final push = PushService(Get.find());
        Get.put<PushService>(push, permanent: true);
        unawaited(push.init());
      }
    },
    (error, stack) =>
        CrashReporter.instance.recordError(error, stack, fatal: true),
  );
}

/// Best effort — the iOS `GoogleService-Info.plist` may not be in place yet, and
/// a plain-web build has no config. A failure just leaves the logging reporter.
Future<bool> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } on Object catch (e) {
    AppLog.w('Firebase not initialised ($e) — using the logging reporter');
    return false;
  }
}
