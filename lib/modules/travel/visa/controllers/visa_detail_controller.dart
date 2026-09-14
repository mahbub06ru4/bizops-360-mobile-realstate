import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/visa_application.dart';
import '../../../../domain/repositories/visa_repository.dart';

class VisaDetailController extends GetxController {
  VisaDetailController(this._repo, this._id, {VisaApplication? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final VisaRepository _repo;
  final String _id;

  final Rx<AsyncValue<VisaApplication>> state;
  final RxBool busy = false.obs;
  final RxnString actionError = RxnString();

  @override
  void onInit() {
    super.onInit();
    if (state.value is! AsyncData) reload();
  }

  Future<void> reload() async {
    state.value = (await _repo.byId(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> toggleDoc(String name) async {
    final result = await _repo.toggleDoc(_id, name);
    result.fold((a) => state.value = AsyncValue.data(a), (_) {});
  }

  Future<void> submit() async {
    actionError.value = null;
    busy.value = true;
    final result = await _repo.submit(_id);
    busy.value = false;
    result.fold(
      (a) => state.value = AsyncValue.data(a),
      (f) => actionError.value = f.message,
    );
  }

  Future<void> moveStage(VisaStage stage) async {
    final result = await _repo.moveStage(_id, stage);
    result.fold((a) => state.value = AsyncValue.data(a), (_) {});
  }

  Future<void> decide({required bool approved}) async {
    busy.value = true;
    final result = await _repo.decide(_id, approved: approved);
    busy.value = false;
    result.fold((a) => state.value = AsyncValue.data(a), (_) {});
  }
}
