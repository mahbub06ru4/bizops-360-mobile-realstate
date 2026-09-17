import '../../core/error/result.dart';
import '../../domain/entities/designation.dart';
import '../../domain/repositories/designation_repository.dart';
import '../datasources/designation_remote_datasource.dart';
import '../models/designation_mappers.dart';
import 'remote_guard.dart';

class DesignationRepositoryImpl implements DesignationRepository {
  DesignationRepositoryImpl(this._remote);

  final DesignationRemoteDataSource _remote;

  @override
  Future<Result<List<Designation>>> designations() {
    return guardRequest(
      () async => (await _remote.designations())
          .map(designationFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Designation>> createDesignation(DesignationInput input) {
    return guardRequest(
      () async => designationFromJson(
        await _remote.create(designationInputToJson(input)),
      ),
    );
  }

  @override
  Future<Result<Designation>> updateDesignation(
    String id,
    DesignationInput input,
  ) {
    return guardRequest(
      () async => designationFromJson(
        await _remote.update(id, designationInputToJson(input)),
      ),
    );
  }

  @override
  Future<Result<void>> deleteDesignation(String id) {
    return guardRequest(() => _remote.delete(id));
  }
}
