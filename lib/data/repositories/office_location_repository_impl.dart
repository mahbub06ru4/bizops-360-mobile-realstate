import '../../core/error/result.dart';
import '../../domain/entities/office_location.dart';
import '../../domain/repositories/office_location_repository.dart';
import '../datasources/hr_remote_datasource.dart';
import '../models/hr_mappers.dart';
import 'remote_guard.dart';

class OfficeLocationRepositoryImpl implements OfficeLocationRepository {
  OfficeLocationRepositoryImpl(this._remote);

  final HrRemoteDataSource _remote;

  @override
  Future<Result<OfficeLocation>> get() {
    return guardRequest(
      () async => officeLocationFromJson(await _remote.officeLocation()),
    );
  }

  @override
  Future<Result<OfficeLocation>> update(OfficeLocation location) {
    return guardRequest(
      () async => officeLocationFromJson(
        await _remote.updateOfficeLocation(officeLocationToJson(location)),
      ),
    );
  }
}
