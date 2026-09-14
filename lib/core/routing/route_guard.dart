import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../application/auth/auth_controller.dart';
import 'app_routes.dart';

/// Keeps signed-out users out of every screen but sign-in, and signed-in users
/// off the sign-in screen. The splash screen still does the first-launch
/// routing; this is defence in depth for deep links and manual navigation.
class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authed =
        Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isAuthenticated;

    if (route == Routes.signIn) {
      return authed ? const RouteSettings(name: Routes.shell) : null;
    }
    return authed ? null : const RouteSettings(name: Routes.signIn);
  }
}
