import '../../core/error/result.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_mappers.dart';
import 'remote_guard.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl(this._remote);

  final BookingRemoteDataSource _remote;

  @override
  Future<Result<List<Booking>>> bookings() {
    return guardRequest(
      () async =>
          (await _remote.list()).map(bookingFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Booking>> byId(String id) {
    return guardRequest(() async => bookingFromJson(await _remote.byId(id)));
  }

  @override
  Future<Result<Booking>> quickCreate({
    required String travellerName,
    required BookingKind kind,
    required String reference,
    required DateTime travelDate,
    required num amount,
  }) {
    return guardRequest(() async {
      final body = <String, dynamic>{
        'title': '$travellerName — $reference',
        'type': bookingKindToApi[kind] ?? 'other',
        if (reference.isNotEmpty) 'pnr': reference,
        'depart_on': travelDate.toIso8601String().split('T').first,
        'sell_amount': amount,
      };
      return bookingFromJson(await _remote.create(body));
    });
  }

  @override
  Future<Result<Booking>> issue(String id) {
    return guardRequest(() async => bookingFromJson(await _remote.issue(id)));
  }

  @override
  Future<Result<Booking>> cancel(String id) {
    return guardRequest(() async => bookingFromJson(await _remote.cancel(id)));
  }

  @override
  Future<Result<List<Booking>>> departures() {
    return guardRequest(() async {
      final all = (await _remote.list()).map(bookingFromJson);
      final horizon = DateTime.now().add(const Duration(days: 14));
      final rows =
          all
              .where(
                (b) =>
                    b.isActive &&
                    b.travelDate.isBefore(horizon) &&
                    b.travelDate.isAfter(
                      DateTime.now().subtract(const Duration(days: 1)),
                    ),
              )
              .toList()
            ..sort((a, b) => a.travelDate.compareTo(b.travelDate));
      return rows;
    });
  }
}
