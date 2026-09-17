import '../../core/error/result.dart';
import '../entities/employee.dart';

abstract interface class EmployeeRepository {
  /// One page of the team directory `employee.view` lets the caller see.
  /// [page] is 1-based, matching the Laravel paginator. [q] matches name,
  /// employee code or email (server-side, case-insensitive).
  Future<Result<List<Employee>>> employees({
    int page = 1,
    int perPage = 20,
    String? q,
  });

  Future<Result<Employee>> employee(String id);

  Future<Result<Employee>> createEmployee(EmployeeInput input);

  Future<Result<Employee>> updateEmployee(String id, EmployeeInput input);

  /// Sets `employment_status` to terminated. Irreversible from the app's UI.
  Future<Result<Employee>> terminateEmployee(String id);
}
