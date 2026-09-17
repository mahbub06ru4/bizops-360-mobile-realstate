import '../../core/error/result.dart';
import '../entities/department.dart';

abstract interface class DepartmentRepository {
  Future<Result<List<Department>>> departments();
  Future<Result<Department>> createDepartment(DepartmentInput input);
  Future<Result<Department>> updateDepartment(String id, DepartmentInput input);
  Future<Result<void>> deleteDepartment(String id);
}
