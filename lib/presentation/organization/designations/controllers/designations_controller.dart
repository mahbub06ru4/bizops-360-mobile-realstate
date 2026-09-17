import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/state/async_value.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../domain/entities/department.dart';
import '../../../../domain/entities/designation.dart';
import '../../../../domain/repositories/department_repository.dart';
import '../../../../domain/repositories/designation_repository.dart';

class DesignationsController extends GetxController {
  DesignationsController(this._repo, this._departmentRepo);

  final DesignationRepository _repo;
  final DepartmentRepository _departmentRepo;

  final Rx<AsyncValue<List<Designation>>> state =
      const AsyncValue<List<Designation>>.loading().obs;
  final RxList<Department> departments = <Department>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
    unawaited(_loadDepartments());
  }

  Future<void> _loadDepartments() async {
    departments.value =
        (await _departmentRepo.departments()).valueOrNull ?? const [];
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.designations()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<bool> save(DesignationInput input, {Designation? existing}) async {
    final result = existing == null
        ? await _repo.createDesignation(input)
        : await _repo.updateDesignation(existing.id, input);
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

  Future<void> delete(Designation designation) async {
    final confirmed = await AppDialog.confirm(
      title: Tr.orgDeleteConfirmTitle.tr,
      message: Tr.orgDeleteConfirmBody.trParams({'name': designation.title}),
    );
    if (!confirmed) return;

    final result = await _repo.deleteDesignation(designation.id);
    result.fold((_) {
      AppSnackbar.show(Tr.orgDeleted.tr, tone: FeedbackTone.success);
      unawaited(load());
    }, (failure) => AppSnackbar.error(failure.message));
  }
}
