import '../../core/error/failure.dart';
import '../../core/error/result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/follow_up.dart';
import '../../domain/repositories/crm_repository.dart';
import '../datasources/crm_remote_datasource.dart';
import '../models/crm_mappers.dart';
import 'remote_guard.dart';

class CrmRepositoryImpl implements CrmRepository {
  CrmRepositoryImpl(this._remote);

  final CrmRemoteDataSource _remote;

  @override
  Future<Result<List<Customer>>> customers() {
    return guardRequest(
      () async => (await _remote.customers())
          .map(customerFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<Customer>> customer(String id) {
    return guardRequest(
      () async => customerFromJson(await _remote.customer(id)),
    );
  }

  @override
  Future<Result<List<CustomerActivity>>> history(String id) {
    return guardRequest(
      () async => customerHistoryFromJson(await _remote.history(id)),
    );
  }

  @override
  Future<Result<Customer>> moveStage(String id, PipelineStage stage) async {
    // A customer is a converted lead — the pipeline stage is a lead concept and
    // there is no endpoint to move it. Fail closed; the UI leaves the row as is.
    return const Result.err(
      ForbiddenFailure('Stage changes happen on the lead, not the customer.'),
    );
  }

  @override
  Future<Result<List<FollowUp>>> followUps() {
    return guardRequest(
      () async => (await _remote.followUps())
          .map(followUpFromJson)
          .toList(growable: false),
    );
  }

  @override
  Future<Result<FollowUp>> completeFollowUp(
    String id,
    FollowUpOutcome outcome,
  ) {
    return guardRequest(
      () async => followUpFromJson(
        await _remote.completeFollowUp(
          id,
          followUpOutcomeToApi[outcome] ?? 'Completed',
        ),
      ),
    );
  }
}
