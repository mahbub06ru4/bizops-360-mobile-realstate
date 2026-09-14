import 'package:get/get.dart';

import '../../../../core/error/result.dart';
import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/booking.dart';
import '../../../../domain/repositories/booking_repository.dart';

class BookingDetailController extends GetxController {
  BookingDetailController(this._repo, this._id, {Booking? seed})
    : state = Rx(seed == null ? const AsyncLoading() : AsyncData(seed));

  final BookingRepository _repo;
  final String _id;

  final Rx<AsyncValue<Booking>> state;
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

  Future<void> issue() => _act(() => _repo.issue(_id));
  Future<void> cancel() => _act(() => _repo.cancel(_id));

  Future<void> _act(Future<Result<Booking>> Function() run) async {
    busy.value = true;
    final result = await run();
    busy.value = false;
    result.fold((b) => state.value = AsyncValue.data(b), (_) {});
  }
}
