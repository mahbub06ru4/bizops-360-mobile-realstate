import '../../core/error/result.dart';
import '../../domain/entities/department.dart';
import '../../domain/repositories/department_repository.dart';
import '../datasources/department_remote_datasource.dart';
import '../models/department_mappers.dart';
import 'remote_guard.dart';

class DepartmentRepositoryImpl implements DepartmentRepository {
  DepartmentRepositoryImpl(this._remote);

  final DepartmentRemoteDataSource _remote;

  @override
  Future<Result<List<Department>>> departments() {
    return guardRequest(
      () async => (await _remote.departments())
          .map(departmentFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Department>> createDepartment(DepartmentInput input) {
    return guardRequest(
      () async => departmentFromJson(
        await _remote.create(departmentInputToJson(input)),
      ),
    );
  }

  @override
  Future<Result<Department>> updateDepartment(
    String id,
    DepartmentInput input,
  ) {
    return guardRequest(
      () async => departmentFromJson(
        await _remote.update(id, departmentInputToJson(input)),
      ),
    );
  }

  @override
  Future<Result<void>> deleteDepartment(String id) {
    return guardRequest(() => _remote.delete(id));
  }
}
