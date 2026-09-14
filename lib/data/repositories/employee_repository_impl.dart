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
  Future<Result<List<Employee>>> employees() {
    return guardRequest(
      () async => (await _remote.employees())
          .map(employeeFromJson)
          .toList(growable: false),
    );
  }
}
