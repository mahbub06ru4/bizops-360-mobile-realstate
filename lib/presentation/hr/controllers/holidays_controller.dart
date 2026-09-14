import 'package:get/get.dart';

import '../../../core/state/async_value.dart';
import '../../../domain/entities/holiday.dart';
import '../../../domain/repositories/holiday_repository.dart';

class HolidaysController extends GetxController {
  HolidaysController(this._repo);

  final HolidayRepository _repo;

  final Rx<AsyncValue<List<HolidayEntry>>> state =
      const AsyncValue<List<HolidayEntry>>.loading().obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = const AsyncValue.loading();
    state.value = (await _repo.holidays()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  List<HolidayEntry> get upcoming =>
      (state.value.valueOrNull ?? const []).where((h) => !h.isPast).toList();

  List<HolidayEntry> get past =>
      (state.value.valueOrNull ?? const []).where((h) => h.isPast).toList();
}
