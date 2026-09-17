import 'package:get/get.dart';

import '../../org_repo_registrations.dart';
import '../controllers/team_members_controller.dart';
import '../controllers/teams_controller.dart';

class TeamsBinding extends Bindings {
  @override
  void dependencies() {
    ensureTeamRepo();
    Get.lazyPut<TeamsController>(() => TeamsController(Get.find()));
  }
}

class TeamMembersBinding extends Bindings {
  @override
  void dependencies() {
    ensureTeamRepo();
    ensureEmployeeRepo();
    final teamId = Get.arguments as String;
    Get.lazyPut<TeamMembersController>(
      () => TeamMembersController(Get.find(), Get.find(), teamId),
    );
  }
}
