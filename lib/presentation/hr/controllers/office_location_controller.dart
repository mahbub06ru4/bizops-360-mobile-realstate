import 'package:get/get.dart';

import '../../../core/location/location_service.dart';
import '../../../core/state/async_value.dart';
import '../../../domain/entities/office_location.dart';
import '../../../domain/repositories/office_location_repository.dart';

class OfficeLocationController extends GetxController {
  OfficeLocationController(this._repo, this._location);

  final OfficeLocationRepository _repo;
  final LocationService _location;

  final Rx<AsyncValue<OfficeLocation>> state =
      const AsyncValue<OfficeLocation>.loading().obs;
  final RxBool saving = false.obs;
  final RxBool locating = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    state.value = (await _repo.get()).fold(AsyncValue.data, AsyncValue.error);
  }

  /// Fills lat/lng from the device's current position — avoids needing a maps
  /// SDK just to pin the office.
  Future<void> useCurrentLocation() async {
    final office = state.value.valueOrNull;
    if (office == null || locating.value) return;
    locating.value = true;
    final fix = await _location.current();
    locating.value = false;
    fix.fold((f) {
      state.value = AsyncValue.data(
        office.copyWith(latitude: f.latitude, longitude: f.longitude),
      );
    }, (_) {});
  }

  Future<bool> save({
    required String label,
    required double latitude,
    required double longitude,
    required double radiusMeters,
    required String startTime,
    required String endTime,
  }) async {
    if (saving.value) return false;
    saving.value = true;
    final result = await _repo.update(
      OfficeLocation(
        label: label,
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        startTime: startTime,
        endTime: endTime,
      ),
    );
    saving.value = false;
    return result.fold((o) {
      state.value = AsyncValue.data(o);
      return true;
    }, (_) => false);
  }
}
