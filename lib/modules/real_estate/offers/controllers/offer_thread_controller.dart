import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/offer.dart';
import '../../../../domain/repositories/offer_repository.dart';
import '../../../../domain/repositories/real_estate_booking_repository.dart';

/// The full negotiation chain for one lead+unit thread, plus the
/// counter/accept/reject/reserve actions gated by the latest offer's status.
class OfferThreadController extends GetxController {
  OfferThreadController(this._repo, this._bookings, this.headOfferId);

  final OfferRepository _repo;
  final RealEstateBookingRepository _bookings;
  final String headOfferId;

  final Rx<AsyncValue<List<Offer>>> state =
      const AsyncValue<List<Offer>>.loading().obs;
  final RxBool busy = false.obs;
  final RxnString error = RxnString();

  Offer? get latest {
    final list = state.value.valueOrNull;
    return list == null || list.isEmpty ? null : list.last;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.history(
      headOfferId,
    )).fold(AsyncValue.data, AsyncValue.error);
  }

  Future<bool> counter({
    required num offeredPrice,
    required OfferParty by,
    String? notes,
  }) async {
    final head = latest;
    if (head == null) return false;
    return _act(
      () => _repo.counter(
        head.id,
        offeredPrice: offeredPrice,
        offeredBy: by,
        notes: notes,
      ),
    );
  }

  Future<bool> accept() async {
    final head = latest;
    if (head == null) return false;
    return _act(() => _repo.accept(head.id));
  }

  Future<bool> reject() async {
    final head = latest;
    if (head == null) return false;
    return _act(() => _repo.reject(head.id));
  }

  /// Reserves a booking from the accepted offer — the roadmap's
  /// "Negotiation -> Reservation" hand-off.
  Future<String?> reserveBooking() async {
    final head = latest;
    if (head == null || head.status != OfferStatus.accepted) return null;
    busy.value = true;
    error.value = null;
    final result = await _bookings.reserve(offerId: head.id);
    busy.value = false;
    return result.fold((b) => b.id, (f) {
      error.value = f.message;
      return null;
    });
  }

  Future<bool> _act<T>(Future<Result<T>> Function() run) async {
    busy.value = true;
    error.value = null;
    final result = await run();
    busy.value = false;
    return result.fold(
      (_) {
        load();
        return true;
      },
      (f) {
        error.value = f.message;
        return false;
      },
    );
  }
}
