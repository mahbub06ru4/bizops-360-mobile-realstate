import '../../core/error/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../models/employee_mappers.dart';
import 'remote_guard.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  EmployeeRepositoryImpl(this._remote);

  final EmployeeRemoteDataSource _remote;

  @override
  Future<Result<List<Employee>>> employees({
    int page = 1,
    int perPage = 20,
    String? q,
  }) {
    return guardRequest(
      () async => (await _remote.employees(
        page: page,
        perPage: perPage,
        q: q,
      )).map(employeeFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Employee>> employee(String id) {
    return guardRequest(
      () async => employeeFromJson(await _remote.employee(id)),
    );
  }

  @override
  Future<Result<Employee>> createEmployee(EmployeeInput input) {
    return guardRequest(
      () async =>
          employeeFromJson(await _remote.create(employeeInputToJson(input))),
    );
  }

  @override
  Future<Result<Employee>> updateEmployee(String id, EmployeeInput input) {
    return guardRequest(
      () async => employeeFromJson(
        await _remote.update(id, employeeInputToJson(input)),
      ),
    );
  }

  @override
  Future<Result<Employee>> terminateEmployee(String id) {
    return guardRequest(
      () async => employeeFromJson(await _remote.terminate(id)),
    );
  }
}
