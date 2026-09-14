import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/offer.dart';
import '../../../../domain/repositories/offer_repository.dart';

/// One row per negotiation thread — its latest offer/counter.
class OffersController extends GetxController {
  OffersController(this._repo);

  final OfferRepository _repo;

  final Rx<AsyncValue<List<Offer>>> state =
      const AsyncValue<List<Offer>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.latestPerThread()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }
}
