import '../../core/error/result.dart';
import '../entities/office_location.dart';

abstract interface class OfficeLocationRepository {
  Future<Result<OfficeLocation>> get();

  Future<Result<OfficeLocation>> update(OfficeLocation location);
}
