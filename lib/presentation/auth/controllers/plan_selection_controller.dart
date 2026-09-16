import 'dart:async';

import 'package:get/get.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/state/async_value.dart';
import '../../../domain/entities/billing_plan.dart';
import '../../../domain/repositories/billing_repository.dart';

/// Plan selection immediately after self-serve registration (roadmap §7
/// Phase 3). Fetches `GET /billing/plans`, submits the chosen plan via
/// `PUT /billing/subscription`, then lands in the normal staff shell — same
/// as a regular sign-in.
class PlanSelectionController extends GetxController {
  PlanSelectionController(this._repo);

  final BillingRepository _repo;

  final Rx<AsyncValue<List<BillingPlan>>> state =
      const AsyncValue<List<BillingPlan>>.loading().obs;
  final RxnString selectedCode = RxnString();
  final RxBool submitting = false.obs;
  final RxnString formError = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    final result = await _repo.getPlans();
    state.value = result.fold(AsyncValue.data, AsyncValue.error);
    final plans = state.value.valueOrNull;
    if (plans != null && plans.isNotEmpty) {
      selectedCode.value = plans.first.code;
    }
  }

  void select(String code) => selectedCode.value = code;

  Future<void> confirm() async {
    final code = selectedCode.value;
    if (code == null) return;
    formError.value = null;
    submitting.value = true;
    final result = await _repo.selectPlan(code);
    submitting.value = false;
    result.fold(
      (_) => unawaited(Get.offAllNamed<void>(Routes.shell)),
      (failure) => formError.value = failure.message,
    );
  }
}
