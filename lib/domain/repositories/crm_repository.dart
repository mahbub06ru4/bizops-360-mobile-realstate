import '../../core/error/result.dart';
import '../entities/customer.dart';
import '../entities/follow_up.dart';

abstract interface class CrmRepository {
  Future<Result<List<Customer>>> customers();

  Future<Result<Customer>> customer(String id);

  Future<Result<List<CustomerActivity>>> history(String id);

  Future<Result<Customer>> moveStage(String id, PipelineStage stage);

  Future<Result<List<FollowUp>>> followUps();

  Future<Result<FollowUp>> completeFollowUp(String id, FollowUpOutcome outcome);
}
