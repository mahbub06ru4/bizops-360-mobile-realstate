import 'package:get/get.dart';

import '../../../domain/entities/employee.dart';
import '../../organization/org_repo_registrations.dart';
import '../controllers/employee_detail_controller.dart';
import '../controllers/employee_form_controller.dart';
import '../controllers/team_controller.dart';

class TeamBinding extends Bindings {
  @override
  void dependencies() {
    ensureEmployeeRepo();
    Get.lazyPut<TeamController>(() => TeamController(Get.find()));
  }
}

class EmployeeDetailBinding extends Bindings {
  @override
  void dependencies() {
    ensureEmployeeRepo();
    final id = Get.arguments as String;
    Get.lazyPut<EmployeeDetailController>(
      () => EmployeeDetailController(Get.find(), id),
    );
  }
}

class EmployeeFormBinding extends Bindings {
  @override
  void dependencies() {
    ensureEmployeeRepo();
    ensureBranchRepo();
    ensureDepartmentRepo();
    ensureDesignationRepo();
    final existing = Get.arguments is Employee
        ? Get.arguments as Employee
        : null;
    Get.lazyPut<EmployeeFormController>(
      () => EmployeeFormController(
        Get.find(),
        Get.find(),
        Get.find(),
        Get.find(),
        existing: existing,
      ),
    );
  }
}
