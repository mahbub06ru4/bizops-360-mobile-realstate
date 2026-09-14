import 'package:get/get.dart';

import '../../hr/bindings/hr_bindings.dart';
import '../controllers/expenses_controller.dart';

class ExpensesBinding extends Bindings {
  @override
  void dependencies() {
    ensureExpenseRepo();
    Get.lazyPut<ExpensesController>(() => ExpensesController(Get.find()));
  }
}
