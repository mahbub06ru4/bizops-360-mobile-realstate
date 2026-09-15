import 'package:get/get.dart';

import '../../../../../core/state/async_value.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../../../../../domain/repositories/buyer_repository.dart';
import '../../../../../domain/repositories/real_estate_project_repository.dart';

/// Compare is capped at 3 (roadmap §7 Phase 2: "compare 3 projects").
const compareMax = 3;

class SavedController extends GetxController {
  SavedController(this._buyer, this._projects);

  final BuyerRepository _buyer;
  final RealEstateProjectRepository _projects;

  final Rx<AsyncValue<List<RealEstateProject>>> state = Rx(
    const AsyncLoading(),
  );

  /// Ids selected for comparison, in selection order (capped at [compareMax]).
  final RxList<String> selectedForCompare = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncLoading();
    final idsResult = await _buyer.savedProjectIds();
    final ids = idsResult.valueOrNull ?? const [];
    if (ids.isEmpty) {
      state.value = const AsyncValue.data([]);
      return;
    }
    final allResult = await _projects.list();
    state.value = allResult.fold(
      (all) => AsyncValue.data(
        all.where((p) => ids.contains(p.id)).toList(growable: false),
      ),
      AsyncValue.error,
    );
  }

  Future<void> unsave(String projectId) async {
    await _buyer.unsaveProject(projectId);
    selectedForCompare.remove(projectId);
    await load();
  }

  bool isSelected(String projectId) => selectedForCompare.contains(projectId);

  /// Toggles [projectId] in the compare selection. Returns `false` (and
  /// leaves the selection unchanged) when adding it would exceed
  /// [compareMax].
  bool toggleCompare(String projectId) {
    if (selectedForCompare.contains(projectId)) {
      selectedForCompare.remove(projectId);
      return true;
    }
    if (selectedForCompare.length >= compareMax) return false;
    selectedForCompare.add(projectId);
    return true;
  }

  bool get canCompare => selectedForCompare.length >= 2;
}
