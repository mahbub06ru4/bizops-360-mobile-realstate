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
    final registered = Get.isRegistered<AuthController>();
    final auth = registered ? Get.find<AuthController>() : null;
    final authed = auth?.isAuthenticated ?? false;

    if (route == Routes.signIn) {
      if (!authed) return null;
      return RouteSettings(
        name: auth!.user!.isBuyer ? Routes.buyerShell : Routes.shell,
      );
    }
    return authed ? null : const RouteSettings(name: Routes.signIn);
  }
}
