import '../../core/error/result.dart';
import '../entities/designation.dart';

abstract interface class DesignationRepository {
  Future<Result<List<Designation>>> designations();
  Future<Result<Designation>> createDesignation(DesignationInput input);
  Future<Result<Designation>> updateDesignation(
    String id,
    DesignationInput input,
  );
  Future<Result<void>> deleteDesignation(String id);
}
