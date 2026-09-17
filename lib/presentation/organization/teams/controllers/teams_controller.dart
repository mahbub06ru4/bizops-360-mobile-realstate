import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/localization/translation_keys.dart';
import '../../../../core/state/async_value.dart';
import '../../../../core/widgets/app_feedback.dart';
import '../../../../domain/entities/team.dart';
import '../../../../domain/repositories/team_repository.dart';

class TeamsController extends GetxController {
  TeamsController(this._repo);

  final TeamRepository _repo;

  final Rx<AsyncValue<List<Team>>> state =
      const AsyncValue<List<Team>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.teams()).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<bool> save(TeamInput input, {Team? existing}) async {
    final result = existing == null
        ? await _repo.createTeam(input)
        : await _repo.updateTeam(existing.id, input);
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

  Future<void> delete(Team team) async {
    final confirmed = await AppDialog.confirm(
      title: Tr.orgDeleteConfirmTitle.tr,
      message: Tr.orgDeleteConfirmBody.trParams({'name': team.name}),
    );
    if (!confirmed) return;

    final result = await _repo.deleteTeam(team.id);
    result.fold((_) {
      AppSnackbar.show(Tr.orgDeleted.tr, tone: FeedbackTone.success);
      unawaited(load());
    }, (failure) => AppSnackbar.error(failure.message));
  }
}
