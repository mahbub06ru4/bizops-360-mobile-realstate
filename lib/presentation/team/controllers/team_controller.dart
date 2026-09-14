import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/employee.dart';
import '../../../domain/repositories/employee_repository.dart';

class TeamController extends GetxController {
  TeamController(this._repo);

  final EmployeeRepository _repo;

  final Rx<AsyncValue<List<Employee>>> state =
      const AsyncValue<List<Employee>>.loading().obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.employees()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<Employee> get visible {
    final all = state.value.valueOrNull ?? const [];
    final q = query.value.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all
        .where(
          (e) =>
              e.name.toLowerCase().contains(q) ||
              (e.designation?.toLowerCase().contains(q) ?? false) ||
              (e.department?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}
