import 'package:bizops360_mobile/data/repositories/fake_booking_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_traveller_repository.dart';
import 'package:bizops360_mobile/domain/entities/booking.dart';
import 'package:bizops360_mobile/modules/travel/bookings/controllers/booking_detail_controller.dart';
import 'package:bizops360_mobile/modules/travel/bookings/controllers/bookings_controller.dart';
import 'package:bizops360_mobile/modules/travel/bookings/controllers/departures_controller.dart';
import 'package:bizops360_mobile/modules/travel/travellers/controllers/travellers_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('travellers search matches name or passport', () async {
    final c = TravellersController(FakeTravellerRepository());
    await c.load();
    c.query.value = 'BW9910044';
    expect(c.visible, hasLength(1));
    expect(c.visible.first.name, 'Mizanur Rahman');
  });

  test('booking issue advances held → ticketed', () async {
    final c = BookingDetailController(FakeBookingRepository(), 'b1');
    await c.reload();
    expect(c.state.value.valueOrNull!.status, BookingStatus.held);
    await c.issue();
    expect(c.state.value.valueOrNull!.status, BookingStatus.ticketed);
  });

  test('cancelled booking drops out of the departures board', () async {
    final repo = FakeBookingRepository();
    final dep = DeparturesController(repo);
    await dep.load();
    final before = dep.grouped.fold<int>(0, (n, g) => n + g.bookings.length);
    expect(before, greaterThan(0));

    final detail = BookingDetailController(repo, 'b1');
    await detail.reload();
    await detail.cancel();

    await dep.load();
    final after = dep.grouped.fold<int>(0, (n, g) => n + g.bookings.length);
    expect(after, before - 1);
  });

  test('quickCreate prepends a held booking', () async {
    final c = BookingsController(FakeBookingRepository());
    await c.load();
    final before = c.state.value.valueOrNull!.length;
    final ok = await c.quickCreate(
      travellerName: 'Test User',
      kind: BookingKind.hotel,
      reference: 'abc123',
      travelDate: DateTime(2026, 10, 3),
      amount: 5000,
    );
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(ok, isTrue);
    expect(c.state.value.valueOrNull!.length, before + 1);
    expect(c.state.value.valueOrNull!.first.reference, 'ABC123');
  });
}
