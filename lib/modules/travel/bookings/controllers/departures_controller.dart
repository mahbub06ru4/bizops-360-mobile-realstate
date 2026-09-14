import 'package:get/get.dart';

import '../../../../core/state/async_value.dart';
import '../../../../domain/entities/booking.dart';
import '../../../../domain/repositories/booking_repository.dart';

typedef DepartureDay = ({DateTime day, List<Booking> bookings});

class DeparturesController extends GetxController {
  DeparturesController(this._repo);

  final BookingRepository _repo;

  final Rx<AsyncValue<List<Booking>>> state =
      const AsyncValue<List<Booking>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.departures()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<DepartureDay> get grouped {
    final list = state.value.valueOrNull ?? const [];
    final map = <DateTime, List<Booking>>{};
    for (final b in list) {
      final key = DateTime(
        b.travelDate.year,
        b.travelDate.month,
        b.travelDate.day,
      );
      map.putIfAbsent(key, () => []).add(b);
    }
    final keys = map.keys.toList()..sort();
    return [for (final k in keys) (day: k, bookings: map[k]!)];
  }
}
