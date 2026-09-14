import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/follow_up.dart';
import '../../../domain/repositories/crm_repository.dart';

enum FollowUpBucket { today, overdue, upcoming, done }

class FollowUpsController extends GetxController {
  FollowUpsController(this._repo);

  final CrmRepository _repo;

  final Rx<AsyncValue<List<FollowUp>>> state =
      const AsyncValue<List<FollowUp>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.followUps()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<FollowUp> bucket(FollowUpBucket b) {
    final all = state.value.valueOrNull ?? const [];
    return switch (b) {
      FollowUpBucket.done => all.where((f) => f.done).toList(),
      FollowUpBucket.overdue =>
        all.where((f) => !f.done && f.isOverdue).toList(),
      FollowUpBucket.today =>
        all.where((f) => !f.done && f.isDueToday() && !f.isOverdue).toList(),
      FollowUpBucket.upcoming =>
        all.where((f) => !f.done && !f.isOverdue && !f.isDueToday()).toList(),
    };
  }

  int countOf(FollowUpBucket b) => bucket(b).length;

  Future<void> complete(String id, FollowUpOutcome outcome) async {
    final result = await _repo.completeFollowUp(id, outcome);
    final current = state.value.valueOrNull;
    if (current == null) return;
    result.fold((updated) {
      state.value = AsyncValue.data([
        for (final f in current)
          if (f.id == updated.id) updated else f,
      ]);
    }, (_) {});
  }
}
