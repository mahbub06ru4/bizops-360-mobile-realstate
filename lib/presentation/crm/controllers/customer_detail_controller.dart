import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/customer.dart';
import '../../../domain/repositories/crm_repository.dart';

class CustomerDetailController extends GetxController {
  CustomerDetailController(this._repo, this._id, {Customer? seed})
    : customer = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final CrmRepository _repo;
  final String _id;

  final Rx<AsyncValue<Customer>> customer;
  final Rx<AsyncValue<List<CustomerActivity>>> history =
      const AsyncValue<List<CustomerActivity>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    if (customer.value is! AsyncData) _loadCustomer();
    _loadHistory();
  }

  Future<void> _loadCustomer() async {
    customer.value = (await _repo.customer(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> _loadHistory() async {
    history.value = (await _repo.history(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> moveStage(PipelineStage stage) async {
    final result = await _repo.moveStage(_id, stage);
    result.fold((c) => customer.value = AsyncValue.data(c), (_) {});
  }
}
