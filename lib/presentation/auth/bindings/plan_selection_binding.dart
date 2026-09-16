import 'package:get/get.dart';

import '../controllers/plan_selection_controller.dart';

class PlanSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PlanSelectionController>(
      () => PlanSelectionController(Get.find()),
    );
  }
}
