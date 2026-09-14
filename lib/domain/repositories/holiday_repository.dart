import '../../core/error/result.dart';
import '../entities/holiday.dart';

abstract interface class HolidayRepository {
  /// The tenant's holiday calendar, soonest first.
  Future<Result<List<HolidayEntry>>> holidays();
}
