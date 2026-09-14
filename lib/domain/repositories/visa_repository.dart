import '../../core/error/result.dart';
import '../entities/visa_application.dart';

abstract interface class VisaRepository {
  Future<Result<List<VisaApplication>>> applications();

  Future<Result<VisaApplication>> byId(String id);

  Future<Result<VisaApplication>> toggleDoc(String id, String docName);

  Future<Result<VisaApplication>> moveStage(String id, VisaStage stage);

  /// Submit the case — only valid once every document is collected.
  Future<Result<VisaApplication>> submit(String id);

  Future<Result<VisaApplication>> decide(String id, {required bool approved});
}
