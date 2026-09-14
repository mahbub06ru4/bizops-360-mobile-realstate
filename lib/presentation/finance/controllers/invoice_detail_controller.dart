import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/invoice_repository.dart';

class InvoiceDetailController extends GetxController {
  InvoiceDetailController(this._repo, this._id, {Invoice? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final InvoiceRepository _repo;
  final String _id;

  final Rx<AsyncValue<Invoice>> state;
  final RxBool busy = false.obs;

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

  Future<bool> recordPayment({
    required num amount,
    required String method,
    String? note,
  }) async {
    busy.value = true;
    final result = await _repo.recordPayment(
      invoiceId: _id,
      amount: amount,
      method: method,
      note: note,
    );
    busy.value = false;
    return result.fold((i) {
      state.value = AsyncValue.data(i);
      return true;
    }, (_) => false);
  }
}
