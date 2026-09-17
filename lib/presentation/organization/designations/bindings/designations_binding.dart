import 'package:get/get.dart';

import '../../org_repo_registrations.dart';
import '../controllers/designations_controller.dart';

class DesignationsBinding extends Bindings {
  @override
  void dependencies() {
    ensureDesignationRepo();
    ensureDepartmentRepo();
    Get.lazyPut<DesignationsController>(
      () => DesignationsController(Get.find(), Get.find()),
    );
  }
}
