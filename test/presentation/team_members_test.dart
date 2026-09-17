import 'package:bizops360_mobile/data/repositories/fake_employee_repository.dart';
import 'package:bizops360_mobile/data/repositories/fake_team_repository.dart';
import 'package:bizops360_mobile/presentation/organization/teams/controllers/team_members_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'TeamMembersController loads current members and toggles/saves',
    () async {
      final controller = TeamMembersController(
        FakeTeamRepository(),
        FakeEmployeeRepository(),
        't1',
      );
      await controller.load();

      // Seeded fake team `t1` starts with e1 and e3.
      expect(controller.selectedIds, {'e1', 'e3'});
      expect(controller.allEmployees, isNotEmpty);

      // Remove e3, add e2.
      controller.toggle('e3');
      controller.toggle('e2');
      expect(controller.selectedIds, {'e1', 'e2'});

      final error = await controller.saveMembers();
      expect(error, isNull);
      expect(
        controller.team.value.valueOrNull?.members.map((e) => e.id).toSet(),
        {'e1', 'e2'},
      );
    },
  );
}
