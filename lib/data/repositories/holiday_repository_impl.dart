import '../../core/error/result.dart';
import '../../domain/entities/holiday.dart';
import '../../domain/repositories/holiday_repository.dart';
import '../datasources/holiday_remote_datasource.dart';
import '../models/holiday_mappers.dart';
import 'remote_guard.dart';

class HolidayRepositoryImpl implements HolidayRepository {
  HolidayRepositoryImpl(this._remote);

  final HolidayRemoteDataSource _remote;

  @override
  Future<Result<List<HolidayEntry>>> holidays() {
    return guardRequest(() async {
      final list = (await _remote.holidays())
          .map(holidayFromJson)
          .toList(growable: false);
      return [...list]..sort((a, b) => a.date.compareTo(b.date));
    });
  }
}
