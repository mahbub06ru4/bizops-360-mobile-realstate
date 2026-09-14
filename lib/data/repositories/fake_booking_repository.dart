import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';

/// In-memory bookings for UI-first development (`Env.useFakeData`).
class FakeBookingRepository implements BookingRepository {
  FakeBookingRepository() : _items = _seed();

  List<Booking> _items;
  var _nextId = 300;

  static DateTime _inDays(int d, [int h = 9]) {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day, h).add(Duration(days: d));
  }

  static List<Booking> _seed() => [
    Booking(
      id: 'b1',
      reference: 'BQ7K2P',
      travellerName: 'Karim Rahman',
      kind: BookingKind.flight,
      status: BookingStatus.held,
      amount: 92000,
      travelDate: _inDays(2, 2),
      segments: [
        BookingSegment(
          from: 'DAC',
          to: 'DXB',
          carrier: 'Emirates',
          flightNo: 'EK585',
          departsAt: _inDays(2, 2),
        ),
        BookingSegment(
          from: 'DXB',
          to: 'CDG',
          carrier: 'Emirates',
          flightNo: 'EK073',
          departsAt: _inDays(2, 8),
        ),
      ],
    ),
    Booking(
      id: 'b2',
      reference: 'LM49XT',
      travellerName: 'Nusrat Jahan',
      kind: BookingKind.flight,
      status: BookingStatus.ticketed,
      amount: 74000,
      travelDate: _inDays(5, 14),
      segments: [
        BookingSegment(
          from: 'DAC',
          to: 'DXB',
          carrier: 'Biman',
          flightNo: 'BG047',
          departsAt: _inDays(5, 14),
        ),
      ],
    ),
    Booking(
      id: 'b3',
      reference: 'HTL8830',
      travellerName: 'Hasan & family',
      kind: BookingKind.hotel,
      status: BookingStatus.ticketed,
      amount: 145000,
      travelDate: _inDays(9),
      hotelName: 'Grand Hyatt, Bali — 6 nights',
    ),
    Booking(
      id: 'b4',
      reference: 'PKG2043',
      travellerName: 'Sadia Islam',
      kind: BookingKind.package,
      status: BookingStatus.completed,
      amount: 210000,
      travelDate: _inDays(-20),
      itinerary: 'Kuala Lumpur + Genting, 5 days / 4 nights.',
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 320), () => v);

  Booking? _find(String id) => _items.where((b) => b.id == id).firstOrNull;

  Result<Booking> _replace(Booking b) {
    _items = [
      for (final x in _items)
        if (x.id == b.id) b else x,
    ];
    return Result.ok(b);
  }

  @override
  Future<Result<List<Booking>>> bookings() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<Booking>> byId(String id) {
    final b = _find(id);
    return _delayed(
      b == null ? const Result.err(NotFoundFailure()) : Result.ok(b),
    );
  }

  @override
  Future<Result<Booking>> quickCreate({
    required String travellerName,
    required BookingKind kind,
    required String reference,
    required DateTime travelDate,
    required num amount,
  }) {
    final b = Booking(
      id: '${_nextId++}',
      reference: reference.toUpperCase(),
      travellerName: travellerName,
      kind: kind,
      status: BookingStatus.held,
      amount: amount,
      travelDate: travelDate,
    );
    _items = [b, ..._items];
    return _delayed(Result.ok(b));
  }

  @override
  Future<Result<Booking>> issue(String id) {
    final b = _find(id);
    if (b == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(_replace(b.copyWith(status: BookingStatus.ticketed)));
  }

  @override
  Future<Result<Booking>> cancel(String id) {
    final b = _find(id);
    if (b == null) return _delayed(const Result.err(NotFoundFailure()));
    return _delayed(_replace(b.copyWith(status: BookingStatus.cancelled)));
  }

  @override
  Future<Result<List<Booking>>> departures() {
    final cutoff = DateTime.now().add(const Duration(days: 14));
    final list =
        _items
            .where(
              (b) =>
                  b.kind == BookingKind.flight &&
                  b.isActive &&
                  b.travelDate.isBefore(cutoff),
            )
            .toList()
          ..sort((a, b) => a.travelDate.compareTo(b.travelDate));
    return _delayed(Result.ok(list));
  }
}
