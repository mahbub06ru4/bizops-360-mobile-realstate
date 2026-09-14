import '../../core/error/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

/// In-memory team directory for UI-first development (`Env.useFakeData`).
class FakeEmployeeRepository implements EmployeeRepository {
  static const _items = <Employee>[
    Employee(
      id: 'e1',
      name: 'Nadia Haque',
      status: EmploymentStatus.active,
      designation: 'Branch Manager',
      department: 'Operations',
      phone: '+8801711000010',
      email: 'nadia@wanderlust.test',
    ),
    Employee(
      id: 'e2',
      name: 'Rahim Uddin',
      status: EmploymentStatus.active,
      designation: 'Travel Consultant',
      department: 'Sales',
      phone: '+8801711000011',
    ),
    Employee(
      id: 'e3',
      name: 'Sadia Islam',
      status: EmploymentStatus.onLeave,
      designation: 'Visa Officer',
      department: 'Operations',
      phone: '+8801711000012',
    ),
    Employee(
      id: 'e4',
      name: 'Tanvir Hasan',
      status: EmploymentStatus.active,
      designation: 'Ticketing Executive',
      department: 'Operations',
    ),
    Employee(
      id: 'e5',
      name: 'Farhana Akter',
      status: EmploymentStatus.inactive,
      designation: 'Accounts',
      department: 'Finance',
    ),
  ];

  @override
  Future<Result<List<Employee>>> employees() => Future.delayed(
    const Duration(milliseconds: 300),
    () => const Result.ok(_items),
  );
}
