import '../../core/error/result.dart';
import '../entities/employee.dart';

abstract interface class EmployeeRepository {
  /// The team directory — everyone `employee.view` lets the caller see.
  Future<Result<List<Employee>>> employees();
}
