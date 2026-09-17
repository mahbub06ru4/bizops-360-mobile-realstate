import 'package:get/get.dart';

import '../../org_repo_registrations.dart';
import '../controllers/departments_controller.dart';

class DepartmentsBinding extends Bindings {
  @override
  void dependencies() {
    ensureDepartmentRepo();
    ensureBranchRepo();
    Get.lazyPut<DepartmentsController>(
      () => DepartmentsController(Get.find(), Get.find()),
    );
  }
}
