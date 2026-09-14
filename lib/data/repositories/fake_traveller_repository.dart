import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/traveller.dart';
import '../../domain/repositories/traveller_repository.dart';

/// In-memory travellers for UI-first development (`Env.useFakeData`).
class FakeTravellerRepository implements TravellerRepository {
  static DateTime _y(int year, int month, int day) =>
      DateTime(year, month, day);
  static DateTime _fromNow(int days) =>
      DateTime.now().add(Duration(days: days));

  static var _items = <Traveller>[
    Traveller(
      id: 't1',
      name: 'Karim Rahman',
      nationality: 'Bangladeshi',
      phone: '+8801711111111',
      dateOfBirth: _y(1988, 4, 12),
      passportNumber: 'BX0451227',
      passportExpiry: _fromNow(90),
      tripCount: 6,
    ),
    Traveller(
      id: 't2',
      name: 'Ayesha Karim',
      nationality: 'Bangladeshi',
      phone: '+8801711111112',
      dateOfBirth: _y(1992, 9, 3),
      passportNumber: 'BX0451228',
      passportExpiry: _fromNow(900),
      tripCount: 3,
    ),
    Traveller(
      id: 't3',
      name: 'Mizanur Rahman',
      nationality: 'Bangladeshi',
      phone: '+8801711111113',
      dateOfBirth: _y(1979, 1, 22),
      passportNumber: 'BW9910044',
      passportExpiry: _fromNow(-30),
      tripCount: 12,
    ),
  ];

  Future<T> _delayed<T>(T v) =>
      Future<T>.delayed(const Duration(milliseconds: 300), () => v);

  @override
  Future<Result<List<Traveller>>> travellers() =>
      _delayed(Result.ok(List.unmodifiable(_items)));

  @override
  Future<Result<Traveller>> byId(String id) {
    final m = _items.where((t) => t.id == id).firstOrNull;
    return _delayed(
      m == null ? const Result.err(NotFoundFailure()) : Result.ok(m),
    );
  }

  var _nextId = 90;

  @override
  Future<Result<Traveller>> create({
    required String name,
    String? nationality,
    String? phone,
    String? passportNumber,
    DateTime? passportExpiry,
  }) {
    final t = Traveller(
      id: 't${_nextId++}',
      name: name,
      nationality: (nationality == null || nationality.isEmpty)
          ? 'Bangladeshi'
          : nationality,
      phone: phone,
      passportNumber: passportNumber,
      passportExpiry: passportExpiry,
    );
    _items = [t, ..._items];
    return _delayed(Result.ok(t));
  }

  @override
  Future<Result<List<TravelHistoryEntry>>> history(String id) => _delayed(
    Result.ok([
      TravelHistoryEntry(
        id: 'h1',
        destination: 'Bangkok, Thailand',
        date: DateTime(2025, 12, 2),
        purpose: 'Leisure',
      ),
      TravelHistoryEntry(
        id: 'h2',
        destination: 'Kuala Lumpur, Malaysia',
        date: DateTime(2025, 6, 18),
        purpose: 'Business',
      ),
      TravelHistoryEntry(
        id: 'h3',
        destination: 'Dubai, UAE',
        date: DateTime(2024, 11, 9),
        purpose: 'Leisure',
      ),
    ]),
  );
}
