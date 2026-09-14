import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/real_estate_project.dart';
import '../../../../domain/repositories/real_estate_project_repository.dart';

/// Shared seller + buyer detail screen state. Which actions render is decided
/// by the screen's `Can(...)` gating, not by two separate controllers.
class ProjectDetailController extends GetxController {
  ProjectDetailController(this._repo, this._id, {RealEstateProject? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final RealEstateProjectRepository _repo;
  final String _id;

  final Rx<AsyncValue<RealEstateProject>> state;
  final RxBool busy = false.obs;
  final RxnString submitError = RxnString();

  @override
  void onInit() {
    super.onInit();
    if (state.value is! AsyncData) reload();
  }

  Future<void> reload() async {
    state.value = (await _repo.getById(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<bool> submitForVerification() async {
    submitError.value = null;
    return _act(() => _repo.submitForVerification(_id));
  }

  Future<bool> _act(Future<Result<RealEstateProject>> Function() run) async {
    busy.value = true;
    final result = await run();
    busy.value = false;
    return result.fold(
      (p) {
        state.value = AsyncValue.data(p);
        return true;
      },
      (f) {
        submitError.value = f.message;
        return false;
      },
    );
  }
}
