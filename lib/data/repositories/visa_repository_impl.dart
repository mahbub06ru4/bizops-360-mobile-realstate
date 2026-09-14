import '../../core/error/result.dart';
import '../../domain/entities/visa_application.dart';
import '../../domain/repositories/visa_repository.dart';
import '../datasources/visa_remote_datasource.dart';
import '../models/travel_mappers.dart';
import 'remote_guard.dart';

/// HTTP-backed [VisaRepository] against the `industry:travel` visa endpoints.
class VisaRepositoryImpl implements VisaRepository {
  VisaRepositoryImpl(this._remote);

  final VisaRemoteDataSource _remote;

  @override
  Future<Result<List<VisaApplication>>> applications() {
    return guardRequest(
      () async => (await _remote.list())
          .map(visaApplicationFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<VisaApplication>> byId(String id) {
    return guardRequest(
      () async => visaApplicationFromJson(await _remote.byId(id)),
    );
  }

  @override
  Future<Result<VisaApplication>> toggleDoc(String id, String docName) {
    return guardRequest(() async {
      final current = await _remote.byId(id);
      final requirementId = requirementIdByName(current, docName);
      if (requirementId == null) return visaApplicationFromJson(current);

      await _remote.toggleRequirement(
        requirementId,
        collected: !requirementCollected(current, docName),
      );
      return visaApplicationFromJson(await _remote.byId(id));
    });
  }

  @override
  Future<Result<VisaApplication>> moveStage(String id, VisaStage stage) {
    return guardRequest(() async {
      final json = stage == VisaStage.processing
          ? await _remote.processing(id)
          : await _remote.byId(id);
      return visaApplicationFromJson(json);
    });
  }

  @override
  Future<Result<VisaApplication>> submit(String id) {
    return guardRequest(
      () async => visaApplicationFromJson(await _remote.submit(id)),
    );
  }

  @override
  Future<Result<VisaApplication>> decide(String id, {required bool approved}) {
    final decisionOn = DateTime.now().toIso8601String().split('T').first;
    return guardRequest(
      () async => visaApplicationFromJson(
        await _remote.decision(
          id,
          outcome: approved ? 'approved' : 'rejected',
          decisionOn: decisionOn,
        ),
      ),
    );
  }
}
