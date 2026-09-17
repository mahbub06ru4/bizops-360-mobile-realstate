import 'package:get/get.dart';

import '../../org_repo_registrations.dart';
import '../controllers/branches_controller.dart';

class BranchesBinding extends Bindings {
  @override
  void dependencies() {
    ensureBranchRepo();
    Get.lazyPut<BranchesController>(() => BranchesController(Get.find()));
  }
}
