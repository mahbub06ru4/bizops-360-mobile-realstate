import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/booking.dart';
import '../../../../domain/repositories/booking_repository.dart';

class BookingsController extends GetxController {
  BookingsController(this._repo);

  final BookingRepository _repo;

  final Rx<AsyncValue<List<Booking>>> state =
      const AsyncValue<List<Booking>>.loading().obs;
  final Rxn<BookingStatus> statusFilter = Rxn<BookingStatus>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.bookings()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<Booking> get visible {
    final all = state.value.valueOrNull ?? const [];
    return statusFilter.value == null
        ? all
        : all.where((b) => b.status == statusFilter.value).toList();
  }

  void toggleStatus(BookingStatus s) =>
      statusFilter.value = statusFilter.value == s ? null : s;

  Future<bool> quickCreate({
    required String travellerName,
    required BookingKind kind,
    required String reference,
    required DateTime travelDate,
    required num amount,
  }) async {
    final result = await _repo.quickCreate(
      travellerName: travellerName,
      kind: kind,
      reference: reference,
      travelDate: travelDate,
      amount: amount,
    );
    return result.fold((_) {
      load();
      return true;
    }, (_) => false);
  }
}
