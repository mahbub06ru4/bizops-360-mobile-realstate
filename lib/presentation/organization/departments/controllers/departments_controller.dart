import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/state/async_value.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../domain/entities/branch.dart';
import '../../../../domain/entities/department.dart';
import '../../../../domain/repositories/branch_repository.dart';
import '../../../../domain/repositories/department_repository.dart';

class DepartmentsController extends GetxController {
  DepartmentsController(this._repo, this._branchRepo);

  final DepartmentRepository _repo;
  final BranchRepository _branchRepo;

  final Rx<AsyncValue<List<Department>>> state =
      const AsyncValue<List<Department>>.loading().obs;
  final RxList<Branch> branches = <Branch>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
    unawaited(_loadBranches());
  }

  Future<void> _loadBranches() async {
    branches.value = (await _branchRepo.branches()).valueOrNull ?? const [];
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.departments()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<bool> save(DepartmentInput input, {Department? existing}) async {
    final result = existing == null
        ? await _repo.createDepartment(input)
        : await _repo.updateDepartment(existing.id, input);
    return result.fold(
      (_) {
        AppSnackbar.show(Tr.orgSaved.tr, tone: FeedbackTone.success);
        unawaited(load());
        return true;
      },
      (failure) {
        AppSnackbar.error(failure.message);
        return false;
      },
    );
  }

  Future<void> delete(Department department) async {
    final confirmed = await AppDialog.confirm(
      title: Tr.orgDeleteConfirmTitle.tr,
      message: Tr.orgDeleteConfirmBody.trParams({'name': department.name}),
    );
    if (!confirmed) return;

    final result = await _repo.deleteDepartment(department.id);
    result.fold((_) {
      AppSnackbar.show(Tr.orgDeleted.tr, tone: FeedbackTone.success);
      unawaited(load());
    }, (failure) => AppSnackbar.error(failure.message));
  }
}
