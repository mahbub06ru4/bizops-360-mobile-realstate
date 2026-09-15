import 'package:get/get.dart';

import '../../../../../core/state/async_value.dart';
import '../../../../../domain/entities/real_estate_project.dart';
import '../../../../../domain/repositories/buyer_repository.dart';

/// Verified-only listings + Bangladesh location/landmark keyword search
/// (roadmap §7 Phase 2). Plain substring matching against the project's own
/// location fields — no NLP (that's Phase 4).
class BrowseController extends GetxController {
  BrowseController(this._repo);

  final BuyerRepository _repo;

  final Rx<AsyncValue<List<RealEstateProject>>> state = Rx(
    const AsyncLoading(),
  );
  final RxSet<String> savedIds = <String>{}.obs;
  final RxString query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    load();
    _loadSavedIds();
  }

  Future<void> load() async {
    state.value = const AsyncLoading();
    final result = await _repo.browseVerified(
      query: query.value.isEmpty ? null : query.value,
    );
    state.value = result.fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> search(String value) async {
    query.value = value.trim();
    await load();
  }

  Future<void> _loadSavedIds() async {
    final result = await _repo.savedProjectIds();
    savedIds.assignAll(result.valueOrNull ?? const []);
  }

  bool isSaved(String projectId) => savedIds.contains(projectId);

  Future<void> toggleSave(String projectId) async {
    if (isSaved(projectId)) {
      await _repo.unsaveProject(projectId);
      savedIds.remove(projectId);
    } else {
      await _repo.saveProject(projectId);
      savedIds.add(projectId);
    }
  }
}
