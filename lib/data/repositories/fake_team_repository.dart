import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';

/// The same five employees `FakeEmployeeRepository` seeds — kept in sync so
/// `setMembers` can resolve an id it wasn't already holding a member for
/// (mirrors the real API re-loading `members` from the employees table).
const _directory = <String, Employee>{
  'e1': Employee(
    id: 'e1',
    employeeCode: 'EMP-001',
    firstName: 'Nadia',
    lastName: 'Haque',
    name: 'Nadia Haque',
    status: EmploymentStatus.active,
  ),
  'e2': Employee(
    id: 'e2',
    employeeCode: 'EMP-002',
    firstName: 'Rahim',
    lastName: 'Uddin',
    name: 'Rahim Uddin',
    status: EmploymentStatus.active,
  ),
  'e3': Employee(
    id: 'e3',
    employeeCode: 'EMP-003',
    firstName: 'Sadia',
    lastName: 'Islam',
    name: 'Sadia Islam',
    status: EmploymentStatus.onLeave,
  ),
  'e4': Employee(
    id: 'e4',
    employeeCode: 'EMP-004',
    firstName: 'Tanvir',
    lastName: 'Hasan',
    name: 'Tanvir Hasan',
    status: EmploymentStatus.probation,
  ),
  'e5': Employee(
    id: 'e5',
    employeeCode: 'EMP-005',
    firstName: 'Farhana',
    lastName: 'Akter',
    name: 'Farhana Akter',
    status: EmploymentStatus.terminated,
  ),
};

class FakeTeamRepository implements TeamRepository {
  FakeTeamRepository();

  final List<Team> _items = [
    const Team(
      id: 't1',
      name: 'Site Visit Squad',
      description: 'Handles buyer site visits',
      leadEmployeeId: 'e1',
      membersCount: 2,
      members: [
        Employee(
          id: 'e1',
          employeeCode: 'EMP-001',
          firstName: 'Nadia',
          lastName: 'Haque',
          name: 'Nadia Haque',
          status: EmploymentStatus.active,
        ),
        Employee(
          id: 'e3',
          employeeCode: 'EMP-003',
          firstName: 'Sadia',
          lastName: 'Islam',
          name: 'Sadia Islam',
          status: EmploymentStatus.onLeave,
        ),
      ],
    ),
  ];

  int _nextId = 2;

  @override
  Future<Result<List<Team>>> teams() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return Result.ok(List.unmodifiable(_items));
  }

  @override
  Future<Result<Team>> team(String id) async {
    final found = _items.where((t) => t.id == id);
    if (found.isEmpty) return const Result.err(NotFoundFailure());
    return Result.ok(found.first);
  }

  @override
  Future<Result<Team>> createTeam(TeamInput input) async {
    final team = Team(
      id: 't${_nextId++}',
      name: input.name,
      description: input.description,
      leadEmployeeId: input.leadEmployeeId,
    );
    _items.add(team);
    return Result.ok(team);
  }

  @override
  Future<Result<Team>> updateTeam(String id, TeamInput input) async {
    final index = _items.indexWhere((t) => t.id == id);
    if (index == -1) return const Result.err(NotFoundFailure());
    final current = _items[index];
    final updated = Team(
      id: id,
      name: input.name,
      description: input.description,
      leadEmployeeId: input.leadEmployeeId,
      membersCount: current.membersCount,
      members: current.members,
    );
    _items[index] = updated;
    return Result.ok(updated);
  }

  @override
  Future<Result<void>> deleteTeam(String id) async {
    _items.removeWhere((t) => t.id == id);
    return const Result.ok(null);
  }

  @override
  Future<Result<Team>> setMembers(String id, List<String> employeeIds) async {
    final index = _items.indexWhere((t) => t.id == id);
    if (index == -1) return const Result.err(NotFoundFailure());
    final current = _items[index];
    final members = [
      for (final id in employeeIds)
        if (_directory[id] != null) _directory[id]!,
    ];
    final updated = Team(
      id: current.id,
      name: current.name,
      description: current.description,
      leadEmployeeId: current.leadEmployeeId,
      membersCount: employeeIds.length,
      members: members,
    );
    _items[index] = updated;
    return Result.ok(updated);
  }
}
