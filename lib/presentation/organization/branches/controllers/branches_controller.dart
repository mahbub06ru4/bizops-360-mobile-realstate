import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/state/async_value.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../domain/entities/branch.dart';
import '../../../../domain/repositories/branch_repository.dart';

class BranchesController extends GetxController {
  BranchesController(this._repo);

  final BranchRepository _repo;

  final Rx<AsyncValue<List<Branch>>> state =
      const AsyncValue<List<Branch>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.branches()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<bool> save(BranchInput input, {Branch? existing}) async {
    final result = existing == null
        ? await _repo.createBranch(input)
        : await _repo.updateBranch(existing.id, input);
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

  Future<void> delete(Branch branch) async {
    final confirmed = await AppDialog.confirm(
      title: Tr.orgDeleteConfirmTitle.tr,
      message: Tr.orgDeleteConfirmBody.trParams({'name': branch.name}),
    );
    if (!confirmed) return;

    final result = await _repo.deleteBranch(branch.id);
    result.fold((_) {
      AppSnackbar.show(Tr.orgDeleted.tr, tone: FeedbackTone.success);
      unawaited(load());
    }, (failure) => AppSnackbar.error(failure.message));
  }
}
