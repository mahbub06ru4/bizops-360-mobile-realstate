import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/real_estate_booking.dart';
import '../../../../domain/repositories/real_estate_booking_repository.dart';

class ReBookingsController extends GetxController {
  ReBookingsController(this._repo);

  final RealEstateBookingRepository _repo;

  final Rx<AsyncValue<List<RealEstateBooking>>> state =
      const AsyncValue<List<RealEstateBooking>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.list()).fold(AsyncValue.data, AsyncValue.error);
  }
}
