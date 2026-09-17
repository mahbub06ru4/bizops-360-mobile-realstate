import 'package:get/get.dart';

import '../../../core/localization/translation_keys.dart';
import '../../../core/state/async_value.dart';
import '../../../core/widgets/app_feedback.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';

class EmployeeDetailController extends GetxController {
  EmployeeDetailController(this._repo, this.employeeId);

  final EmployeeRepository _repo;
  final String employeeId;

  final Rx<AsyncValue<Employee>> state =
      const AsyncValue<Employee>.loading().obs;
  final RxBool terminating = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.employee(
      employeeId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<bool> terminate() async {
    final confirmed = await AppDialog.confirm(
      title: Tr.empTerminateConfirmTitle.tr,
      message: Tr.empTerminateConfirmBody.tr,
      confirmLabel: Tr.empTerminate.tr,
    );
    if (!confirmed) return false;

    terminating.value = true;
    final result = await _repo.terminateEmployee(employeeId);
    terminating.value = false;

    return result.fold(
      (employee) {
        state.value = AsyncValue.data(employee);
        AppSnackbar.show(Tr.empTerminated.tr, tone: FeedbackTone.success);
        return true;
      },
      (failure) {
        AppSnackbar.error(failure.message);
        return false;
      },
    );
  }
}
