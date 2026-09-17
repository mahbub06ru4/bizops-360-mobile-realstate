import '../../core/error/result.dart';
import '../../domain/entities/team.dart';
import '../../domain/repositories/team_repository.dart';
import '../datasources/team_remote_datasource.dart';
import '../models/team_mappers.dart';
import 'remote_guard.dart';

class TeamRepositoryImpl implements TeamRepository {
  TeamRepositoryImpl(this._remote);

  final TeamRemoteDataSource _remote;

  @override
  Future<Result<List<Team>>> teams() {
    return guardRequest(
      () async =>
          (await _remote.teams()).map(teamFromJson).toList(growable: false),
    );
  }

  @override
  Future<Result<Team>> team(String id) {
    return guardRequest(() async => teamFromJson(await _remote.team(id)));
  }

  @override
  Future<Result<Team>> createTeam(TeamInput input) {
    return guardRequest(
      () async => teamFromJson(await _remote.create(teamInputToJson(input))),
    );
  }

  @override
  Future<Result<Team>> updateTeam(String id, TeamInput input) {
    return guardRequest(
      () async =>
          teamFromJson(await _remote.update(id, teamInputToJson(input))),
    );
  }

  @override
  Future<Result<void>> deleteTeam(String id) {
    return guardRequest(() => _remote.delete(id));
  }

  @override
  Future<Result<Team>> setMembers(String id, List<String> employeeIds) {
    return guardRequest(
      () async => teamFromJson(await _remote.setMembers(id, employeeIds)),
    );
  }
}
