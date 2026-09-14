import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/visa_application.dart';
import '../../../../domain/repositories/visa_repository.dart';

class VisaQueueController extends GetxController {
  VisaQueueController(this._repo);

  final VisaRepository _repo;

  final Rx<AsyncValue<List<VisaApplication>>> state =
      const AsyncValue<List<VisaApplication>>.loading().obs;
  final Rxn<VisaStage> filter = Rxn<VisaStage>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.applications()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<VisaApplication> get visible {
    final all = state.value.valueOrNull ?? const [];
    return filter.value == null
        ? all
        : all.where((a) => a.stage == filter.value).toList();
  }

  int stageCount(VisaStage stage) => (state.value.valueOrNull ?? const [])
      .where((a) => a.stage == stage)
      .length;

  void toggleFilter(VisaStage stage) =>
      filter.value = filter.value == stage ? null : stage;
}
