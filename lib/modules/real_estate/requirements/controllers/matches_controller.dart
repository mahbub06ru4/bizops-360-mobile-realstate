import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/property_match.dart';
import '../../../../domain/repositories/property_requirement_repository.dart';

class MatchesController extends GetxController {
  MatchesController(this._repo, this.requirementId);

  final PropertyRequirementRepository _repo;
  final String requirementId;

  final Rx<AsyncValue<List<PropertyMatch>>> state =
      const AsyncValue<List<PropertyMatch>>.loading().obs;
  final RxBool rematching = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.matchesFor(
      requirementId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> rematch() async {
    rematching.value = true;
    final result = await _repo.match(requirementId);
    rematching.value = false;
    result.fold((matches) => state.value = AsyncValue.data(matches), (_) {});
  }
}
