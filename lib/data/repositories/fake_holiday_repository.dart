import '../../core/error/result.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';

/// In-memory holiday calendar for UI-first development (`Env.useFakeData`).
class FakeHolidayRepository implements HolidayRepository {
  static final _items = <HolidayEntry>[
    HolidayEntry(
      id: 'h1',
      name: 'Independence Day',
      date: DateTime(2026, 3, 26),
    ),
    HolidayEntry(id: 'h2', name: 'Eid-ul-Fitr', date: DateTime(2026, 3, 21)),
    // ignore: avoid_redundant_argument_values
    HolidayEntry(id: 'h3', name: 'May Day', date: DateTime(2026, 5, 1)),
    HolidayEntry(id: 'h4', name: 'Eid-ul-Adha', date: DateTime(2026, 5, 28)),
    HolidayEntry(id: 'h5', name: 'Victory Day', date: DateTime(2026, 12, 16)),
    HolidayEntry(
      id: 'h6',
      name: 'New Year (bank holiday)',
      // ignore: avoid_redundant_argument_values
      date: DateTime(2027, 1, 1),
    ),
  ];

  @override
  Future<Result<List<HolidayEntry>>> holidays() =>
      Future.delayed(const Duration(milliseconds: 250), () {
        final sorted = [..._items]..sort((a, b) => a.date.compareTo(b.date));
        return Result.ok(sorted);
      });
}
