import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/crm_repository.dart';

class CustomersController extends GetxController {
  CustomersController(this._repo);

  final CrmRepository _repo;

  final Rx<AsyncValue<List<Customer>>> state =
      const AsyncValue<List<Customer>>.loading().obs;
  final Rxn<PipelineStage> stageFilter = Rxn<PipelineStage>();
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.customers()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<Customer> get visible {
    final all = state.value.valueOrNull ?? const [];
    final q = query.value.trim().toLowerCase();
    return all.where((c) {
      final stageOk = stageFilter.value == null || c.stage == stageFilter.value;
      final queryOk = q.isEmpty || c.name.toLowerCase().contains(q);
      return stageOk && queryOk;
    }).toList();
  }

  int stageCount(PipelineStage stage) => (state.value.valueOrNull ?? const [])
      .where((c) => c.stage == stage)
      .length;

  void toggleStage(PipelineStage stage) =>
      stageFilter.value = stageFilter.value == stage ? null : stage;
}
