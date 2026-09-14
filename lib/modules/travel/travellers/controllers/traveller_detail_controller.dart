import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/traveller.dart';
import '../../../../domain/repositories/traveller_repository.dart';

class TravellerDetailController extends GetxController {
  TravellerDetailController(this._repo, this._id, {Traveller? seed})
    : traveller = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final TravellerRepository _repo;
  final String _id;

  final Rx<AsyncValue<Traveller>> traveller;
  final Rx<AsyncValue<List<TravelHistoryEntry>>> history =
      const AsyncValue<List<TravelHistoryEntry>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    if (traveller.value is! AsyncData) _load();
    _loadHistory();
  }

  Future<void> _load() async {
    traveller.value = (await _repo.byId(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<void> _loadHistory() async {
    history.value = (await _repo.history(
      _id,
    )).fold(AsyncValue.data, AsyncValue.error);
  }
}
