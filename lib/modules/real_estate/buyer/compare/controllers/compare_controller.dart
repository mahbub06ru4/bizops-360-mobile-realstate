import 'package:get/get.dart';

import '../../../../../core/state/async_value.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../../../../../domain/repositories/real_estate_project_repository.dart';

/// Side-by-side comparison of up to [compareMax] (see `saved_controller.dart`)
/// saved projects — price, location, unit types/sizes, amenities and
/// verification status (roadmap §7 Phase 2). The 3-project cap itself is
/// enforced upstream in `SavedController.toggleCompare`; this controller just
/// loads whichever ids it was handed via the route arguments.
class CompareController extends GetxController {
  CompareController(this._repo, this._ids);

  final RealEstateProjectRepository _repo;
  final List<String> _ids;

  final Rx<AsyncValue<List<RealEstateProject>>> state = Rx(
    const AsyncLoading(),
  );

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncLoading();
    final result = await _repo.list();
    state.value = result.fold(
      (all) => AsyncValue.data([
        for (final id in _ids) ...all.where((p) => p.id == id),
      ]),
      AsyncValue.error,
    );
  }
}
