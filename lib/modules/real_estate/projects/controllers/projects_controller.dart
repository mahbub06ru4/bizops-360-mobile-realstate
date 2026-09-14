import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/repositories/real_estate_project_repository.dart';

/// The seller's own project list — Phase 0 has no buyer-facing browse/search,
/// so this is always "my projects", not a marketplace feed.
class ProjectsController extends GetxController {
  ProjectsController(this._repo);

  final RealEstateProjectRepository _repo;

  final Rx<AsyncValue<List<RealEstateProject>>> state =
      const AsyncValue<List<RealEstateProject>>.loading().obs;
  final Rxn<ProjectStatus> statusFilter = Rxn<ProjectStatus>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.list()).fold(AsyncValue.data, AsyncValue.error);
  }

  List<RealEstateProject> get visible {
    final all = state.value.valueOrNull ?? const [];
    return statusFilter.value == null
        ? all
        : all.where((p) => p.status == statusFilter.value).toList();
  }

  void toggleStatus(ProjectStatus s) =>
      statusFilter.value = statusFilter.value == s ? null : s;
}
