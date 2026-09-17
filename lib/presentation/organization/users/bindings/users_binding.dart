import 'package:get/get.dart';

import '../../../../application/permissions/permissions_controller.dart';
import '../../org_repo_registrations.dart';
import '../controllers/users_controller.dart';

class UsersBinding extends Bindings {
  @override
  void dependencies() {
    ensureUserRepo();
    Get.lazyPut<UsersController>(
      () => UsersController(Get.find(), Get.find<PermissionsController>()),
    );
  }
}
