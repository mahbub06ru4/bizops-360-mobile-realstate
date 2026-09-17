import '../../core/error/result.dart';
import '../entities/team.dart';

abstract interface class TeamRepository {
  Future<Result<List<Team>>> teams();
  Future<Result<Team>> team(String id);
  Future<Result<Team>> createTeam(TeamInput input);
  Future<Result<Team>> updateTeam(String id, TeamInput input);
  Future<Result<void>> deleteTeam(String id);

  /// Replaces the team's member list with [employeeIds].
  Future<Result<Team>> setMembers(String id, List<String> employeeIds);
}
