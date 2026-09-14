import 'package:get/get.dart';

import '../../../core/location/geo_distance.dart';
import '../../../core/location/location_service.dart';
import '../../../core/state/async_value.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/entities/office_location.dart';
import '../../../domain/repositories/attendance_repository.dart';
import '../../../domain/repositories/office_location_repository.dart';

class AttendanceController extends GetxController {
  AttendanceController(this._repo, this._officeRepo, this._location);

  final AttendanceRepository _repo;
  final OfficeLocationRepository _officeRepo;
  final LocationService _location;

  final Rx<AsyncValue<AttendanceToday>> today =
      const AsyncValue<AttendanceToday>.loading().obs;
  final Rx<AsyncValue<List<AttendanceDay>>> history =
      const AsyncValue<List<AttendanceDay>>.loading().obs;
  final RxBool busy = false.obs;

  /// Set when a punch attempt couldn't get a location fix at all — the only
  /// case that actually stops a punch. Distance from the office never blocks
  /// it, it only tags the record "Office" vs "Outside".
  final Rx<String?> locationError = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    today.value = const AsyncValue.loading();
    history.value = const AsyncValue.loading();
    today.value = (await _repo.today()).fold(AsyncValue.data, AsyncValue.error);
    history.value = (await _repo.history()).fold(
      AsyncValue.data,
      AsyncValue.error,
    );
  }

  Future<void> punch() async {
    final current = today.value.valueOrNull;
    if (busy.value || current == null || current.isDone) return;
    busy.value = true;
    locationError.value = null;

    final fix = await _location.current();
    final zone = await fix.fold<Future<PunchZone?>>(
      (f) async {
        final office = (await _officeRepo.get()).valueOrNull;
        if (office == null) return PunchZone.office;
        final meters = distanceMeters(
          f.latitude,
          f.longitude,
          office.latitude,
          office.longitude,
        );
        return meters <= office.radiusMeters
            ? PunchZone.office
            : PunchZone.outside;
      },
      (failure) async {
        locationError.value = failure.message;
        return null;
      },
    );

    if (zone == null) {
      busy.value = false;
      return;
    }

    final result = current.isCheckedIn
        ? await _repo.checkOut(zone)
        : await _repo.checkIn(zone);
    busy.value = false;
    result.fold((t) => today.value = AsyncValue.data(t), (_) {});
  }
}

/// Office hours the app tags late / early-leave against — mirrors the
/// backend's own attendance-status computation; kept here for any UI copy
/// that wants to say "office hours are 10:00–18:00" without another round trip.
const officeStartHour = 10;
const officeEndHour = 18;

extension OfficeLocationHours on OfficeLocation {
  int get startHour =>
      int.tryParse(startTime.split(':').first) ?? officeStartHour;
  int get endHour => int.tryParse(endTime.split(':').first) ?? officeEndHour;
}
