import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/employee.dart';
import '../../../../domain/entities/team.dart';
import '../../../../domain/repositories/employee_repository.dart';
import '../../../../domain/repositories/team_repository.dart';

/// Assign/remove employees from one team. Reuses the employee directory
/// (`EmployeeRepository`) rather than a separate picker component.
class TeamMembersController extends GetxController {
  TeamMembersController(this._teamRepo, this._employeeRepo, this.teamId);

  final TeamRepository _teamRepo;
  final EmployeeRepository _employeeRepo;
  final String teamId;

  final Rx<AsyncValue<Team>> team = const AsyncValue<Team>.loading().obs;
  final RxList<Employee> allEmployees = <Employee>[].obs;
  final RxSet<String> selectedIds = <String>{}.obs;
  final RxBool saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    team.value = const AsyncValue.loading();

    final teamResult = await _teamRepo.team(teamId);
    final employeesResult = await _employeeRepo.employees(perPage: 100);

    final failure = teamResult.failureOrNull ?? employeesResult.failureOrNull;
    if (failure != null) {
      team.value = AsyncValue.error(failure);
      return;
    }

    final loadedTeam = teamResult.valueOrNull!;
    allEmployees.value = employeesResult.valueOrNull ?? const [];
    selectedIds.assignAll(loadedTeam.members.map((e) => e.id));
    team.value = AsyncValue.data(loadedTeam);
  }

  void toggle(String employeeId) {
    if (selectedIds.contains(employeeId)) {
      selectedIds.remove(employeeId);
    } else {
      selectedIds.add(employeeId);
    }
  }

  /// Returns `null` on success, or a failure message for the screen to show.
  /// Feedback (snackbars) stays a presentation concern so this method is
  /// plain-unit-testable without a widget binding.
  Future<String?> saveMembers() async {
    saving.value = true;
    final result = await _teamRepo.setMembers(teamId, selectedIds.toList());
    saving.value = false;

    return result.fold((updated) {
      team.value = AsyncValue.data(updated);
      return null;
    }, (failure) => failure.message);
  }
}
