import '../../core/error/result.dart';
import '../entities/booking.dart';

abstract interface class BookingRepository {
  Future<Result<List<Booking>>> bookings();

  Future<Result<Booking>> byId(String id);

  Future<Result<Booking>> quickCreate({
    required String travellerName,
    required BookingKind kind,
    required String reference,
    required DateTime travelDate,
    required num amount,
  });

  Future<Result<Booking>> issue(String id);

  Future<Result<Booking>> cancel(String id);

  /// Active flight bookings departing within the next two weeks, soonest first.
  Future<Result<List<Booking>>> departures();
}
