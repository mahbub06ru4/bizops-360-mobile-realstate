import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/customer.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/entities/site_visit.dart';
import '../../../../domain/repositories/crm_repository.dart';
import '../../../../domain/repositories/real_estate_project_repository.dart';
import '../../../../domain/repositories/site_visit_repository.dart';

/// Site-visit list + the schedule form's supporting lookups (leads,
/// projects/units) — kept on one controller since the schedule sheet is a
/// small part of this same screen, not a separate route.
class SiteVisitsController extends GetxController {
  SiteVisitsController(
    this._repo,
    this._crm,
    this._projects, {
    this.prefillProjectId,
    this.prefillUnitId,
    this.prefillUnitName,
  });

  final SiteVisitRepository _repo;
  final CrmRepository _crm;
  final RealEstateProjectRepository _projects;

  /// Set when this screen was reached from a project's unit-list "Schedule
  /// visit" action, so the schedule sheet can open pre-filled.
  final String? prefillProjectId;
  final String? prefillUnitId;
  final String? prefillUnitName;

  final Rx<AsyncValue<List<SiteVisit>>> state =
      const AsyncValue<List<SiteVisit>>.loading().obs;
  final RxList<Customer> leads = <Customer>[].obs;
  final RxList<RealEstateProject> projects = <RealEstateProject>[].obs;
  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
    _loadLookups();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.list()).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> _loadLookups() async {
    final c = await _crm.customers();
    c.fold((v) => leads.assignAll(v), (_) {});
    final p = await _projects.list();
    p.fold((v) => projects.assignAll(v), (_) {});
  }

  Future<bool> schedule({
    required Customer lead,
    required RealEstateProject project,
    String? unitId,
    String? unitName,
    required DateTime scheduledAt,
  }) async {
    busy.value = true;
    error.value = null;
    final result = await _repo.schedule(
      leadId: lead.id,
      leadName: lead.name,
      unitId: unitId,
      unitName: unitName,
      projectId: unitId == null ? project.id : null,
      projectTitle: unitId == null ? project.title : null,
      scheduledAt: scheduledAt,
    );
    busy.value = false;
    return result.fold(
      (v) {
        state.value = AsyncValue.data([
          v,
          ...(state.value.valueOrNull ?? const []),
        ]);
        return true;
      },
      (f) {
        error.value = f.message;
        return false;
      },
    );
  }

  Future<void> complete(String id) async {
    final result = await _repo.complete(id);
    result.fold((v) => _replace(v), (_) {});
  }

  Future<void> cancel(String id) async {
    final result = await _repo.cancel(id);
    result.fold((v) => _replace(v), (_) {});
  }

  void _replace(SiteVisit v) {
    final list = state.value.valueOrNull;
    if (list == null) return;
    state.value = AsyncValue.data([
      for (final x in list)
        if (x.id == v.id) v else x,
    ]);
  }
}
