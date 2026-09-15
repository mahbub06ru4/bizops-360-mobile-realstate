import 'package:get/get.dart';

import '../../../../../application/auth/auth_controller.dart';
import '../../../../../domain/entities/auth_user.dart';

/// Minimal buyer profile — name/email/phone, sign out (roadmap §7 Phase 2).
class BuyerProfileController extends GetxController {
  AuthController get _auth => Get.find<AuthController>();

  AuthUser? get user => _auth.user;

  Future<void> signOut() => _auth.signOut();
}
