import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

/// In-memory team directory for UI-first development (`Env.useFakeData`).
/// Fully functional CRUD + server-shaped search/pagination so the employee
/// list, detail, form and terminate flows all demo without a backend.
class FakeEmployeeRepository implements EmployeeRepository {
  final List<Employee> _items = [
    const Employee(
      id: 'e1',
      employeeCode: 'EMP-001',
      firstName: 'Nadia',
      lastName: 'Haque',
      name: 'Nadia Haque',
      status: EmploymentStatus.active,
      designationName: 'Branch Manager',
      departmentName: 'Operations',
      branchName: 'Head Office',
      phone: '+8801711000010',
      email: 'nadia@bizops360.test',
    ),
    const Employee(
      id: 'e2',
      employeeCode: 'EMP-002',
      firstName: 'Rahim',
      lastName: 'Uddin',
      name: 'Rahim Uddin',
      status: EmploymentStatus.active,
      designationName: 'Sales Executive',
      departmentName: 'Sales',
      branchName: 'Head Office',
      phone: '+8801711000011',
    ),
    const Employee(
      id: 'e3',
      employeeCode: 'EMP-003',
      firstName: 'Sadia',
      lastName: 'Islam',
      name: 'Sadia Islam',
      status: EmploymentStatus.onLeave,
      designationName: 'Site Officer',
      departmentName: 'Operations',
      branchName: 'Gulshan Branch',
      phone: '+8801711000012',
    ),
    const Employee(
      id: 'e4',
      employeeCode: 'EMP-004',
      firstName: 'Tanvir',
      lastName: 'Hasan',
      name: 'Tanvir Hasan',
      status: EmploymentStatus.probation,
      designationName: 'Site Officer',
      departmentName: 'Operations',
      branchName: 'Gulshan Branch',
    ),
    const Employee(
      id: 'e5',
      employeeCode: 'EMP-005',
      firstName: 'Farhana',
      lastName: 'Akter',
      name: 'Farhana Akter',
      status: EmploymentStatus.terminated,
      designationName: 'Accounts Officer',
      departmentName: 'Finance',
      branchName: 'Head Office',
    ),
  ];

  int _nextId = 6;

  @override
  Future<Result<List<Employee>>> employees({
    int page = 1,
    int perPage = 20,
    String? q,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var filtered = _items;
    final term = q?.trim().toLowerCase();
    if (term != null && term.isNotEmpty) {
      filtered = _items
          .where(
            (e) =>
                e.name.toLowerCase().contains(term) ||
                e.employeeCode.toLowerCase().contains(term) ||
                (e.email?.toLowerCase().contains(term) ?? false),
          )
          .toList();
    }
    final start = (page - 1) * perPage;
    if (start >= filtered.length) return const Result.ok([]);
    final end = (start + perPage).clamp(0, filtered.length);
    return Result.ok(filtered.sublist(start, end));
  }

  @override
  Future<Result<Employee>> employee(String id) async {
    final found = _items.where((e) => e.id == id).firstOrNull;
    if (found == null) {
      return const Result.err(NotFoundFailure());
    }
    return Result.ok(found);
  }

  @override
  Future<Result<Employee>> createEmployee(EmployeeInput input) async {
    final employee = Employee(
      id: 'e${_nextId++}',
      employeeCode: input.employeeCode,
      firstName: input.firstName,
      lastName: input.lastName,
      name: '${input.firstName} ${input.lastName}'.trim(),
      status: input.employmentStatus ?? EmploymentStatus.active,
      email: input.email,
      phone: input.phone,
      hireDate: input.hireDate,
      userId: input.userId,
      branchId: input.branchId,
      departmentId: input.departmentId,
      designationId: input.designationId,
    );
    _items.add(employee);
    return Result.ok(employee);
  }

  @override
  Future<Result<Employee>> updateEmployee(
    String id,
    EmployeeInput input,
  ) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return const Result.err(NotFoundFailure());
    final updated = Employee(
      id: id,
      employeeCode: input.employeeCode,
      firstName: input.firstName,
      lastName: input.lastName,
      name: '${input.firstName} ${input.lastName}'.trim(),
      status: input.employmentStatus ?? _items[index].status,
      email: input.email,
      phone: input.phone,
      hireDate: input.hireDate,
      userId: input.userId,
      branchId: input.branchId,
      departmentId: input.departmentId,
      designationId: input.designationId,
    );
    _items[index] = updated;
    return Result.ok(updated);
  }

  @override
  Future<Result<Employee>> terminateEmployee(String id) async {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return const Result.err(NotFoundFailure());
    final updated = _items[index].copyWith(status: EmploymentStatus.terminated);
    _items[index] = updated;
    return Result.ok(updated);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
