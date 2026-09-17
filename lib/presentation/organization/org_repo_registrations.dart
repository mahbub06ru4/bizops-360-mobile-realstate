import 'package:get/get.dart';

import '../../core/network/api_client.dart';
import '../../data/datasources/branch_remote_datasource.dart';
import '../../data/datasources/department_remote_datasource.dart';
import '../../data/datasources/designation_remote_datasource.dart';
import '../../data/datasources/employee_remote_datasource.dart';
import '../../data/datasources/team_remote_datasource.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/branch_repository_impl.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../data/repositories/designation_repository_impl.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../data/repositories/team_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/repositories/branch_repository.dart';
import '../../domain/repositories/department_repository.dart';
import '../../domain/repositories/designation_repository.dart';
import '../../domain/repositories/employee_repository.dart';
import '../../domain/repositories/team_repository.dart';
import '../../domain/repositories/user_repository.dart';

/// One place registering every Organization-module repository. Real,
/// API-backed implementations only — this module always talks to
/// `bizops360-api`, no `Env.useFakeData` fallback. Feature bindings call the
/// `ensure*` they need instead of hand-rolling the registration — several
/// features share a repository (Employee form needs Branch/Department/
/// Designation lookups; Team members needs Employee).
void _ensure<T>(T Function(ApiClient client) real) {
  if (Get.isRegistered<T>()) return;
  Get.put<T>(real(Get.find<ApiClient>()), permanent: true);
}

void ensureEmployeeRepo() => _ensure<EmployeeRepository>(
  (client) => EmployeeRepositoryImpl(EmployeeRemoteDataSource(client)),
);

void ensureBranchRepo() => _ensure<BranchRepository>(
  (client) => BranchRepositoryImpl(BranchRemoteDataSource(client)),
);

void ensureDepartmentRepo() => _ensure<DepartmentRepository>(
  (client) => DepartmentRepositoryImpl(DepartmentRemoteDataSource(client)),
);

void ensureDesignationRepo() => _ensure<DesignationRepository>(
  (client) => DesignationRepositoryImpl(DesignationRemoteDataSource(client)),
);

void ensureTeamRepo() => _ensure<TeamRepository>(
  (client) => TeamRepositoryImpl(TeamRemoteDataSource(client)),
);

void ensureUserRepo() => _ensure<UserRepository>(
  (client) => UserRepositoryImpl(UserRemoteDataSource(client)),
);
