import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/invoice.dart';
import '../../../domain/repositories/invoice_repository.dart';

class InvoicesController extends GetxController {
  InvoicesController(this._repo);

  final InvoiceRepository _repo;

  final Rx<AsyncValue<List<Invoice>>> state =
      const AsyncValue<List<Invoice>>.loading().obs;
  final Rxn<InvoiceStatus> statusFilter = Rxn<InvoiceStatus>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.invoices()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<Invoice> get visible {
    final all = state.value.valueOrNull ?? const [];
    return statusFilter.value == null
        ? all
        : all.where((i) => i.status == statusFilter.value).toList();
  }

  num get outstanding => (state.value.valueOrNull ?? const <Invoice>[])
      .where((i) => !i.isSettled)
      .fold<num>(0, (sum, i) => sum + i.due);

  void toggleStatus(InvoiceStatus s) =>
      statusFilter.value = statusFilter.value == s ? null : s;
}
